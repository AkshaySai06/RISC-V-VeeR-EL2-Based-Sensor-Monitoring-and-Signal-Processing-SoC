// SPDX-License-Identifier: Apache-2.0
// I2C VIP Monitor
// Observes open-drain SCL and SDA lines, decoding START/STOP conditions,
// 7-bit addressing, R/W direction, data bytes, and ACK/NACK responses.

`ifndef I2C_VIP_MONITOR_SV
`define I2C_VIP_MONITOR_SV

class i2c_vip_monitor extends uvm_monitor;

    virtual i2c_vip_if vif;
    uvm_analysis_port #(i2c_vip_item) ap;

    `uvm_component_utils(i2c_vip_monitor)

    function new(string name = "i2c_vip_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        i2c_vip_item cur_item = null;
        logic [7:0]  shift_reg;
        int          bit_count;
        bit          in_transaction = 0;
        bit          is_addr_byte   = 0;

        if (vif == null) begin
            `uvm_fatal("I2C_MON", "vif handle is null in i2c_vip_monitor!")
            return;
        end

        // Wait for reset release
        wait (vif.rst_n === 1'b1);
        @(posedge vif.clk);

        `uvm_info(get_type_name(), "I2C VIP Monitor active.", UVM_LOW)

        fork
            // Process 1: START and STOP condition detection
            forever begin
                @(vif.sda_i);
                #10ps; // Settle delta cycles to prevent false START/STOP on SCL/SDA edges
                if (vif.scl_i === 1'b1) begin
                    if (vif.sda_i === 1'b0) begin
                        // START or REPEATED START
                        $display("[I2C_MON_DEBUG] @%0t: START/REP_START condition. in_tx=%0d", $time, in_transaction);
                        if (in_transaction && cur_item != null) begin
                            // Publish previous transaction segment before repeated start
                            cur_item.repeated_start = 1;
                            cur_item.timestamp      = $time;
                            ap.write(cur_item);
                            `uvm_info(get_type_name(),
                                $sformatf("Repeated START observed: %s", cur_item.convert2string()),
                                UVM_LOW)
                        end else begin
                            `uvm_info(get_type_name(), "START condition observed on I2C bus", UVM_LOW)
                        end

                        cur_item = i2c_vip_item::type_id::create("i2c_item");
                        cur_item.start_detected = 1;
                        cur_item.timestamp      = $time;
                        in_transaction          = 1;
                        is_addr_byte            = 1;
                        bit_count               = 0;
                        shift_reg               = 8'h00;
                    end else if (vif.sda_i === 1'b1 && in_transaction) begin
                        // STOP condition
                        if (cur_item != null) begin
                            cur_item.stop_detected = 1;
                            cur_item.timestamp     = $time;
                            ap.write(cur_item);
                            `uvm_info(get_type_name(),
                                $sformatf("STOP condition observed: %s", cur_item.convert2string()),
                                UVM_LOW)
                            cur_item = null;
                        end
                        in_transaction = 0;
                    end
                end
            end

            // Process 2: SCL Clock Edge Bit Sampling
            forever begin
                @(posedge vif.scl_i);
                #10ps;
                if (in_transaction && cur_item != null) begin
                    if (bit_count < 8) begin
                        // Data/Address bit (MSB first)
                        shift_reg[7 - bit_count] = vif.sda_i;
                        bit_count++;
                    end else begin
                        // 9th clock: ACK / NACK bit (0=ACK, 1=NACK)
                        bit ack_val = vif.sda_i;

                        if (is_addr_byte) begin
                            cur_item.addr = shift_reg[7:1];
                            cur_item.op   = (shift_reg[0] ? I2C_READ : I2C_WRITE);
                            is_addr_byte  = 0;
                            $display("[I2C_MON_DEBUG] @%0t: Addr Byte sampled: shift_reg=0x%02x -> Addr=0x%02x Op=%s ACK=%0b",
                                $time, shift_reg, cur_item.addr, (cur_item.op == I2C_READ ? "READ" : "WRITE"), ack_val);
                            `uvm_info(get_type_name(),
                                $sformatf("I2C Address Byte: Addr=0x%02x Op=%s ACK=%0b",
                                    cur_item.addr, (cur_item.op == I2C_READ ? "READ" : "WRITE"), ack_val),
                                UVM_LOW)
                        end else begin
                            cur_item.data_bytes.push_back(shift_reg);
                            cur_item.ack_bits.push_back(ack_val);
                            $display("[I2C_MON_DEBUG] @%0t: Data Byte sampled: 0x%02x ACK=%0b",
                                $time, shift_reg, ack_val);
                            `uvm_info(get_type_name(),
                                $sformatf("I2C Data Byte: 0x%02x (ACK=%0b)", shift_reg, ack_val),
                                UVM_LOW)
                        end

                        bit_count = 0;
                        shift_reg = 8'h00;
                    end
                end
            end
        join
    endtask

endclass : i2c_vip_monitor

`endif // I2C_VIP_MONITOR_SV
