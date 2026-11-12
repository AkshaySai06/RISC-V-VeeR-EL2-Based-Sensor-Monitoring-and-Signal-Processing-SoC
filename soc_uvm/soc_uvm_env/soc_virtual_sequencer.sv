// SPDX-License-Identifier: Apache-2.0
// SoC-Level Virtual Sequencer
// Aggregates all six VIP sequencers as handles, providing a single
// coordination point for multi-peripheral virtual sequences.

`ifndef SOC_VIRTUAL_SEQUENCER_SV
`define SOC_VIRTUAL_SEQUENCER_SV

class soc_virtual_sequencer extends uvm_sequencer;

    `uvm_component_utils(soc_virtual_sequencer)

    // -------------------------------------------------------------------------
    // Handles to the six individual VIP sequencers
    // Assigned during soc_env connect_phase.
    // -------------------------------------------------------------------------
    uart_vip_sequencer  uart_seqr;
    gpio_vip_sequencer  gpio_seqr;
    i2c_vip_sequencer   i2c_seqr;
    timer_vip_sequencer timer_seqr;
    fir_vip_sequencer   fir_seqr;
    pwm_vip_sequencer   pwm_seqr;

    function new(string name = "soc_virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("SOC_VSEQR", "SoC Virtual Sequencer created.", UVM_LOW)
    endfunction

endclass : soc_virtual_sequencer

`endif // SOC_VIRTUAL_SEQUENCER_SV
