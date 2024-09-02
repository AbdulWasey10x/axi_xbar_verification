`timescale 1ps/1ps

`include "uvm_macros.svh"
`include "/home/wasey-10x/4intf_axi_xbar/AXI_Compiled_xbar_working/axi/include/axi/assign.svh"
`include "/home/wasey-10x/4intf_axi_xbar/AXI_Compiled_xbar_working/axi/include/axi/typedef.svh"

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




// Test module
module testbench #( 
  // Number of AXI masters connected to the xbar. (Number of slave ports)
    parameter int unsigned TbNumMasters        = 32'd2,
    /// Number of AXI slaves connected to the xbar. (Number of master ports)
    parameter int unsigned TbNumSlaves         = 32'd2,
    /// Number of write transactions per master.
    parameter int unsigned TbNumWrites         = 32'd200,
    /// Number of read transactions per master.
    parameter int unsigned TbNumReads          = 32'd200,
    /// AXI4+ATOP ID width of the masters connected to the slave ports of the DUT.
    /// The ID width of the slaves is calculated depending on the xbar configuration.
    parameter int unsigned TbAxiIdWidthMasters = 32'd14, 
    /// The used ID width of the DUT.
    /// Has to be `TbAxiIdWidthMasters >= TbAxiIdUsed`.
    parameter int unsigned TbAxiIdUsed         = 32'd3,
    /// Data width of the AXI channels.
    parameter int unsigned TbAxiDataWidth      = 32'd64,
    /// Pipeline stages in the xbar itself (between demux and mux).
    parameter int unsigned TbPipeline          = 32'd1,
    /// Enable ATOP generation
    parameter bit          TbEnAtop            = 1'b1,
    /// Enable exclusive accesses
    parameter bit TbEnExcl                     = 1'b0,   
    /// Restrict to only unique IDs         
    parameter bit TbUniqueIds                  = 1'b0     
);
  // TB timing parameters
    localparam time CyclTime = 10ns;
    localparam time ApplTime =  2ns;
    localparam time TestTime =  8ns;

  // AXI configuration which is automatically derived.
    localparam int unsigned TbAxiIdWidthSlaves =  TbAxiIdWidthMasters + $clog2(TbNumMasters);
    localparam int unsigned TbAxiAddrWidth     =  32'd32;
    localparam int unsigned TbAxiStrbWidth     =  TbAxiDataWidth / 8;
    localparam int unsigned TbAxiUserWidth     =  5;
  // In the bench can change this variables which are set here freely,
    localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
    NoSlvPorts:         TbNumMasters,
    NoMstPorts:         TbNumSlaves,
    MaxMstTrans:        10,
    MaxSlvTrans:        6,
    FallThrough:        1'b0,
    LatencyMode:        axi_pkg::CUT_ALL_AX,
    PipelineStages:     TbPipeline,
    AxiIdWidthSlvPorts: TbAxiIdWidthMasters,
    AxiIdUsedSlvPorts:  TbAxiIdUsed,
    UniqueIds:          TbUniqueIds,
    AxiAddrWidth:       TbAxiAddrWidth,
    AxiDataWidth:       TbAxiDataWidth,
    NoAddrRules:        TbNumSlaves
    };

    
  // Each slave has its own address range: 
 typedef axi_pkg::xbar_rule_32_t         rule_t;
 localparam rule_t [TbNumSlaves-1:0] AddrMap = addr_map_gen();
 function rule_t [TbNumSlaves-1:0] addr_map_gen ();
    for (int unsigned i = 0; i < TbNumSlaves; i++) begin
        addr_map_gen[i] = rule_t'{
        idx:        unsigned'(i),
        start_addr:  i    * 32'h0000_2000,
        end_addr:   (i+1) * 32'h0000_2000,
        default:    '0
        };
    end
    endfunction

