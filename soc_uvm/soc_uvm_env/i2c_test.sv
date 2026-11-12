// SPDX-License-Identifier: Apache-2.0
// SoC-Level I2C End-to-End Verification Test
// Performs:
// 1. Bus idle state verification (open-drain pull-ups, SCL=1, SDA=1)
// 2. I2C START and repeated START condition verification
// 3. 7-bit slave address decoding (0x48) and R/W operation verification
// 4. Register write (0x00) with Slave ACK
// 5. 2-byte sensor data read (0x1234) with Master ACK on byte 0 and NACK on byte 1
// 6. STOP condition and bus return to IDLE

`ifndef I2C_TEST_SV
`define I2C_TEST_SV

class i2c_test extends soc_test;

    `uvm_component_utils(i2c_test)

    function new(string name = "i2c_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        string banner;

        phase.raise_objection(this);

        `uvm_info(get_type_name(), "====================================================================", UVM_LOW)
        `uvm_info(get_type_name(), "   STARTING I2C VERIFICATION TEST (Phase 3 End-to-End Verification) ", UVM_LOW)
        `uvm_info(get_type_name(), "====================================================================", UVM_LOW)

        // Wait for reset deassertion
        `uvm_info(get_type_name(), "Waiting for SoC reset deassertion...", UVM_LOW)
        wait (cfg.i2c_vip_vif.rst_n === 1'b1);
        repeat (100) @(posedge cfg.i2c_vip_vif.clk);
        `uvm_info(get_type_name(), "Reset released. CPU and I2C controller active.", UVM_LOW)

        // Wait for at least one complete I2C sensor read transaction (approx. 500 us - 1 ms)
        fork
            begin
                wait (env.i2c_agent.sb.verified_read_data && env.i2c_agent.sb.verified_stop);
                `uvm_info(get_type_name(), "Observed complete I2C sensor read transaction over bus.", UVM_LOW)
            end
            begin
                #10ms;
                `uvm_error(get_type_name(), "Timeout waiting for I2C transaction to complete!")
            end
        join_any
        disable fork;

        // Allow brief post-transaction settle
        repeat (500) @(posedge cfg.i2c_vip_vif.clk);

        // Scoreboard evaluation
        `uvm_info(get_type_name(), "Checking I2C Verification Results...", UVM_LOW)

        if (env.i2c_agent.sb.mismatch_count == 0 &&
            env.i2c_agent.sb.verified_addr &&
            env.i2c_agent.sb.verified_write_reg &&
            env.i2c_agent.sb.verified_repeated &&
            env.i2c_agent.sb.verified_read_data &&
            env.i2c_agent.sb.verified_stop) begin

            banner = $sformatf(
                "\n========================================================================\n [I2C VERIFICATION SIGN-OFF: SUCCESS]\n  Test Name           : i2c_test\n  Target Slave Addr   : 0x48 (Sensor Model)\n  Register Address    : 0x00 (Sensor Raw Data)\n  Repeated START      : Verified\n  16-bit Payload Read : 0x1234 (MSB=0x12, LSB=0x34)\n  Master ACK / NACK   : Verified (Byte0=ACK, Byte1=NACK)\n  STOP Condition      : Clean return to IDLE\n  Scoreboard Matches  : %0d Matches (0 Mismatches)\n  Overall Status      : TEST PASSED\n========================================================================",
                env.i2c_agent.sb.match_count);
            `uvm_info(get_type_name(), banner, UVM_LOW)
        end else begin
            `uvm_error(get_type_name(),
                $sformatf("I2C Verification FAILED: matches=%0d, mismatches=%0d",
                    env.i2c_agent.sb.match_count, env.i2c_agent.sb.mismatch_count))
        end

        #500ns;
        phase.drop_objection(this);
    endtask

endclass : i2c_test

`endif // I2C_TEST_SV
