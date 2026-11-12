// SPDX-License-Identifier: Apache-2.0
// Unit Testbench for axi4lite_regif per Section 14.1 of SoC Specification v2.0

`timescale 1ns/1ps

module tb_axi4lite_regif;

    logic        aclk;
    logic        aresetn;

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

    // Register interface signals
    logic [5:0]  reg_waddr;
    logic [31:0] reg_wdata;
    logic        reg_wen;
    logic [5:0]  reg_raddr;
    logic        reg_ren;
    logic [31:0] reg_rdata;
    logic        reg_err;

    // Clock generation: 50 MHz
    initial aclk = 0;
    always #10 aclk = ~aclk;

    // Emulated IP register array (64 registers)
    logic [31:0] ip_regs [0:63];

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            for (int i = 0; i < 64; i++) ip_regs[i] <= 32'h0;
            reg_rdata <= 32'h0;
        end else begin
            if (reg_wen) begin
                ip_regs[reg_waddr] <= reg_wdata;
            end
            if (reg_ren) begin
                reg_rdata <= ip_regs[reg_raddr];
            end
        end
    end

    // Instantiate DUT
    axi4lite_regif #(
        .ADDR_LSB(2),
        .REG_BITS(6)
    ) dut (
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

    // Bind assertions
    axi4lite_assertions #(
        .PORT_NAME("TB_REGIF"),
        .IS_PERIPHERAL(1'b1)
    ) u_assert (
        .aclk   (aclk),
        .aresetn(aresetn),
        .awaddr (s_awaddr),
        .awprot (s_awprot),
        .awvalid(s_awvalid),
        .awready(s_awready),
        .wdata  (s_wdata),
        .wstrb  (s_wstrb),
        .wvalid (s_wvalid),
        .wready (s_wready),
        .bresp  (s_bresp),
        .bvalid (s_bvalid),
        .bready (s_bready),
        .araddr (s_araddr),
        .arprot (s_arprot),
        .arvalid(s_arvalid),
        .arready(s_arready),
        .rdata  (s_rdata),
        .rresp  (s_rresp),
        .rvalid (s_rvalid),
        .rready (s_rready)
    );

    // Master BFM
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

    // Test sequence
    initial begin
        logic [31:0] rdata;
        logic [1:0]  resp;

        reg_err = 1'b0;
        aresetn = 1'b0;
        bfm.reset_master();
        repeat (5) @(posedge aclk);
        aresetn = 1'b1;
        repeat (5) @(posedge aclk);

        $display("=== [TEST] tb_axi4lite_regif START ===");

        // Test 1: Simultaneous AW & W write
        $display("[Test 1] Simultaneous AW+W write");
        bfm.write(32'h0000_0004, 32'hDEAD_BEEF, 4'hF, resp, 0, 0);
        if (resp !== 2'b00 || ip_regs[1] !== 32'hDEAD_BEEF) begin
            $display("FAILED: Test 1 - resp=%b, ip_reg=%h", resp, ip_regs[1]);
            test_errors++;
        end

        // Test 2: Read back
        $display("[Test 2] Basic read");
        bfm.read(32'h0000_0004, rdata, resp, 0);
        if (resp !== 2'b00 || rdata !== 32'hDEAD_BEEF) begin
            $display("FAILED: Test 2 - resp=%b, rdata=%h", resp, rdata);
            test_errors++;
        end

        // Test 3: AW before W
        $display("[Test 3] AW before W");
        bfm.write(32'h0000_0008, 32'hCAFE_BABE, 4'hF, resp, 1, 0);
        if (resp !== 2'b00 || ip_regs[2] !== 32'hCAFE_BABE) begin
            $display("FAILED: Test 3 - resp=%b, ip_reg=%h", resp, ip_regs[2]);
            test_errors++;
        end

        // Test 4: W before AW
        $display("[Test 4] W before AW");
        bfm.write(32'h0000_000C, 32'h1234_5678, 4'hF, resp, 2, 0);
        if (resp !== 2'b00 || ip_regs[3] !== 32'h1234_5678) begin
            $display("FAILED: Test 4 - resp=%b, ip_reg=%h", resp, ip_regs[3]);
            test_errors++;
        end

        // Test 5: Backpressure on B (1, 2, 10 cycles)
        $display("[Test 5] Backpressure on B channel");
        bfm.write(32'h0000_0010, 32'hAAAA_BBBB, 4'hF, resp, 0, 1);
        if (resp !== 2'b00) test_errors++;
        bfm.write(32'h0000_0014, 32'hCCCC_DDDD, 4'hF, resp, 0, 2);
        if (resp !== 2'b00) test_errors++;
        bfm.write(32'h0000_0018, 32'hEEEE_FFFF, 4'hF, resp, 0, 10);
        if (resp !== 2'b00) test_errors++;

        // Test 6: Backpressure on R (1, 2, 10 cycles)
        $display("[Test 6] Backpressure on R channel");
        bfm.read(32'h0000_0010, rdata, resp, 1);
        if (resp !== 2'b00 || rdata !== 32'hAAAA_BBBB) test_errors++;
        bfm.read(32'h0000_0014, rdata, resp, 2);
        if (resp !== 2'b00 || rdata !== 32'hCCCC_DDDD) test_errors++;
        bfm.read(32'h0000_0018, rdata, resp, 10);
        if (resp !== 2'b00 || rdata !== 32'hEEEE_FFFF) test_errors++;

        // Test 7: WSTRB != 4'hF returns SLVERR (2'b10)
        $display("[Test 7] Partial strobe WSTRB != 4'hF returns SLVERR");
        bfm.write(32'h0000_0020, 32'h0000_00AA, 4'h1, resp, 0, 0);
        if (resp !== 2'b10) begin
            $display("FAILED: Test 7 expected SLVERR (2'b10), got %b", resp);
            test_errors++;
        end

        // Test 8: IP reg_err returns SLVERR
        $display("[Test 8] IP signalled reg_err returns SLVERR");
        reg_err = 1'b1;
        bfm.write(32'h0000_0024, 32'h5555_5555, 4'hF, resp, 0, 0);
        if (resp !== 2'b10) begin
            $display("FAILED: Test 8 write expected SLVERR, got %b", resp);
            test_errors++;
        end
        bfm.read(32'h0000_0024, rdata, resp, 0);
        if (resp !== 2'b10) begin
            $display("FAILED: Test 8 read expected SLVERR, got %b", resp);
            test_errors++;
        end
        reg_err = 1'b0;

        // Test 9: Simultaneous Read and Write in flight
        $display("[Test 9] Simultaneous Read and Write");
        fork
            bfm.write(32'h0000_0028, 32'h8888_9999, 4'hF, resp, 0, 0);
            bfm.read(32'h0000_0010, rdata, resp, 0);
        join

        repeat (10) @(posedge aclk);

        if (test_errors == 0) begin
            $display("=== [TEST] tb_axi4lite_regif: PASS ===");
        end else begin
            $display("=== [TEST] tb_axi4lite_regif: FAIL with %0d errors ===", test_errors);
        end

        $finish;
    end

endmodule

