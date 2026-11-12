// SPDX-License-Identifier: Apache-2.0
// SoC-Level UVM Top-Level Testbench
// Instantiates the actual soc_top RTL as soc_dut, creates all six SoC-level
// SystemVerilog interfaces and VIP interfaces, connects them to the DUT, and
// launches the UVM test via run_test().
//
// Scope: Steps 1-5 — SoC environment construction and VIP integration check.

`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

// Import all six VIP packages
import uart_vip_pkg::*;
import gpio_vip_pkg::*;
import i2c_vip_pkg::*;
import timer_vip_pkg::*;
import fir_vip_pkg::*;
import pwm_vip_pkg::*;

// Core VeeR EL2 package (required by soc_top)
import el2_pkg::*;

// Include VIP interface definitions (matching VIP drivers/monitors)
`include "soc_vip_interfaces.sv"

// Include SoC UVM environment components
`include "soc_config.sv"
`include "soc_virtual_sequencer.sv"
`include "soc_virtual_sequence.sv"
`include "soc_env.sv"
`include "soc_test.sv"
`include "uart_connectivity_test.sv"
`include "gpio_test.sv"
`include "timer_test.sv"
`include "i2c_test.sv"

module tb_soc_uvm_top;

    // =========================================================================
    // Clock & Reset Generation
    // 50 MHz clock: 20 ns period (10 ns high, 10 ns low)
    // Active-low reset: asserted for 20 cycles, then synchronously released
    // =========================================================================
    logic clk;
    logic rst_n;

    initial clk = 1'b0;
    always #10 clk = ~clk;   // 50 MHz

    initial begin
        rst_n = 1'b0;
        repeat (20) @(posedge clk);
        @(posedge clk);
        rst_n = 1'b1;
        `uvm_info("TB", "Reset deasserted. soc_dut running.", UVM_LOW)
    end

    // =========================================================================
    // Top-Level SoC Signal Declarations
    // =========================================================================
    wire         uart_tx;
    wire         uart_rx;
    wire         i2c_scl;
    wire         i2c_sda;
    wire [0:0]   pwm_out;
    wire [15:0]  gpio;

    // Open-drain pull-ups for I2C bus
    pullup(i2c_scl);
    pullup(i2c_sda);

    // Pull-ups for bidirectional GPIO bus
    genvar gi;
    generate
        for (gi = 0; gi < 16; gi++) begin : gen_gpio_pu
            pullup(gpio[gi]);
        end
    endgenerate

    // =========================================================================
    // SoC DUT Instantiation: soc_top as soc_dut
    // Using actual RTL with all parameters matching design specification
    // =========================================================================
    soc_top #(
        .NUM_CH    (1),
        .NGPIO     (16),
        .IMEM_DEPTH(8192),  // 32 KB
        .DMEM_DEPTH(8192)   // 32 KB
    ) soc_dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .uart_tx (uart_tx),
        .uart_rx (uart_rx),
        .i2c_scl (i2c_scl),
        .i2c_sda (i2c_sda),
        .pwm_out (pwm_out),
        .gpio    (gpio)
    );

    // =========================================================================
    // IMEM Firmware Preload (Robust Path Resolution)
    // =========================================================================
    string hex_file = "";
    int hex_fd;

    initial begin
        if (!$value$plusargs("HEX_FILE=%s", hex_file)) begin
            hex_file = "../sw/main.hex";
            hex_fd = $fopen(hex_file, "r");
            if (hex_fd != 0) begin
                $fclose(hex_fd);
            end else begin
                hex_file = "../../sw/main.hex";
            end
        end

        hex_fd = $fopen(hex_file, "r");
        if (hex_fd != 0) begin
            $fclose(hex_fd);
            `uvm_info("TB", $sformatf("Preloading IMEM from %s ...", hex_file), UVM_LOW)
            $readmemh(hex_file, soc_dut.u_imem.mem);
            `uvm_info("TB", "IMEM preload complete.", UVM_LOW)
        end else begin
            `uvm_info("TB", "No HEX file found for preload — proceeding without preload.", UVM_LOW)
        end
    end

    // =========================================================================
    // Six SoC-Level SystemVerilog Interface Instantiations
    // =========================================================================

    // --- UART Interface ---
    uart_if u_uart_if (.clk(clk), .rst_n(rst_n));
    assign u_uart_if.uart_tx = uart_tx;
    assign u_uart_if.uart_rx = uart_rx;
    assign u_uart_if.irq     = soc_dut.irq_uart;

    // --- GPIO Interface ---
    gpio_if #(.NGPIO(16)) u_gpio_if (.clk(clk), .rst_n(rst_n));
    assign u_gpio_if.gpio_in  = soc_dut.gpio_in;
    assign u_gpio_if.gpio_out = soc_dut.gpio_out;
    assign u_gpio_if.gpio_oe  = soc_dut.gpio_oe;
    assign u_gpio_if.irq      = soc_dut.irq_gpio;

    // --- I2C Interface ---
    i2c_if u_i2c_if (
        .clk  (clk),
        .rst_n(rst_n),
        .scl  (i2c_scl),
        .sda  (i2c_sda)
    );
    assign u_i2c_if.scl_o  = soc_dut.u_i2c.scl_o;
    assign u_i2c_if.scl_oe = soc_dut.u_i2c.scl_oe;
    assign u_i2c_if.sda_o  = soc_dut.u_i2c.sda_o;
    assign u_i2c_if.sda_oe = soc_dut.u_i2c.sda_oe;
    assign u_i2c_if.irq    = soc_dut.irq_i2c;

    // --- Timer Interface ---
    timer_if u_timer_if (.clk(clk), .rst_n(rst_n));
    assign u_timer_if.timer_int = soc_dut.timer_int;
    assign u_timer_if.irq       = soc_dut.irq_timer;

    // --- FIR Interface ---
    fir_if u_fir_if (.clk(clk), .rst_n(rst_n));
    assign u_fir_if.sample_in      = soc_dut.u_fir.reg_wdata[15:0];
    assign u_fir_if.sample_valid   = soc_dut.u_fir.reg_wen && (soc_dut.u_fir.reg_waddr == 6'd2);
    assign u_fir_if.sample_ready   = soc_dut.u_fir.status_idle;
    assign u_fir_if.filtered_out   = soc_dut.u_fir.data_out_q;
    assign u_fir_if.filtered_valid = soc_dut.u_fir.status_done;
    assign u_fir_if.status_busy    = soc_dut.u_fir.status_busy;
    assign u_fir_if.status_done    = soc_dut.u_fir.status_done;
    assign u_fir_if.irq            = soc_dut.irq_fir;

    // --- PWM Interface ---
    pwm_if #(.NUM_CH(1)) u_pwm_if (.clk(clk), .rst_n(rst_n));
    assign u_pwm_if.pwm_out = pwm_out;
    assign u_pwm_if.irq     = soc_dut.irq_pwm;

    // =========================================================================
    // Six VIP-Level Interface Instantiations
    // =========================================================================
    uart_vip_if  u_uart_vip_if();
    gpio_vip_if  u_gpio_vip_if();
    i2c_vip_if   u_i2c_vip_if();
    timer_vip_if u_timer_vip_if();
    fir_vip_if   u_fir_vip_if();
    pwm_vip_if   u_pwm_vip_if();

    // UART VIP
    // VIP Driver injects stimulus into u_uart_vip_if.uart_rx, which drives the SoC uart_rx pin
    assign uart_rx               = u_uart_vip_if.uart_rx;
    assign u_uart_vip_if.clk     = clk;
    assign u_uart_vip_if.rst_n   = rst_n;
    assign u_uart_vip_if.uart_tx = uart_tx;
    assign u_uart_vip_if.irq     = soc_dut.irq_uart;

    // DUT internal probes mapped into VIP interface for Scoreboard checking
    assign u_uart_vip_if.dut_rx_data          = soc_dut.u_uart.rx_fifo[0];
    assign u_uart_vip_if.dut_rx_count         = soc_dut.u_uart.rx_count;
    assign u_uart_vip_if.dut_rx_empty         = soc_dut.u_uart.rx_empty;
    assign u_uart_vip_if.dut_rx_wptr          = soc_dut.u_uart.rx_wptr;
    assign u_uart_vip_if.dut_rx_rptr          = soc_dut.u_uart.rx_rptr;
    assign u_uart_vip_if.dut_status_frame_err = soc_dut.u_uart.status_frame_err;
    assign u_uart_vip_if.dut_status_overrun   = soc_dut.u_uart.status_overrun;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            u_uart_vip_if.dut_last_rx_byte <= 8'h00;
            u_uart_vip_if.dut_rx_committed <= 1'b0;
        end else begin
            if (soc_dut.u_uart.rx_state == 2'd3 &&
                soc_dut.u_uart.rx_sample_cnt == 4'd15 &&
                soc_dut.u_uart.rx_baud_cnt >= (soc_dut.u_uart.sample_period - 1) &&
                soc_dut.u_uart.rx_sync2) begin
                u_uart_vip_if.dut_last_rx_byte <= soc_dut.u_uart.rx_shift_reg;
                u_uart_vip_if.dut_rx_committed <= 1'b1;
            end
        end
    end

    // GPIO VIP
    assign u_gpio_vip_if.clk          = clk;
    assign u_gpio_vip_if.rst_n        = rst_n;
    assign u_gpio_vip_if.gpio_in      = soc_dut.gpio_in;
    assign u_gpio_vip_if.gpio_out     = soc_dut.gpio_out;
    assign u_gpio_vip_if.gpio_oe      = soc_dut.gpio_oe;
    assign u_gpio_vip_if.irq          = soc_dut.irq_gpio;
    assign u_gpio_vip_if.dut_sync_ff2 = soc_dut.u_gpio.sync_ff2;
    assign u_gpio_vip_if.dut_data_out = soc_dut.u_gpio.data_out_q;
    assign u_gpio_vip_if.dut_dir      = soc_dut.u_gpio.dir_q;
    assign u_gpio_vip_if.dut_irq_mask = soc_dut.u_gpio.irq_mask_q;
    assign u_gpio_vip_if.dut_irq_stat = soc_dut.u_gpio.irq_stat_q;

    // GPIO VIP Driver bidirectional bus driving
    for (gi = 0; gi < 16; gi++) begin : gen_gpio_vip_drv
        assign gpio[gi] = u_gpio_vip_if.drv_en[gi] ? u_gpio_vip_if.drv_val[gi] : 1'bz;
    end

    // I2C VIP
    assign u_i2c_vip_if.clk            = clk;
    assign u_i2c_vip_if.rst_n          = rst_n;
    assign u_i2c_vip_if.scl_i          = i2c_scl;
    assign u_i2c_vip_if.scl_o          = soc_dut.u_i2c.scl_o;
    assign u_i2c_vip_if.scl_oe         = soc_dut.u_i2c.scl_oe;
    assign u_i2c_vip_if.sda_i          = i2c_sda;
    assign u_i2c_vip_if.sda_o          = soc_dut.u_i2c.sda_o;
    assign u_i2c_vip_if.sda_oe         = soc_dut.u_i2c.sda_oe;
    assign u_i2c_vip_if.irq            = soc_dut.irq_i2c;
    assign u_i2c_vip_if.dut_prer       = soc_dut.u_i2c.prer;
    assign u_i2c_vip_if.dut_ctrl_en    = soc_dut.u_i2c.ctrl_en;
    assign u_i2c_vip_if.dut_txr        = soc_dut.u_i2c.txr;
    assign u_i2c_vip_if.dut_rxr        = soc_dut.u_i2c.rxr;
    assign u_i2c_vip_if.dut_stat_rxack = soc_dut.u_i2c.stat_rxack;
    assign u_i2c_vip_if.dut_stat_busy  = soc_dut.u_i2c.stat_busy;
    assign u_i2c_vip_if.dut_stat_tip   = soc_dut.u_i2c.stat_tip;

    // Timer VIP
    assign u_timer_vip_if.clk                   = clk;
    assign u_timer_vip_if.rst_n                 = rst_n;
    assign u_timer_vip_if.timer_int             = soc_dut.timer_int;
    assign u_timer_vip_if.irq                   = soc_dut.irq_timer;
    assign u_timer_vip_if.dut_mtime             = soc_dut.u_timer.mtime;
    assign u_timer_vip_if.dut_mtimecmp          = soc_dut.u_timer.mtimecmp;
    assign u_timer_vip_if.dut_prescale          = soc_dut.u_timer.prescale;
    assign u_timer_vip_if.dut_ctrl_en           = soc_dut.u_timer.ctrl_en;
    assign u_timer_vip_if.dut_ctrl_timer_irq_en = soc_dut.u_timer.ctrl_timer_irq_en;

    // FIR VIP
    assign u_fir_vip_if.clk            = clk;
    assign u_fir_vip_if.rst_n          = rst_n;
    assign u_fir_vip_if.sample_in      = soc_dut.u_fir.reg_wdata[15:0];
    assign u_fir_vip_if.sample_valid   = soc_dut.u_fir.reg_wen && (soc_dut.u_fir.reg_waddr == 6'd2);
    assign u_fir_vip_if.sample_ready   = soc_dut.u_fir.status_idle;
    assign u_fir_vip_if.filtered_out   = soc_dut.u_fir.data_out_q;
    assign u_fir_vip_if.filtered_valid = soc_dut.u_fir.status_done;
    assign u_fir_vip_if.irq            = soc_dut.irq_fir;
    assign u_fir_vip_if.dut_shift      = soc_dut.u_fir.shift_q;
    assign u_fir_vip_if.dut_ctrl_en    = soc_dut.u_fir.ctrl_en;
    assign u_fir_vip_if.dut_status_sat = soc_dut.u_fir.status_sat;

    // PWM VIP
    assign u_pwm_vip_if.clk          = clk;
    assign u_pwm_vip_if.rst_n        = rst_n;
    assign u_pwm_vip_if.pwm_out      = pwm_out[0];
    assign u_pwm_vip_if.irq          = soc_dut.irq_pwm;
    assign u_pwm_vip_if.dut_period   = soc_dut.u_pwm.period_active;
    assign u_pwm_vip_if.dut_duty     = soc_dut.u_pwm.duty_active;
    assign u_pwm_vip_if.dut_prescale = soc_dut.u_pwm.prescale_active;
    assign u_pwm_vip_if.dut_ctrl_en  = soc_dut.u_pwm.ctrl_en;
    assign u_pwm_vip_if.dut_ctrl_pol = soc_dut.u_pwm.ctrl_pol;

    // =========================================================================
    // UVM Config DB Registration & Test Execution
    // =========================================================================
    initial begin
        // Register SoC-level interfaces for soc_test
        uvm_config_db #(virtual uart_if )::set(null, "*", "uart_vif",  u_uart_if);
        uvm_config_db #(virtual gpio_if )::set(null, "*", "gpio_vif",  u_gpio_if);
        uvm_config_db #(virtual i2c_if  )::set(null, "*", "i2c_vif",   u_i2c_if);
        uvm_config_db #(virtual timer_if)::set(null, "*", "timer_vif", u_timer_if);
        uvm_config_db #(virtual fir_if  )::set(null, "*", "fir_vif",   u_fir_if);
        uvm_config_db #(virtual pwm_if  )::set(null, "*", "pwm_vif",   u_pwm_if);

        // Register VIP-level interfaces for VIP agents
        uvm_config_db #(virtual uart_vip_if )::set(null, "*", "uart_vip_vif",  u_uart_vip_if);
        uvm_config_db #(virtual gpio_vip_if )::set(null, "*", "gpio_vip_vif",  u_gpio_vip_if);
        uvm_config_db #(virtual i2c_vip_if  )::set(null, "*", "i2c_vip_vif",   u_i2c_vip_if);
        uvm_config_db #(virtual timer_vip_if)::set(null, "*", "timer_vip_vif", u_timer_vip_if);
        uvm_config_db #(virtual fir_vip_if  )::set(null, "*", "fir_vip_vif",   u_fir_vip_if);
        uvm_config_db #(virtual pwm_vip_if  )::set(null, "*", "pwm_vip_vif",   u_pwm_vip_if);

        // Launch the UVM test
        run_test("soc_test");
    end

    // =========================================================================
    // Verification Models (reused from tb/models/)
    // =========================================================================
    i2c_sensor_model #(.I2C_ADDR(7'h48)) u_sensor (
        .scl(i2c_scl),
        .sda(i2c_sda)
    );

    uart_monitor #(
        .CLK_FREQ_HZ(50_000_000),
        .BAUD_RATE  (115_200)
    ) u_uart_mon (
        .clk    (clk),
        .rst_n  (rst_n),
        .uart_tx(uart_tx)
    );

    pwm_monitor u_pwm_mon (
        .clk    (clk),
        .rst_n  (rst_n),
        .pwm_in (pwm_out[0])
    );

    // =========================================================================
    // Diagnostic Hardware Probes (visible at UVM_HIGH)
    // =========================================================================
    always @(soc_dut.uart_rx) begin
        `uvm_info("UART_HW_PROBE", $sformatf("soc_dut.uart_rx transitioned to %0b", soc_dut.uart_rx), UVM_HIGH)
    end
    always @(soc_dut.u_uart.rx_state) begin
        `uvm_info("UART_HW_PROBE", $sformatf("soc_dut.u_uart.rx_state = %0d (rx_sync2=%0b, ctrl_rx_en=%0b, aresetn=%0b)",
            soc_dut.u_uart.rx_state, soc_dut.u_uart.rx_sync2, soc_dut.u_uart.ctrl_rx_en, soc_dut.u_uart.aresetn), UVM_HIGH)
    end
    always @(soc_dut.u_uart.rx_wptr or soc_dut.u_uart.rx_count or soc_dut.u_uart.rx_pop) begin
        `uvm_info("UART_FIFO_PROBE", $sformatf("rx_wptr=%0d, rx_rptr=%0d, rx_count=%0d, rx_pop=%0b, rx_fifo[0]=0x%02x, shift_reg=0x%02x, frame_err=%0b",
            soc_dut.u_uart.rx_wptr, soc_dut.u_uart.rx_rptr, soc_dut.u_uart.rx_count, soc_dut.u_uart.rx_pop,
            soc_dut.u_uart.rx_fifo[0], soc_dut.u_uart.rx_shift_reg, soc_dut.u_uart.status_frame_err), UVM_HIGH)
    end
    always @(posedge soc_dut.clk) begin
        if (soc_dut.u_uart.reg_ren && soc_dut.u_uart.reg_raddr == 0) begin
            `uvm_info("UART_BUS_READ_DATA", $sformatf("READ RX DATA @ %0t, PC=0x%08x",
                $time, {soc_dut.u_core.veer.dec.dec_i0_pc_d, 1'b0}), UVM_HIGH)
        end
    end
    // =========================================================================
    // Waveform Dumping (VPD and VCD)
    // =========================================================================
    initial begin
        `uvm_info("TB_WAVE", "Recording waveforms to uart_verification.vpd and uart_verification.vcd...", UVM_LOW)
        $vcdplusfile("uart_verification.vpd");
        $vcdpluson(0, tb_soc_uvm_top);
        $dumpfile("uart_verification.vcd");
        $dumpvars(0, tb_soc_uvm_top);
    end

    // =========================================================================
    // Watchdog: prevent infinite simulation on hang
    // =========================================================================
    initial begin
        #25_000_000; // 25 ms watchdog
        `uvm_fatal("TB_WATCHDOG",
            "Simulation exceeded 25 ms watchdog limit — check for UVM phase hang.")
        $finish;
    end

endmodule : tb_soc_uvm_top
