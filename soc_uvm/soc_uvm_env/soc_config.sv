// SPDX-License-Identifier: Apache-2.0
// SoC-Level UVM Configuration Object
// Holds virtual interface handles for all six peripherals.
// Distributed to agents via uvm_config_db.

`ifndef SOC_CONFIG_SV
`define SOC_CONFIG_SV

class soc_config extends uvm_object;

    `uvm_object_utils(soc_config)

    // -------------------------------------------------------------------------
    // SoC-level Virtual Interface Handles — one per peripheral
    // -------------------------------------------------------------------------
    virtual uart_if   uart_vif;
    virtual gpio_if   gpio_vif;
    virtual i2c_if    i2c_vif;
    virtual timer_if  timer_vif;
    virtual fir_if    fir_vif;
    virtual pwm_if    pwm_vif;

    // -------------------------------------------------------------------------
    // VIP-level Virtual Interface Handles
    // -------------------------------------------------------------------------
    virtual uart_vip_if   uart_vip_vif;
    virtual gpio_vip_if   gpio_vip_vif;
    virtual i2c_vip_if    i2c_vip_vif;
    virtual timer_vip_if  timer_vip_vif;
    virtual fir_vip_if    fir_vip_vif;
    virtual pwm_vip_if    pwm_vip_vif;

    // -------------------------------------------------------------------------
    // Agent Active/Passive Configuration
    // -------------------------------------------------------------------------
    // UART: active — VIP driver injects stimulus on uart_rx
    uvm_active_passive_enum uart_is_active  = UVM_ACTIVE;
    // GPIO: active — VIP driver can drive gpio_in stimulus
    uvm_active_passive_enum gpio_is_active  = UVM_ACTIVE;
    // I2C: passive — CPU firmware owns the I2C master; VIP monitors only
    uvm_active_passive_enum i2c_is_active   = UVM_PASSIVE;
    // Timer: passive — CPU firmware configures timer; VIP monitors only
    uvm_active_passive_enum timer_is_active = UVM_PASSIVE;
    // FIR: passive — CPU firmware writes samples; VIP monitors only
    uvm_active_passive_enum fir_is_active   = UVM_PASSIVE;
    // PWM: passive — CPU firmware configures PWM; VIP monitors output
    uvm_active_passive_enum pwm_is_active   = UVM_PASSIVE;

    // -------------------------------------------------------------------------
    // SoC Clock/Reset parameters (informational)
    // -------------------------------------------------------------------------
    int unsigned clk_period_ns = 20;    // 50 MHz
    int unsigned rst_cycles    = 20;    // Reset assertion duration

    function new(string name = "soc_config");
        super.new(name);
    endfunction

endclass : soc_config

`endif // SOC_CONFIG_SV
