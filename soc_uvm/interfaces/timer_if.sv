// SPDX-License-Identifier: Apache-2.0
// SoC-Level Timer Interface
// The timer peripheral is AXI4-Lite register mapped; CPU firmware drives it.
// This interface exposes observable signals: timer_int and irq_timer.

`timescale 1ns/1ps

interface timer_if (
    input logic clk,
    input logic rst_n
);
    // Timer interrupt outputs (observable from DUT hierarchy)
    logic timer_int;   // Core timer interrupt (connected to CPU timer_int input)
    logic irq;         // PIC interrupt request (irq_timer -> extintsrc_req[2])

    // Clocking block for monitor
    clocking monitor_cb @(posedge clk);
        default input #1ns;
        input timer_int;
        input irq;
    endclocking

    // Modports
    modport monitor_mp (clocking monitor_cb, input clk, rst_n);
    modport passive_mp (input timer_int, irq, clk, rst_n);

endinterface : timer_if