// overlapping Address Map for test case verification
    /*localparam rule_t [TbNumSlaves-1:0] AddrMap = '{
    '{idx: 32'd1, start_addr: 32'h0000_1800, end_addr: 32'h0000_3800},
    '{idx: 32'd0, start_addr: 32'h0000_0000, end_addr: 32'h0000_2000}
    };*/

  import uvm_pkg::*;

  // Import the DDVAPI CDN_AXI SV interface and the generic Mem interface
  import DenaliSvCdn_axi::*;
  import DenaliSvMem::*; 

  // Import the VIP UVM base classes
  import cdnAxiUvm::*;  

  // Import the example environment reusable files
  import axi4UvmUser::*;

  // Includes the Test library
  `include "axi4UvmUserTests.sv"

  reg aclk;
  reg aresetn;
 cdnAxi4Interface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)) master_interface0 (aclk,aresetn);
 cdnAxi4Interface#(.ID_WIDTH(`CDN_AXI_ID_WIDTH),.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)) slave_interface0 (aclk,aresetn);
 cdnAxi4Interface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)) master_interface1 (aclk,aresetn);
 cdnAxi4Interface#(.ID_WIDTH(`CDN_AXI_ID_WIDTH),.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)) slave_interface1 (aclk,aresetn);  

// making an array of master and slave ref::(axi_intf.sv)
   AXI_BUS #(
    .AXI_ADDR_WIDTH ( TbAxiAddrWidth      ),
    .AXI_DATA_WIDTH ( TbAxiDataWidth      ),
    .AXI_ID_WIDTH   ( TbAxiIdWidthMasters ),
    .AXI_USER_WIDTH ( TbAxiUserWidth      )
  ) master [TbNumMasters -1 :0] ();

  AXI_BUS #(
    .AXI_ADDR_WIDTH ( TbAxiAddrWidth     ),
    .AXI_DATA_WIDTH ( TbAxiDataWidth     ),
    .AXI_ID_WIDTH   ( TbAxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( TbAxiUserWidth     )
  ) slave [TbNumSlaves-1:0] ();


// Connecting the VIP Interfaces to Design Interfaces

assign master[0].aw_id            = master_interface0.awid     ;
assign master[0].aw_addr          = master_interface0.awaddr   ;
assign master[0].aw_len           = master_interface0.awlen    ;
assign master[0].aw_size          = master_interface0.awsize   ;
assign master[0].aw_burst         = master_interface0.awburst  ;
assign master[0].aw_lock          = master_interface0.awlock   ;
assign master[0].aw_cache         = master_interface0.awcache  ;
assign master[0].aw_prot          = master_interface0.awprot   ;
assign master[0].aw_qos           = master_interface0.awqos    ;
assign master[0].aw_region        = master_interface0.awregion ;
assign master[0].aw_user          = master_interface0.awuser   ;
assign master[0].aw_valid         = master_interface0.awvalid  ;
assign master[0].w_data           = master_interface0.wdata    ;
assign master[0].w_strb           = master_interface0.wstrb    ;
assign master[0].w_last           = master_interface0.wlast    ;
assign master[0].w_user           = master_interface0.wuser    ;
assign master[0].w_valid          = master_interface0.wvalid   ;
assign master[0].b_ready          = master_interface0.bready   ;
assign master[0].ar_id            = master_interface0.arid     ;
assign master[0].ar_addr          = master_interface0.araddr   ;
assign master[0].ar_len           = master_interface0.arlen    ;
assign master[0].ar_size          = master_interface0.arsize   ;
assign master[0].ar_burst         = master_interface0.arburst  ;
assign master[0].ar_lock          = master_interface0.arlock   ;
assign master[0].ar_cache         = master_interface0.arcache  ;
assign master[0].ar_prot          = master_interface0.arprot   ;
assign master[0].ar_qos           = master_interface0.arqos    ;
assign master[0].ar_region        = master_interface0.arregion ;
assign master[0].ar_user          = master_interface0.aruser   ;
assign master[0].ar_valid         = master_interface0.arvalid  ;
assign master[0].r_ready          = master_interface0.rready   ;
  
