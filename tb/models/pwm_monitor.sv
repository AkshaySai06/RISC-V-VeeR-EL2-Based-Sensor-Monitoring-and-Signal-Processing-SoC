// SPDX-License-Identifier: Apache-2.0
// PWM Duty Cycle Monitor per Section 14.2 of SoC Specification v2.0

`timescale 1ns/1ps

module pwm_monitor (
    input logic clk,
    input logic rst_n,
    input logic pwm_in
);

    time high_time;
    time period_time;
    time t_rise, t_fall;
    real duty_pct;

    initial begin
        high_time   = 0;
        period_time = 0;
        duty_pct    = 0.0;
    end

    always @(posedge pwm_in) begin
        if (t_rise > 0) begin
            period_time = $time - t_rise;
            if (period_time > 0) begin
                duty_pct = (real'(high_time) / real'(period_time)) * 100.0;
            end
        end
        t_rise = $time;
    end

    always @(negedge pwm_in) begin
        t_fall = $time;
        if (t_rise > 0) begin
            high_time = t_fall - t_rise;
        end
    end

endmodule

