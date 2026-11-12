// SPDX-License-Identifier: Apache-2.0
// System Integration Testbench for VeeR EL2 SoC (tb_soc_top)
// Compliant with Section 14.2 of VeeR EL2 SoC Specification v2.0

`timescale 1ns/1ps

module tb_soc_top;

    logic clk;
    logic rst_n;

    // Clock: 50 MHz (20 ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // Peripherals / Pins
    wire               uart_tx;
    logic              uart_rx;
    wire               i2c_scl;
    wire               i2c_sda;
    wire [0:0]         pwm_out;
    wire [15:0]        gpio;

    // Pull-ups on open-drain I2C bus
    pullup(i2c_scl);
    pullup(i2c_sda);

    // Pull-ups on GPIO lines
    genvar gi;
    generate
        for (gi = 0; gi < 16; gi++) begin : gen_gpio_pull
            pullup(gpio[gi]);
        end
    endgenerate

    // =========================================================================
    // DUT Instantiation
    // =========================================================================
    soc_top #(
        .NUM_CH    (1),
        .NGPIO     (16),
        .IMEM_DEPTH(8192), // 32 KB
        .DMEM_DEPTH(8192)  // 32 KB
    ) dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .uart_tx(uart_tx),
        .uart_rx(uart_rx),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .pwm_out(pwm_out),
        .gpio   (gpio)
    );

    // =========================================================================
    // Verification Models
    // =========================================================================

    // I2C Sensor Model (address 0x48, returns 16-bit signed measurement)
    i2c_sensor_model #(.I2C_ADDR(7'h48)) u_sensor (
        .scl(i2c_scl),
        .sda(i2c_sda)
    );

    // UART Monitor: decodes and displays characters to console
    uart_monitor #(
        .CLK_FREQ_HZ(50_000_000),
        .BAUD_RATE  (115_200)
    ) u_uart_mon (
        .clk    (clk),
        .rst_n  (rst_n),
        .uart_tx(uart_tx)
    );

    // PWM duty cycle monitor
    pwm_monitor u_pwm_mon (
        .clk    (clk),
        .rst_n  (rst_n),
        .pwm_in (pwm_out[0])
    );

    // =========================================================================
    // UART PASS Detector
    // Reads raw bytes off uart_tx (8-N-1 at 115200) and looks for the ASCII
    // sequence P-A-S-S using a 4-state match FSM. Safe for all VCS versions.
    // =========================================================================
    bit uart_pass_seen = 1'b0;

    initial begin : uart_pass_detector
        // Bit period at 115200 baud in ns
        localparam real BIT_NS = 1.0e9 / 115_200.0;

        logic [7:0] rxb;
        // PASS pattern: 0x50='P', 0x41='A', 0x53='S', 0x53='S'
        int         match_state = 0;

        forever begin
            // Detect start bit (falling edge on TX)
            @(negedge uart_tx);
            #(BIT_NS * 1.5); // skip to middle of bit 0

            // Sample 8 data bits, LSB first
            for (int b = 0; b < 8; b++) begin
                rxb[b] = uart_tx;
                if (b < 7) #(BIT_NS);
            end

            // 4-state FSM matching "PASS"
            case (match_state)
                0: if (rxb == 8'h50) match_state = 1; // 'P'
                1: if (rxb == 8'h41) match_state = 2; // 'A'
                   else if (rxb == 8'h50) match_state = 1;
                   else match_state = 0;
                2: if (rxb == 8'h53) match_state = 3; // 'S'
                   else if (rxb == 8'h50) match_state = 1;
                   else match_state = 0;
                3: if (rxb == 8'h53) begin             // 'S' -> PASS!
                       uart_pass_seen = 1'b1;
                   end else if (rxb == 8'h50) match_state = 1;
                   else match_state = 0;
                default: match_state = 0;
            endcase
        end
    end

    // =========================================================================
    // Waveform Dumping for Verdi (FSDB) & DVE (VPD)
    // =========================================================================
    initial begin
        if ($test$plusargs("FSDB") || $test$plusargs("VERDI") || $test$plusargs("DUMP")) begin
            $display("[TB] Dumping Verdi FSDB waveform to soc_top.fsdb ...");
            $fsdbDumpfile("soc_top.fsdb");
            $fsdbDumpvars(0, tb_soc_top);
            $fsdbDumpMDA();
        end
        if ($test$plusargs("VPD")) begin
            $display("[TB] Dumping VPD waveform to soc_top.vpd ...");
            $vcdplusfile("soc_top.vpd");
            $vcdpluson(0, tb_soc_top);
            $vcdplusmemon(0, tb_soc_top);
        end
    end

    // =========================================================================
    // Simulation Control & IMEM Firmware Preload
    // =========================================================================
    bit trace_en = 1'b0;
    initial begin
        if ($test$plusargs("TRACE")) trace_en = 1'b1;
    end

    always @(posedge clk) begin
        if (rst_n && trace_en) begin
            if (dut.u_core.trace_rv_i_valid_ip) begin
                $display("[TRACE] PC=0x%08h INSN=0x%08h", dut.u_core.trace_rv_i_address_ip, dut.u_core.trace_rv_i_insn_ip);
            end
            if (dut.u_core.lsu_axi_awvalid && dut.u_core.lsu_axi_awready) begin
                $display("[LSU AW] Addr=0x%08h", dut.u_core.lsu_axi_awaddr);
            end
            if (dut.u_core.lsu_axi_wvalid && dut.u_core.lsu_axi_wready) begin
                $display("[LSU W] Data=0x%016h Strb=%02h", dut.u_core.lsu_axi_wdata, dut.u_core.lsu_axi_wstrb);
            end
            if (dut.u_core.trace_rv_i_exception_ip) begin
                $display("[EXC] ecause=%0d tval=0x%08h at PC=0x%08h",
                    dut.u_core.trace_rv_i_ecause_ip, dut.u_core.trace_rv_i_tval_ip, dut.u_core.trace_rv_i_address_ip);
            end
        end
    end
    string hex_file   = "../sw/main.hex";
    int    max_cycles = 500_000;

    initial begin
        uart_rx = 1'b1; // Idle high
        rst_n   = 1'b0;

        // Optional override via command line: +HEX_FILE=<path>
        if ($value$plusargs("HEX_FILE=%s", hex_file)) begin
            $display("[TB] Loading custom firmware from: %s", hex_file);
        end

        // Backdoor firmware preload into IMEM before reset
        $display("[TB] Preloading IMEM from %s ...", hex_file);
        $readmemh(hex_file, dut.u_imem.mem);
        $display("[TB] IMEM preload complete.");

        // Assert reset for at least 20 cycles (spec CP-10: min 16)
        repeat (20) @(posedge clk);
        rst_n = 1'b1;
        $display("[TB] Reset deasserted. VeeR EL2 starts at PC=0x00000000.");

        // Watchdog + PASS detector running in parallel
        fork
            // --- Watchdog ---
            begin : WATCHDOG
                repeat (max_cycles) @(posedge clk);
                $display("[TB] *** WATCHDOG TIMEOUT after %0d cycles! ***", max_cycles);
                $display("=== [TEST] tb_soc_top: FAIL ===");
                $finish;
            end

            // --- PASS poller: checks uart_pass_seen every 500 cycles ---
            begin : PASS_POLLER
                forever begin
                    repeat (500) @(posedge clk);
                    if (uart_pass_seen) begin
                        // Allow remaining UART characters to flush to console
                        repeat (40_000) @(posedge clk);
                        $display("[TB] *** Firmware transmitted 'PASS' via UART! ***");
                        $display("=== [TEST] tb_soc_top: PASS ===");
                        disable WATCHDOG;
                        $finish;
                    end
                end
            end
        join_any
        disable PASS_POLLER;
    end

endmodule
