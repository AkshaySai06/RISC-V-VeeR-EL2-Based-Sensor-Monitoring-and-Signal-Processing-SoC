// SPDX-License-Identifier: Apache-2.0
// I2C VIP Sequence Item
// Represents observed I2C bus transactions: START, address, R/W direction, data bytes, ACK/NACK, and STOP.

`ifndef I2C_VIP_ITEM_SV
`define I2C_VIP_ITEM_SV

typedef enum bit {
    I2C_WRITE = 1'b0,
    I2C_READ  = 1'b1
} i2c_op_e;

class i2c_vip_item extends uvm_sequence_item;

    bit [6:0]      addr;             // 7-bit slave address
    i2c_op_e       op;               // Operation: READ or WRITE
    bit [7:0]      data_bytes[$];    // Transferred data bytes
    bit            ack_bits[$];      // ACK/NACK status for each byte (0=ACK, 1=NACK)
    bit            start_detected;   // START condition observed
    bit            repeated_start;   // Repeated START condition observed
    bit            stop_detected;    // STOP condition observed
    time           timestamp;

    `uvm_object_utils_begin(i2c_vip_item)
        `uvm_field_int(addr,            UVM_ALL_ON | UVM_HEX)
        `uvm_field_enum(i2c_op_e, op,   UVM_ALL_ON)
        `uvm_field_queue_int(data_bytes, UVM_ALL_ON | UVM_HEX)
        `uvm_field_queue_int(ack_bits,   UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(start_detected,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(repeated_start,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(stop_detected,   UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(timestamp,       UVM_ALL_ON | UVM_TIME)
    `uvm_object_utils_end

    function new(string name = "i2c_vip_item");
        super.new(name);
        addr           = 7'h00;
        op             = I2C_WRITE;
        start_detected = 0;
        repeated_start = 0;
        stop_detected  = 0;
        timestamp      = 0;
    endfunction

    virtual function string convert2string();
        string s;
        s = $sformatf("Addr=0x%02x Op=%s Start=%0b RepStart=%0b Stop=%0b Bytes=[",
            addr, (op == I2C_READ ? "READ" : "WRITE"), start_detected, repeated_start, stop_detected);
        foreach (data_bytes[i]) begin
            s = {s, $sformatf(" 0x%02x(ack=%0b)", data_bytes[i], ack_bits[i])};
        end
        s = {s, " ]"};
        return s;
    endfunction

endclass : i2c_vip_item

`endif // I2C_VIP_ITEM_SV
