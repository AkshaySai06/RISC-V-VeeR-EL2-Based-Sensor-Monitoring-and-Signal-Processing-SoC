module tb_top;
import uvm_pkg::*; import pwm_vip_pkg::*;
pwm_vip_if vif();
initial run_test("pwm_vip_test");
endmodule
