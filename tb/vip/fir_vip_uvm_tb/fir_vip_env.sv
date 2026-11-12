class fir_vip_env extends uvm_env;
fir_vip_agent agent; fir_vip_scoreboard sb;
`uvm_component_utils(fir_vip_env)
function new(string n,uvm_component p);super.new(n,p);endfunction
function void build_phase(uvm_phase phase); agent=fir_vip_agent::type_id::create("agent",this); sb=fir_vip_scoreboard::type_id::create("sb",this); endfunction
endclass
