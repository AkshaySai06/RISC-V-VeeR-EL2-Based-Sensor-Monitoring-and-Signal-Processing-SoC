// SPDX-License-Identifier: Apache-2.0
// SoC-Level Virtual Sequence (Base Class)
// Foundation for coordinating sequences across multiple VIP agents.
// Actual peripheral transaction tests are NOT implemented here (future phases).

`ifndef SOC_VIRTUAL_SEQUENCE_SV
`define SOC_VIRTUAL_SEQUENCE_SV

class soc_virtual_sequence extends uvm_sequence #(uvm_sequence_item);

    `uvm_object_utils(soc_virtual_sequence)

    // -------------------------------------------------------------------------
    // Shorthand handle to the virtual sequencer (cast in body)
    // -------------------------------------------------------------------------
    soc_virtual_sequencer p_sequencer;

    function new(string name = "soc_virtual_sequence");
        super.new(name);
    endfunction

    // Cast the sequencer handle in pre_body for convenience in child sequences
    task pre_body();
        if (!$cast(p_sequencer, m_sequencer)) begin
            `uvm_fatal("SOC_VSEQ",
                "Virtual sequencer cast failed — ensure soc_virtual_sequencer is used.")
        end
    endtask

    // Base body: no transactions — override in derived test-specific sequences
    virtual task body();
        `uvm_info("SOC_VSEQ",
            "soc_virtual_sequence base body — no transactions scheduled (integration check only).",
            UVM_LOW)
    endtask

endclass : soc_virtual_sequence

`endif // SOC_VIRTUAL_SEQUENCE_SV
