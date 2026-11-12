// SPDX-License-Identifier: Apache-2.0
// VIP Interface Definitions matching existing VIP driver and monitor requirements
`timescale 1ns/1ps

`ifndef SOC_VIP_INTERFACES_SV
`define SOC_VIP_INTERFACES_SV

// =============================================================================
// UART VIP Interface
// =============================================================================
interface uart_vip_if;
    logic        clk;
    logic        rst_n;
    logic        uart_rx = 1'b1;
    logic        uart_tx;
    logic        irq;

    // DUT UART Internal Probes (for Scoreboard Verification)
    logic [7:0]  dut_rx_data;          // Latched content of FIFO[0]
    logic [7:0]  dut_last_rx_byte;     // Byte committed to FIFO by receiver FSM
    logic        dut_rx_committed;     // Strobe/flag: receiver pushed byte into FIFO
    logic [4:0]  dut_rx_count;         // Current FIFO count
    logic        dut_rx_empty;
    logic        dut_status_frame_err;
    logic        dut_status_overrun;
    logic [3:0]  dut_rx_wptr;          // Write pointer
    logic [3:0]  dut_rx_rptr;          // Read pointer
endinterface

// =============================================================================
// GPIO VIP Interface
// =============================================================================
interface gpio_vip_if;
    logic        clk;
    logic        rst_n;
    logic [15:0] gpio_in;
    logic [15:0] gpio_out;
    logic [15:0] gpio_oe;
    logic        irq;

    // VIP Driver Control
    logic [15:0] drv_val = 16'h0000;
    logic [15:0] drv_en  = 16'h0000;

    // DUT GPIO Internal Probes
    logic [15:0] dut_sync_ff2;
    logic [15:0] dut_data_out;
    logic [15:0] dut_dir;
    logic [15:0] dut_irq_mask;
    logic [15:0] dut_irq_stat;
endinterface

// =============================================================================
// I2C VIP Interface
// =============================================================================
interface i2c_vip_if;
    logic        clk;
    logic        rst_n;
    logic        scl_i;
    logic        scl_o;
    logic        scl_oe;
    logic        sda_i;
    logic        sda_o;
    logic        sda_oe;
    logic        irq;

    // DUT I2C Internal Probes
    logic [15:0] dut_prer;
    logic        dut_ctrl_en;
    logic [7:0]  dut_txr;
    logic [7:0]  dut_rxr;
    logic        dut_stat_rxack;
    logic        dut_stat_busy;
    logic        dut_stat_tip;
endinterface

// =============================================================================
// Timer VIP Interface
// =============================================================================
interface timer_vip_if;
    logic        clk;
    logic        rst_n;
    logic        timer_int;
    logic        irq;

    // DUT Timer Internal Probes
    logic [63:0] dut_mtime;
    logic [63:0] dut_mtimecmp;
    logic [31:0] dut_prescale;
    logic        dut_ctrl_en;
    logic        dut_ctrl_timer_irq_en;
endinterface

// =============================================================================
// FIR VIP Interface
// =============================================================================
interface fir_vip_if;
    logic        clk;
    logic        rst_n;
    logic [15:0] sample_in;
    logic        sample_valid;
    logic        sample_ready;
    logic [15:0] filtered_out;
    logic        filtered_valid;
    logic        irq;

    // DUT FIR Internal Probes
    logic [5:0]  dut_shift;
    logic        dut_ctrl_en;
    logic        dut_status_sat;
endinterface

// =============================================================================
// PWM VIP Interface
// =============================================================================
interface pwm_vip_if;
    logic        clk;
    logic        rst_n;
    logic        pwm_out;
    logic        irq;

    // DUT PWM Internal Probes
    logic [15:0] dut_period;
    logic [15:0] dut_duty;
    logic [15:0] dut_prescale;
    logic        dut_ctrl_en;
    logic        dut_ctrl_pol;
endinterface

`endif // SOC_VIP_INTERFACES_SV
