
// ****************************************************************************
// Class : axi4UvmUserEnv
// Desc. : This Demo env instantiates: active slave (mimicking DUT)
//         PassiveSlave (to shadow DUT) and a activeMaster (to drive DUT), 
// **************************************************************************** 
class axi4UvmUserEnv extends uvm_env;

  // ***************************************************************
  // The environment instantiates Master and Slave components
  // ***************************************************************
  axi4UvmUserActiveMasterAgent activeMaster;
  axi4UvmUserActiveSlaveAgent activeSlave;
  axi4UvmUserActiveMasterAgent activeMaster1;
  axi4UvmUserActiveSlaveAgent activeSlave1;
//  axi4UvmUserPassiveAgent passiveSlave;
//  axi4UvmUserPassiveAgent passiveMaster;



  `uvm_component_utils_begin(axi4UvmUserEnv)          
  `uvm_component_utils_end

  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "axi4UvmUserEnv", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new 

  // ***************************************************************
  // Desc.  : Build all of the components of the environment.  The
  //          environment consists one active slave (mimicking DUT)
  //          one PassiveSlave (to shadow DUT) and one activeMaster 
  //          (to drive DUT),
  // ***************************************************************
  virtual function void build_phase(uvm_phase phase);    
    super.build_phase(phase);

    // Active Master
    activeMaster = axi4UvmUserActiveMasterAgent::type_id::create("activeMaster", this);
    begin
      axi4UvmUserConfig activeMasterCfg = axi4UvmUserConfig::type_id::create("activeMasterCfg",this);
      activeMasterCfg.is_active = UVM_ACTIVE;
      activeMasterCfg.PortType = CDN_AXI_CFG_MASTER;
      activeMasterCfg.reset_signals_sim_start = 1;
      activeMasterCfg.verbosity = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW;
