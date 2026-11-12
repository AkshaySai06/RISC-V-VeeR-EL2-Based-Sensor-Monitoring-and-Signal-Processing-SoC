module tb_top;
import uvm_pkg::*; import i2c_vip_pkg::*;
i2c_vip_if vif();
initial run_test("i2c_vip_test");
endmodule
