// SPDX-License-Identifier: Apache-2.0
// Standard-Mode Master-Only I2C Controller (i2c_ctrl)
// Compliant with Section 8.1 of VeeR EL2 SoC Specification v2.0 (OpenCores Register Model)

`timescale 1ns/1ps

module i2c_ctrl (
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

    // Open-Drain Modelling Interface
    input  logic                 scl_i,
    output logic                 scl_o,
    output logic                 scl_oe,
    input  logic                 sda_i,
    output logic                 sda_o,
    output logic                 sda_oe,

    output logic                 irq
);

    // Open-drain outputs always drive 0 when enabled
    assign scl_o = 1'b0;
    assign sda_o = 1'b0;

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

    // Registers
    logic [15:0] prer;
    logic        ctrl_en;
    logic        ctrl_ien;
    logic [7:0]  txr;
    logic [7:0]  rxr;

    // Status bits
    logic        stat_rxack;
    logic        stat_busy;
    logic        stat_al;
    logic        stat_tip;
    logic        stat_if;

    assign irq = stat_if && ctrl_ien;

    // Command bits (latched when CMD is written)
    logic cmd_sta, cmd_sto, cmd_rd, cmd_wr, cmd_ack;

    // Clock prescaler: 5 * SCL_FREQ per quarter-cycle tick
    logic [15:0] clk_cnt;
    logic        q_tick; // Quarter-cycle tick

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            clk_cnt <= '0;
            q_tick  <= 1'b0;
        end else if (ctrl_en) begin
            if (clk_cnt >= prer) begin
                clk_cnt <= '0;
                q_tick  <= 1'b1;
            end else begin
                clk_cnt <= clk_cnt + 1;
                q_tick  <= 1'b0;
            end
        end else begin
            clk_cnt <= '0;
            q_tick  <= 1'b0;
        end
    end

    // =========================================================================
    // I2C Master FSM
    // =========================================================================
    typedef enum logic [3:0] {
        M_IDLE,
        M_START_A, M_START_B, M_START_C, M_START_D,
        M_WRITE_BIT,
        M_READ_BIT,
        M_ACK_WR,
        M_ACK_RD,
        M_STOP_A, M_STOP_B, M_STOP_C,
        M_DONE
    } i2c_state_t;

    i2c_state_t state;
    logic [1:0] phase;
    logic [3:0] bit_cnt;
    logic [7:0] shift_reg;

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            state       <= M_IDLE;
            phase       <= 2'b00;
            bit_cnt     <= 4'd0;
            shift_reg   <= 8'h00;
            rxr         <= 8'h00;
            scl_oe      <= 1'b0; // High-Z (pulled up)
            sda_oe      <= 1'b0;
            stat_tip    <= 1'b0;
            stat_busy   <= 1'b0;
            stat_if     <= 1'b0;
            stat_rxack  <= 1'b0;
            stat_al     <= 1'b0;
        end else begin
            // Clear interrupt flag on CMD.IACK write
            if (reg_wen && (reg_waddr == 6'd4) && reg_wdata[0]) begin
                stat_if <= 1'b0;
            end

            // Start new transfer on CMD write
            if (reg_wen && (reg_waddr == 6'd4) && (state == M_IDLE) && ctrl_en) begin
                cmd_sta    <= reg_wdata[7];
                cmd_sto    <= reg_wdata[6];
                cmd_rd     <= reg_wdata[5];
                cmd_wr     <= reg_wdata[4];
                cmd_ack    <= reg_wdata[3];
                stat_tip   <= 1'b1;
                shift_reg  <= txr;
                bit_cnt    <= 4'd7;
                phase      <= 2'b00;

                if (reg_wdata[7]) begin // START
                    state     <= M_START_A;
                    stat_busy <= 1'b1;
                end else if (reg_wdata[4]) begin // WRITE
                    state <= M_WRITE_BIT;
                end else if (reg_wdata[5]) begin // READ
                    state <= M_READ_BIT;
                end else if (reg_wdata[6]) begin // STOP
                    state <= M_STOP_A;
                end
            end

            // FSM advances on quarter-cycle tick
            if (q_tick && stat_tip) begin
                phase <= phase + 1;

                case (state)
                    // START Generation: SDA drops while SCL is high
                    M_START_A: begin
                        sda_oe <= 1'b0; // SDA = 1
                        scl_oe <= 1'b0; // SCL = 1
                        if (phase == 2'b11) state <= M_START_B;
                    end
                    M_START_B: begin
                        sda_oe <= 1'b1; // SDA = 0
                        scl_oe <= 1'b0; // SCL = 1
                        if (phase == 2'b11) state <= M_START_C;
                    end
                    M_START_C: begin
                        sda_oe <= 1'b1; // SDA = 0
                        scl_oe <= 1'b1; // SCL = 0
                        if (phase == 2'b11) begin
                            if (cmd_wr) state <= M_WRITE_BIT;
                            else if (cmd_rd) state <= M_READ_BIT;
                            else state <= M_DONE;
                        end
                    end

                    // Write 8 Data Bits
                    M_WRITE_BIT: begin
                        case (phase)
                            2'b00: begin
                                scl_oe <= 1'b1; // SCL low
                                sda_oe <= ~shift_reg[bit_cnt]; // Set SDA bit
                            end
                            2'b01: scl_oe <= 1'b0; // SCL high
                            2'b10: scl_oe <= 1'b0; // Hold SCL high
                            2'b11: begin
                                scl_oe <= 1'b1; // SCL low
                                if (bit_cnt == 0) begin
                                    state <= M_ACK_WR;
                                end else begin
                                    bit_cnt <= bit_cnt - 1;
                                end
                            end
                        endcase
                    end

                    // Read Slave ACK/NACK
                    M_ACK_WR: begin
                        case (phase)
                            2'b00: begin
                                scl_oe <= 1'b1;
                                sda_oe <= 1'b0; // Release SDA so slave can ACK
                            end
                            2'b01: begin
                                scl_oe     <= 1'b0;
                                stat_rxack <= sda_i; // Sample ACK (0 = ACK, 1 = NACK)
                            end
                            2'b10: scl_oe <= 1'b0;
                            2'b11: begin
                                scl_oe <= 1'b1;
                                if (cmd_sto) state <= M_STOP_A;
                                else state <= M_DONE;
                            end
                        endcase
                    end

                    // Read 8 Data Bits
                    M_READ_BIT: begin
                        case (phase)
                            2'b00: begin
                                scl_oe <= 1'b1;
                                sda_oe <= 1'b0; // Release SDA
                            end
                            2'b01: begin
                                scl_oe <= 1'b0;
                                shift_reg[bit_cnt] <= sda_i; // Sample SDA
                            end
                            2'b10: scl_oe <= 1'b0;
                            2'b11: begin
                                scl_oe <= 1'b1;
                                if (bit_cnt == 0) begin
                                    rxr   <= {shift_reg[7:1], sda_i};
                                    state <= M_ACK_RD;
                                end else begin
                                    bit_cnt <= bit_cnt - 1;
                                end
                            end
                        endcase
                    end

                    // Send Master ACK/NACK
                    M_ACK_RD: begin
                        case (phase)
                            2'b00: begin
                                scl_oe <= 1'b1;
                                sda_oe <= ~cmd_ack; // 0 = send ACK (pull low), 1 = send NACK
                            end
                            2'b01: scl_oe <= 1'b0;
                            2'b10: scl_oe <= 1'b0;
                            2'b11: begin
                                scl_oe <= 1'b1;
                                sda_oe <= 1'b0;
                                if (cmd_sto) state <= M_STOP_A;
                                else state <= M_DONE;
                            end
                        endcase
                    end

                    // STOP Generation: SDA rises while SCL is high
                    M_STOP_A: begin
                        sda_oe <= 1'b1; // SDA = 0
                        scl_oe <= 1'b1; // SCL = 0
                        if (phase == 2'b11) state <= M_STOP_B;
                    end
                    M_STOP_B: begin
                        sda_oe <= 1'b1; // SDA = 0
                        scl_oe <= 1'b0; // SCL = 1
                        if (phase == 2'b11) state <= M_STOP_C;
                    end
                    M_STOP_C: begin
                        sda_oe    <= 1'b0; // SDA = 1 (rising edge with SCL=1 -> STOP!)
                        scl_oe    <= 1'b0; // SCL = 1
                        stat_busy <= 1'b0;
                        if (phase == 2'b11) state <= M_DONE;
                    end

                    M_DONE: begin
                        stat_tip <= 1'b0;
                        stat_if  <= 1'b1;
                        state    <= M_IDLE;
                    end
                endcase
            end
        end
    end

    // =========================================================================
    // Control & Status Register Writes & Reads
    // =========================================================================
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            prer     <= 16'h00FF;
            ctrl_en  <= 1'b0;
            ctrl_ien <= 1'b0;
            txr      <= 8'h00;
        end else if (reg_wen) begin
            case (reg_waddr)
                6'd0: prer[7:0]  <= reg_wdata[7:0];  // 0x00: PRER_LO
                6'd1: prer[15:8] <= reg_wdata[7:0];  // 0x04: PRER_HI
                6'd2: begin // 0x08: CTRL
                    ctrl_en  <= reg_wdata[7];
                    ctrl_ien <= reg_wdata[6];
                end
                6'd3: txr <= reg_wdata[7:0];         // 0x0C: TXR
                default: ;
            endcase
        end
    end

    // Read mux
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            reg_rdata <= 32'h0;
        end else if (reg_ren) begin
            case (reg_raddr)
                6'd0: reg_rdata <= {24'b0, prer[7:0]};
                6'd1: reg_rdata <= {24'b0, prer[15:8]};
                6'd2: reg_rdata <= {24'b0, ctrl_en, ctrl_ien, 6'b0};
                6'd3: reg_rdata <= {24'b0, rxr}; // RXR
                6'd4: reg_rdata <= {24'b0, stat_rxack, stat_busy, stat_al, 3'b0, stat_tip, stat_if}; // STAT
                default: reg_rdata <= 32'h0;
            endcase
        end
    end

endmodule

