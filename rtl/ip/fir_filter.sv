// SPDX-License-Identifier: Apache-2.0
// 16-Tap Direct-Form FIR Filter (fir_filter)
// Compliant with Section 8.2 of VeeR EL2 SoC Specification v2.0

`timescale 1ns/1ps

module fir_filter #(
    parameter int NTAPS  = 16, // Number of taps (power of two)
    parameter int DWIDTH = 16, // Sample width, signed
    parameter int CWIDTH = 16, // Coefficient width, signed Q1.15
    parameter int AWIDTH = 40  // Accumulator width
)(
    input  logic                 aclk,
    input  logic                 aresetn,

    // AXI4-Lite Slave Port
    input  logic [31:0]          s_awaddr,
    input  logic [2:0]           s_awprot,
    input  logic                 s_awvalid,
    output logic                 s_awready,

    input  logic [31:0]          s_wdata,
    input  logic [3:0]           s_wstrb,
    input  logic                 s_wvalid,
    output logic                 s_wready,

    output logic [1:0]           s_bresp,
    output logic                 s_bvalid,
    input  logic                 s_bready,

    input  logic [31:0]          s_araddr,
    input  logic [2:0]           s_arprot,
    input  logic                 s_arvalid,
    output logic                 s_arready,

    output logic [31:0]          s_rdata,
    output logic [1:0]           s_rresp,
    output logic                 s_rvalid,
    input  logic                 s_rready,

    // Interrupt output
    output logic                 irq
);

    localparam int TAP_BITS = $clog2(NTAPS);

    // Register interface signals from shim
    logic [5:0]  reg_waddr;
    logic [31:0] reg_wdata;
    logic        reg_wen;
    logic [5:0]  reg_raddr;
    logic        reg_ren;
    logic [31:0] reg_rdata;
    logic        reg_err;

    // Instantiate Reusable Slave Shim
    axi4lite_regif #(
        .ADDR_LSB(2),
        .REG_BITS(6)
    ) u_regif (
        .aclk     (aclk),
        .aresetn  (aresetn),
        .s_awaddr (s_awaddr),
        .s_awprot (s_awprot),
        .s_awvalid(s_awvalid),
        .s_awready(s_awready),
        .s_wdata  (s_wdata),
        .s_wstrb  (s_wstrb),
        .s_wvalid (s_wvalid),
        .s_wready (s_wready),
        .s_bresp  (s_bresp),
        .s_bvalid (s_bvalid),
        .s_bready (s_bready),
        .s_araddr (s_araddr),
        .s_arprot (s_arprot),
        .s_arvalid(s_arvalid),
        .s_arready(s_arready),
        .s_rdata  (s_rdata),
        .s_rresp  (s_rresp),
        .s_rvalid (s_rvalid),
        .s_rready (s_rready),
        .reg_waddr(reg_waddr),
        .reg_wdata(reg_wdata),
        .reg_wen  (reg_wen),
        .reg_raddr(reg_raddr),
        .reg_ren  (reg_ren),
        .reg_rdata(reg_rdata),
        .reg_err  (reg_err)
    );

    // =========================================================================
    // Registers & Storage
    // =========================================================================
    // 0x00: CTRL: [0] EN, [1] FLUSH (self-clearing), [2] IRQ_EN
    logic ctrl_en;
    logic ctrl_irq_en;

    // 0x04: STATUS: [0] IDLE, [1] DONE, [2] BUSY, [3] SAT
    logic status_done;
    logic status_sat;

    // 0x0C: DATA_OUT: [15:0] signed result sign-extended
    logic signed [DWIDTH-1:0] data_out_q;

    // 0x10: COEF_ADDR: [3:0]
    logic [TAP_BITS-1:0] coef_addr_q;

    // 0x18: SHIFT: [5:0], default 15
    logic [5:0] shift_q;

    // Coefficient Memory & Delay Line
    logic signed [CWIDTH-1:0] coef_mem [0:NTAPS-1];
    logic signed [DWIDTH-1:0] delay_line [0:NTAPS-1];

    // FSM States
    typedef enum logic [1:0] {
        S_IDLE,
        S_MAC,
        S_ROUND
    } state_t;

    state_t state;
    logic [TAP_BITS:0] tap_k;
    logic signed [AWIDTH-1:0] acc;

    wire status_idle = (state == S_IDLE);
    wire status_busy = (state == S_MAC || state == S_ROUND);

    // Interrupt output: level-sensitive, holds until DONE is cleared
    assign irq = status_done && ctrl_irq_en;

    // =========================================================================
    // Multiplier & Datapath
    // =========================================================================
    logic signed [DWIDTH-1:0] mult_sample;
    logic signed [CWIDTH-1:0] mult_coef;
    logic signed [31:0]       mult_prod;

    assign mult_sample = delay_line[tap_k[TAP_BITS-1:0]];
    assign mult_coef   = coef_mem[tap_k[TAP_BITS-1:0]];
    assign mult_prod   = mult_sample * mult_coef;

    // =========================================================================
    // FSM & Computation
    // =========================================================================
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            state       <= S_IDLE;
            status_done <= 1'b0;
            status_sat  <= 1'b0;
            data_out_q  <= '0;
            acc         <= '0;
            tap_k       <= '0;
            for (int i = 0; i < NTAPS; i++) delay_line[i] <= '0;
        end else begin
            // Clear DONE on read of DATA_OUT (reg_raddr == 3)
            if (reg_ren && (reg_raddr == 6'd3)) begin
                status_done <= 1'b0;
            end

            // Flush delay line
            if (reg_wen && (reg_waddr == 6'd0) && reg_wdata[1]) begin
                for (int i = 0; i < NTAPS; i++) delay_line[i] <= '0;
            end

            // Clear sticky SAT flag by writing 1 to STATUS[3]
            if (reg_wen && (reg_waddr == 6'd1) && reg_wdata[3]) begin
                status_sat <= 1'b0;
            end

            case (state)
                S_IDLE: begin
                    // Write to DATA_IN (reg_waddr == 2) when enabled starts computation
                    if (reg_wen && (reg_waddr == 6'd2) && ctrl_en) begin
                        // Shift delay line: new sample at index 0, oldest pushed out
                        for (int i = NTAPS-1; i > 0; i--) begin
                            delay_line[i] <= delay_line[i-1];
                        end
                        delay_line[0] <= reg_wdata[DWIDTH-1:0];

                        acc   <= '0;
                        tap_k <= '0;
                        state <= S_MAC;
                    end
                end

                S_MAC: begin
                    acc   <= acc + mult_prod;
                    tap_k <= tap_k + 1;
                    if (tap_k == NTAPS - 1) begin
                        state <= S_ROUND;
                    end
                end

                S_ROUND: begin
                    // Arithmetic right shift by SHIFT
                    logic signed [AWIDTH-1:0] shifted_acc;
                    shifted_acc = acc >>> shift_q;

                    // Saturate to 16-bit signed range [-32768, +32767]
                    if (shifted_acc > 40'sd32767) begin
                        data_out_q <= 16'sh7FFF;
                        status_sat <= 1'b1;
                    end else if (shifted_acc < -40'sd32768) begin
                        data_out_q <= -16'sh8000;
                        status_sat <= 1'b1;
                    end else begin
                        data_out_q <= shifted_acc[DWIDTH-1:0];
                    end

                    status_done <= 1'b1;
                    state       <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    // =========================================================================
    // Register Read/Write Accesses
    // =========================================================================
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            ctrl_en     <= 1'b0;
            ctrl_irq_en <= 1'b0;
            coef_addr_q <= '0;
            shift_q     <= 6'd15;
            for (int i = 0; i < NTAPS; i++) coef_mem[i] <= '0;
        end else begin
            if (reg_wen) begin
                case (reg_waddr)
                    6'd0: begin // CTRL (0x00)
                        ctrl_en     <= reg_wdata[0];
                        ctrl_irq_en <= reg_wdata[2];
                    end

                    6'd4: begin // COEF_ADDR (0x10)
                        coef_addr_q <= reg_wdata[TAP_BITS-1:0];
                    end

                    6'd5: begin // COEF_DATA (0x14)
                        coef_mem[coef_addr_q] <= reg_wdata[CWIDTH-1:0];
                        coef_addr_q           <= coef_addr_q + 1; // Auto-increment!
                    end

                    6'd6: begin // SHIFT (0x18)
                        shift_q <= reg_wdata[5:0];
                    end

                    default: ;
                endcase
            end
        end
    end

    // Error detection: Write to DATA_IN (reg_waddr == 2) while BUSY generates SLVERR
    always_comb begin
        reg_err = 1'b0;
        if (reg_wen && (reg_waddr == 6'd2) && status_busy) begin
            reg_err = 1'b1;
        end
    end

    // Read mux (valid 1 cycle after reg_ren)
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            reg_rdata <= 32'h0;
        end else if (reg_ren) begin
            case (reg_raddr)
                6'd0: reg_rdata <= {29'b0, ctrl_irq_en, 1'b0, ctrl_en};
                6'd1: reg_rdata <= {28'b0, status_sat, status_busy, status_done, status_idle};
                6'd3: reg_rdata <= {{16{data_out_q[15]}}, data_out_q}; // Sign extended
                6'd4: reg_rdata <= {28'b0, coef_addr_q};
                6'd5: reg_rdata <= {{16{coef_mem[coef_addr_q][15]}}, coef_mem[coef_addr_q]};
                6'd6: reg_rdata <= {26'b0, shift_q};
                6'd7: reg_rdata <= 32'd16; // TAPS
                default: reg_rdata <= 32'h0;
            endcase
        end
    end

endmodule

