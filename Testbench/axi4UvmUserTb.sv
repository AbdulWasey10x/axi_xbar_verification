`timescale 1ps/1ps

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




// Test module
module testbench;
  // Number of AXI masters connected to the xbar. (Number of slave ports)
    parameter int unsigned TbNumMasters        = 32'd2;
    /// Number of AXI slaves connected to the xbar. (Number of master ports)
    parameter int unsigned TbNumSlaves         = 32'd2;
    /// Number of write transactions per master.
    parameter int unsigned TbNumWrites         = 32'd10;
    /// Number of read transactions per master.
    parameter int unsigned TbNumReads          = 32'd10;
    /// AXI4+ATOP ID width of the masters connected to the slave ports of the DUT.
    /// The ID width of the slaves is calculated depending on the xbar configuration.
    parameter int unsigned TbAxiIdWidthMasters = 32'd14;
    /// The used ID width of the DUT.
    /// Has to be `TbAxiIdWidthMasters >= TbAxiIdUsed`.
    parameter int unsigned TbAxiIdUsed         = 32'd3;
    /// Data width of the AXI channels.
    parameter int unsigned TbAxiDataWidth      = 32'd128;
    /// Pipeline stages in the xbar itself (between demux and mux).
    parameter int unsigned TbPipeline          = 32'd1;
    /// Enable ATOP generation
    parameter bit          TbEnAtop            = 1'b1;
    /// Enable exclusive accesses
    parameter bit TbEnExcl                     = 1'b0;   
    /// Restrict to only unique IDs         
    parameter bit TbUniqueIds                  = 1'b0;     

  // TB timing parameters
    localparam time CyclTime = 10ns;
    localparam time ApplTime =  2ns;
    localparam time TestTime =  8ns;

  // AXI configuration which is automatically derived.
    localparam int unsigned TbAxiIdWidthSlaves =  TbAxiIdWidthMasters + ($clog2(TbNumMasters)-1);
    localparam int unsigned TbAxiAddrWidth     =  32'd32;
    localparam int unsigned TbAxiStrbWidth     =  TbAxiDataWidth / 8;
    localparam int unsigned TbAxiUserWidth     =  32;
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
    typedef logic [TbAxiIdWidthMasters-1:0] id_mst_t;
    typedef logic [TbAxiIdWidthSlaves-1:0]  id_slv_t;
    typedef logic [TbAxiAddrWidth-1:0]      addr_t;
    typedef axi_pkg::xbar_rule_32_t         rule_t; // Has to be the same width as axi addr
    typedef logic [TbAxiDataWidth-1:0]      data_t;
    typedef logic [TbAxiStrbWidth-1:0]      strb_t;
    typedef logic [TbAxiUserWidth-1:0]      user_t;

  // Each slave has its own address range:
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
 cdnAxi4Interface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)) MasterInterface0 (aclk,aresetn);
 cdnAxi4Interface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)) SlaveInterface0 (aclk,aresetn);
 cdnAxi4Interface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)) MasterInterface1 (aclk,aresetn);
 cdnAxi4Interface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)) SlaveInterface1 (aclk,aresetn);  

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


  //connecting VIP interface signals with the design signals.
  // for (genvar i =0 ; i <= (TbNumSlaves-1); i++) begin

  // For these signals the source is master. 
    assign master[0].aw_id     = MasterInterface0.activeSlave.awid;
    assign master[0].aw_addr   = MasterInterface0.activeSlave.awaddr  ;
    assign master[0].aw_len    = MasterInterface0.activeSlave.awlen  ;
    assign master[0].aw_size   = MasterInterface0.activeSlave.awsize  ;
    assign master[0].aw_burst  = MasterInterface0.activeSlave.awburst  ;
    assign master[0].aw_lock   = MasterInterface0.activeSlave.awlock  ;
    assign master[0].aw_cache  = MasterInterface0.activeSlave.awcache  ;
    assign master[0].aw_prot   = MasterInterface0.activeSlave.awprot  ;
    assign master[0].aw_qos    = MasterInterface0.activeSlave.awqos  ;
    assign master[0].aw_region = MasterInterface0.activeSlave.awregion  ;
    // mst_req_t.aw.atop = userDutInterface.
    assign master[0].aw_user  = MasterInterface0.activeSlave.awuser   ;
    assign master[0].aw_valid = MasterInterface0.activeSlave.awvalid ;
    // assign master[0].aw_id     = MasterInterface0.activeMaster.wid ;
    assign master[0].w_data   = MasterInterface0.activeSlave.wdata  ;
    assign master[0].w_strb   = MasterInterface0.activeSlave.wstrb ;
    assign master[0].w_last   = MasterInterface0.activeSlave.wlast ;
    assign master[0].w_user   = MasterInterface0.activeSlave.wuser  ;
    assign master[0].w_valid  = MasterInterface0.activeSlave.wvalid ;
    assign master[0].b_ready  = MasterInterface0.activeSlave.bready;

    assign master[0].ar_id     = MasterInterface0.activeSlave.arid     ;
    assign master[0].ar_addr   = MasterInterface0.activeSlave.araddr   ;
    assign master[0].ar_len    = MasterInterface0.activeSlave.arlen     ;
    assign master[0].ar_size   = MasterInterface0.activeSlave.arsize    ;
    assign master[0].ar_burst  = MasterInterface0.activeSlave.arburst   ;
    assign master[0].ar_lock   = MasterInterface0.activeSlave.arlock    ;
    assign master[0].ar_cache  = MasterInterface0.activeSlave.arcache   ;
    assign master[0].ar_prot   = MasterInterface0.activeSlave.arprot    ;
    assign master[0].ar_qos    = MasterInterface0.activeSlave.arqos    ;
    assign master[0].ar_region = MasterInterface0.activeSlave.arregion  ;
    assign master[0].ar_user   = MasterInterface0.activeSlave.aruser    ;
    assign master[0].ar_valid  = MasterInterface0.activeSlave.arvalid   ;
    assign master[0].r_ready   = MasterInterface0.activeSlave.rready;

    // For these signals the source is Slaves. Slave will drive on xbar and then it will get in interface.
    assign MasterInterface0.activeMaster.awready  = master[0].aw_ready;
    assign MasterInterface0.activeMaster.wready   = master[0].w_ready ;
    assign MasterInterface0.activeMaster.bid      = master[0].b_id    ;
    assign MasterInterface0.activeMaster.bresp    = master[0].b_resp  ;
    assign MasterInterface0.activeMaster.buser    = master[0].b_user  ;
    assign MasterInterface0.activeMaster.bvalid   = master[0].b_valid ;
    assign MasterInterface0.activeMaster.arready  = master[0].ar_ready;
    assign MasterInterface0.activeMaster.rid      = master[0].r_id    ;
    assign MasterInterface0.activeMaster.rdata    = master[0].r_data  ;
    assign MasterInterface0.activeMaster.rresp    = master[0].r_resp  ;
    assign MasterInterface0.activeMaster.rlast    = master[0].r_last  ;
    assign MasterInterface0.activeMaster.ruser    = master[0].r_user  ;
    assign MasterInterface0.activeMaster.rvalid   = master[0].r_valid ;


    assign slave[0].aw_ready   = SlaveInterface0.activeMaster.awready;
    assign slave[0].w_ready    = SlaveInterface0.activeMaster.wready;
    assign slave[0].b_id       = SlaveInterface0.activeMaster.bid;
    assign slave[0].b_resp     = SlaveInterface0.activeMaster.bresp  ;
    assign slave[0].b_user     = SlaveInterface0.activeMaster.buser ;
    assign slave[0].b_valid    = SlaveInterface0.activeMaster.bvalid;
    assign slave[0].ar_ready   = SlaveInterface0.activeMaster.arready; //output modport
    assign slave[0].r_id       = SlaveInterface0.activeMaster.rid     ;
    assign slave[0].r_data     = SlaveInterface0.activeMaster.rdata    ;
    assign slave[0].r_resp     = SlaveInterface0.activeMaster.rresp    ;
    assign slave[0].r_last     = SlaveInterface0.activeMaster.rlast   ;
    assign slave[0].r_user     = SlaveInterface0.activeMaster.ruser   ;
    assign slave[0].r_valid    = SlaveInterface0.activeMaster.rvalid  ;
  

    //for these signals source is master

    assign SlaveInterface0.activeSlave.awid     =  slave[0].aw_id     ;
    assign SlaveInterface0.activeSlave.awaddr   =  slave[0].aw_addr   ;
    assign SlaveInterface0.activeSlave.awlen    =  slave[0].aw_len    ;
    assign SlaveInterface0.activeSlave.awsize   =  slave[0].aw_size   ;
    assign SlaveInterface0.activeSlave.awburst  =  slave[0].aw_burst  ;
    assign SlaveInterface0.activeSlave.awlock   =  slave[0].aw_lock   ;
    assign SlaveInterface0.activeSlave.awcache  =  slave[0].aw_cache  ;
    assign SlaveInterface0.activeSlave.awprot   =  slave[0].aw_prot   ;
    assign SlaveInterface0.activeSlave.awqos    =  slave[0].aw_qos    ;
    assign SlaveInterface0.activeSlave.awregion =  slave[0].aw_region ;


    assign  SlaveInterface0.activeSlave.awuser  = slave[0].aw_user      ;
    assign  SlaveInterface0.activeSlave.awvalid = slave[0].aw_valid     ;
    // assign  SlaveInterface0.activeSlave.wid     = slave[0].w_id     ;
    assign  SlaveInterface0.activeSlave.wdata   = slave[0].w_data      ;
    assign  SlaveInterface0.activeSlave.wstrb   = slave[0].w_strb     ;
    assign  SlaveInterface0.activeSlave.wlast   = slave[0].w_last     ;
    assign  SlaveInterface0.activeSlave.wuser   = slave[0].w_user      ;
    assign  SlaveInterface0.activeSlave.wvalid  = slave[0].w_valid     ;
    assign  SlaveInterface0.activeSlave.bready  = slave[0].b_ready    ;

    assign  SlaveInterface0.activeSlave.arid     =  slave[0].ar_id     ;
    assign  SlaveInterface0.activeSlave.araddr   =  slave[0].ar_addr   ;
    assign  SlaveInterface0.activeSlave.arlen    =  slave[0].ar_len     ;
    assign  SlaveInterface0.activeSlave.arsize   =  slave[0].ar_size    ;
    assign  SlaveInterface0.activeSlave.arburst  =  slave[0].ar_burst   ;
    assign  SlaveInterface0.activeSlave.arlock   =  slave[0].ar_lock    ;
    assign  SlaveInterface0.activeSlave.arcache  =  slave[0].ar_cache   ;
    assign  SlaveInterface0.activeSlave.arprot   =  slave[0].ar_prot    ;
    assign  SlaveInterface0.activeSlave.arqos    =  slave[0].ar_qos    ;
    assign  SlaveInterface0.activeSlave.arregion =  slave[0].ar_region  ;
    assign  SlaveInterface0.activeSlave.aruser   =  slave[0].ar_user    ;
    assign  SlaveInterface0.activeSlave.arvalid  =  slave[0].ar_valid   ;
    assign  SlaveInterface0.activeSlave.rready   =  slave[0].r_ready ;  



    // For these signals source is master
    assign master[1].aw_id     = MasterInterface1.activeSlave.awid;
    assign master[1].aw_addr   = MasterInterface1.activeSlave.awaddr  ;
    assign master[1].aw_len    = MasterInterface1.activeSlave.awlen  ;
    assign master[1].aw_size   = MasterInterface1.activeSlave.awsize  ;
    assign master[1].aw_burst  = MasterInterface1.activeSlave.awburst  ;
    assign master[1].aw_lock   = MasterInterface1.activeSlave.awlock  ;
    assign master[1].aw_cache  = MasterInterface1.activeSlave.awcache  ;
    assign master[1].aw_prot   = MasterInterface1.activeSlave.awprot  ;
    assign master[1].aw_qos    = MasterInterface1.activeSlave.awqos  ;
    assign master[1].aw_region = MasterInterface1.activeSlave.awregion  ;
    // mst_req_t.aw.atop = userDutInterface.
    assign master[1].aw_user  = MasterInterface1.activeSlave.awuser   ;
    assign master[1].aw_valid = MasterInterface1.activeSlave.awvalid ;
    // assign master[1].w_id     = MasterInterface1.activeMaster.wid ;
    assign master[1].w_data   = MasterInterface1.activeSlave.wdata  ;
    assign master[1].w_strb   = MasterInterface1.activeSlave.wstrb ;
    assign master[1].w_last   = MasterInterface1.activeSlave.wlast ;
    assign master[1].w_user   = MasterInterface1.activeSlave.wuser  ;
    assign master[1].w_valid  = MasterInterface1.activeSlave.wvalid ;
    assign master[1].b_ready  = MasterInterface1.activeSlave.bready;

    assign master[1].ar_id     = MasterInterface1.activeSlave.arid     ;
    assign master[1].ar_addr   = MasterInterface1.activeSlave.araddr   ;
    assign master[1].ar_len    = MasterInterface1.activeSlave.arlen     ;
    assign master[1].ar_size   = MasterInterface1.activeSlave.arsize    ;
    assign master[1].ar_burst  = MasterInterface1.activeSlave.arburst   ;
    assign master[1].ar_lock   = MasterInterface1.activeSlave.arlock    ;
    assign master[1].ar_cache  = MasterInterface1.activeSlave.arcache   ;
    assign master[1].ar_prot   = MasterInterface1.activeSlave.arprot    ;
    assign master[1].ar_qos    = MasterInterface1.activeSlave.arqos    ;
    assign master[1].ar_region = MasterInterface1.activeSlave.arregion  ;
    assign master[1].ar_user   = MasterInterface1.activeSlave.aruser    ;
    assign master[1].ar_valid  = MasterInterface1.activeSlave.arvalid   ;
    assign master[1].r_ready   = MasterInterface1.activeSlave.rready;

   // For these signals source is Slave
   assign MasterInterface1.activeMaster.awready  = master[1].aw_ready;
   assign MasterInterface1.activeMaster.wready   = master[1].w_ready ;
   assign MasterInterface1.activeMaster.bid      = master[1].b_id    ;
   assign MasterInterface1.activeMaster.bresp    = master[1].b_resp  ;
   assign MasterInterface1.activeMaster.buser    = master[1].b_user  ;
   assign MasterInterface1.activeMaster.bvalid   = master[1].b_valid ;
   assign MasterInterface1.activeMaster.arready  = master[1].ar_ready;
   assign MasterInterface1.activeMaster.rid      = master[1].r_id    ;
   assign MasterInterface1.activeMaster.rdata    = master[1].r_data  ;
   assign MasterInterface1.activeMaster.rresp    = master[1].r_resp  ;
   assign MasterInterface1.activeMaster.rlast    = master[1].r_last  ;
   assign MasterInterface1.activeMaster.ruser    = master[1].r_user  ;
   assign MasterInterface1.activeMaster.rvalid   = master[1].r_valid ;


    assign slave[1].aw_ready   = SlaveInterface1.activeMaster.awready;
    assign slave[1].w_ready    = SlaveInterface1.activeMaster.wready;
    assign slave[1].b_id       = SlaveInterface1.activeMaster.bid;
    assign slave[1].b_resp     = SlaveInterface1.activeMaster.bresp  ;
    assign slave[1].b_user     = SlaveInterface1.activeMaster.buser ;
    assign slave[1].b_valid    = SlaveInterface1.activeMaster.bvalid;
    assign slave[1].ar_ready   = SlaveInterface1.activeMaster.arready; //output modport
    assign slave[1].r_id       = SlaveInterface1.activeMaster.rid     ;
    assign slave[1].r_data     = SlaveInterface1.activeMaster.rdata    ;
    assign slave[1].r_resp     = SlaveInterface1.activeMaster.rresp    ;
    assign slave[1].r_last     = SlaveInterface1.activeMaster.rlast   ;
    assign slave[1].r_user     = SlaveInterface1.activeMaster.ruser   ;
    assign slave[1].r_valid    = SlaveInterface1.activeMaster.rvalid  ;

// For these signals source is master
assign SlaveInterface1.activeSlave.awid     =  slave[1].aw_id     ;
assign SlaveInterface1.activeSlave.awaddr   =  slave[1].aw_addr   ;
assign SlaveInterface1.activeSlave.awlen    =  slave[1].aw_len    ;
assign SlaveInterface1.activeSlave.awsize   =  slave[1].aw_size   ;
assign SlaveInterface1.activeSlave.awburst  =  slave[1].aw_burst  ;
assign SlaveInterface1.activeSlave.awlock   =  slave[1].aw_lock   ;
assign SlaveInterface1.activeSlave.awcache  =  slave[1].aw_cache  ;
assign SlaveInterface1.activeSlave.awprot   =  slave[1].aw_prot   ;
assign SlaveInterface1.activeSlave.awqos    =  slave[1].aw_qos    ;
assign SlaveInterface1.activeSlave.awregion =  slave[1].aw_region ;


assign  SlaveInterface1.activeSlave.awuser  = slave[1].aw_user      ;
assign  SlaveInterface1.activeSlave.awvalid = slave[1].aw_valid     ;
// assign  SlaveInterface1.activeSlave.wid     = slave[1].w_id     ;
assign  SlaveInterface1.activeSlave.wdata   = slave[1].w_data      ;
assign  SlaveInterface1.activeSlave.wstrb   = slave[1].w_strb     ;
assign  SlaveInterface1.activeSlave.wlast   = slave[1].w_last     ;
assign  SlaveInterface1.activeSlave.wuser   = slave[1].w_user      ;
assign  SlaveInterface1.activeSlave.wvalid  = slave[1].w_valid     ;
assign  SlaveInterface1.activeSlave.bready  = slave[1].b_ready    ;

assign  SlaveInterface1.activeSlave.arid     =  slave[1].ar_id     ;
assign  SlaveInterface1.activeSlave.araddr   =  slave[1].ar_addr   ;
assign  SlaveInterface1.activeSlave.arlen    =  slave[1].ar_len     ;
assign  SlaveInterface1.activeSlave.arsize   =  slave[1].ar_size    ;
assign  SlaveInterface1.activeSlave.arburst  =  slave[1].ar_burst   ;
assign  SlaveInterface1.activeSlave.arlock   =  slave[1].ar_lock    ;
assign  SlaveInterface1.activeSlave.arcache  =  slave[1].ar_cache   ;
assign  SlaveInterface1.activeSlave.arprot   =  slave[1].ar_prot    ;
assign  SlaveInterface1.activeSlave.arqos    =  slave[1].ar_qos    ;
assign  SlaveInterface1.activeSlave.arregion =  slave[1].ar_region  ;
assign  SlaveInterface1.activeSlave.aruser   =  slave[1].ar_user    ;
assign  SlaveInterface1.activeSlave.arvalid  =  slave[1].ar_valid   ;
assign  SlaveInterface1.activeSlave.rready   =  slave[1].r_ready ;  




    // end

    // DUT 
    // connection with the Design
  
    axi_xbar_intf #(
    .AXI_USER_WIDTH ( TbAxiUserWidth  ),
    .Cfg            ( xbar_cfg        ),
    .rule_t         ( rule_t          )
    ) i_xbar_dut (
    .clk_i                  ( aclk     ),
    .rst_ni                 ( aresetn   ),
    .test_i                 ( 1'b0    ),
    .slv_ports              ( master  ),
    .mst_ports              ( slave ),
    .addr_map_i             ( AddrMap ),
    .en_default_mst_port_i  ( '0      ),
    .default_mst_port_i     ( '0      )
    );

//waveform 

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
    // #5000;
    // aresetn = 1'b1;
  end
  
  
  //setting the virtual interface to the sve and starting uvm.
  initial
  begin        
    /*uvm_config_db#(virtual interface cdnAxi4ActiveMasterInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster", "vif", userDutInterface.activeMaster);
    uvm_config_db#(virtual interface cdnAxi4ActiveSlaveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave", "vif", userDutInterface.activeSlave);
    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave", "vif", userDutInterface.activeSlave);
    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster", "vif", userDutInterface.activeMaster);
    uvm_config_db#(virtual interface cdnAxi4ActiveMasterInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster1", "vif", testbench.userDutInterface1.activeMaster);
    uvm_config_db#(virtual interface cdnAxi4ActiveSlaveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave1", "vif", testbench.userDutInterface1.activeSlave);
    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave1", "vif", testbench.userDutInterface1.activeSlave);
    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster1", "vif", testbench.userDutInterface1.activeMaster);
    */
    
    uvm_config_db#(virtual interface cdnAxi4ActiveMasterInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster", "vif", MasterInterface0.activeMaster);
//    uvm_config_db#(virtual interface cdnAxi4ActiveSlaveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave", "vif", MasterInterface0.activeSlave);
//    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave", "vif", MasterInterface0.activeSlave);
//    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster", "vif", MasterInterface0.activeMaster);

//    uvm_config_db#(virtual interface cdnAxi4ActiveMasterInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster", "vif", SlaveInterface0.activeMaster);
    uvm_config_db#(virtual interface cdnAxi4ActiveSlaveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave", "vif", SlaveInterface0.activeSlave);
//    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave", "vif", SlaveInterface0.activeSlave);
//    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster", "vif", SlaveInterface0.activeMaster);
    
    uvm_config_db#(virtual interface cdnAxi4ActiveMasterInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster1", "vif", MasterInterface1.activeMaster);
//    uvm_config_db#(virtual interface cdnAxi4ActiveSlaveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave1", "vif", MasterInterface1.activeSlave);
//    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave1", "vif", MasterInterface1.activeSlave);
//    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster1", "vif", MasterInterface1.activeMaster);

//    uvm_config_db#(virtual interface cdnAxi4ActiveMasterInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster1", "vif", SlaveInterface1.activeMaster);
    uvm_config_db#(virtual interface cdnAxi4ActiveSlaveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave1", "vif", SlaveInterface1.activeSlave);
//    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeSlave1", "vif", SlaveInterface1.activeSlave);
//    uvm_config_db#(virtual interface cdnAxi4PassiveInterface#(.ADDR_WIDTH(`CDN_AXI_ADDR_WIDTH),.DATA_WIDTH(`CDN_AXI_DATA_WIDTH)))::set(null,"*activeMaster1", "vif", SlaveInterface1.activeMaster);

    run_test(); 
  end     

endmodule