assign master_interface0.awready  = master[0].aw_ready         ;
assign master_interface0.wready   = master[0].w_ready          ;
assign master_interface0.bid      = master[0].b_id             ;
assign master_interface0.bresp    = master[0].b_resp           ;
assign master_interface0.buser    = master[0].b_user           ;
assign master_interface0.bvalid   = master[0].b_valid          ;
assign master_interface0.arready  = master[0].ar_ready         ;
assign master_interface0.rid      = master[0].r_id             ;
assign master_interface0.rdata    = master[0].r_data           ;
assign master_interface0.rresp    = master[0].r_resp           ;
assign master_interface0.rlast    = master[0].r_last           ;
assign master_interface0.ruser    = master[0].r_user           ;
assign master_interface0.rvalid   = master[0].r_valid          ;

assign slave[0].aw_ready          = slave_interface0.awready   ;
assign slave[0].w_ready           = slave_interface0.wready    ;
assign slave[0].b_id              = slave_interface0.bid       ;
assign slave[0].b_resp            = slave_interface0.bresp     ;
assign slave[0].b_user            = slave_interface0.buser     ;
assign slave[0].b_valid           = slave_interface0.bvalid    ;
assign slave[0].ar_ready          = slave_interface0.arready   ; 
assign slave[0].r_id              = slave_interface0.rid       ;
assign slave[0].r_data            = slave_interface0.rdata     ;
assign slave[0].r_resp            = slave_interface0.rresp     ;
assign slave[0].r_last            = slave_interface0.rlast     ;
assign slave[0].r_user            = slave_interface0.ruser     ;
assign slave[0].r_valid           = slave_interface0.rvalid    ; 

assign slave_interface0.awid      = slave[0].aw_id             ;
assign slave_interface0.awaddr    = slave[0].aw_addr           ;
assign slave_interface0.awlen     = slave[0].aw_len            ;
assign slave_interface0.awsize    = slave[0].aw_size           ;
assign slave_interface0.awburst   = slave[0].aw_burst          ;
assign slave_interface0.awlock    = slave[0].aw_lock           ;
assign slave_interface0.awcache   = slave[0].aw_cache          ;
assign slave_interface0.awprot    = slave[0].aw_prot           ;
assign slave_interface0.awqos     = slave[0].aw_qos            ;
assign slave_interface0.awregion  = slave[0].aw_region         ;
 
assign  slave_interface0.awuser   = slave[0].aw_user           ;
assign  slave_interface0.awvalid  = slave[0].aw_valid          ;
assign  slave_interface0.wdata    = slave[0].w_data            ;
assign  slave_interface0.wstrb    = slave[0].w_strb            ;
assign  slave_interface0.wlast    = slave[0].w_last            ;
assign  slave_interface0.wuser    = slave[0].w_user            ;
assign  slave_interface0.wvalid   = slave[0].w_valid           ;
assign  slave_interface0.bready   = slave[0].b_ready           ;
assign  slave_interface0.arid     = slave[0].ar_id             ;
assign  slave_interface0.araddr   = slave[0].ar_addr           ;
assign  slave_interface0.arlen    = slave[0].ar_len            ;
assign  slave_interface0.arsize   = slave[0].ar_size           ;
assign  slave_interface0.arburst  = slave[0].ar_burst          ;
assign  slave_interface0.arlock   = slave[0].ar_lock           ;
assign  slave_interface0.arcache  = slave[0].ar_cache          ;
assign  slave_interface0.arprot   = slave[0].ar_prot           ;
assign  slave_interface0.arqos    = slave[0].ar_qos            ;
assign  slave_interface0.arregion = slave[0].ar_region         ;
assign  slave_interface0.aruser   = slave[0].ar_user           ;
assign  slave_interface0.arvalid  = slave[0].ar_valid          ;
assign  slave_interface0.rready   = slave[0].r_ready           ;  