//      activeMasterCfg.addToMemorySegments(32'h0,32'h3000,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
            
      activeMasterCfg.addToMemorySegments(64'h0,64'hFFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
      activeMasterCfg.addToMemorySegments(64'h10000,64'h5FFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
      activeMasterCfg.no_changes_in_address_channels_limit = 100;
      activeMasterCfg.max_write_bursts_behavior = CDN_AXI_CFG_MAX_WRITE_BURSTS_BEHAVIOR_CONTINUE_TO_SEND;
      activeMasterCfg.write_issuing_capability = 7;
      //activeMasterCfg.       
      uvm_config_object::set(this,"activeMaster","cfg",activeMasterCfg); 
       
    end

    // Active Slave
    activeSlave = axi4UvmUserActiveSlaveAgent::type_id::create("activeSlave", this);
    begin
      axi4UvmUserConfig activeSlaveCfg = axi4UvmUserConfig::type_id::create("activeSlaveCfg",this);
      activeSlaveCfg.is_active = UVM_ACTIVE;
      activeSlaveCfg.PortType = CDN_AXI_CFG_SLAVE;
      activeSlaveCfg.reset_signals_sim_start = 1;
     // activeSlaveCfg.addToMemorySegments(32'h0,32'h1000,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
      //activeSlaveCfg.addToMemorySegments(32'h2000,32'h3000,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
      
      activeSlaveCfg.addToMemorySegments(64'h0,64'hFFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
      activeSlaveCfg.addToMemorySegments(64'h10000,64'h5FFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
        
          
      activeSlaveCfg.do_signal_check_only_when_valid = 1;
      activeSlaveCfg.no_changes_in_address_channels_limit = 100;     
      activeSlaveCfg.write_acceptance_capability = 6;
      activeSlaveCfg.disable_memory_update_on_write_burst = 0;
//      activeSlaveCfg.
//      activeSlaveCfg.
//      activeSlaveCfg.
      uvm_config_object::set(this,"activeSlave","cfg",activeSlaveCfg); 
    end

    // Passive Slave
//    passiveSlave = axi4UvmUserPassiveAgent::type_id::create("passiveSlave", this);    
//    begin
//      axi4UvmUserConfig passiveSlaveCfg = axi4UvmUserConfig::type_id::create("passiveSlaveCfg");
//      passiveSlaveCfg.is_active = UVM_PASSIVE;
//      passiveSlaveCfg.PortType = CDN_AXI_CFG_SLAVE;
//      passiveSlaveCfg.verbosity = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW;
//      //passiveSlaveCfg.addToMemorySegments(32'h0,32'h1000,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
//      //passiveSlaveCfg.addToMemorySegments(32'h2000,32'h3000,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
//      
//      passiveSlaveCfg.addToMemorySegments(64'h0,64'hFFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
//      passiveSlaveCfg.addToMemorySegments(64'h10000,64'h5FFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
//      
//      passiveSlaveCfg.do_signal_check_only_when_valid = 1;
//      passiveSlaveCfg.no_changes_in_address_channels_limit = 100;     
//      passiveSlaveCfg.max_write_bursts_behavior = CDN_AXI_CFG_MAX_WRITE_BURSTS_BEHAVIOR_CONTINUE_TO_SEND;
//      passiveSlaveCfg.write_acceptance_capability = 6;
//      passiveSlaveCfg.disable_memory_update_on_write_burst = 0;
//      passiveSlaveCfg.
//      passiveSlaveCfg.
//      passiveSlaveCfg.
//      uvm_config_object::set(this,"passiveSlave","cfg",passiveSlaveCfg); 
//    end
    
    // Passive Master
//    passiveMaster = axi4UvmUserPassiveAgent::type_id::create("passiveMaster", this);    
//    begin
//      axi4UvmUserConfig passiveMasterCfg = axi4UvmUserConfig::type_id::create("passiveMasterCfg");
//      passiveMasterCfg.is_active = UVM_PASSIVE;
//      passiveMasterCfg.PortType = CDN_AXI_CFG_MASTER;
//      passiveMasterCfg.verbosity = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW;
//      
//      //passiveMasterCfg.addToMemorySegments(32'h0,32'h3000,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
//      
//      passiveMasterCfg.addToMemorySegments(64'h0,64'hFFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
//      passiveMasterCfg.addToMemorySegments(64'h10000,64'h5FFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
//      passiveMasterCfg.no_changes_in_address_channels_limit = 100;
//      passiveMasterCfg.max_write_bursts_behavior = CDN_AXI_CFG_MAX_WRITE_BURSTS_BEHAVIOR_CONTINUE_TO_SEND;
//      passiveMasterCfg.write_issuing_capability = 7;
//      //passiveMasterCfg.
//      
//      uvm_config_object::set(this,"passiveMaster","cfg",passiveMasterCfg);       
//    end
     
       // Active Master 1
    activeMaster1 = axi4UvmUserActiveMasterAgent::type_id::create("activeMaster1", this);
    begin
      axi4UvmUserConfig activeMasterCfg1 = axi4UvmUserConfig::type_id::create("activeMasterCfg1",this);
      activeMasterCfg1.is_active = UVM_ACTIVE;
      activeMasterCfg1.PortType = CDN_AXI_CFG_MASTER;
      activeMasterCfg1.reset_signals_sim_start = 1;
      activeMasterCfg1.verbosity = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW;
//      activeMasterCfg.addToMemorySegments(32'h0,32'h3000,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
            
      activeMasterCfg1.addToMemorySegments(64'h0,64'hFFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
      activeMasterCfg1.addToMemorySegments(64'h10000,64'h5FFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
      activeMasterCfg1.no_changes_in_address_channels_limit = 100;
      activeMasterCfg1.max_write_bursts_behavior = CDN_AXI_CFG_MAX_WRITE_BURSTS_BEHAVIOR_CONTINUE_TO_SEND;
      activeMasterCfg1.write_issuing_capability = 7;
      //activeMasterCfg.       
      uvm_config_object::set(this,"activeMaster1","cfg",activeMasterCfg1); 
       
    end
    
      
    // Active Slave 1
    activeSlave1 = axi4UvmUserActiveSlaveAgent::type_id::create("activeSlave1", this);
    begin
      axi4UvmUserConfig activeSlaveCfg1 = axi4UvmUserConfig::type_id::create("activeSlaveCfg1",this);
      activeSlaveCfg1.is_active = UVM_ACTIVE;
      activeSlaveCfg1.PortType = CDN_AXI_CFG_SLAVE;
      activeSlaveCfg1.reset_signals_sim_start = 1;
     // activeSlaveCfg.addToMemorySegments(32'h0,32'h1000,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
      //activeSlaveCfg.addToMemorySegments(32'h2000,32'h3000,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
      
      activeSlaveCfg1.addToMemorySegments(64'h0,64'hFFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
      activeSlaveCfg1.addToMemorySegments(64'h10000,64'h5FFFF,CDN_AXI_CFG_DOMAIN_NON_SHAREABLE);
        
          
      activeSlaveCfg1.do_signal_check_only_when_valid = 1;
      activeSlaveCfg1.no_changes_in_address_channels_limit = 100;     
      activeSlaveCfg1.write_acceptance_capability = 6;
      activeSlaveCfg1.disable_memory_update_on_write_burst = 0;
//      activeSlaveCfg.
//      activeSlaveCfg.
//      activeSlaveCfg.
      uvm_config_object::set(this,"activeSlave1","cfg",activeSlaveCfg1); 
    end

  endfunction : build_phase
  
  virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      activeMaster.cfg.write_issuing_capability = 5;
      activeMaster.reconfigure(activeMaster.cfg); 
      activeMaster1.cfg.write_issuing_capability = 5;
      activeMaster1.reconfigure(activeMaster1.cfg); 
  endtask
  
  
  function void end_of_elaboration_phase(uvm_phase phase);

    super.end_of_elaboration_phase(phase);
	
    `uvm_info(get_type_name(), "Setting callbacks", UVM_LOW);
  
      // Enable PureSpec callbacks. Uncomment as necessary
    // Refer to the User Guide for callbacks description

    // Active Master
    void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_Error));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_ResetStarted));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_ResetEnded));
    void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSend));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendAddress));
    void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendResponse));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendTransfer));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_Started));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedAddress));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedResponse));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedTransfer));
    void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_Ended));
    void'(activeMaster.inst.updateErrorControl(CDN_AXI_FATAL_ERROR_INSUFFICIENT_NUMBER_OF_PASSIVE_AGENTS_IN_ENV,DENALI_CDN_AXI_ERR_CONFIG_SEVERITY_Silent));
    // activeMaster.inst.updateErrorControl(CDN_AXI_FATAL_ERROR_INSUFFICIENT_NUMBER_OF_PASSIVE_AGENTS_IN_ENV,DENALI_CDN_AXI_ERR_CONFIG_SEVERITY_Silent);
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedAddress));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedResponse));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedTransfer));
    
    // Passive Master
//    void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_Error));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_ResetStarted));
//    void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_ResetEnded));
//    void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_Started));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedAddress));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedResponse));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedTransfer));
//    void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_Ended));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedAddress));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedResponse));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedTransfer));
    
    // Active Slave
    void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_Error));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_ResetStarted));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_ResetEnded));
    void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSend));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendAddress));
    void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendResponse));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendTransfer));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_Started));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_StartedAddress));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_StartedResponse));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_StartedTransfer));
    void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_Ended));
    void'(activeSlave.inst.updateErrorControl(CDN_AXI_FATAL_ERROR_INSUFFICIENT_NUMBER_OF_PASSIVE_AGENTS_IN_ENV,DENALI_CDN_AXI_ERR_CONFIG_SEVERITY_Silent));
    // activeSlave.inst.updateErrorControl(CDN_AXI_FATAL_ERROR_INSUFFICIENT_NUMBER_OF_PASSIVE_AGENTS_IN_ENV,DENALI_CDN_AXI_ERR_CONFIG_SEVERITY_Silent);
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_EndedAddress));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_EndedResponse));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_EndedTransfer));
    
    //for master 1
    void'(activeMaster1.inst.setCallback( DENALI_CDN_AXI_CB_Error));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_ResetStarted));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_ResetEnded));
    void'(activeMaster1.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSend));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendAddress));
    void'(activeMaster1.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendResponse));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendTransfer));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_Started));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedAddress));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedResponse));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedTransfer));
    void'(activeMaster1.inst.setCallback( DENALI_CDN_AXI_CB_Ended));
    void'(activeMaster1.inst.updateErrorControl(CDN_AXI_FATAL_ERROR_INSUFFICIENT_NUMBER_OF_PASSIVE_AGENTS_IN_ENV,DENALI_CDN_AXI_ERR_CONFIG_SEVERITY_Silent));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedAddress));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedResponse));
    //void'(activeMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedTransfer));
    
    // Passive Master
//    void'(passiveMaster1.inst.setCallback( DENALI_CDN_AXI_CB_Error));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_ResetStarted));
//    void'(passiveMaster1.inst.setCallback( DENALI_CDN_AXI_CB_ResetEnded));
//    void'(passiveMaster1.inst.setCallback( DENALI_CDN_AXI_CB_Started));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedAddress));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedResponse));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_StartedTransfer));
//    void'(passiveMaster1.inst.setCallback( DENALI_CDN_AXI_CB_Ended));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedAddress));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedResponse));
    //void'(passiveMaster.inst.setCallback( DENALI_CDN_AXI_CB_EndedTransfer));
    
    // Active Slave
   void'(activeSlave1.inst.setCallback( DENALI_CDN_AXI_CB_Error));
  //   //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_ResetStarted));
  //   //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_ResetEnded));
   void'(activeSlave1.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSend));
  //   //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendAddress));
   void'(activeSlave1.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendResponse));
  //   //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_BeforeSendTransfer));
  //   //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_Started));
  //   //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_StartedAddress));
  //   //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_StartedResponse));
  //   //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_StartedTransfer));
   void'(activeSlave1.inst.setCallback( DENALI_CDN_AXI_CB_Ended));
   void'(activeSlave1.inst.updateErrorControl(CDN_AXI_FATAL_ERROR_INSUFFICIENT_NUMBER_OF_PASSIVE_AGENTS_IN_ENV,DENALI_CDN_AXI_ERR_CONFIG_SEVERITY_Silent));
  //  activeSlave1.inst.updateErrorControl(CDN_AXI_FATAL_ERROR_INSUFFICIENT_NUMBER_OF_PASSIVE_AGENTS_IN_ENV,DENALI_CDN_AXI_ERR_CONFIG_SEVERITY_Silent);
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_EndedAddress));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_EndedResponse));
    //void'(activeSlave.inst.setCallback( DENALI_CDN_AXI_CB_EndedTransfer));

    `uvm_info(get_type_name(), "Setting callbacks ... DONE", UVM_LOW);
    
  endfunction : end_of_elaboration_phase
  
endclass : axi4UvmUserEnv