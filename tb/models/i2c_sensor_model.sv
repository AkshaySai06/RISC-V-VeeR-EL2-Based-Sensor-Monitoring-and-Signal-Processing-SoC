// SPDX-License-Identifier: Apache-2.0
// Behavioural I2C Sensor Model (Address 0x48) per Assumption A1 & Section 14.2 of Spec v2.0
// Returns a programmable 16-bit signed value across two consecutive register bytes (MSB first at reg 0x00)

`timescale 1ns/1ps

module i2c_sensor_model #(
    parameter logic [6:0] I2C_ADDR = 7'h48
)(
    input  wire scl,
    inout  wire sda
);

    logic sda_out;
    assign sda = sda_out ? 1'bz : 1'b0;

    initial sda_out = 1; // Release bus

    // Mode: 0 = Constant, 1 = Clean ramp, 2 = Noisy ramp, 3 = Step
    int unsigned mode = 0;
    logic [15:0] sensor_value = 16'h1234;
    logic [15:0] ramp_base    = 16'h1000;
    int          step_threshold = 20;
    int          sample_count   = 0;

    logic [7:0] reg_addr;
    logic [7:0] shift_in;
    logic [7:0] shift_out;

    typedef enum logic [3:0] {
        IDLE,
        ADDR_PHASE,
        ACK_ADDR,
        REG_PHASE,
        ACK_REG,
        DATA_TX_MSB,
        ACK_MSB,
        DATA_TX_LSB,
        ACK_LSB
    } sensor_state_t;

    sensor_state_t state = IDLE;

    // Detect START and STOP conditions
    always @(negedge sda) begin
        if (scl) begin
            state   <= ADDR_PHASE;
            sda_out <= 1;
        end
    end

    always @(posedge sda) begin
        if (scl) begin
            state   <= IDLE;
            sda_out <= 1;
        end
    end

    // Value generation task
    function automatic [15:0] get_current_sensor_val();
        logic signed [15:0] noise;
        case (mode)
            0: return sensor_value; // Constant (e.g. 0x1234)
            1: begin // Clean ramp
                return ramp_base + (sample_count * 50);
            end
            2: begin // Ramp + Noise
                noise = $urandom_range(0, 100) - 50;
                return ramp_base + (sample_count * 50) + noise;
            end
            3: begin // Step response
                return (sample_count >= step_threshold) ? 16'd20000 : 16'd5000;
            end
            default: return sensor_value;
        endcase
    endfunction

    // I2C Bit Processing
    int bit_idx = 7;
    logic is_read = 0;

    always @(posedge scl) begin
        case (state)
            ADDR_PHASE: begin
                shift_in[bit_idx] = sda;
                if (bit_idx == 0) begin
                    bit_idx = 7;
                    if (shift_in[7:1] == I2C_ADDR) begin
                        is_read = shift_in[0];
                        state   = ACK_ADDR;
                    end else begin
                        state = IDLE;
                    end
                end else begin
                    bit_idx = bit_idx - 1;
                end
            end

            ACK_ADDR: begin
                if (is_read) begin
                    sensor_value = get_current_sensor_val();
                    shift_out    = sensor_value[15:8]; // MSB
                    bit_idx      = 7;
                    state        = DATA_TX_MSB;
                end else begin
                    bit_idx = 7;
                    state   = REG_PHASE;
                end
            end

            REG_PHASE: begin
                shift_in[bit_idx] = sda;
                if (bit_idx == 0) begin
                    bit_idx  = 7;
                    reg_addr = shift_in;
                    state    = ACK_REG;
                end else begin
                    bit_idx = bit_idx - 1;
                end
            end

            ACK_REG: begin
                state = IDLE; // Wait for repeated start or next op
            end

            DATA_TX_MSB: begin
                if (bit_idx == 0) begin
                    bit_idx = 7;
                    state   = ACK_MSB;
                end else begin
                    bit_idx = bit_idx - 1;
                end
            end

            ACK_MSB: begin
                // Master ACK sampled on 9th clock
                shift_out = sensor_value[7:0]; // LSB
                bit_idx   = 7;
                state     = DATA_TX_LSB;
            end

            DATA_TX_LSB: begin
                if (bit_idx == 0) begin
                    bit_idx = 7;
                    state   = ACK_LSB;
                end else begin
                    bit_idx = bit_idx - 1;
                end
            end

            ACK_LSB: begin
                sample_count = sample_count + 1;
                state = IDLE;
            end

            default: ;
        endcase
    end

    // Drive SDA on falling edge of SCL
    always @(negedge scl) begin
        case (state)
            ACK_ADDR: begin
                sda_out <= 0; // Send ACK
            end

            ACK_REG: begin
                sda_out <= 0; // Send ACK
            end

            DATA_TX_MSB: begin
                sda_out <= shift_out[bit_idx];
            end

            ACK_MSB: begin
                sda_out <= 1; // Release for master ACK
            end

            DATA_TX_LSB: begin
                sda_out <= shift_out[bit_idx];
            end

            ACK_LSB: begin
                sda_out <= 1; // Release for master ACK
            end

            default: begin
                sda_out <= 1; // Float
            end
        endcase
    end

endmodule

