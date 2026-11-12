// SPDX-License-Identifier: Apache-2.0
// VCS Filelist for Unit Testbenches

+libext+.v+.sv

+incdir+../rtl/bus
+incdir+../rtl/mem
+incdir+../rtl/ip
+incdir+../tb/models

// SoC Bus & Memory RTL
../rtl/bus/axi4lite_assertions.sv
../rtl/bus/axi4lite_decoder.sv
../rtl/bus/axi4lite_err_slave.sv
../rtl/bus/axi4lite_regif.sv
../rtl/bus/axi4lite_interconnect.sv
../rtl/bus/axi4_to_axi4lite.sv
../rtl/bus/axi4_to_axi4lite_ro.sv
../rtl/mem/axi4lite_sram.sv
../rtl/mem/axi4lite_sram_dp.sv

// SoC IPs
../rtl/ip/uart.sv
../rtl/ip/timer.sv
../rtl/ip/gpio.sv
../rtl/ip/i2c_ctrl.sv
../rtl/ip/fir_filter.sv
../rtl/ip/pwm_gen.sv

// Models
../tb/models/axi4lite_master_bfm.sv
../tb/models/axi4lite_slave_bfm.sv
../tb/models/i2c_sensor_model.sv
../tb/models/uart_monitor.sv
../tb/models/pwm_monitor.sv

