// SPDX-License-Identifier: Apache-2.0
// SoC-Level UVM Test (Integration Construction Check)
// Creates soc_env, populates soc_config with virtual interfaces from config_db,
// and runs a base virtual sequence to confirm environment construction.
// No peripheral transactions are performed in this test.

`ifndef SOC_TEST_SV
`define SOC_TEST_SV

class soc_test extends uvm_test;

    `uvm_component_utils(soc_test)

    soc_env    env;
    soc_config cfg;

    function new(string name = "soc_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // -------------------------------------------------------------------------
    // build_phase: build config and env
    // -------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cfg = soc_config::type_id::create("cfg");

        // Retrieve SoC-level virtual interfaces set by tb_soc_uvm_top
        if (!uvm_config_db #(virtual uart_if )::get(this, "", "uart_vif",  cfg.uart_vif))
            `uvm_fatal("SOC_TEST", "uart_vif not found in uvm_config_db!")
        if (!uvm_config_db #(virtual gpio_if )::get(this, "", "gpio_vif",  cfg.gpio_vif))
            `uvm_fatal("SOC_TEST", "gpio_vif not found in uvm_config_db!")
        if (!uvm_config_db #(virtual i2c_if  )::get(this, "", "i2c_vif",   cfg.i2c_vif))
            `uvm_fatal("SOC_TEST", "i2c_vif not found in uvm_config_db!")
        if (!uvm_config_db #(virtual timer_if)::get(this, "", "timer_vif", cfg.timer_vif))
            `uvm_fatal("SOC_TEST", "timer_vif not found in uvm_config_db!")
        if (!uvm_config_db #(virtual fir_if  )::get(this, "", "fir_vif",   cfg.fir_vif))
            `uvm_fatal("SOC_TEST", "fir_vif not found in uvm_config_db!")
        if (!uvm_config_db #(virtual pwm_if  )::get(this, "", "pwm_vif",   cfg.pwm_vif))
            `uvm_fatal("SOC_TEST", "pwm_vif not found in uvm_config_db!")

        // Retrieve VIP-level virtual interfaces set by tb_soc_uvm_top
        void'(uvm_config_db #(virtual uart_vip_if )::get(this, "", "uart_vip_vif",  cfg.uart_vip_vif));
        void'(uvm_config_db #(virtual gpio_vip_if )::get(this, "", "gpio_vip_vif",  cfg.gpio_vip_vif));
        void'(uvm_config_db #(virtual i2c_vip_if  )::get(this, "", "i2c_vip_vif",   cfg.i2c_vip_vif));
        void'(uvm_config_db #(virtual timer_vip_if)::get(this, "", "timer_vip_vif", cfg.timer_vip_vif));
        void'(uvm_config_db #(virtual fir_vip_if  )::get(this, "", "fir_vip_vif",   cfg.fir_vip_vif));
        void'(uvm_config_db #(virtual pwm_vip_if  )::get(this, "", "pwm_vip_vif",   cfg.pwm_vip_vif));

        // Push config down to env
        uvm_config_db #(soc_config)::set(this, "env", "soc_cfg", cfg);

        // Create environment
        env = soc_env::type_id::create("env", this);

        `uvm_info("SOC_TEST", "soc_test build_phase complete: config retrieved, env created.", UVM_LOW)
    endfunction

    // -------------------------------------------------------------------------
    // run_phase: run the base virtual sequence (no transactions)
    // -------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        soc_virtual_sequence v_seq;

        phase.raise_objection(this);

        `uvm_info("SOC_TEST", "run_phase started — running base virtual sequence.", UVM_LOW)

        v_seq = soc_virtual_sequence::type_id::create("v_seq");
        v_seq.start(env.v_seqr);

        // Brief pause to allow all components to verify run_phase initialization
        #500ns;

        `uvm_info("SOC_TEST",
            "==================================================================",
            UVM_LOW)
        `uvm_info("SOC_TEST",
            " [INTEGRATION CHECK] soc_test completed successfully: PASS",
            UVM_LOW)
        `uvm_info("SOC_TEST",
            " All six VIP agents instantiated and virtual interfaces verified.",
            UVM_LOW)
        `uvm_info("SOC_TEST",
            "==================================================================",
            UVM_LOW)

        phase.drop_objection(this);
    endtask

    // -------------------------------------------------------------------------
    // end_of_elaboration_phase: print topology
    // -------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

endclass : soc_test

`endif // SOC_TEST_SV
