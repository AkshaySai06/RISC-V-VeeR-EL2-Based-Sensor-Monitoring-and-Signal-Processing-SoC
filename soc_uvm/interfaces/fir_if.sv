// SPDX-License-Identifier: Apache-2.0
// SoC-Level FIR Filter Interface
// The FIR peripheral is AXI4-Lite register mapped; CPU firmware drives it.
// This interface exposes observable signals: status signals, data output, and irq.

`timescale 1ns/1ps

interface fir_if (
    input logic clk,
    input logic rst_n
);
    // Observable register-bus monitoring signals (from DUT hierarchy)
    logic [15:0] sample_in;       // reg_wdata[15:0]          (input sample value)
    logic        sample_valid;    // reg_wen && reg_waddr==2  (sample write strobe)
    logic        sample_ready;    // fir_filter.status_idle   (ready to accept sample)
    logic [15:0] filtered_out;    // fir_filter.data_out_q    (output result)
    logic        filtered_valid;  // fir_filter.status_done   (result valid strobe)
    logic        status_busy;     // fir_filter.status_busy   (MAC computation in progress)
    logic        status_done;     // fir_filter.status_done   (MAC completed)
    logic        irq;             // FIR interrupt (irq_fir -> extintsrc_req[4])

    // Clocking block for monitor
    clocking monitor_cb @(posedge clk);
        default input #1ns;
        input sample_valid;
        input sample_in;
        input sample_ready;
        input status_busy;
        input status_done;
        input filtered_out;
        input filtered_valid;
        input irq;
    endclocking

    // Modports
    modport monitor_mp (clocking monitor_cb, input clk, rst_n);
    modport passive_mp (input sample_valid, sample_in, sample_ready,
                        status_busy, status_done, filtered_out, filtered_valid,
                        irq, clk, rst_n);

endinterface : fir_if
