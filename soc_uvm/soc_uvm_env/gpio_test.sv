// SPDX-License-Identifier: Apache-2.0
// SoC-Level GPIO End-to-End Verification Test
// Performs:
// 1. Reset state verification
// 2. Output enable and output data verification (driven by firmware)
// 3. Input driving and 2-FF synchronization verification across pins 8..15
//    (Walking 1s on individual pins + multi-pin alternating patterns)

`ifndef GPIO_TEST_SV
`define GPIO_TEST_SV

class gpio_test extends soc_test;

    `uvm_component_utils(gpio_test)

    function new(string name = "gpio_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpio_connectivity_sequence gpio_seq;
        string banner;

        phase.raise_objection(this);

        `uvm_info(get_type_name(), "====================================================================", UVM_LOW)
        `uvm_info(get_type_name(), "  STARTING GPIO VERIFICATION TEST (Phase 3 End-to-End Verification) ", UVM_LOW)
        `uvm_info(get_type_name(), "====================================================================", UVM_LOW)

        // Wait for reset deassertion
        `uvm_info(get_type_name(), "Waiting for SoC reset deassertion...", UVM_LOW)
        wait (cfg.gpio_vip_vif.rst_n === 1'b1);
        repeat (100) @(posedge cfg.gpio_vip_vif.clk);
        `uvm_info(get_type_name(), "Reset released. CPU and GPIO peripheral active.", UVM_LOW)

        // Wait for CPU to reach and complete GPIO initialization (gpio_set_dir 0x00FF, gpio_write 0x00AA)
        fork
            begin
                wait (cfg.gpio_vip_vif.gpio_oe === 16'h00FF && (cfg.gpio_vip_vif.gpio_out & 16'h00FF) === 16'h00AA);
                `uvm_info(get_type_name(),
                    "Observed GPIO direction configured to 0x00FF and output set to 0xAA by CPU firmware.", UVM_LOW)
            end
            begin
                #100us;
                `uvm_error(get_type_name(), "Timeout waiting for CPU firmware to initialize GPIO!")
            end
        join_any
        disable fork;

        // Execute GPIO Connectivity Sequence
        gpio_seq = gpio_connectivity_sequence::type_id::create("gpio_seq");
        `uvm_info(get_type_name(), "Executing GPIO Connectivity Sequence on gpio_agent.seqr...", UVM_LOW)
        gpio_seq.start(env.gpio_agent.seqr);

        // Allow post-sequence settle time
        repeat (100) @(posedge cfg.gpio_vip_vif.clk);

        // Scoreboard evaluation
        `uvm_info(get_type_name(), "Checking GPIO Verification Results...", UVM_LOW)

        if (env.gpio_agent.sb.mismatch_count == 0 &&
            env.gpio_agent.sb.verified_output_dir &&
            env.gpio_agent.sb.verified_output_data &&
            env.gpio_agent.sb.verified_input_drive) begin

            banner = "\n========================================================================\n [GPIO VERIFICATION SIGN-OFF: SUCCESS]\n  Test Name           : gpio_test\n  Output Config       : Pins 0..7 OUTPUT (dir=0x00FF)\n  Output Data         : 0xAA (per firmware gpio_write)\n  Input Config        : Pins 8..15 INPUT (dir=0x00FF)\n  Input Patterns      : Walking 1s (Pins 8..15) + Multi-pin patterns\n  DUT Synchronization : 2-FF synchronizer verified (sync_ff2)\n  Scoreboard Matches  : PASS (0 Mismatches)\n  Overall Status      : TEST PASSED\n========================================================================";
            `uvm_info(get_type_name(), banner, UVM_LOW)
        end else begin
            `uvm_error(get_type_name(),
                $sformatf("GPIO Verification FAILED: matches=%0d, mismatches=%0d",
                    env.gpio_agent.sb.match_count, env.gpio_agent.sb.mismatch_count))
        end

        #500ns;
        phase.drop_objection(this);
    endtask

endclass : gpio_test

`endif // GPIO_TEST_SV
