// SPDX-License-Identifier: Apache-2.0
// I2C VIP Agent
// Encapsulates I2C monitor, scoreboard, and optional sequencer/driver.

`ifndef I2C_VIP_AGENT_SV
`define I2C_VIP_AGENT_SV

class i2c_vip_agent extends uvm_agent;

    i2c_vip_driver     drv;
    i2c_vip_monitor    mon;
    i2c_vip_sequencer  seqr;
    i2c_vip_scoreboard sb;

    `uvm_component_utils(i2c_vip_agent)

    function new(string name = "i2c_vip_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mon = i2c_vip_monitor::type_id::create("mon", this);
        sb  = i2c_vip_scoreboard::type_id::create("sb", this);

        if (get_is_active() == UVM_ACTIVE) begin
            drv  = i2c_vip_driver::type_id::create("drv", this);
            seqr = i2c_vip_sequencer::type_id::create("seqr", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end

        mon.ap.connect(sb.mon_export);
    endfunction

endclass : i2c_vip_agent

`endif // I2C_VIP_AGENT_SV