assign master[1].aw_id            = master_interface1.awid     ;
assign master[1].aw_addr          = master_interface1.awaddr   ;
assign master[1].aw_len           = master_interface1.awlen    ;
assign master[1].aw_size          = master_interface1.awsize   ;
assign master[1].aw_burst         = master_interface1.awburst  ;
assign master[1].aw_lock          = master_interface1.awlock   ;
assign master[1].aw_cache         = master_interface1.awcache  ;
assign master[1].aw_prot          = master_interface1.awprot   ;
assign master[1].aw_qos           = master_interface1.awqos    ;
assign master[1].aw_region        = master_interface1.awregion ;
assign master[1].aw_user          = master_interface1.awuser   ;
assign master[1].aw_valid         = master_interface1.awvalid  ;
assign master[1].w_data           = master_interface1.wdata    ;
assign master[1].w_strb           = master_interface1.wstrb    ;
assign master[1].w_last           = master_interface1.wlast    ;
assign master[1].w_user           = master_interface1.wuser    ;
assign master[1].w_valid          = master_interface1.wvalid   ;
assign master[1].b_ready          = master_interface1.bready   ;
assign master[1].ar_id            = master_interface1.arid     ;
assign master[1].ar_addr          = master_interface1.araddr   ;
assign master[1].ar_len           = master_interface1.arlen    ;
assign master[1].ar_size          = master_interface1.arsize   ;
assign master[1].ar_burst         = master_interface1.arburst  ;
assign master[1].ar_lock          = master_interface1.arlock   ;
assign master[1].ar_cache         = master_interface1.arcache  ;
assign master[1].ar_prot          = master_interface1.arprot   ;
assign master[1].ar_qos           = master_interface1.arqos    ;
assign master[1].ar_region        = master_interface1.arregion ;
assign master[1].ar_user          = master_interface1.aruser   ;
assign master[1].ar_valid         = master_interface1.arvalid  ;
assign master[1].r_ready          = master_interface1.rready   ;

assign master_interface1.awready  = master[1].aw_ready         ;
assign master_interface1.wready   = master[1].w_ready          ;
assign master_interface1.bid      = master[1].b_id             ;
assign master_interface1.bresp    = master[1].b_resp           ;
assign master_interface1.buser    = master[1].b_user           ;
assign master_interface1.bvalid   = master[1].b_valid          ;
assign master_interface1.arready  = master[1].ar_ready         ;
assign master_interface1.rid      = master[1].r_id             ;
assign master_interface1.rdata    = master[1].r_data           ;
assign master_interface1.rresp    = master[1].r_resp           ;
assign master_interface1.rlast    = master[1].r_last           ;
assign master_interface1.ruser    = master[1].r_user           ;
assign master_interface1.rvalid   = master[1].r_valid          ;

assign slave[1].aw_ready          = slave_interface1.awready   ;
assign slave[1].w_ready           = slave_interface1.wready    ;
assign slave[1].b_id              = slave_interface1.bid       ; 
assign slave[1].b_resp            = slave_interface1.bresp     ;
assign slave[1].b_user            = slave_interface1.buser     ;
assign slave[1].b_valid           = slave_interface1.bvalid    ;
assign slave[1].ar_ready          = slave_interface1.arready   ; 
assign slave[1].r_id              = slave_interface1.rid       ;
assign slave[1].r_data            = slave_interface1.rdata     ;
assign slave[1].r_resp            = slave_interface1.rresp     ;
assign slave[1].r_last            = slave_interface1.rlast     ;
assign slave[1].r_user            = slave_interface1.ruser     ;
assign slave[1].r_valid           = slave_interface1.rvalid    ;

