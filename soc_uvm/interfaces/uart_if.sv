// SPDX-License-Identifier: Apache-2.0
// SoC-Level UART Interface
// Matches soc_top ports: uart_tx (output), uart_rx (input)
// Internal observable: irq_uart (via hierarchical reference in tb)

`timescale 1ns/1ps

interface uart_if (
    input logic clk,
    input logic rst_n
);
    // Top-level SoC UART pins
    logic uart_tx;          // DUT drives (output from SoC)
    logic uart_rx;          // Driven from TB or VIP (input to SoC)

    // Interrupt (observable from DUT hierarchy)
    logic irq;

    // Clocking block for driver (active master side)
    clocking driver_cb @(posedge clk);
        default input #1ns output #1ns;
        input  uart_rx;
        input  uart_tx;
        input  irq;
    endclocking

    // Clocking block for monitor (passive observe side)
    clocking monitor_cb @(posedge clk);
        default input #1ns;
        input uart_tx;
        input uart_rx;
        input irq;
    endclocking

    // Modports
    modport driver_mp  (clocking driver_cb,  input clk, rst_n);
    modport monitor_mp (clocking monitor_cb, input clk, rst_n);
    modport passive_mp (input uart_tx, uart_rx, irq, clk, rst_n);

endinterface : uart_if
