class fir_vip_monitor extends uvm_monitor;
virtual fir_vip_if vif;
uvm_analysis_port #(fir_vip_item) ap;
`uvm_component_utils(fir_vip_monitor)
function new(string n,uvm_component p); super.new(n,p); ap=new("ap",this); endfunction
endclass
