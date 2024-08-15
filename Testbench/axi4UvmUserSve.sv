
class axi4UvmUserSve extends uvm_env;

  axi4UvmUserEnv axiEnv0;
  axi4UvmUserVirtualSequencer vs;
      
  `uvm_component_utils(axi4UvmUserSve)
        
  function new(string name = "axi4UvmUserSve", uvm_component parent);
    super.new(name,parent);
  endfunction // new
   
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);  
    axiEnv0 = axi4UvmUserEnv::type_id::create("axiEnv0", this);
    vs = axi4UvmUserVirtualSequencer::type_id::create("vs", this);    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    $cast(vs.slaveSeqr, axiEnv0.activeSlave.sequencer);
    $cast(vs.masterSeqr, axiEnv0.activeMaster.sequencer);
    $cast(vs.masterSeqr1, axiEnv0.activeMaster1.sequencer);
    $cast(vs.slaveSeqr1, axiEnv0.activeSlave1.sequencer);
    $cast(vs.pEnv, axiEnv0);
  endfunction 
           
endclass : axi4UvmUserSve