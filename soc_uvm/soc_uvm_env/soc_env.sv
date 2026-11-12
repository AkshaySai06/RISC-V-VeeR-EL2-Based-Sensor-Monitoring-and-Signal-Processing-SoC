// SPDX-License-Identifier: Apache-2.0
// SoC-Level UVM Environment
// Instantiates all six existing VIP agents and the virtual sequencer.
// Distributes virtual interface handles via uvm_config_db.

`ifndef SOC_ENV_SV
`define SOC_ENV_SV

class soc_env extends uvm_env;

    `uvm_component_utils(soc_env)

    // -------------------------------------------------------------------------
    // Six VIP Agent Instances
    // -------------------------------------------------------------------------
    uart_vip_agent  uart_agent;
    gpio_vip_agent  gpio_agent;
    i2c_vip_agent   i2c_agent;
    timer_vip_agent timer_agent;
    fir_vip_agent   fir_agent;
    pwm_vip_agent   pwm_agent;

    // Virtual Sequencer
    soc_virtual_sequencer v_seqr;

    // SoC Configuration Object
    soc_config cfg;

    function new(string name = "soc_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // -------------------------------------------------------------------------
    // build_phase: retrieve config, create all agents and virtual sequencer
    // -------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Retrieve soc_config from config_db
        if (!uvm_config_db #(soc_config)::get(this, "", "soc_cfg", cfg)) begin
            `uvm_fatal("SOC_ENV", "Cannot find soc_config in uvm_config_db!")
        end

        // Configure active/passive modes in config_db before agent build
        uvm_config_db#(uvm_active_passive_enum)::set(this, "uart_agent",  "is_active", cfg.uart_is_active);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "gpio_agent",  "is_active", cfg.gpio_is_active);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "i2c_agent",   "is_active", cfg.i2c_is_active);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "timer_agent", "is_active", cfg.timer_is_active);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "fir_agent",   "is_active", cfg.fir_is_active);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "pwm_agent",   "is_active", cfg.pwm_is_active);

        // Create the six VIP agents
        uart_agent  = uart_vip_agent ::type_id::create("uart_agent",  this);
        gpio_agent  = gpio_vip_agent ::type_id::create("gpio_agent",  this);
        i2c_agent   = i2c_vip_agent  ::type_id::create("i2c_agent",   this);
        timer_agent = timer_vip_agent::type_id::create("timer_agent", this);
        fir_agent   = fir_vip_agent  ::type_id::create("fir_agent",   this);
        pwm_agent   = pwm_vip_agent  ::type_id::create("pwm_agent",   this);

        // Set is_active property on agents
        uart_agent.is_active  = cfg.uart_is_active;
        gpio_agent.is_active  = cfg.gpio_is_active;
        i2c_agent.is_active   = cfg.i2c_is_active;
        timer_agent.is_active = cfg.timer_is_active;
        fir_agent.is_active   = cfg.fir_is_active;
        pwm_agent.is_active   = cfg.pwm_is_active;

        // Create virtual sequencer
        v_seqr = soc_virtual_sequencer::type_id::create("v_seqr", this);

        // Distribute SoC-level virtual interfaces via config_db
        uvm_config_db #(virtual uart_if )::set(this, "uart_agent.*",  "uart_vif",  cfg.uart_vif);
        uvm_config_db #(virtual gpio_if )::set(this, "gpio_agent.*",  "gpio_vif",  cfg.gpio_vif);
        uvm_config_db #(virtual i2c_if  )::set(this, "i2c_agent.*",   "i2c_vif",   cfg.i2c_vif);
        uvm_config_db #(virtual timer_if)::set(this, "timer_agent.*", "timer_vif", cfg.timer_vif);
        uvm_config_db #(virtual fir_if  )::set(this, "fir_agent.*",   "fir_vif",   cfg.fir_vif);
        uvm_config_db #(virtual pwm_if  )::set(this, "pwm_agent.*",   "pwm_vif",   cfg.pwm_vif);

        `uvm_info("SOC_ENV", "SoC UVM Environment built: 6 VIP agents + virtual sequencer.", UVM_LOW)
    endfunction

    // -------------------------------------------------------------------------
    // connect_phase: wire VIP sequencers into virtual sequencer and connect vif
    // -------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect VIP sequencers to the virtual sequencer
        v_seqr.uart_seqr  = uart_agent.seqr;
        v_seqr.gpio_seqr  = gpio_agent.seqr;
        v_seqr.i2c_seqr   = i2c_agent.seqr;
        v_seqr.timer_seqr = timer_agent.seqr;
        v_seqr.fir_seqr   = fir_agent.seqr;
        v_seqr.pwm_seqr   = pwm_agent.seqr;

        // Connect VIP virtual interfaces to VIP drivers, monitors, and scoreboards
        if (cfg.uart_vip_vif != null) begin
            if (uart_agent.drv != null) uart_agent.drv.vif = cfg.uart_vip_vif;
            if (uart_agent.mon != null) uart_agent.mon.vif = cfg.uart_vip_vif;
            if (uart_agent.sb  != null) uart_agent.sb.vif  = cfg.uart_vip_vif;
        end
        if (cfg.gpio_vip_vif != null) begin
            if (gpio_agent.drv != null) gpio_agent.drv.vif = cfg.gpio_vip_vif;
            if (gpio_agent.mon != null) gpio_agent.mon.vif = cfg.gpio_vip_vif;
            if (gpio_agent.sb  != null) gpio_agent.sb.vif  = cfg.gpio_vip_vif;
        end
        if (cfg.i2c_vip_vif != null) begin
            if (i2c_agent.drv != null) i2c_agent.drv.vif = cfg.i2c_vip_vif;
            if (i2c_agent.mon != null) i2c_agent.mon.vif = cfg.i2c_vip_vif;
            if (i2c_agent.sb  != null) i2c_agent.sb.vif  = cfg.i2c_vip_vif;
        end
        if (cfg.timer_vip_vif != null) begin
            if (timer_agent.drv != null) timer_agent.drv.vif = cfg.timer_vip_vif;
            if (timer_agent.mon != null) timer_agent.mon.vif = cfg.timer_vip_vif;
            if (timer_agent.sb  != null) timer_agent.sb.vif  = cfg.timer_vip_vif;
        end
        if (cfg.fir_vip_vif != null) begin
            if (fir_agent.drv != null) fir_agent.drv.vif = cfg.fir_vip_vif;
            if (fir_agent.mon != null) fir_agent.mon.vif = cfg.fir_vip_vif;
        end
        if (cfg.pwm_vip_vif != null) begin
            if (pwm_agent.drv != null) pwm_agent.drv.vif = cfg.pwm_vip_vif;
            if (pwm_agent.mon != null) pwm_agent.mon.vif = cfg.pwm_vip_vif;
        end

        `uvm_info("SOC_ENV",
            "connect_phase: VIP sequencers and virtual interfaces connected successfully.", UVM_LOW)
    endfunction

endclass : soc_env

`endif // SOC_ENV_SV
