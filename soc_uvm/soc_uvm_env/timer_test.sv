// SPDX-License-Identifier: Apache-2.0
// SoC-Level Timer End-to-End Verification Test
// Performs:
// 1. Reset state verification (mtime=0, mtimecmp=0xFFFFFFFFFFFFFFFF, prescale=49)
// 2. Prescaler cadence verification (verifies exact 50 clock cycles = 1.00 us per mtime tick)
// 3. Monotonic counting verification across multiple ticks
// 4. Comparator & interrupt checking (ensures timer_int remains 0 while mtime < mtimecmp)

`ifndef TIMER_TEST_SV
`define TIMER_TEST_SV

class timer_test extends soc_test;

    `uvm_component_utils(timer_test)

    function new(string name = "timer_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        string banner;

        phase.raise_objection(this);

        `uvm_info(get_type_name(), "====================================================================", UVM_LOW)
        `uvm_info(get_type_name(), "  STARTING TIMER VERIFICATION TEST (Phase 3 End-to-End Verification)", UVM_LOW)
        `uvm_info(get_type_name(), "====================================================================", UVM_LOW)

        // Wait for reset deassertion
        `uvm_info(get_type_name(), "Waiting for SoC reset deassertion...", UVM_LOW)
        wait (cfg.timer_vip_vif.rst_n === 1'b1);
        repeat (100) @(posedge cfg.timer_vip_vif.clk);
        `uvm_info(get_type_name(), "Reset released. CPU and Timer peripheral active.", UVM_LOW)

        // Allow Timer to run and generate at least 25-30 ticks (each tick is 1 us = 50 clock cycles)
        // 35 us = 1750 clock cycles
        `uvm_info(get_type_name(), "Observing Timer counter progression and cadence rate...", UVM_LOW)
        repeat (1800) @(posedge cfg.timer_vip_vif.clk);

        // Scoreboard evaluation
        `uvm_info(get_type_name(), "Checking Timer Verification Results...", UVM_LOW)

        if (env.timer_agent.sb.mismatch_count == 0 &&
            env.timer_agent.sb.verified_reset &&
            env.timer_agent.sb.verified_cadence &&
            env.timer_agent.sb.verified_monotonic) begin

            banner = $sformatf(
                "\n========================================================================\n [TIMER VERIFICATION SIGN-OFF: SUCCESS]\n  Test Name           : timer_test\n  Counter Bits        : 64-bit (mtime & mtimecmp)\n  Prescaler Value     : %0d (50 clock cycles = 1.00 us @ 50 MHz)\n  Cadence Verified    : PASS (Exact 50 cycles per tick)\n  Monotonic Count     : PASS (Sequential increments)\n  Scoreboard Matches  : %0d Matches (0 Mismatches)\n  Overall Status      : TEST PASSED\n========================================================================",
                env.timer_agent.sb.vif.dut_prescale, env.timer_agent.sb.match_count);
            `uvm_info(get_type_name(), banner, UVM_LOW)
        end else begin
            `uvm_error(get_type_name(),
                $sformatf("Timer Verification FAILED: matches=%0d, mismatches=%0d",
                    env.timer_agent.sb.match_count, env.timer_agent.sb.mismatch_count))
        end

        #500ns;
        phase.drop_objection(this);
    endtask

endclass : timer_test

`endif // TIMER_TEST_SV
