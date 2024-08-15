// ----------------------------------------------------------------------------
// 
// Class : axi4UvmUserVirtualSequencer.sv
//
// ----------------------------------------------------------------------------
class axi4UvmUserVirtualSequencer extends uvm_sequencer;
  
  cdnAxiUvmSequencer masterSeqr;
  cdnAxiUvmSequencer masterSeqr1;
  cdnAxiUvmSequencer slaveSeqr;
  cdnAxiUvmSequencer slaveSeqr1;
  
  axi4UvmUserEnv pEnv;
  
  `uvm_component_utils_begin(axi4UvmUserVirtualSequencer)
    `uvm_field_object(masterSeqr, UVM_ALL_ON)
    `uvm_field_object(masterSeqr1, UVM_ALL_ON)
    `uvm_field_object(slaveSeqr, UVM_ALL_ON)
    `uvm_field_object(slaveSeqr1, UVM_ALL_ON)
    `uvm_field_object(pEnv, UVM_ALL_ON)
  `uvm_component_utils_end
   
  function new(string name = "axi4UvmUserVirtualSequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass 
