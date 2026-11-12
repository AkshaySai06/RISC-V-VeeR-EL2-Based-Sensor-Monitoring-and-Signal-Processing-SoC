// SPDX-License-Identifier: Apache-2.0
// I2C VIP Package

`ifndef I2C_VIP_PKG_SV
`define I2C_VIP_PKG_SV

package i2c_vip_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "i2c_vip_item.sv"
    `include "i2c_vip_sequencer.sv"
    `include "i2c_vip_driver.sv"
    `include "i2c_vip_monitor.sv"
    `include "i2c_vip_scoreboard.sv"
    `include "i2c_vip_agent.sv"
    `include "i2c_vip_env.sv"
    `include "i2c_vip_test.sv"

endpackage : i2c_vip_pkg

`endif // I2C_VIP_PKG_SV
