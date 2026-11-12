// SPDX-License-Identifier: Apache-2.0
// Double-Buffered PWM Generator (pwm_gen)
// Compliant with Section 8.3 of VeeR EL2 SoC Specification v2.0

`timescale 1ns/1ps

module pwm_gen #(
    parameter int NUM_CH = 1,
    parameter int CWIDTH = 16
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

    // PWM Output & Interrupt
    output logic [NUM_CH-1:0]    pwm_out,
    output logic                 irq
);

    // Register interface signals from shim
    logic [5:0]  reg_waddr;
    logic [31:0] reg_wdata;
    logic        reg_wen;
    logic [5:0]  reg_raddr;
    logic        reg_ren;
    logic [31:0] reg_rdata;
    logic        reg_err;

    assign reg_err = 1'b0;

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
    // Registers (Channel 0)
    // =========================================================================
    // Control: [0] EN, [1] POL, [2] IRQ_EN, [3] FORCE
    logic ctrl_en;
    logic ctrl_pol;
    logic ctrl_irq_en;
    logic ctrl_force;

    // Shadow Registers
    logic [CWIDTH-1:0] period_shadow;
    logic [CWIDTH-1:0] duty_shadow;
    logic [CWIDTH-1:0] prescale_shadow;

    // Active Registers (loaded at wrap)
    logic [CWIDTH-1:0] period_active;
    logic [CWIDTH-1:0] duty_active;
    logic [CWIDTH-1:0] prescale_active;

    // Counters
    logic [CWIDTH-1:0] count;
    logic [CWIDTH-1:0] pre_cnt;

    // Status: [0] WRAP
    logic status_wrap;

    assign irq = status_wrap && ctrl_irq_en;

    // =========================================================================
    // PWM Logic & Double-Buffering
    // =========================================================================
    wire tick = (pre_cnt == prescale_active);
    wire wrap = (count == period_active) && tick;
    wire pwm_raw = (count < duty_active);

    assign pwm_out[0] = ctrl_force ? ctrl_pol : (ctrl_en ? (pwm_raw ^ ctrl_pol) : 1'b0);

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            ctrl_en         <= 1'b0;
            ctrl_pol        <= 1'b0;
            ctrl_irq_en     <= 1'b0;
            ctrl_force      <= 1'b0;
            period_shadow   <= {CWIDTH{1'b1}};
            duty_shadow     <= '0;
            prescale_shadow <= '0;
            period_active   <= {CWIDTH{1'b1}};
            duty_active     <= '0;
            prescale_active <= '0;
            count           <= '0;
            pre_cnt         <= '0;
            status_wrap     <= 1'b0;
        end else begin
            // Register writes
            if (reg_wen) begin
                case (reg_waddr)
                    6'd0: begin // CTRL (0x00)
                        ctrl_en     <= reg_wdata[0];
                        ctrl_pol    <= reg_wdata[1];
                        ctrl_irq_en <= reg_wdata[2];
                        ctrl_force  <= reg_wdata[3];
                    end
                    6'd1: period_shadow   <= reg_wdata[CWIDTH-1:0]; // 0x04
                    6'd2: duty_shadow     <= reg_wdata[CWIDTH-1:0]; // 0x08
                    6'd3: prescale_shadow <= reg_wdata[CWIDTH-1:0]; // 0x0C
                    6'd5: begin // STATUS (0x14, W1C)
                        if (reg_wdata[0]) status_wrap <= 1'b0;
                    end
                    default: ;
                endcase
            end

            // Counter & Wrap logic
            if (ctrl_en) begin
                if (tick) begin
                    pre_cnt <= '0;
                    if (count == period_active) begin
                        count           <= '0;
                        status_wrap     <= 1'b1;
                        // Transfer shadow registers to active registers on wrap
                        period_active   <= period_shadow;
                        duty_active     <= duty_shadow;
                        prescale_active <= prescale_shadow;
                    end else begin
                        count <= count + 1;
                    end
                end else begin
                    pre_cnt <= pre_cnt + 1;
                end
            end else begin
                count           <= '0;
                pre_cnt         <= '0;
                period_active   <= period_shadow;
                duty_active     <= duty_shadow;
                prescale_active <= prescale_shadow;
            end
        end
    end

    // Register Read mux
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            reg_rdata <= 32'h0;
        end else if (reg_ren) begin
            case (reg_raddr)
                6'd0: reg_rdata <= {28'b0, ctrl_force, ctrl_irq_en, ctrl_pol, ctrl_en};
                6'd1: reg_rdata <= {16'b0, period_shadow};
                6'd2: reg_rdata <= {16'b0, duty_shadow};
                6'd3: reg_rdata <= {16'b0, prescale_shadow};
                6'd4: reg_rdata <= {16'b0, count};
                6'd5: reg_rdata <= {31'b0, status_wrap};
                default: reg_rdata <= 32'h0;
            endcase
        end
    end

endmodule

