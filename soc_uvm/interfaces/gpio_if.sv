// SPDX-License-Identifier: Apache-2.0
// SoC-Level GPIO Interface
// Matches soc_top internal signals: gpio_in, gpio_out, gpio_oe, irq_gpio
// The bidirectional gpio[15:0] wire is at top level; the split internal signals
// gpio_in / gpio_out / gpio_oe are observable via hierarchy.

`timescale 1ns/1ps

interface gpio_if #(
    parameter int NGPIO = 16
)(
    input logic clk,
    input logic rst_n
);
    // Internal DUT signals (driven or observed via hierarchy)
    logic [NGPIO-1:0] gpio_in;    // Sampled from bidirectional gpio pad
    logic [NGPIO-1:0] gpio_out;   // DUT output data register
    logic [NGPIO-1:0] gpio_oe;    // DUT output enable (direction)
    logic             irq;        // GPIO interrupt

    // Clocking block for driver
    clocking driver_cb @(posedge clk);
        default input #1ns output #1ns;
        input  gpio_in;
        input  gpio_out;
        input  gpio_oe;
        input  irq;
    endclocking

    // Clocking block for monitor
    clocking monitor_cb @(posedge clk);
        default input #1ns;
        input gpio_in;
        input gpio_out;
        input gpio_oe;
        input irq;
    endclocking

    // Modports
    modport driver_mp  (clocking driver_cb,  input clk, rst_n);
    modport monitor_mp (clocking monitor_cb, input clk, rst_n);
    modport passive_mp (input gpio_in, gpio_out, gpio_oe, irq, clk, rst_n);

endinterface : gpio_if
