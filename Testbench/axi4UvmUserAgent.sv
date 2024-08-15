
// ****************************************************************************
// Class : axi4UvmUserAgent
// Desc. : This class is used as a basis for the Agents.
//         in cdn_axi VIP the mapped address segments are initially empty,
//         this agent type defines the entire 32bit address range as valid. 
// ****************************************************************************
class axi4UvmUserAgent extends cdnAxiUvmAgent;
  
  `uvm_component_utils_begin(axi4UvmUserAgent)        
  `uvm_component_utils_end

	
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "axi4UvmUserAgent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      
  
  
  virtual function integer memoryRead8Bytes(reg [63:0] addr, ref reg [7:0] data []);
    void'(inst.memoryRead8Bytes(addr,data));
  endfunction
  
  virtual function integer memoryWrite8Bytes(reg [63:0] addr, reg [7:0] data []);
    void'(inst.memoryWrite8Bytes(addr,data));
  endfunction

endclass : axi4UvmUserAgent

class axi4UvmUserActiveMasterAgent extends axi4UvmUserAgent;
  
  `uvm_component_utils_begin(axi4UvmUserActiveMasterAgent)        
  `uvm_component_utils_end
   
  `cdnAxiDeclareVif(virtual interface cdnAxi4ActiveMasterInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))

  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "axi4UvmUserActiveMasterAgent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

endclass : axi4UvmUserActiveMasterAgent

class axi4UvmUserActiveSlaveAgent extends axi4UvmUserAgent;
  
  `uvm_component_utils_begin(axi4UvmUserActiveSlaveAgent)        
  `uvm_component_utils_end

  `cdnAxiDeclareVif(virtual interface cdnAxi4ActiveSlaveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))

  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "axi4UvmUserActiveSlaveAgent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

endclass : axi4UvmUserActiveSlaveAgent

class axi4UvmUserPassiveAgent extends axi4UvmUserAgent;
  
  `uvm_component_utils_begin(axi4UvmUserPassiveAgent)        
  `uvm_component_utils_end

  `cdnAxiDeclareVif(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))

  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "axi4UvmUserPassiveAgent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

endclass : axi4UvmUserPassiveAgent
