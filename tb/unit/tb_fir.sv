// SPDX-License-Identifier: Apache-2.0
// Unit Testbench for FIR Filter per Section 14.1 of SoC Specification v2.0

`timescale 1ns/1ps

module tb_fir;

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

    logic        irq;

    // DUT
    fir_filter #(
        .NTAPS (16),
        .DWIDTH(16),
        .CWIDTH(16),
        .AWIDTH(40)
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
        .irq      (irq)
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

    // Golden coefficients from sw/gen_coeffs.py
    function automatic int abs_diff(int a, int b);
        int d = a - b;
        return (d < 0) ? -d : d;
    endfunction

    shortint golden_coeffs[0:15] = '{
        -97, -136, -119, 250, 1242, 2815, 4496, 5591,
        5591, 4496, 2815, 1242, 250, -119, -136, -97
    };

    task automatic poll_done();
        logic [31:0] rdata;
        logic [1:0]  resp;
        do begin
            bfm.read(32'h8000_4004, rdata, resp, 0); // STATUS
        end while ((rdata & 32'h2) == 0); // while (!DONE)
    endtask

    initial begin
        logic [31:0] rdata;
        logic [1:0]  resp;
        shortint     result;

        aresetn = 1'b0;
        bfm.reset_master();
        repeat (5) @(posedge aclk);
        aresetn = 1'b1;
        repeat (5) @(posedge aclk);

        $display("=== [TEST] tb_fir START ===");

        // Test 1: Check compiled-in TAPS
        $display("[Test 1] Verify TAPS register");
        bfm.read(32'h8000_401C, rdata, resp, 0); // TAPS
        if (rdata !== 32'd16) begin
            $display("FAILED: Expected TAPS=16, got %d", rdata);
            test_errors++;
        end

        // Test 2: Load coefficients into COEF_DATA
        $display("[Test 2] Loading 16 coefficients with auto-increment");
        bfm.write(32'h8000_4010, 32'h0, 4'hF, resp, 0, 0); // COEF_ADDR = 0
        for (int i = 0; i < 16; i++) begin
            bfm.write(32'h8000_4014, {16'h0, golden_coeffs[i]}, 4'hF, resp, 0, 0);
        end

        // Verify readback of coefficient 5
        bfm.write(32'h8000_4010, 32'd5, 4'hF, resp, 0, 0);
        bfm.read(32'h8000_4014, rdata, resp, 0);
        if ($signed(rdata[15:0]) !== golden_coeffs[5]) begin
            $display("FAILED: Coef[5] expected %d, got %d", golden_coeffs[5], $signed(rdata[15:0]));
            test_errors++;
        end

        // Test 3: Enable filter (CTRL = 1)
        bfm.write(32'h8000_4000, 32'h1, 4'hF, resp, 0, 0); // CTRL.EN = 1

        // Test 4: Impulse Response
        // Feed input = 32767 (representing 1.0 in Q1.15), followed by 15 zeros
        // Outputs should match the coefficients!
        $display("[Test 4] Verifying Impulse Response");
        for (int i = 0; i < 16; i++) begin
            automatic shortint in_val = (i == 0) ? 16'sh7FFF : 16'sh0000;
            bfm.write(32'h8000_4008, {16'h0, in_val}, 4'hF, resp, 0, 0); // DATA_IN
            poll_done();
            bfm.read(32'h8000_400C, rdata, resp, 0); // DATA_OUT
            result = rdata[15:0];
            // Allowed tolerance of +/- 2 counts due to integer truncation
            if (abs_diff(result, golden_coeffs[i]) > 2) begin
                $display("FAILED: Impulse tap %0d expected %d, got %d", i, golden_coeffs[i], result);
                test_errors++;
            end
        end

        // Test 5: FLUSH clears delay line
        $display("[Test 5] Test FLUSH delay line");
        bfm.write(32'h8000_4000, 32'h2, 4'hF, resp, 0, 0); // CTRL.FLUSH = 1
        repeat (2) @(posedge aclk);
        // Next zero sample must produce exactly 0
        bfm.write(32'h8000_4000, 32'h1, 4'hF, resp, 0, 0); // CTRL.EN = 1
        bfm.write(32'h8000_4008, 32'h0, 4'hF, resp, 0, 0); // DATA_IN = 0
        poll_done();
        bfm.read(32'h8000_400C, rdata, resp, 0);
        if (rdata[15:0] !== 16'h0) begin
            $display("FAILED: Flush expected 0, got %d", rdata[15:0]);
            test_errors++;
        end

        // Test 6: Write while BUSY returns SLVERR
        $display("[Test 6] Write while BUSY returns SLVERR");
        // Start computation
        bfm.write(32'h8000_4008, 32'h1000, 4'hF, resp, 0, 0);
        // Immediately try another write while still running MAC
        bfm.write(32'h8000_4008, 32'h2000, 4'hF, resp, 0, 0);
        if (resp !== 2'b10) begin
            $display("FAILED: Expected SLVERR (2'b10) on write while BUSY, got %b", resp);
            test_errors++;
        end

        poll_done();
        bfm.read(32'h8000_400C, rdata, resp, 0);

        repeat (5) @(posedge aclk);
        if (test_errors == 0) begin
            $display("=== [TEST] tb_fir: PASS ===");
        end else begin
            $display("=== [TEST] tb_fir: FAIL with %0d errors ===", test_errors);
        end

        $finish;
    end

endmodule

