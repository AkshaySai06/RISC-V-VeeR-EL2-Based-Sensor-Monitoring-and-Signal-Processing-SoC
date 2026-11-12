module tb_top;
import uvm_pkg::*; import fir_vip_pkg::*;
fir_vip_if vif();
initial run_test("fir_vip_test");
endmodule
