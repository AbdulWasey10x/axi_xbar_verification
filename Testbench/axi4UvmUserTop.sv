
`ifndef _MY_CDN_AXI_TOP
`define _MY_CDN_AXI_TOP

`include "uvm_macros.svh"

// The following code enables this example to support multiple UVM versions, including the new UVM-IEEE.
// If your testbench targets only the new UVM-IEEE, you can skip this, and adapt the example code to use
// only UVM-IEEE constructs.
 
`ifdef UVM_VERSION
  `ifndef UVM_ENABLE_DEPRECATED_API
 
    // enable changes added for UVM 1.2
    `define UVM_POST_VERSION_1_1
 
    // include the sequence macros as a convenience layer
    `include "deprecated/macros/uvm_sequence_defines.svh"
 
  `endif // UVM_ENABLE_DEPRECATED_API
`endif // UVM_VERSION

`include "cdnAxiUvmDefines.sv"

`ifndef CDN_AXI_ADDR_WIDTH
  `define CDN_AXI_ADDR_WIDTH 64
`endif
`ifndef CDN_AXI_DATA_WIDTH
  `define CDN_AXI_DATA_WIDTH 128
`endif


package axi4UvmUser;
  
  import uvm_pkg::*;
  import DenaliSvMem::*;
  import DenaliSvCdn_axi::*;
  import cdnAxiUvm::*;
  
  typedef class axi4UvmUserVirtualSequencer;
      
  
`include "axi4UvmUserConfig.sv"  
`include "axi4UvmUserAgent.sv"
`include "axi4UvmUserSeqLib.sv"
`include "axi4UvmUserEnv.sv"
`include "axi4UvmUserSve.sv"
`include "axi4UvmUserVirtualSequencer.sv"
`include "axi4UvmUserVirtualSeqLib.sv"

endpackage


`endif // _MY_CDN_AXI_TOP
