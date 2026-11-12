// SPDX-License-Identifier: Apache-2.0
// Unit Testbench for PWM Generator per Section 14.1 of SoC Specification v2.0

`timescale 1ns/1ps

module tb_pwm;

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

    logic [0:0]  pwm_out;
    logic        irq;

    // DUT
    pwm_gen #(.NUM_CH(1), .CWIDTH(16)) dut (
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
        .pwm_out  (pwm_out),
        .irq      (irq)
    );

    // PWM Monitor
    pwm_monitor mon (
        .clk     (aclk),
        .rst_n   (aresetn),
        .pwm_in  (pwm_out[0])
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

    initial begin
        logic [31:0] rdata;
        logic [1:0]  resp;

        aresetn = 1'b0;
        bfm.reset_master();
        repeat (5) @(posedge aclk);
        aresetn = 1'b1;
        repeat (5) @(posedge aclk);

        $display("=== [TEST] tb_pwm START ===");

        // Configure PERIOD = 9 (period of 10 ticks), PRESCALE = 0 (1 tick per clock)
        bfm.write(32'h8000_5004, 32'd9, 4'hF, resp, 0, 0); // PERIOD = 9
        bfm.write(32'h8000_500C, 32'd0, 4'hF, resp, 0, 0); // PRESCALE = 0

        // Test 1: DUTY = 5 (50% duty cycle)
        $display("[Test 1] 50%% duty cycle");
        bfm.write(32'h8000_5008, 32'd5, 4'hF, resp, 0, 0); // DUTY = 5
        bfm.write(32'h8000_5000, 32'h1, 4'hF, resp, 0, 0); // CTRL: EN=1

        repeat (50) @(posedge aclk);
        $display("Measured duty: %0.2f%%", mon.duty_pct);
        if (mon.duty_pct < 45.0 || mon.duty_pct > 55.0) begin
            $display("FAILED: Expected ~50%% duty, got %f", mon.duty_pct);
            test_errors++;
        end

        // Test 2: DUTY = 0 (always low)
        $display("[Test 2] DUTY = 0 (always low)");
        bfm.write(32'h8000_5008, 32'd0, 4'hF, resp, 0, 0);
        repeat (30) @(posedge aclk);
        if (pwm_out[0] !== 1'b0) begin
            $display("FAILED: Expected low for duty=0");
            test_errors++;
        end

        // Test 3: DUTY > PERIOD (always high)
        $display("[Test 3] DUTY > PERIOD (always high)");
        bfm.write(32'h8000_5008, 32'd15, 4'hF, resp, 0, 0);
        repeat (30) @(posedge aclk);
        if (pwm_out[0] !== 1'b1) begin
            $display("FAILED: Expected high for duty > period");
            test_errors++;
        end

        // Test 4: FORCE mode (bit 3)
        $display("[Test 4] FORCE mode");
        bfm.write(32'h8000_5000, 32'b1001, 4'hF, resp, 0, 0); // FORCE=1, POL=0 -> forces 0
        repeat (5) @(posedge aclk);
        if (pwm_out[0] !== 1'b0) begin
            $display("FAILED: FORCE POL=0 failed");
            test_errors++;
        end
        bfm.write(32'h8000_5000, 32'b1011, 4'hF, resp, 0, 0); // FORCE=1, POL=1 -> forces 1
        repeat (5) @(posedge aclk);
        if (pwm_out[0] !== 1'b1) begin
            $display("FAILED: FORCE POL=1 failed");
            test_errors++;
        end

        repeat (5) @(posedge aclk);
        if (test_errors == 0) begin
            $display("=== [TEST] tb_pwm: PASS ===");
        end else begin
            $display("=== [TEST] tb_pwm: FAIL with %0d errors ===", test_errors);
        end

        $finish;
    end

endmodule

