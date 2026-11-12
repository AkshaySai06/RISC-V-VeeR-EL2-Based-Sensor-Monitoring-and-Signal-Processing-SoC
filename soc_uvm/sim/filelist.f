// SPDX-License-Identifier: Apache-2.0
// VCS Filelist for SoC-Level UVM Verification Environment (tb_soc_uvm_top)

+libext+.v+.sv
+define+RV_BUILD_AXI4
+define+RV_OPENSOURCE

+incdir+../../core_config
+incdir+../../Cores-VeeR-EL2-main/design/include
+incdir+../../Cores-VeeR-EL2-main/design/lib
+incdir+../../rtl/bus
+incdir+../../rtl/mem
+incdir+../../rtl/ip
+incdir+../../tb/vip/uart_vip_uvm_tb
+incdir+../../tb/vip/gpio_vip_uvm_tb
+incdir+../../tb/vip/i2c_vip_uvm_tb
+incdir+../../tb/vip/timer_vip_uvm_tb
+incdir+../../tb/vip/fir_vip_uvm_tb
+incdir+../../tb/vip/pwm_vip_uvm_tb
+incdir+../interfaces
+incdir+../soc_uvm_env
+incdir+../../tb/models

// VeeR EL2 Core RTL
../../Cores-VeeR-EL2-main/design/lib/el2_assert.sv
../../Cores-VeeR-EL2-main/design/el2_mubi_pkg.sv
../../Cores-VeeR-EL2-main/design/include/el2_def.sv
../../Cores-VeeR-EL2-main/design/el2_mem.sv
../../Cores-VeeR-EL2-main/design/el2_pic_ctrl.sv
../../Cores-VeeR-EL2-main/design/el2_veer.sv
../../Cores-VeeR-EL2-main/design/el2_dma_ctrl.sv
../../Cores-VeeR-EL2-main/design/el2_pmp.sv
../../Cores-VeeR-EL2-main/design/ifu/el2_ifu_aln_ctl.sv
../../Cores-VeeR-EL2-main/design/ifu/el2_ifu_compress_ctl.sv
../../Cores-VeeR-EL2-main/design/ifu/el2_ifu_ifc_ctl.sv
../../Cores-VeeR-EL2-main/design/ifu/el2_ifu_bp_ctl.sv
../../Cores-VeeR-EL2-main/design/ifu/el2_ifu_ic_mem.sv
../../Cores-VeeR-EL2-main/design/ifu/el2_ifu_mem_ctl.sv
../../Cores-VeeR-EL2-main/design/ifu/el2_ifu_iccm_mem.sv
../../Cores-VeeR-EL2-main/design/ifu/el2_ifu.sv
../../Cores-VeeR-EL2-main/design/dec/el2_dec_decode_ctl.sv
../../Cores-VeeR-EL2-main/design/dec/el2_dec_gpr_ctl.sv
../../Cores-VeeR-EL2-main/design/dec/el2_dec_ib_ctl.sv
../../Cores-VeeR-EL2-main/design/dec/el2_dec_pmp_ctl.sv
../../Cores-VeeR-EL2-main/design/dec/el2_dec_tlu_ctl.sv
../../Cores-VeeR-EL2-main/design/dec/el2_dec_trigger.sv
../../Cores-VeeR-EL2-main/design/dec/el2_dec.sv
../../Cores-VeeR-EL2-main/design/exu/el2_exu_alu_ctl.sv
../../Cores-VeeR-EL2-main/design/exu/el2_exu_mul_ctl.sv
../../Cores-VeeR-EL2-main/design/exu/el2_exu_div_ctl.sv
../../Cores-VeeR-EL2-main/design/exu/el2_exu.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu_clkdomain.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu_addrcheck.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu_lsc_ctl.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu_stbuf.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu_bus_buffer.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu_bus_intf.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu_ecc.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu_dccm_mem.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu_dccm_ctl.sv
../../Cores-VeeR-EL2-main/design/lsu/el2_lsu_trigger.sv
../../Cores-VeeR-EL2-main/design/dbg/el2_dbg.sv
../../Cores-VeeR-EL2-main/design/dmi/dmi_mux.v
../../Cores-VeeR-EL2-main/design/dmi/dmi_wrapper.v
../../Cores-VeeR-EL2-main/design/dmi/dmi_jtag_to_core_sync.v
../../Cores-VeeR-EL2-main/design/dmi/rvjtag_tap.v
../../Cores-VeeR-EL2-main/design/lib/el2_lib.sv
../../Cores-VeeR-EL2-main/design/lib/el2_mem_if.sv
-v ../../Cores-VeeR-EL2-main/design/lib/beh_lib.sv
-v ../../Cores-VeeR-EL2-main/design/lib/mem_lib.sv
../../Cores-VeeR-EL2-main/design/el2_veer_wrapper.sv

// SoC Bus & Memory RTL
../../rtl/bus/axi4lite_assertions.sv
../../rtl/bus/axi4lite_decoder.sv
../../rtl/bus/axi4lite_err_slave.sv
../../rtl/bus/axi4lite_regif.sv
../../rtl/bus/axi4lite_interconnect.sv
../../rtl/bus/axi4_to_axi4lite.sv
../../rtl/bus/axi4_to_axi4lite_ro.sv
../../rtl/mem/axi4lite_sram.sv
../../rtl/mem/axi4lite_sram_dp.sv

// Six Peripheral RTL Modules & SoC Top
../../rtl/ip/uart.sv
../../rtl/ip/timer.sv
../../rtl/ip/gpio.sv
../../rtl/ip/i2c_ctrl.sv
../../rtl/ip/fir_filter.sv
../../rtl/ip/pwm_gen.sv
../../rtl/soc_top.sv

// Verification Models & Helpers
../../tb/models/i2c_sensor_model.sv
../../tb/models/uart_monitor.sv
../../tb/models/pwm_monitor.sv

// VIP Interfaces (Required by VIP drivers & monitors)
../interfaces/soc_vip_interfaces.sv

// Six Generated VIP Packages
../../tb/vip/uart_vip_uvm_tb/uart_vip_pkg.sv
../../tb/vip/gpio_vip_uvm_tb/gpio_vip_pkg.sv
../../tb/vip/i2c_vip_uvm_tb/i2c_vip_pkg.sv
../../tb/vip/timer_vip_uvm_tb/timer_vip_pkg.sv
../../tb/vip/fir_vip_uvm_tb/fir_vip_pkg.sv
../../tb/vip/pwm_vip_uvm_tb/pwm_vip_pkg.sv

// Six SoC SystemVerilog Interfaces
../interfaces/uart_if.sv
../interfaces/gpio_if.sv
../interfaces/i2c_if.sv
../interfaces/timer_if.sv
../interfaces/fir_if.sv
../interfaces/pwm_if.sv

// Top-Level SoC UVM Testbench
../tb/tb_soc_uvm_top.sv
