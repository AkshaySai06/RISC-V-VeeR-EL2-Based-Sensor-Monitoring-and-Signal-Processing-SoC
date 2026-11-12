// SPDX-License-Identifier: Apache-2.0
// Unit Testbench for I2C Controller per Section 14.1 of SoC Specification v2.0

`timescale 1ns/1ps

module tb_i2c;

    logic aclk;
    logic aresetn;

    initial aclk = 0;
    always #10 aclk = ~aclk;

    // AXI4-Lite signals
    logic [31:0] s_awaddr;
    logic [2:0]  s_awprot;
    logic        s_awvalid;
    logic        s_awready;

    logic [31:0] s_wdata;
    logic [3:0]  s_wstrb;
    logic        s_wvalid;
    logic        s_wready;

    logic [1:0]  s_bresp;
    logic        s_bvalid;
    logic        s_bready;

    logic [31:0] s_araddr;
    logic [2:0]  s_arprot;
    logic        s_arvalid;
    logic        s_arready;

    logic [31:0] s_rdata;
    logic [1:0]  s_rresp;
    logic        s_rvalid;
    logic        s_rready;

    // Open drain lines
    wire scl;
    wire sda;

    pullup(scl);
    pullup(sda);

    logic scl_o, scl_oe;
    logic sda_o, sda_oe;
    logic irq;

    assign scl = scl_oe ? 1'b0 : 1'bz;
    assign sda = sda_oe ? 1'b0 : 1'bz;

    // DUT
    i2c_ctrl dut (
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
        .scl_i    (scl),
        .scl_o    (scl_o),
        .scl_oe   (scl_oe),
        .sda_i    (sda),
        .sda_o    (sda_o),
        .sda_oe   (sda_oe),
        .irq      (irq)
    );

    // Sensor Model
    i2c_sensor_model #(.I2C_ADDR(7'h48)) u_sensor (
        .scl(scl),
        .sda(sda)
    );

    // BFM
    axi4lite_master_bfm bfm (
        .aclk     (aclk),
        .aresetn  (aresetn),
        .m_awaddr (s_awaddr),
        .m_awprot (s_awprot),
        .m_awvalid(s_awvalid),
        .m_awready(s_awready),
        .m_wdata  (s_wdata),
        .m_wstrb  (s_wstrb),
        .m_wvalid (s_wvalid),
        .m_wready (s_wready),
        .m_bresp  (s_bresp),
        .m_bvalid (s_bvalid),
        .m_bready (s_bready),
        .m_araddr (s_araddr),
        .m_arprot (s_arprot),
        .m_arvalid(s_arvalid),
        .m_arready(s_arready),
        .m_rdata  (s_rdata),
        .m_rresp  (s_rresp),
        .m_rvalid (s_rvalid),
        .m_rready (s_rready)
    );

    int test_errors = 0;

    task automatic poll_tip();
        logic [31:0] rdata;
        logic [1:0]  resp;
        do begin
            repeat (2) @(posedge aclk);
            bfm.read(32'h8000_3010, rdata, resp, 0); // STAT
        end while ((rdata & 32'h2) != 0); // while TIP==1
    endtask

    initial begin
        logic [31:0] rdata;
        logic [1:0]  resp;
        logic [7:0]  msb, lsb;

        aresetn = 1'b0;
        bfm.reset_master();
        repeat (5) @(posedge aclk);
        aresetn = 1'b1;
        repeat (5) @(posedge aclk);

        $display("=== [TEST] tb_i2c START ===");

        // Configure fast prescaler for simulation (PRER = 4)
        bfm.write(32'h8000_3000, 32'd4, 4'hF, resp, 0, 0); // PRER_LO
        bfm.write(32'h8000_3004, 32'd0, 4'hF, resp, 0, 0); // PRER_HI
        bfm.write(32'h8000_3008, 32'h80, 4'hF, resp, 0, 0); // CTRL: EN=1

        // Execute 2-byte read sequence per Section 8.1.6:
        // 1. Write Slave Addr 0x48 (Write mode): (0x48<<1) | 0 = 0x90
        $display("[Test 1] 2-byte sensor read sequence");
        bfm.write(32'h8000_300C, 32'h90, 4'hF, resp, 0, 0); // TXR <= 0x90
        bfm.write(32'h8000_3010, 32'h90, 4'hF, resp, 0, 0); // CMD <= STA | WR (0x80 | 0x10 = 0x90)
        poll_tip();

        // 2. Write Register Address 0x00
        bfm.write(32'h8000_300C, 32'h00, 4'hF, resp, 0, 0); // TXR <= 0x00
        bfm.write(32'h8000_3010, 32'h10, 4'hF, resp, 0, 0); // CMD <= WR (0x10)
        poll_tip();

        // 3. Repeated START with Slave Addr 0x48 (Read mode): (0x48<<1) | 1 = 0x91
        bfm.write(32'h8000_300C, 32'h91, 4'hF, resp, 0, 0); // TXR <= 0x91
        bfm.write(32'h8000_3010, 32'h90, 4'hF, resp, 0, 0); // CMD <= STA | WR (0x90)
        poll_tip();

        // 4. Read MSB (with Master ACK: ACK=0 -> RD = 0x20)
        bfm.write(32'h8000_3010, 32'h20, 4'hF, resp, 0, 0); // CMD <= RD (ACK=0)
        poll_tip();
        bfm.read(32'h8000_300C, rdata, resp, 0); // Read RXR
        msb = rdata[7:0];

        // 5. Read LSB (with STOP and NACK: RD | STO | ACK = 0x20 | 0x40 | 0x08 = 0x68)
        bfm.write(32'h8000_3010, 32'h68, 4'hF, resp, 0, 0); // CMD <= RD | STO | ACK=1
        poll_tip();
        bfm.read(32'h8000_300C, rdata, resp, 0); // Read RXR
        lsb = rdata[7:0];

        $display("Sensor read result: 0x%02X%02X (Expected: 0x1234)", msb, lsb);
        if ({msb, lsb} !== 16'h1234) begin
            $display("FAILED: Expected 0x1234, got 0x%02X%02X", msb, lsb);
            test_errors++;
        end

        repeat (5) @(posedge aclk);
        if (test_errors == 0) begin
            $display("=== [TEST] tb_i2c: PASS ===");
        end else begin
            $display("=== [TEST] tb_i2c: FAIL with %0d errors ===", test_errors);
        end

        $finish;
    end

endmodule

