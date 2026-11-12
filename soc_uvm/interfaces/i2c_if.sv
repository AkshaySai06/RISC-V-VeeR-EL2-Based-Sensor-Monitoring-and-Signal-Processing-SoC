// SPDX-License-Identifier: Apache-2.0
// SoC-Level I2C Interface
// soc_top exposes i2c_scl and i2c_sda as open-drain inout wires.
// Internal split signals: scl_o, scl_oe, sda_o, sda_oe from u_i2c.

`timescale 1ns/1ps

interface i2c_if (
    input logic clk,
    input logic rst_n,
    inout wire  scl,
    inout wire  sda
);
    // Internal split signals (observable via hierarchy for monitoring)
    logic scl_o;    // Always 1'b0 (open-drain driver drives 0 or releases)
    logic scl_oe;   // 1 = drive low, 0 = release (pull-up)
    logic sda_o;    // Always 1'b0
    logic sda_oe;   // 1 = drive low, 0 = release (pull-up)
    logic irq;      // I2C interrupt

    // Clocking block for monitor (observe only)
    clocking monitor_cb @(posedge clk);
        default input #1ns;
        input scl;
        input sda;
        input scl_oe;
        input sda_oe;
        input irq;
    endclocking

    // Modports
    modport monitor_mp (clocking monitor_cb, input clk, rst_n);
    // Passive observe with direct pin access (for open-drain toggling)
    modport passive_mp (inout scl, sda, input scl_o, scl_oe, sda_o, sda_oe, irq, clk, rst_n);

endinterface : i2c_if
