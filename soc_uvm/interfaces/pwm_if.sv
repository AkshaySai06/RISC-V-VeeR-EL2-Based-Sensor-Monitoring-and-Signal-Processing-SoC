// SPDX-License-Identifier: Apache-2.0
// SoC-Level PWM Interface
// soc_top exposes pwm_out[NUM_CH-1:0] as an output port (NUM_CH=1 by default).
// Also exposes irq_pwm from the PIC interrupt bus.

`timescale 1ns/1ps

interface pwm_if #(
    parameter int NUM_CH = 1
)(
    input logic clk,
    input logic rst_n
);
    // Top-level SoC PWM pin
    logic [NUM_CH-1:0] pwm_out;   // DUT output (connected to soc_dut.pwm_out)

    // Interrupt (observable from DUT hierarchy)
    logic irq;   // irq_pwm -> extintsrc_req[5]

    // Clocking block for monitor
    clocking monitor_cb @(posedge clk);
        default input #1ns;
        input pwm_out;
        input irq;
    endclocking

    // Modports
    modport monitor_mp (clocking monitor_cb, input clk, rst_n);
    modport passive_mp (input pwm_out, irq, clk, rst_n);

endinterface : pwm_if