assign slave_interface1.awid      = slave[1].aw_id             ;
assign slave_interface1.awaddr    = slave[1].aw_addr           ;
assign slave_interface1.awlen     = slave[1].aw_len            ;
assign slave_interface1.awsize    = slave[1].aw_size           ;
assign slave_interface1.awburst   = slave[1].aw_burst          ;
assign slave_interface1.awlock    = slave[1].aw_lock           ;
assign slave_interface1.awcache   = slave[1].aw_cache          ;
assign slave_interface1.awprot    = slave[1].aw_prot           ;
assign slave_interface1.awqos     = slave[1].aw_qos            ;
assign slave_interface1.awregion  = slave[1].aw_region         ;

assign  slave_interface1.awuser   = slave[1].aw_user           ;
assign  slave_interface1.awvalid  = slave[1].aw_valid          ;
assign  slave_interface1.wdata    = slave[1].w_data            ;
assign  slave_interface1.wstrb    = slave[1].w_strb            ;
assign  slave_interface1.wlast    = slave[1].w_last            ;
assign  slave_interface1.wuser    = slave[1].w_user            ;
assign  slave_interface1.wvalid   = slave[1].w_valid           ;
assign  slave_interface1.bready   = slave[1].b_ready           ;
assign  slave_interface1.arid     = slave[1].ar_id             ;
assign  slave_interface1.araddr   = slave[1].ar_addr           ;
assign  slave_interface1.arlen    = slave[1].ar_len            ;
assign  slave_interface1.arsize   = slave[1].ar_size           ;
assign  slave_interface1.arburst  = slave[1].ar_burst          ;
assign  slave_interface1.arlock   = slave[1].ar_lock           ;
assign  slave_interface1.arcache  = slave[1].ar_cache          ;
assign  slave_interface1.arprot   = slave[1].ar_prot           ;
assign  slave_interface1.arqos    = slave[1].ar_qos            ;
assign  slave_interface1.arregion = slave[1].ar_region         ;
assign  slave_interface1.aruser   = slave[1].ar_user           ;
assign  slave_interface1.arvalid  = slave[1].ar_valid          ;
assign  slave_interface1.rready   = slave[1].r_ready           ;  

// connection with the Design
  
axi_xbar_intf #(
.AXI_USER_WIDTH ( TbAxiUserWidth  ),
.Cfg            ( xbar_cfg        ),
.rule_t         ( rule_t          )
) i_xbar_dut (
.clk_i                  ( aclk     ),
.rst_ni                 ( aresetn   ),
.test_i                 ( 1'b0     ),
.slv_ports              ( master  ),
.mst_ports              ( slave ),
.addr_map_i             ( AddrMap ),
.en_default_mst_port_i  (   2'b00    ),
.default_mst_port_i     (   2'b00    )
);

// For VCD Waveform 
initial begin
  $dumpfile("axi_compiled_xbar.vcd");
  $dumpvars;
end


  //Toggling the clock
  always #50 aclk = ~aclk;

  //Controlling the reset
  initial
  begin
    aclk = 1'b0;
    aresetn = 1'b0;
    #500;
    aresetn = 1'b1;   
  end
  
  
  //setting the virtual interface to the sve and starting uvm.
  initial
  begin        
    uvm_config_db#(virtual interface cdnAxi4ActiveMasterInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster", "vif", master_interface0.activeMaster);
    uvm_config_db#(virtual interface cdnAxi4ActiveSlaveInterface#(.ID_WIDTH(`CDN_AXI_ID_WIDTH),.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave", "vif", slave_interface0.activeSlave);
    uvm_config_db#(virtual interface cdnAxi4ActiveMasterInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster1", "vif", master_interface1.activeMaster);
    uvm_config_db#(virtual interface cdnAxi4ActiveSlaveInterface#(.ID_WIDTH(`CDN_AXI_ID_WIDTH),.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave1", "vif", slave_interface1.activeSlave);
    run_test(); 
  end     

endmodule
