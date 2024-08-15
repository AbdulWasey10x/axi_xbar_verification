
// Classname: cdn_axi

// ****************************************************************************
// Class : axi4UvmUserConfig
// Desc. : This class can be created by newPureview or manually by customer
// ****************************************************************************
`define TRUE 1
`define FALSE 0

class axi4UvmUserConfig extends cdnAxiUvmConfig;
    
  `uvm_object_utils_begin(axi4UvmUserConfig)  
  `uvm_object_utils_end
  
  function new(string name = "axi4UvmUserConfig");
    super.new(name);

    // set feature values
    spec_ver = CDN_AXI_CFG_SPEC_VER_AMBA4;
    spec_subtype = CDN_AXI_CFG_SPEC_SUBTYPE_BASE;
    spec_interface = CDN_AXI_CFG_SPEC_INTERFACE_FULL;  
  endfunction : new    
  
endclass
