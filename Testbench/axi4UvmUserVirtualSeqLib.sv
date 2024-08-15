// ***************************************************************
// Class: axi4UvmVirtualSequence
//
// This class defines a base virtual sequence
// ***************************************************************
`ifndef CDN_AXI_UVM_VIRTUAL_SEQUENCE_SV
`define CDN_AXI_UVM_VIRTUAL_SEQUENCE_SV

class axi4UvmVirtualSequence extends uvm_sequence;
  
   // By default, if the response_queue overflows, an error is reported. The
   // response_queue will overflow if more responses are sent to this sequence
   // from the driver than get_response calls are made. Setting value to 1
   // disables these errors, while setting it to 0 enables them.
   bit response_queue_error_report_disbaled = 1;

   `uvm_object_utils_begin(axi4UvmVirtualSequence)
      `uvm_field_int(response_queue_error_report_disbaled, UVM_ALL_ON)
    `uvm_object_utils_end
	
  `uvm_declare_p_sequencer(axi4UvmUserVirtualSequencer)

  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "axi4UvmVirtualSequence");
    super.new(name);
`ifdef UVM_VERSION
   // UVM-IEEE
   set_response_queue_error_report_enabled(!response_queue_error_report_disbaled);
`else
   set_response_queue_error_report_disabled(response_queue_error_report_disbaled);
`endif
  endfunction : new

  // ***************************************************************
  // Method : pre_body
  // Desc.  : Raise an objection to prevent premature simulation end
  // ***************************************************************
  virtual task pre_body();
    `ifdef UVM_POST_VERSION_1_1
	var uvm_phase starting_phase = get_starting_phase();
    `endif
    if (starting_phase != null) begin
      starting_phase.raise_objection(this);
      
      // enable Active master tracker
      p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_EnableTracker,1);
      
    end
  endtask

  // ***************************************************************
  // Method : post_body
  // Desc.  : Drop the objection raised earlier
  // ***************************************************************
  virtual task post_body();
    `ifdef UVM_POST_VERSION_1_1
	var uvm_phase starting_phase = get_starting_phase();
    `endif
    if (starting_phase != null) begin
      starting_phase.drop_objection(this);
    end
  endtask
  
endclass : axi4UvmVirtualSequence 

`endif // CDN_AXI_UVM_VIRTUAL_SEQUENCE_SV 

// ****************************************************************************
// Class : perChannalDelaySeq
// Desc. : Eval ID: 4.9
// VIP support dynamic configuration of per channel valid-ready delay
// ****************************************************************************
class perChannalDelaySeq extends axi4UvmVirtualSequence;

	`uvm_object_utils(perChannalDelaySeq)
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "perChannalDelaySeq");
    super.new(name);        
  endfunction : new 
	
	myAxiTransaction masterBurst;
	
	virtual task body();
		
		`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence perChannalDelaySeq started", UVM_LOW);
		
		// disable all AXI channels valid and ready
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteAddrChannel,1); 	// AWVALID
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableReadAddrChannel,1);  	// ARVALID
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteDataChannel,1);		// WVALID
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableReadDataChannel,1); 		// RREADY
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteRespChannel,1); 	// BREADY
  
  	p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteAddrChannel,1);		// AWREADY
  	p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableReadAddrChannel,1);			// ARREADY
  	p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteDataChannel,1);		// WREADY
  	p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableReadDataChannel,1);			// RVALID
  	p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteRespChannel,1);		// BVALID
  	
		`uvm_do_on_with(masterBurst, p_sequencer.masterSeqr,  { 
			masterBurst.Type == DENALI_CDN_AXI_TR_Write;
			masterBurst.Length == 4;
			masterBurst.TransmitDelay == 0;
		})
						
		`uvm_do_on_with(masterBurst, p_sequencer.masterSeqr,  { 
			masterBurst.Type == DENALI_CDN_AXI_TR_Read;
			masterBurst.Length == 4;
			masterBurst.TransmitDelay == 0;
		})
		
		#5000;
		// enable AWVALID
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteAddrChannel,0);
		
		#5000;
		// enable AWREADY
		p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteAddrChannel,0);
		
		#5000;
		// enable WVALID
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteDataChannel,0);
		
		#5000;
		// enable WREADY
		p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteDataChannel,0);
		
		#5000;
		// enable BVALID
		p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteRespChannel,0);
		
		#5000;
		// enable BREADY
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteRespChannel,0); 
		
		#5000;
		// enable ARVALID
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableReadAddrChannel,0);
		
		#5000;
		// enable ARREADY
		p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableReadAddrChannel,0);
		
		#5000;
		// enable RVALID
		p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_DisableReadDataChannel,0);
		
		#5000;
		// enable RREADY
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableReadDataChannel,0);
		
		#10000;

  endtask
	
endclass : perChannalDelaySeq

// ****************************************************************************
// Class : perTransactionDelaySeq
// Desc. : Eval ID: 4.9
// VIP support dynamic configuration of per transaction valid-ready delay
// ****************************************************************************
class perTransactionDelaySeq extends axi4UvmVirtualSequence;
	
	`uvm_object_utils(perTransactionDelaySeq)
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "perTransactionDelaySeq");
    super.new(name);        
  endfunction : new 
	
	myAxiTransaction masterBurst;
	mySlaveResp slaveResponse;
	
	virtual task body();	
		`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence perTranscationDelaySeq started", UVM_LOW);
		// xREADY signals initial value after reset
		p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_AwreadyValueAfterReset,0);
		p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_WreadyValueAfterReset,0);
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_BreadyValueAfterReset,0);
		p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_ArreadyValueAfterReset,0);
		p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_RreadyValueAfterReset,0);
		
		for (int i=0; i<5; i++) begin
		
			`uvm_do_on_with(slaveResponse, p_sequencer.slaveSeqr,  {
				slaveResponse.Type == DENALI_CDN_AXI_TR_Write;
				slaveResponse.Length == 4;
				// AWVALID to AWREADY delay
				slaveResponse.AreadyControl == DENALI_CDN_AXI_READYCONTROL_STALL_UNTIL_VALID_AND_DELAY;
				slaveResponse.AddressDelay == 5;			
				// WREADY delay
				slaveResponse.WreadyControl == DENALI_CDN_AXI_READYCONTROL_STALL_UNTIL_VALID_AND_DELAY;
				slaveResponse.TransfersChannelDelay.size() == 4;
				foreach(slaveResponse.TransfersChannelDelay[index]){
		    		slaveResponse.TransfersChannelDelay[index] == 5; // WREADY delay after each WVALID assertion
		    }
				// BVALID delay (from WLAST)
				slaveResponse.ChannelDelay == 5;
			})
							
			`uvm_do_on_with(slaveResponse, p_sequencer.slaveSeqr,  { 
				slaveResponse.Type == DENALI_CDN_AXI_TR_Read;
				slaveResponse.Length == 4;
				// ARVALID to ARREADY delay
				slaveResponse.AreadyControl == DENALI_CDN_AXI_READYCONTROL_STALL_UNTIL_VALID_AND_DELAY;
				slaveResponse.AddressDelay >= 5; // min ARVALID_to_ARREADY delay 
				slaveResponse.AddressDelay <= 10;// max ARVALID_to_ARREADY delay
				
				// TransfersChannelDelay[0] set the delay between ARVALID+ARREADY and first RVALID
				slaveResponse.TransfersChannelDelay.size() == 4;
				foreach(slaveResponse.TransfersChannelDelay[index]){
		    		slaveResponse.TransfersChannelDelay[index] == 5; // RVALID to RVALID delay
		    }
			})
			
			`uvm_create_on(masterBurst, p_sequencer.masterSeqr)
			masterBurst.TransmitDelay_const.constraint_mode(0);
			`uvm_rand_send_with(masterBurst, { 
				masterBurst.Type == DENALI_CDN_AXI_TR_Write;
				masterBurst.Length == 4;
				masterBurst.TransmitDelay == 5; // AwVALID delay	
				// TransfersChannelDelay[0] set the delay between AWVALID+AWREADY and first WVALID
				masterBurst.TransfersChannelDelay.size() == 4;
				foreach(masterBurst.TransfersChannelDelay[index]){
		    		masterBurst.TransfersChannelDelay[index] == 5; // WVALID to WVALID delay
		    }
				// BVALID to BREADY delay
				masterBurst.BreadyControl == DENALI_CDN_AXI_READYCONTROL_STALL_UNTIL_VALID_AND_DELAY;
				masterBurst.BreadyDelay == 5;
	
			})
							
			`uvm_create_on(masterBurst, p_sequencer.masterSeqr)
			masterBurst.TransmitDelay_const.constraint_mode(0);
			`uvm_rand_send_with(masterBurst, { 
				masterBurst.Type == DENALI_CDN_AXI_TR_Read;
				masterBurst.Length == 4;
				masterBurst.TransmitDelay == 5; // ARVALID delay
				// RREADY delay
				masterBurst.RreadyControl == DENALI_CDN_AXI_READYCONTROL_STALL_UNTIL_VALID_AND_DELAY;
				foreach(masterBurst.TransfersChannelDelay[index]){
		    		masterBurst.TransfersChannelDelay[index] == 5; // RREADY delay after each RVALID assertion
		    }
			})
			#100000;
		end
  endtask
	
endclass : perTransactionDelaySeq

// ****************************************************************************
// Class : cross4kBounderySeq
// Desc. : Eval ID: 4.17
// Using transaction class object in user sequence/test generate and issue a illegal transaction for negative testing. 
// This could be post randomization of object change transaction parameters
// ****************************************************************************
class cross4kBoundarySeq extends axi4UvmVirtualSequence;

	`uvm_object_utils(cross4kBoundarySeq)
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "cross4kBoundarySeq");
    super.new(name);        
  endfunction : new 
  	
	crossing4kBoundaryModifyTransactionSeq seq;
	
	virtual task body();
		`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence corss4kBoundarySeq started", UVM_LOW);
		`uvm_do_on_with(seq, p_sequencer.masterSeqr, {
			seq.direction == DENALI_CDN_AXI_DIRECTION_READ;
		})

  endtask
	
endclass : cross4kBoundarySeq

// ****************************************************************************
// Class : IdBasedReorderingSeq
// Desc. : Eval ID: 4.25
// Auto ID management for OOO request per instance 
// Address phase IDs order is 5,4,3,2,1 but read data order is 1,2,3,4,5 and write response order is 5,1,2,3,4
// ****************************************************************************
class IdBasedReorderingSeq extends axi4UvmVirtualSequence;

	`uvm_object_utils(IdBasedReorderingSeq)
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "IdBasedReorderingSeq");
    super.new(name);        
  endfunction : new 
	
	myAxiTransaction masterBurst;
	mySlaveResp slaveResponse;
	
	virtual task body();
		
		`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence idBasedReordingSeq started", UVM_LOW);
		
		p_sequencer.pEnv.activeSlave.cfg.read_ordering_algorithm = CDN_AXI_CFG_READ_ORDERING_ALGORITHM_ROUND_ROBIN;
		p_sequencer.pEnv.activeSlave.cfg.write_resp_ordering_algorithm = CDN_AXI_CFG_WRITE_RESP_ORDERING_ALGORITHM_ROUND_ROBIN;
    p_sequencer.pEnv.activeSlave.reconfigure(p_sequencer.pEnv.activeSlave.cfg); 
    
    p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteRespChannel,1); 
    p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableReadDataChannel,1); 
    
    for(int ii=0; ii<5; ii++) begin
			`uvm_do_on_with(masterBurst, p_sequencer.masterSeqr, { 
				masterBurst.Type == DENALI_CDN_AXI_TR_Read;
				masterBurst.Length == 4;
				masterBurst.IdTag == 5-ii;
			})
			
			`uvm_do_on_with(masterBurst, p_sequencer.masterSeqr, { 
				masterBurst.Type == DENALI_CDN_AXI_TR_Write;
				masterBurst.Length == 4;
				masterBurst.IdTag == 4-ii;
			})
		end
    
    #100000;
    p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableWriteRespChannel,0); 
    p_sequencer.pEnv.activeMaster.regInst.writeReg(DENALI_CDN_AXI_REG_DisableReadDataChannel,0);
    #100000; 
    
  endtask
	
endclass : IdBasedReorderingSeq

// ****************************************************************************
// Class : blockingNonBlockingSeq
// Desc. : Eval ID: 4.26
// Blocking and Non-blocking request support
// ***************************************************************************
class blockingNonBlockingSeq extends axi4UvmVirtualSequence;

	`uvm_object_utils(blockingNonBlockingSeq)
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "blockingNonBlockingSeq");
    super.new(name);        
  endfunction : new 
	
	myAxiTransaction masterBurst;
	uvm_sequence_item item;
	
	virtual task body();
		`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence blockingNonBlockingSeq started", UVM_LOW);
		
		
		`uvm_info(get_type_name(), "sending 100 blocking transactions", UVM_LOW);
		for(int j =0; j<10; ++j) begin
			`uvm_do_on_with(masterBurst, p_sequencer.masterSeqr, {
				masterBurst.Type inside {DENALI_CDN_AXI_TR_Read, DENALI_CDN_AXI_TR_Write};
			})
			get_response(item, masterBurst.get_transaction_id());
		end
		
		`uvm_info(get_type_name(), "sending 100 non-blocking transactions", UVM_LOW);
		for(int j =0; j<10; ++j) begin
			`uvm_do_on_with(masterBurst, p_sequencer.masterSeqr, {
				masterBurst.Type inside {DENALI_CDN_AXI_TR_Read, DENALI_CDN_AXI_TR_Write};
				masterBurst.Length < 10;
			})
		end
		#100000;

  endtask
	
endclass : blockingNonBlockingSeq

class readAfterWriteSeq extends axi4UvmVirtualSequence;
    
  axi4UvmBlockingWriteSeq writeSeq;
  axi4UvmBlockingReadSeq readSeq;
  reg [63:0] same_address = 64'h100;
  //rand reg [63:0] same_address;
  reg [7:0] same_length = 4;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_INCR;
  denaliCdn_axiSecureModeT same_secure = DENALI_CDN_AXI_SECUREMODE_NONSECURE;

  reg [7:0] w_data[];

  `uvm_object_utils_begin(readAfterWriteSeq)
  	`uvm_field_object(writeSeq, UVM_ALL_ON)
    `uvm_field_object(readSeq, UVM_ALL_ON)
  `uvm_object_utils_end

   
  function new(string name="readAfterWriteSeq");
    super.new(name);
    `uvm_create(writeSeq);
    `uvm_create(readSeq);
  endfunction // new

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
  
    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence readAfterWriteSeq started", UVM_LOW);
    //`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence readAfterWriteSeq started",same_address UVM_LOW);
    #1000;

    `uvm_info(get_type_name(), "Sending a Write following by a Read to the same address", UVM_LOW);
// writeSeq.lengh_constraints.constraint_mode(0);
//@listitem Send a write burst to a specific address.     
    `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr1, {
        writeSeq.address == same_address;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })
    
    // After the completion of the Write sequence, the updated transaction can
    // be accessed in the sequence's field 'response' 
	w_data = new[writeSeq.response.Data.size()];
	for (int i=0; i<writeSeq.response.Data.size(); i++) begin 
    	w_data[i] = writeSeq.response.Data[i];
    end 

//@listitem Send a read burst to the same address.    
    `uvm_do_on_with(readSeq, p_sequencer.masterSeqr, {
        readSeq.address == same_address;
        readSeq.length  == same_length;
        readSeq.size    == same_size;
        readSeq.kind    == same_kind;
        readSeq.secure  == same_secure;
    })
  
    // After the completion of the Read sequence, the updated transaction can
    // be accessed in the sequence's field 'response'
//@listitem Check consistency. 
    for (int i=0; i<readSeq.response.Data.size(); i++) begin 
		if(readSeq.response.Data[i] != w_data[i]) begin 
			`uvm_fatal(get_type_name(), $sformatf("ERROR: DATA INCONSISTENCY in address (%d)\nData after WRITE: %d\nData after READ: %d",
				readSeq.response.StartAddress+i, w_data[i],readSeq.response.Data[i]));
		end
    end
      
    `uvm_info(get_type_name(), "Finished body of readAfterWriteSeq", UVM_LOW);

  endtask // body
//@olist/


endclass // readAfterWriteSeq



//@section modifyTransactionSeq
//@title modifyTransactionSeq
//@para Issues transactions and modifies them in BeforeSend* callbacks using transSet().
// ****************************************************************************
// Class : modifyTransactionSeq
// Desc. : This sequence performs one Write transaction and on snoop transaction. 
// All data items (master transaction, slave response) 
// are being modified in BeforeSend* callbacks using transSet()
// **************************************************************************** 
class modifyTransactionSeq extends axi4UvmVirtualSequence;

  `uvm_object_utils(modifyTransactionSeq)
  
  axi4UvmUserModifyTransactionSeq masterSeq;    
  axi4UvmUserModifyResponseSeq slaveRespSeq;
  
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "modifyTransactionSeq");
    super.new(name);        
  endfunction : new    

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
  
  	`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence modifyTransactionSeq started", UVM_LOW);
  
  	fork 
      begin
//@listitem Send a write burst and modify it.
        `uvm_do_on(masterSeq,p_sequencer.masterSeqr);
      end  	
      begin
//@listitem Send a write response and modify it.      	
        `uvm_do_on(slaveRespSeq,p_sequencer.slaveSeqr);
      end
    join_any
     
  endtask
//@olist

endclass

//@section unaligned_transfer_seq
//@title unaligned_transfer_seq 
//@para Issues unaligned transfers (this sequence sends unaligned address and unaligned data).
// ****************************************************************************
// Class : unaligned_transfer_seq
// Desc. : Sending unaligned transfers (this seq sends unaligned address and unaligned data)	
// **************************axi4UvmUserConfig**************************************************
class unaligned_transfer_seq extends axi4UvmVirtualSequence;
  
  `uvm_object_utils(unaligned_transfer_seq)
  

   myAxiTransaction masterBurst;
   denaliCdn_axiTransaction resp;
   uvm_sequence_item item;
   mySlaveResp slaveResp;

   integer status;
   
   function new(string name="unaligned_transfer_seq");
      super.new(name);
   endfunction

//@para <b>Test Requirements:</b>
//@ulist
//@listitem Allow un-aligned bursts.
//@ulist/
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();

    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence unaligned_transfer_seq started", UVM_LOW);
    
    #50000;

    // The rest are assigned by UVC
    // Turn off the constraintAligned constraint
//@listitem Send an un-aligned write burst.
    `uvm_info(get_type_name(), "Virtual sequence issuing a write master burst", UVM_LOW);
    

    `uvm_create_on(masterBurst,p_sequencer.masterSeqr)
     masterBurst.constraintAligned.constraint_mode(0);

    `uvm_rand_send_with(masterBurst, { 
       masterBurst.Direction ==  DENALI_CDN_AXI_DIRECTION_WRITE;
	   masterBurst.IdTag ==  2;
	   masterBurst.StartAddress == 'h0002;
       masterBurst.Length == 3;
       masterBurst.Size == DENALI_CDN_AXI_TRANSFERSIZE_WORD;
       masterBurst.Data.size() == 8;
       masterBurst.Kind == DENALI_CDN_AXI_BURSTKIND_INCR; 
       masterBurst.Access == DENALI_CDN_AXI_ACCESS_NORMAL;
	})
    
    //myMonitor.writeBurstEnded.wait_trigger();
    get_response(item, masterBurst.get_transaction_id());
    
    #200;

//@listitem Send an un-aligned read burst.     
    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence issuing a read master burst", UVM_LOW);
    
    `uvm_create_on(masterBurst,p_sequencer.masterSeqr)
     masterBurst.constraintAligned.constraint_mode(0);

    `uvm_rand_send_with(masterBurst,  { 
       masterBurst.Direction ==  DENALI_CDN_AXI_DIRECTION_READ;
	   masterBurst.StartAddress == 'h0002;
           masterBurst.Length == 3;
           masterBurst.Size == DENALI_CDN_AXI_TRANSFERSIZE_WORD;
           masterBurst.Kind == DENALI_CDN_AXI_BURSTKIND_INCR; 
           masterBurst.Access == DENALI_CDN_AXI_ACCESS_NORMAL;
	})
	
    //myMonitor.readBurstEnded.wait_trigger();
    get_response(item, masterBurst.get_transaction_id());

    #500000;
    
    `uvm_info(get_type_name(), "Finished body of unaligned_transfer_seq", UVM_LOW);
      
  endtask
//@olist/

endclass : unaligned_transfer_seq
//@section/

//@section exclusive_seq
//@title exclusive_seq 
//@para Issues Exclusive Sequences.
// ****************************************************************************
// Class : exclusive_seq
// Desc. : Sending Exclusive Sequences
// including multiple bursts and errors during send Send exclusive read burst, 
// followed by exclusive Write
// ****************************************************************************
class exclusive_seq extends axi4UvmVirtualSequence;

  `uvm_object_utils(exclusive_seq)
  
  myAxiTransaction masterBurst;
  axi4UvmUserModifyResponseSeq responseSeq;
  
  rand denaliCdn_axiTransferSizeT size;
  // multiple exclusive seq used in the sequence
  axi4UvmExclusiveSeq exclusiveSeq;
  axi4UvmExclusiveSeq exclusiveSeq2;
  axi4UvmExclusiveSeq exclusiveSeq3;
  axi4UvmExclusiveSeqSpacial exclusiveSpacial;
  
  axi4UvmBlockingWriteSeq writeSeq;
  axi4UvmBlockingReadSeq readSeq;
  reg [3:0] same_length = 4'h5;
  reg [63:0] same_address = 64'h0;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_WORD;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_INCR;
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "exclusive_seq");
    super.new(name);        
  endfunction : new    

//@para <b>Test Requirements:</b>
//@ulist
//@listitem Support for Exclusive transactions.
//@ulist/
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
  	`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence exclusive started", UVM_LOW);

//@listitem Send several times random burst followed by an exclusive sequence.
  	for(int indx =0; indx <10; ++indx) begin
  		// sending normal bursts
	  	`uvm_info(get_type_name(), "Virtual sequence generates a number of random bursts ", UVM_LOW);
	    for (int i=0; i<5; i++) begin
	    	`uvm_do_on_with(masterBurst, p_sequencer.masterSeqr,  { 
		        
		    })
	        #100;
	    end
	  	// sending and exclusive burst	
	  	`uvm_info(get_type_name(), "sending exclusive sequence ", UVM_LOW);
	  	`uvm_do_on_with(exclusiveSeq, p_sequencer.masterSeqr, {
	  		addressMin == 64'h0;
	  		addressMax == 64'hFFFF;
	  		})
	  		
	  	#50000;
 	end

//@listitem Send several multiple exclusive sequence followed parallely.
	// sending multiple exclusive at the same time	
	`uvm_info(get_type_name(), "Multiple exclusive test ", UVM_LOW);
	for(int i = 0; i<5; ++i)
	begin
	  	fork 
	      begin
		  	`uvm_do_on_with(exclusiveSeq, p_sequencer.masterSeqr, {
		  		addressMin == 64'h0;
		  		addressMax == 64'hFFFF;
		  		})
	      end
	      begin
		  	`uvm_do_on_with(exclusiveSeq2, p_sequencer.masterSeqr, {
		  		addressMin == 64'h0;
		  		addressMax == 64'hFFFF;
		  		})
	      end
	      begin
		  	`uvm_do_on_with(exclusiveSeq3, p_sequencer.masterSeqr, {
		  		addressMin == 64'h0;
		  		addressMax == 64'hFFFF;
		  		})
	      end
	    join_any
	end
	
//@listitem Send several random bursts again.	
    for (int i=0; i<5; i++) begin
	    	`uvm_do_on_with(masterBurst, p_sequencer.masterSeqr,  { 
		        
		    })
	        #100;
    end
    #5000
    
//@listitem Send locking bursts to make sure that all previous sent bursts are finished.
    `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr, {
                writeSeq.address == same_address;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure inside { DENALI_CDN_AXI_SECUREMODE_SECURE, DENALI_CDN_AXI_SECUREMODE_NONSECURE }; 
    })
    
    `uvm_do_on_with(readSeq, p_sequencer.masterSeqr, {
            readSeq.address == same_address;
        readSeq.length  == same_length;
        readSeq.size    == same_size;
        readSeq.kind    == same_kind;
        readSeq.secure inside { DENALI_CDN_AXI_SECUREMODE_SECURE, DENALI_CDN_AXI_SECUREMODE_NONSECURE }; 
    })

//@listitem Send several random bursts again.   
    for (int i=0; i<5; i++) begin
	    	`uvm_do_on_with(masterBurst, p_sequencer.masterSeqr,  { 
		        
		    })
	        #100;
    end
    #50000;
    
//@listitem Issue failed exclusive sequence.
    fork 
	      begin
	      	for(int ii =0; ii <5; ++ii) begin
			  	`uvm_do_on_with(exclusiveSeq, p_sequencer.masterSeqr, {
			  		addressMin == 64'h0;
			  		addressMax == 64'h0;
			  		})
	      	end
	      end
	      begin
			for (int i=0; i<15; i++) begin
				    	`uvm_do_on_with(masterBurst, p_sequencer.masterSeqr,  { 
					        masterBurst.Address == 64'h0;
					        masterBurst.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
					    })
			    end
	      end    
    join_any
        `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr, {
			  writeSeq.address == same_address;
			  writeSeq.length  == same_length;
			  writeSeq.size    == same_size;
			  writeSeq.kind    == same_kind;
			  writeSeq.secure inside { DENALI_CDN_AXI_SECUREMODE_SECURE, DENALI_CDN_AXI_SECUREMODE_NONSECURE }; 
		  })

	  `uvm_do_on_with(readSeq, p_sequencer.masterSeqr, {
			  readSeq.address == same_address;
			  readSeq.length  == same_length;
			  readSeq.size    == same_size;
			  readSeq.kind    == same_kind;
			  readSeq.secure inside { DENALI_CDN_AXI_SECUREMODE_SECURE, DENALI_CDN_AXI_SECUREMODE_NONSECURE }; 
		  })
		  
	#500000;
	    fork 
	      begin
	      	for(int ii =0; ii <5; ++ii) begin
			  	`uvm_do_on_with(exclusiveSeq, p_sequencer.masterSeqr, {
			  		addressMin == 64'h0;
			  		addressMax == 64'h0;
			  		})
	      	end
	      	`uvm_do_on_with(exclusiveSeq, p_sequencer.masterSeqr, {
		  		addressMin == 64'h0;
		  		addressMax == 64'h0;
		  		length ==1;
		  		})
	      end
	      begin
			for (int i=0; i<32; i++) begin
				`uvm_do_on_with(responseSeq,p_sequencer.slaveSeqr, {
	        		response == DENALI_CDN_AXI_RESPONSE_SLVERR;
	        
	        	})	
		    end
	      end    
    join_any
    `uvm_info(get_type_name(), "Sending Exclusive special ", UVM_LOW);
    
//@listitem Send an exclusive sequence designed to cover unique coverage corner areas.    
//  	`uvm_do_on_with(exclusiveSpacial, p_sequencer.masterSeqr, {
//		  		addressMin == 64'h0;
//		  		addressMax == 64'h0;
//		  		})
        `uvm_info(get_type_name(), "Done Exclusive special ", UVM_LOW);
    #100;
		  
		  
  endtask
//@olist/

endclass : exclusive_seq
//@section/

//@section access_seq
//@title access_seq 
//@para Issues transactions with various access permission values.
// ****************************************************************************
// Class : access_seq
// Desc. : Sending transactions with various access permission values
// ****************************************************************************
class access_seq extends axi4UvmVirtualSequence;
  
  `uvm_object_utils(access_seq)

   myAxiTransaction masterBurst;
   denaliCdn_axiTransaction resp;
   uvm_sequence_item item;
   mySlaveResp slaveResp;

   integer status;
   
   function new(string name="access_seq");
      super.new(name);
   endfunction

//@para <b>Test Requirements:</b>
//@ulist
//@listitem Support for privileged access transactions.
//@listitem Support for secure access transactions.
//@listitem Support for instruction access transactions.
//@ulist/
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();

    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence access_seq started", UVM_LOW);
    
    #50000;

//@listitem Issue a privileged access transaction. 
    `uvm_info(get_type_name(), "Virtual sequence issuing a privileged access transaction", UVM_LOW);

    `uvm_create_on(masterBurst,p_sequencer.masterSeqr)

    `uvm_rand_send_with(masterBurst, { 
       	   masterBurst.Privileged == DENALI_CDN_AXI_PRIVILEGEDMODE_PRIVILEGED;
	   masterBurst.StartAddress == 'h0010;
	})
    
    get_response(item, masterBurst.get_transaction_id());

    #200;

//@listitem Issue a secure access transaction.
    `uvm_info(get_type_name(), "Virtual sequence issuing a secure access transaction", UVM_LOW);

    `uvm_create_on(masterBurst,p_sequencer.masterSeqr)

    `uvm_rand_send_with(masterBurst, { 
       	   masterBurst.Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
	   masterBurst.StartAddress == 'h0020;
	})
    
    get_response(item, masterBurst.get_transaction_id());

    #200;

//@listitem Issue an instruction access transaction.
    `uvm_info(get_type_name(), "Virtual sequence issuing an instruction access transaction", UVM_LOW);

    `uvm_create_on(masterBurst,p_sequencer.masterSeqr)

    `uvm_rand_send_with(masterBurst, { 
       	   masterBurst.DataInstr == DENALI_CDN_AXI_FETCHKIND_INSTRUCTION;
	   masterBurst.StartAddress == 'h0030;
	})
    
    get_response(item, masterBurst.get_transaction_id());


    #500000;
    
    `uvm_info(get_type_name(), "Finished body of access_seq", UVM_LOW);
      
  endtask
//@olist/

endclass : access_seq
//@section/

//@section axcache_attr_seq
//@title axcache_attr_seq 
//@para Issues transactions with various AxCACHE transaction attributes.
// ****************************************************************************
// Class : axcache_attr_seq
// Desc. : Sequence to send transactions with various AxCACHE transaction attributes
// ****************************************************************************
class axcache_attr_seq extends axi4UvmVirtualSequence;
  
  `uvm_object_utils(axcache_attr_seq)

   myAxiTransaction masterBurst;
   denaliCdn_axiTransaction resp;
   uvm_sequence_item item;
   mySlaveResp slaveResp;

   integer status;
   
   function new(string name="axcache_attr_seq");
      super.new(name);
   endfunction

//@para <b>Test Requirements:</b>
//@ulist
//@listitem Support for bufferable transactions.
//@listitem Support for cacheable transactions.
//@listitem Support for read-allocate transactions.
//@listitem Support for write-allocate transactions.
//@ulist/
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();

    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence axcache_attr_seq started", UVM_LOW);
    
    #50000;

//@listitem Issue a bufferable transaction.
    `uvm_info(get_type_name(), "Virtual sequence issuing a bufferable transaction", UVM_LOW);

    `uvm_create_on(masterBurst,p_sequencer.masterSeqr)

    `uvm_rand_send_with(masterBurst, { 
       	   masterBurst.Bufferable == DENALI_CDN_AXI_BUFFERMODE_BUFFERABLE;
	   masterBurst.StartAddress == 'h0000;
	})
    
    get_response(item, masterBurst.get_transaction_id());

    #200;

//@listitem Issue a cacheable transaction.
    `uvm_info(get_type_name(), "Virtual sequence issuing a cacheable transaction", UVM_LOW);

    `uvm_create_on(masterBurst,p_sequencer.masterSeqr)

    `uvm_rand_send_with(masterBurst, { 
       	   masterBurst.Cacheable == DENALI_CDN_AXI_CACHEMODE_CACHEABLE;
	   masterBurst.StartAddress == 'h0010;
	})
    
    get_response(item, masterBurst.get_transaction_id());

    #200;

//@listitem Issue a read-allocate transaction.
    `uvm_info(get_type_name(), "Virtual sequence issuing a read-allocate transaction", UVM_LOW);

    `uvm_create_on(masterBurst,p_sequencer.masterSeqr)

    `uvm_rand_send_with(masterBurst, { 
       	   masterBurst.ReadAllocate == DENALI_CDN_AXI_READALLOCATE_READ_ALLOCATE;
	   masterBurst.StartAddress == 'h0020;
	})
    
    get_response(item, masterBurst.get_transaction_id());

    #200;

//@listitem Issue a write-allocate transaction.
    `uvm_info(get_type_name(), "Virtual sequence issuing a write-allocate transaction", UVM_LOW);

    `uvm_create_on(masterBurst,p_sequencer.masterSeqr)

    `uvm_rand_send_with(masterBurst, { 
       	   masterBurst.WriteAllocate == DENALI_CDN_AXI_WRITEALLOCATE_WRITE_ALLOCATE;
	   masterBurst.StartAddress == 'h0030;
	})
    
    get_response(item, masterBurst.get_transaction_id());


    #500000;
    
    `uvm_info(get_type_name(), "Finished body of axcache_attr_seq", UVM_LOW);
      
  endtask
//@olist/

endclass : axcache_attr_seq
//@section/

//@section read_reordering_seq
//@title read_reordering_seq 
//@para Issues read transactions and enabling re-order data transfers.
// ****************************************************************************
// Class : read_reordering_seq
// Desc. : Sequence to re-order data transfers in the read transaction
// ****************************************************************************
class read_reordering_seq extends axi4UvmVirtualSequence;
  
  `uvm_object_utils(read_reordering_seq)

   myAxiTransaction masterBurst;
   denaliCdn_axiTransaction resp;
   uvm_sequence_item item;
   mySlaveResp slaveResp;

   integer status;
   
   function new(string name="read_reordering_seq");
      super.new(name);
   endfunction

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();

    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence read_reordering_seq started", UVM_LOW);

//@listitem Configure active slave to perform re-ordering of read data.
    p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_ReadAcceptanceCapability,10);
    p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_ReadDataReorderingDepth,8);
    p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_ReadOrderingAlgorithm, DENALI_CDN_AXI_ORDERINGALGORITHM_ROUND_ROBIN);
    p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_StallAddrAfterMaxReadDepth,1);

    #50000;
    
//@listitem Issue several read burst. 
    `uvm_info(get_type_name(), "Virtual sequence issuing read master bursts", UVM_LOW);
    for(int i = 0; i < 50; i++) begin
      `uvm_do_on_with(masterBurst, p_sequencer.masterSeqr,  { 
           masterBurst.Direction ==  DENALI_CDN_AXI_DIRECTION_READ;
           masterBurst.StartAddress > 64'h00000;
           masterBurst.StartAddress < 64'h01FFF;
           masterBurst.Size == DENALI_CDN_AXI_TRANSFERSIZE_FOUR_WORDS;
           masterBurst.Length == 6;
      })
      #200;
    end

    #50000;

    `uvm_info(get_type_name(), "Finished body of reads_transfers_reordering_seq", UVM_LOW);
      
  endtask
//@olist/

endclass : read_reordering_seq
//@section/

//@section wr_resp_reorder_seq
//@title wr_resp_reorder_seq 
//@para Issues Write transactions and enabling re-order slave's response transfers.
// ****************************************************************************
// Class : wr_resp_reorder_seq
// Desc. : Sequence to re-order slave's response to write transactions
// NOTE: Doesn't work in AXI4 mode
// ****************************************************************************
class wr_resp_reorder_seq extends axi4UvmVirtualSequence;
  
  `uvm_object_utils(wr_resp_reorder_seq)

   myAxiTransaction masterBurst;
   denaliCdn_axiTransaction resp;
   uvm_sequence_item item;
   mySlaveResp slaveResp;

   integer status;
   
   function new(string name="wr_resp_reorder_seq");
      super.new(name);
   endfunction

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();

    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence wr_resp_reorder_seq started", UVM_LOW);

//@listitem Configure active slave to perform re-ordering of write responses.
      p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_WriteAcceptanceCapability,10);
      p_sequencer.pEnv.activeSlave.regInst.writeReg(DENALI_CDN_AXI_REG_OrderingAlgorithm, DENALI_CDN_AXI_ORDERINGALGORITHM_DATA_PHASES_END_TIMES);

    #50000;

//@listitem Issue several write burst. 
     `uvm_info(get_type_name(), "Virtual sequence issuing write master bursts", UVM_LOW);
     for(int i = 0; i < 50; i++) begin
      `uvm_do_on_with(masterBurst, p_sequencer.masterSeqr,  { 
           masterBurst.Direction ==  DENALI_CDN_AXI_DIRECTION_WRITE;
           masterBurst.StartAddress > 64'h00000;
           masterBurst.StartAddress < 64'h01FFF;
           masterBurst.Size == DENALI_CDN_AXI_TRANSFERSIZE_FOUR_WORDS;
           masterBurst.Length == 6;
	})
     #200;
     end

    #50000;

    `uvm_info(get_type_name(), "Finished body of wr_resp_reorder_seq", UVM_LOW);
      
  endtask
//@olist/

endclass : wr_resp_reorder_seq
//@section/

//@section burst_delay_seq
//@title burst_delay_seq
//@para Issues a master burst with various delays.
// ****************************************************************************
// Class : burst_delay_seq
// Desc. : Sequence to send master bursts with various delays.
// ****************************************************************************
class burst_delay_seq extends axi4UvmVirtualSequence;
  
  `uvm_object_utils(burst_delay_seq)

   myAxiTransaction masterBurst;
   denaliCdn_axiTransaction resp;
   uvm_sequence_item item;
   mySlaveResp slaveResp;

   integer status;
   
   function new(string name="burst_delay_seq");
      super.new(name);
   endfunction

//@para <b>Test Requirements:</b>
//@ulist
//@listitem Allow data before address bursts.
//@ulist/
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();

    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence burst_delay_seq started", UVM_LOW);

     // Disable WriteAddressOffset_const constraint.
//@listitem Issue Write transactions with the data transfers starting before the address phase (WriteAddressOffset > 0). 
    // Write transactions with the data transfers starting before the address phase
    for(int i = 0; i < 5; i++) begin
        `uvm_create_on(masterBurst,p_sequencer.masterSeqr)
	    // Disable the built-in constraint which sets WriteAddressOffset to 0
	    masterBurst.DisableWriteAddressOffset_const.constraint_mode(0);
	    `uvm_rand_send_with(masterBurst, {
	         masterBurst.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
	         masterBurst.WriteAddressOffset inside {[1:3]}; 
	         masterBurst.StartAddress > 64'h00000;
	         masterBurst.StartAddress < 64'h01FFF;
	    });
	    
	    #5000;
	     
    end

    #500;
    
//@listitem Turn off Arraysizes_const_TransfersChannelDelay constraint and TransmitDelay_const constraint.
//@listitem Issue read transactions with TransmitDelay and TransfersChannelDelay. RREADY signal control is set to Oscillating.
    // read transaction with the following delays
    // TransmitDelay to delay start of address phase
    // TransfersChannelDelay to define delays between data transfers
    // RREADY signal control is set to Oscillating
    for(int i = 0; i < 5; i++) begin
	    `uvm_create_on(masterBurst, p_sequencer.masterSeqr);
	    // Turn off the built-in constraints
	    masterBurst.Arraysizes_const_TransfersChannelDelay.constraint_mode(0);
	    masterBurst.TransmitDelay_const.constraint_mode(0);
	
	    `uvm_rand_send_with(masterBurst, {
			masterBurst.Direction == DENALI_CDN_AXI_DIRECTION_READ;
			masterBurst.Length == 4;
			masterBurst.StartAddress > 'h0000;
			masterBurst.StartAddress < 'h1000;
			masterBurst.TransmitDelay inside {[1:5]};
			masterBurst.RreadyControl == DENALI_CDN_AXI_READYCONTROL_OSCILLATING;
			masterBurst.TransfersChannelDelay.size() == 4;
			masterBurst.TransfersChannelDelay[0] == 2;
			masterBurst.TransfersChannelDelay[1] == 4;
			masterBurst.TransfersChannelDelay[2] == 6;
			masterBurst.TransfersChannelDelay[3] == 8;
	    })
	    
	    #5000;
	    
    end

    #50000;

    `uvm_info(get_type_name(), "Finished body of burst_delay_seq", UVM_LOW);
      
  endtask
//@olist/

endclass : burst_delay_seq
//@section/

//@section random_auser_seq
//@title random_auser_seq
//@para Issues a master burst with random A*User signals.
// ****************************************************************************
// Class : random_auser_seq
// Desc. : Sequence to send a master burst with random A*User signals.
// ****************************************************************************
class random_auser_seq extends axi4UvmVirtualSequence;
  
  
  `uvm_object_utils(random_auser_seq)

   myAxiTransaction masterBurst;
   denaliCdn_axiTransaction resp;
   uvm_sequence_item item;
   mySlaveResp slaveResp;

   integer status;
   
   function new(string name="random_auser_seq");
      super.new(name);
   endfunction

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();

    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence random_auser_seq started", UVM_LOW);

//@listitem Issue a write burst with random A*User.
    `uvm_create_on(masterBurst,p_sequencer.masterSeqr)

    `uvm_rand_send_with(masterBurst, {
        masterBurst.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
        masterBurst.StartAddress > 64'h00000;
        masterBurst.StartAddress < 64'h01FFF;
        masterBurst.Length == 2;
        masterBurst.Size == DENALI_CDN_AXI_TRANSFERSIZE_FOUR_WORDS;
        masterBurst.Auser.size()== 8; 
/*
		foreach (masterBurst.Auser[index]) begin
		    masterBurst.Auser[index] = $urandom_range(2,10); // Randomize each entry in Auser
		end
*/
    })

    #5000;

    `uvm_info(get_type_name(), "Finished body of random_auser_seq", UVM_LOW);
      
  endtask
//@olist/

endclass : random_auser_seq
//@section/

//@section WriteAddressOffsetSeq
//@title WriteAddressOffsetSeq
//@para Issues write burst with Data before Address, using several write address offset sequence with different definitions.
// ****************************************************************************
// Class : WriteAddressOffsetSeq
// Desc. : Sending Write Data before Address, using several write address offset sequence with different definitions.
// ****************************************************************************
class WriteAddressOffsetSeq extends axi4UvmVirtualSequence;

  `uvm_object_utils(WriteAddressOffsetSeq)
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "WriteAddressOffsetSeq");
    super.new(name);        
  endfunction : new    

  axi4UvmBlockingWriteSeq writeSeq;
  
  reg [3:0] same_length = 4'h5;
  
  reg [63:0] same_address = 64'h0;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_WORD;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_INCR;
  
  axi4UvmWriteOffsetSeq offsetSeq;
  
//@para <b>Test Requirements:</b>
//@ulist
//@listitem Allow data before address bursts.
//@ulist/

//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
	  	`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Starting WriteAddressOffsetSeq sequence ", UVM_LOW);

//@listitem Send several random transmitDelay bursts.
	 for (int i=0; i<50; i++) begin
	 	`uvm_do_on_with(offsetSeq, p_sequencer.masterSeqr, {
	 		offsetSeq.transmitDelay >100;
	 		offsetSeq.address ==same_address;
	 	})

		 #100;
	 end
	 #50000;
	 
//@listitem Issue write bursts with different address offset and large delay (writeAddressOffset > 0).
	 for(int j=0; j < 3; j++) begin
		 for (int offsetIndx=0; offsetIndx<20; offsetIndx++) begin
            `uvm_do_on_with(offsetSeq, p_sequencer.masterSeqr, {
            	offsetSeq.length == 20;
            	offsetSeq.writeAddressOffset == offsetIndx;
            	offsetSeq.transmitDelay ==0;
            	offsetSeq.address ==same_address;
				  })
			 
			 #10000;
		 end
	 end
	 `uvm_info(get_type_name(), "finishing write address offset test sequence ", UVM_LOW);
	 
	 `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr, {
			 writeSeq.address == same_address;
			 writeSeq.length  == same_length;
			 writeSeq.size    == same_size;
			 writeSeq.kind    == same_kind;
			 writeSeq.secure inside { DENALI_CDN_AXI_SECUREMODE_SECURE, DENALI_CDN_AXI_SECUREMODE_NONSECURE };
		 })
    #50000;
  endtask
//@olist/

endclass : WriteAddressOffsetSeq 
//@section/

//@section MultiBytesBackdoorSeq
//@title MultiBytesBackdoorSeq
//@para Do some memory read/write for lists of bytes. .
// ****************************************************************************
// Class : MultiBytesBackdoorSeq
// Desc. : Sending Write Data before Address, using several write address offset sequence with different definitions.
// ****************************************************************************
class MultiBytesBackdoorSeq extends axi4UvmVirtualSequence;

  `uvm_object_utils(MultiBytesBackdoorSeq)
  axi4UvmUserActiveSlaveAgent myAgent;
  axi4UvmBlockingReadSeq readSeq;
  reg [63:0] read_address = 64'h1000;
  reg [63:0] read_address2 = 64'h1040;
  reg [63:0] read_address3 = 64'h1080;
  reg [63:0] read_address4 = 64'h1120;
  reg [7:0] data [];
  reg [7:0] readData[];
  integer res;
  integer cache_line_size = 64;
  
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "MultiBytesBackdoorSeq");
    super.new(name);        
  endfunction : new    
  
//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

virtual function integer validateData(integer size, reg [7:0] data1 [], reg [7:0] data2 [], ref integer res); 
	for (int i=0; i <= size-1 ; i++) begin 
		//`uvm_info(get_type_name(), $sformatf("Data[%d] =  %d",i,readData[i]), UVM_LOW);
		if(data1[i] != data2[i]) begin 
			res = i;
			return 1;
		end
	end
	return 0;
	
endfunction

//@olist
  virtual task body();
  if (!$cast(myAgent, p_sequencer.pEnv.activeSlave))
			`uvm_fatal(get_type_name(), "Unable to render embedded object: File ($cast(myAgent, p_sequencer.pEnv.activeSlave has FAILED) not found.!!");
  
  	`uvm_info(get_type_name(), "Virtual sequence multiBytebackdoorSeq started", UVM_LOW);


#100

	//@listitem Using inst defined method (memoryWrite4Bytes) to backdoor write 4 bytes to memory. 
	data = new[4];
 	readData = new[4];
  	for (int i=0; i<data.size(); i++) begin
      data[i] = i;
    end
    
    
    //@listitem Write 4 bytes to memeory. 
    
    void'(myAgent.inst.memoryWrite4Bytes(read_address, data));
    
    //@listitem Read 4 bytes from memeory.    
    void'(myAgent.inst.memoryRead4Bytes(read_address, readData));
    
    //@listitem Validating the data read from memory.
    if (validateData(4, readData, data, res) == 1) begin
    	`uvm_fatal(get_type_name(), $sformatf("ERROR: WRONG DATA IN READ for address (%d)\nData in back-door: %d\nData after READ: %d",
				read_address+res, res,readData[res]));
    end
     
    
    //@listitem Using a read sequence to validate the data from the memory.
    `uvm_do_on_with(readSeq, p_sequencer.masterSeqr, {
        readSeq.address == read_address;
        readSeq.size == DENALI_CDN_AXI_TRANSFERSIZE_WORD;
        readSeq.kind    == DENALI_CDN_AXI_BURSTKIND_WRAP;
        readSeq.secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    })
    
    if (validateData(4, readSeq.response.Data, data, res) == 1) begin
    	`uvm_fatal(get_type_name(), $sformatf("ERROR: WRONG DATA IN READ for address (%d)\nData in back-door: %d\nData after READ: %d",
				readSeq.response.StartAddress+res, res,readSeq.response.Data[res]));
    end
    
    #10000;

	//@listitem Using method defined in the agent (axi4UvmUserAgent.sv:30) to backdoor write 8 bytes to memory. Useful for user defined action before/after the write. 
 	data = new[8];
 	readData = new[8];
  	for (int i=0; i<data.size(); i++) begin
      data[i] = i;
    end
    
  //@listitem Write 8 bytes to memeory.
  void'(p_sequencer.pEnv.activeSlave.memoryWrite8Bytes(read_address2,data));
  
  //@listitem Read 8 bytes to memeory.
  void'(myAgent.inst.memoryRead8Bytes(read_address2, readData));
  
  //@listitem Validating the data read from memory.
  if (validateData(8, readData, data, res) == 1) begin
    	`uvm_fatal(get_type_name(), $sformatf("ERROR: WRONG DATA IN READ for address (%d)\nData in back-door: %d\nData after READ: %d",
				read_address+res, res,readData[res]));
    end
  
//@listitem Using a read sequence to validate the data from the memory. 
  	`uvm_do_on_with(readSeq, p_sequencer.masterSeqr, {
        readSeq.address == read_address2;
        readSeq.size == DENALI_CDN_AXI_TRANSFERSIZE_WORD;
        readSeq.kind    == DENALI_CDN_AXI_BURSTKIND_WRAP;
        readSeq.secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    })
    
    if (validateData(8, readSeq.response.Data, data, res) == 1) begin
    	`uvm_fatal(get_type_name(), $sformatf("ERROR: WRONG DATA IN READ for address (%d)\nData in back-door: %d\nData after READ: %d",
				readSeq.response.StartAddress+res, res,readSeq.response.Data[res]));
    end
    
    #10000;
    
    
//@listitem Using general method (memoryWriteByteList) to backdoor write 16 bytes to memory. Possible byte count are: 4,8,16,32,64.
    data = new[16];
 	readData = new[16];
  	for (int i=0; i<data.size(); i++) begin
      data[i] = i;
    end
  
  //@listitem Write 16 bytes to memeory. 
  void'(myAgent.inst.memoryWriteByteList(16,read_address3,data));
  
  //@listitem Read 16 bytes to memeory.
  void'(myAgent.inst.memoryReadByteList(16,read_address3, readData));

//@listitem Validating the data read from memory.
  if (validateData(16, readData, data, res) == 1) begin
    	`uvm_fatal(get_type_name(), $sformatf("ERROR: WRONG DATA IN READ for address (%d)\nData in back-door: %d\nData after READ: %d",
				read_address+res, res,readData[res]));
    end
  
//@listitem Using a read sequence to validate the data from the memory.
  	`uvm_do_on_with(readSeq, p_sequencer.masterSeqr, {
        readSeq.address == read_address3;
        readSeq.size == DENALI_CDN_AXI_TRANSFERSIZE_WORD;
        readSeq.kind    == DENALI_CDN_AXI_BURSTKIND_WRAP;
        readSeq.secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    })
    

    if (validateData(16, readSeq.response.Data, data, res) == 1) begin
    	`uvm_fatal(get_type_name(), $sformatf("ERROR: WRONG DATA IN READ for address (%d)\nData in back-door: %d\nData after READ: %d",
				readSeq.response.StartAddress+res, res,readSeq.response.Data[res]));
    end
    
        #10000;
    //@listitem Using general method (memoryWriteByteList) to backdoor write 32 bytes to memory. Possible byte count are: 4,8,16,32,64.
    data = new[32];
 	readData = new[32];
  	for (int i=0; i<data.size(); i++) begin
      data[i] = i;
    end
    
  //@listitem Write 32 bytes to memeory.
  void'(myAgent.inst.memoryWriteByteList(32,read_address4,data));
  
  //@listitem Read 32 bytes to memeory.
  void'(myAgent.inst.memoryReadByteList(32,read_address4, readData));
  
  //@listitem Validated the data.
  if (validateData(16, readData, data, res) == 1) begin
    	`uvm_fatal(get_type_name(), $sformatf("ERROR: WRONG DATA IN READ for address (%d)\nData in back-door: %d\nData after READ: %d",
				read_address+res, res,readData[res]));
    end
  
  
//@listitem Using a read sequence to validate the data from the memory.
  	`uvm_do_on_with(readSeq, p_sequencer.masterSeqr, {
        readSeq.address == read_address4;
        readSeq.size == DENALI_CDN_AXI_TRANSFERSIZE_WORD;
        readSeq.kind    == DENALI_CDN_AXI_BURSTKIND_WRAP;
        readSeq.secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    })    
	#100
    if (validateData(32, readSeq.response.Data, data, res) == 1) begin
    	`uvm_fatal(get_type_name(), $sformatf("ERROR: WRONG DATA IN READ for address (%d)\nData in back-door: %d\nData after READ: %d",
				readSeq.response.StartAddress+res, res,readSeq.response.Data[res]));
    end
    
    #100;
    
  
    
     
  endtask
//@olist/

endclass : MultiBytesBackdoorSeq
//@section/


//@section allVirtualSequences
//@title allVirtualSequences
//@para Run several loops of all the virutal sequences one after another.
// ****************************************************************************
// Class : allVirtualSequences
// Desc. : This sequence run all the other virtual sequences several times.  
// ****************************************************************************	
class allVirtualSequences extends axi4UvmVirtualSequence;
	 `uvm_object_utils(allVirtualSequences)
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "allVirtualSequences");
    super.new(name);        
  endfunction : new  
  
  readAfterWriteSeq readAfterWriteSeq;
  modifyTransactionSeq modifyTransactionSeq;
  unaligned_transfer_seq unalignedTransferSeq;
  exclusive_seq exclusiveSeq;
  access_seq accessSeq;
  axcache_attr_seq axcacheAttrSeq;
  read_reordering_seq readReorderingSeq;
  wr_resp_reorder_seq wrRespReorderSeq;
  burst_delay_seq burstDelaySeq;
  perChannalDelaySeq perChannalDelaySeq;
  perTransactionDelaySeq perTransactionDelaySeq;
  IdBasedReorderingSeq IdBasedReorderingSeq;
  blockingNonBlockingSeq blockingNonBlockingSeq;
  cross4kBoundarySeq cross4kBoundarySeq;
  
  virtual task body();
	  	`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Starting allVirtualSequences sequence ", UVM_LOW);
	  	for(int j=0; j < 1; j++) begin
	  		#1000;  
	  		`uvm_do(readAfterWriteSeq);
	  		#1000;
	  		`uvm_do(modifyTransactionSeq);
	  		#1000;
	  		`uvm_do(unalignedTransferSeq);
	  		#1000;
	  		`uvm_do(exclusiveSeq);
	  		#1000;
	  		`uvm_do(accessSeq);
	  		#1000;
	  		`uvm_do(axcacheAttrSeq);
	  		#1000;
	  		`uvm_do(readReorderingSeq);
	  		#1000;
	  		`uvm_do(wrRespReorderSeq);
	  		#1000;
	  		`uvm_do(burstDelaySeq);
	  		#1000;
	  		`uvm_do(perChannalDelaySeq);
	  		#1000;
	  		`uvm_do(perTransactionDelaySeq);
	  		#1000;
	  		`uvm_do(IdBasedReorderingSeq);
	  		#1000;
	  		`uvm_do(blockingNonBlockingSeq);
	  		#1000;
	  		`uvm_do(cross4kBoundarySeq);
	  	end
  endtask
endclass : allVirtualSequences


//@section allSequences
//@title allSequences
//@para Run several loops of all the sequences one after another.
// ****************************************************************************
// Class : allSequences
// Desc. : This sequence run all the regular sequences several times.  
// ****************************************************************************	
class allSequences extends axi4UvmVirtualSequence;
	 `uvm_object_utils(allSequences)
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "allSequences");
    super.new(name);        
  endfunction : new  
  
  userSimpleSeq userSimpleSeq;
  axi4UvmReadSeq axi4UvmReadSeq;
  axi4UvmBlockingReadSeq axi4UvmBlockingReadSeq;
  axi4UvmWriteSeq axi4UvmWriteSeq;
  axi4UvmBlockingWriteSeq axi4UvmBlockingWriteSeq;
  axi4UvmUserModifyTransactionSeq axi4UvmUserModifyTransactionSeq;
  axi4UvmExclusiveSeq axi4UvmExclusiveSeq;
  axi4UvmExclusiveSeqSpacial axi4UvmExclusiveSeqSpacial;
  axi4UvmWriteOffsetSeq axi4UvmWriteOffsetSeq;
  axi4UvmUserModifyResponseSeq axi4UvmUserModifyResponseSeq;
  
  rand reg [63:0] same_address = 64'h0055c0; 
   denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_WORD;
  
   constraint All_Sequences_Const
  {
  	same_address > 64'h01000;
  	same_address < 64'h10000;
  	same_address % (1 << (same_size -1 ))  == 0;
  }
  
  virtual task body();
	  	`uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Starting allSequences sequence ", UVM_LOW);
	  	for(int j=0; j < 1; j++) begin
	  		
	  		`uvm_info(get_type_name(), "NORMAL_SEQUENCE_IDENTIFIER - Sequence axi4UvmReadSeq ", UVM_LOW);
	  		`uvm_do_on_with(axi4UvmReadSeq, p_sequencer.masterSeqr, { 
	  			axi4UvmReadSeq.address == same_address;
	  			axi4UvmReadSeq.size == same_size;
	  		});
	  		#1000;
	  		`uvm_info(get_type_name(), "NORMAL_SEQUENCE_IDENTIFIER - Sequence axi4UvmBlockingReadSeq ", UVM_LOW);
	  		`uvm_do_on_with(axi4UvmBlockingReadSeq, p_sequencer.masterSeqr, { 
	  			axi4UvmBlockingReadSeq.address == same_address;
	  			axi4UvmBlockingReadSeq.size == same_size;
	  		});
	  		#1000;
	  		`uvm_info(get_type_name(), "NORMAL_SEQUENCE_IDENTIFIER - Sequence axi4UvmWriteSeq ", UVM_LOW);
	  		`uvm_do_on_with(axi4UvmWriteSeq, p_sequencer.masterSeqr, { 
	  			axi4UvmWriteSeq.address == same_address;
	  			axi4UvmWriteSeq.size == same_size;
	  		});
	  		#1000;
	  		`uvm_info(get_type_name(), "NORMAL_SEQUENCE_IDENTIFIER - Sequence axi4UvmBlockingWriteSeq ", UVM_LOW);
	  		`uvm_do_on_with(axi4UvmBlockingWriteSeq, p_sequencer.masterSeqr, { 
	  			axi4UvmBlockingWriteSeq.address == same_address;
	  			axi4UvmBlockingWriteSeq.size == same_size;
	  		});
	  		#1000;
	  		`uvm_info(get_type_name(), "NORMAL_SEQUENCE_IDENTIFIER - Sequence axi4UvmUserModifyTransactionSeq ", UVM_LOW);
	  		`uvm_do_on(axi4UvmUserModifyTransactionSeq, p_sequencer.masterSeqr);
	  		#1000;
	  		`uvm_info(get_type_name(), "NORMAL_SEQUENCE_IDENTIFIER - Sequence axi4UvmExclusiveSeq ", UVM_LOW);
	  		`uvm_do_on_with(axi4UvmExclusiveSeq, p_sequencer.masterSeqr, { 
	  			axi4UvmExclusiveSeq.addressMin == 64'h01000;
	  			axi4UvmExclusiveSeq.addressMax == 64'h10000;
	  		});
	  		#1000;
	  		`uvm_info(get_type_name(), "NORMAL_SEQUENCE_IDENTIFIER - Sequence axi4UvmExclusiveSeqSpacial ", UVM_LOW);
	  		`uvm_do_on_with(axi4UvmExclusiveSeqSpacial, p_sequencer.masterSeqr, { 
	  			axi4UvmExclusiveSeqSpacial.addressMin == 64'h01000;
	  			axi4UvmExclusiveSeqSpacial.addressMax == 64'h10000;
	  		});
	  		#1000;
	  		`uvm_info(get_type_name(), "NORMAL_SEQUENCE_IDENTIFIER - Sequence axi4UvmWriteOffsetSeq ", UVM_LOW);
	  		`uvm_do_on_with(axi4UvmWriteOffsetSeq, p_sequencer.masterSeqr, { 
	  			axi4UvmWriteOffsetSeq.address == same_address;
	  		});
	  		#1000;
	  		`uvm_info(get_type_name(), "NORMAL_SEQUENCE_IDENTIFIER - Sequence axi4UvmUserModifyResponseSeq ", UVM_LOW);
	  		`uvm_do_on(axi4UvmUserModifyResponseSeq, p_sequencer.masterSeqr);
	  		#1000;
	  		
	  	end
  endtask
endclass : allSequences

// Sequence library to execute all AXI sequences
class axi4_seq_lib extends uvm_sequence_library;

	`uvm_object_utils(axi4_seq_lib)
	`uvm_sequence_library_utils(axi4_seq_lib)

	function new (string name = "axi4_seq_lib");
	  super.new(name);

	  // built-in fields
	  min_random_count = 10;
	  max_random_count = 25;
	  //sequence_count = 200;

	  // sequences includes in the library
	  add_typewide_sequence(modifyTransactionSeq::get_type());
	  add_typewide_sequence(unaligned_transfer_seq::get_type());
	  add_typewide_sequence(exclusive_seq::get_type());
	  add_typewide_sequence(access_seq::get_type());
	  add_typewide_sequence(axcache_attr_seq::get_type());
	  add_typewide_sequence(read_reordering_seq::get_type());
	  add_typewide_sequence(wr_resp_reorder_seq::get_type());
	  add_typewide_sequence(burst_delay_seq::get_type());
	  add_typewide_sequence(perChannalDelaySeq::get_type());
	  add_typewide_sequence(perTransactionDelaySeq::get_type());
	  add_typewide_sequence(IdBasedReorderingSeq::get_type());
	  add_typewide_sequence(blockingNonBlockingSeq::get_type());

	  init_sequence_library();
	endfunction
endclass : axi4_seq_lib


class writeFromMaster0toSlave0Seq extends axi4UvmVirtualSequence;
    
  axi4UvmBlockingWriteSeq writeSeq;

  reg [63:0] same_address = 64'h1770;
  reg [7:0] same_length = 4;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_INCR;
  denaliCdn_axiSecureModeT same_secure = DENALI_CDN_AXI_SECUREMODE_NONSECURE;

  reg [7:0] w_data[];

  `uvm_object_utils_begin(writeFromMaster0toSlave0Seq)
  	`uvm_field_object(writeSeq, UVM_ALL_ON)
  `uvm_object_utils_end

   
  function new(string name="writeFromMaster0toSlave0Seq");
    super.new(name);
    `uvm_create(writeSeq);
  endfunction // new

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
  
    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence writeFromMaster0toSlave0Seq started", UVM_LOW);
    #1000;

    `uvm_info(get_type_name(), "Sending a Write transaction from master 0 to slave 0", UVM_LOW);
//@listitem Send a write burst to a specific address.     
    `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr, {
        writeSeq.address == same_address;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })
    
    // After the completion of the Write sequence, the updated transaction can
    // be accessed in the sequence's field 'response' 

	w_data = new[writeSeq.response.Data.size()];
	for (int i=0; i<writeSeq.response.Data.size(); i++) begin 
    	w_data[i] = writeSeq.response.Data[i];
      $display("writeSeq.response.Data.size():: %0d",writeSeq.response.Data.size());
      $display("wdata value::%0h",w_data[i]);
    end 
      
    `uvm_info(get_type_name(), "Finished body of writeFromMaster0toSlave0Seq", UVM_LOW);

  endtask // body


endclass // writeFromMaster0toSlave0Seq

class WriteFromMaster0ToSlave1Seq extends axi4UvmVirtualSequence;
    
  axi4UvmBlockingWriteSeq writeSeq;

  reg [63:0] same_address = 64'h3070;
  reg [7:0] same_length = 6;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_INCR;
  denaliCdn_axiSecureModeT same_secure = DENALI_CDN_AXI_SECUREMODE_NONSECURE;

  reg [7:0] w_data[];

  `uvm_object_utils_begin(WriteFromMaster0ToSlave1Seq)
  	`uvm_field_object(writeSeq, UVM_ALL_ON)
  `uvm_object_utils_end

   
  function new(string name="WriteFromMaster0ToSlave1Seq");
    super.new(name);
    `uvm_create(writeSeq);
  endfunction // new

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
  
    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence WriteFromMaster0ToSlave1Seq started", UVM_LOW);
    #1000;

    `uvm_info(get_type_name(), "Sending a Write transaction from master 0 to slave 1", UVM_LOW);

//@listitem Send a write burst to a specific address.     
    `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr, {
        writeSeq.address == same_address;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })
    
    // After the completion of the Write sequence, the updated transaction can
    // be accessed in the sequence's field 'response' 

	w_data = new[writeSeq.response.Data.size()];
	for (int i=0; i<writeSeq.response.Data.size(); i++) begin 
    	w_data[i] = writeSeq.response.Data[i];
      $display("writeSeq.response.Data.size():: %0d",writeSeq.response.Data.size());
      $display("wdata value::%0h",w_data[i]);
    end 
      
    `uvm_info(get_type_name(), "Finished body of WriteFromMaster0ToSlave1Seq", UVM_LOW);

  endtask // body


endclass // WriteFromMaster0ToSlave1Seq

class WriteFromMaster1ToSlave0Seq extends axi4UvmVirtualSequence;
    
  axi4UvmBlockingWriteSeq writeSeq;

  reg [63:0] same_address = 64'h1000;
  reg [7:0] same_length = 6;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_INCR;
  denaliCdn_axiSecureModeT same_secure = DENALI_CDN_AXI_SECUREMODE_NONSECURE;

  reg [7:0] w_data[];

  `uvm_object_utils_begin(WriteFromMaster1ToSlave0Seq)
  	`uvm_field_object(writeSeq, UVM_ALL_ON)
  `uvm_object_utils_end

   
  function new(string name="WriteFromMaster1ToSlave0Seq");
    super.new(name);
    `uvm_create(writeSeq);
  endfunction // new

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
  
    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence WriteFromMaster1ToSlave0Seq started", UVM_LOW);
    #1000;

    `uvm_info(get_type_name(), "Sending a Write transaction from master 1 to slave 0", UVM_LOW);

//@listitem Send a write burst to a specific address.     
    `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr1, {
        writeSeq.address == same_address;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })
    
    // After the completion of the Write sequence, the updated transaction can
    // be accessed in the sequence's field 'response' 

	w_data = new[writeSeq.response.Data.size()];
	for (int i=0; i<writeSeq.response.Data.size(); i++) begin 
    	w_data[i] = writeSeq.response.Data[i];
      $display("writeSeq.response.Data.size():: %0d",writeSeq.response.Data.size());
      $display("wdata value::%0h",w_data[i]);
    end 
      
    `uvm_info(get_type_name(), "Finished body of WriteFromMaster1ToSlave0Seq", UVM_LOW);

  endtask // body


endclass // WriteFromMaster1ToSlave0Seq

class WriteFromMaster1ToSlave1Seq extends axi4UvmVirtualSequence;
    
  axi4UvmBlockingWriteSeq writeSeq;

  reg [63:0] same_address = 64'h3020;
  reg [7:0] same_length = 4;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_INCR;
  denaliCdn_axiSecureModeT same_secure = DENALI_CDN_AXI_SECUREMODE_NONSECURE;

  reg [7:0] w_data[];

  `uvm_object_utils_begin(WriteFromMaster1ToSlave1Seq)
  	`uvm_field_object(writeSeq, UVM_ALL_ON)
  `uvm_object_utils_end

   
  function new(string name="WriteFromMaster1ToSlave1Seq");
    super.new(name);
    `uvm_create(writeSeq);
  endfunction // new

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
  
    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence WriteFromMaster1ToSlave1Seq started", UVM_LOW);
    #1000;

    `uvm_info(get_type_name(), "Sending a Write transaction from master 1 to slave 1", UVM_LOW);

//@listitem Send a write burst to a specific address.     
    `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr1, {
        writeSeq.address == same_address;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })
    
    // After the completion of the Write sequence, the updated transaction can
    // be accessed in the sequence's field 'response' 

	w_data = new[writeSeq.response.Data.size()];
	for (int i=0; i<writeSeq.response.Data.size(); i++) begin 
    	w_data[i] = writeSeq.response.Data[i];
      $display("writeSeq.response.Data.size():: %0d",writeSeq.response.Data.size());
      $display("wdata value::%0h",w_data[i]);
    end 
      
    `uvm_info(get_type_name(), "Finished body of WriteFromMaster1ToSlave1Seq", UVM_LOW);

  endtask // body
endclass // WriteFromMaster1ToSlave1Seq

class writeFromMaster0toSlave0AndSlave1Seq extends axi4UvmVirtualSequence;
    
  axi4UvmBlockingWriteSeq writeSeq;

  reg [63:0] same_address = 64'h1070;
  reg [7:0] same_length = 2;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_INCR;
  denaliCdn_axiSecureModeT same_secure = DENALI_CDN_AXI_SECUREMODE_NONSECURE;

  reg [7:0] w_data[];

  `uvm_object_utils_begin(writeFromMaster0toSlave0AndSlave1Seq)
  	`uvm_field_object(writeSeq, UVM_ALL_ON)
  `uvm_object_utils_end

   
  function new(string name="writeFromMaster0toSlave0AndSlave1Seq");
    super.new(name);
    `uvm_create(writeSeq);
  endfunction // new

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
  
    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence writeFromMaster0toSlave0AndSlave1Seq started", UVM_LOW);
    #1000;

    `uvm_info(get_type_name(), "Sending a Write transaction from master 0 to slave 0 and slave 1", UVM_LOW);

     `uvm_info(get_type_name(), "First Sending a Write transaction from master 0 to slave 0 ", UVM_LOW);
//@listitem Send a write burst to a specific address.     
    `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr, {
        writeSeq.address == same_address;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })
    
    // After the completion of the Write sequence, the updated transaction can
    // be accessed in the sequence's field 'response' 

	w_data = new[writeSeq.response.Data.size()];
	for (int i=0; i<writeSeq.response.Data.size(); i++) begin 
    	w_data[i] = writeSeq.response.Data[i];
      $display("writeSeq.response.Data.size():: %0d",writeSeq.response.Data.size());
      $display("wdata value::%0h",w_data[i]);
    end 

 `uvm_info(get_type_name(), "Sending a Write transaction to slave 1", UVM_LOW);
   `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr, {
        writeSeq.address == 64'h2800;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })
    
    // After the completion of the Write sequence, the updated transaction can
    // be accessed in the sequence's field 'response' 
	w_data = new[writeSeq.response.Data.size()];
	for (int i=0; i<writeSeq.response.Data.size(); i++) begin 
    	w_data[i] = writeSeq.response.Data[i];
      $display("writeSeq.response.Data.size():: %0d",writeSeq.response.Data.size());
      $display("wdata value::%0h",w_data[i]);
    end   
// #10ns;
      
    `uvm_info(get_type_name(), "Finished body of writeFromMaster0toSlave0AndSlave1Seq", UVM_LOW);

  endtask // body


endclass // writeFromMaster0toSlave0AndSlave1Seq

class WriteTransactionWithSameIdTagSeq extends axi4UvmVirtualSequence;
    
  writeTranswithSameIdTag writeSeq;

  reg [63:0] same_address = 64'h1799;
  reg [7:0] same_length = 6;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_INCR;
  denaliCdn_axiSecureModeT same_secure = DENALI_CDN_AXI_SECUREMODE_NONSECURE;

  reg [7:0] w_data[];

  `uvm_object_utils_begin(WriteTransactionWithSameIdTagSeq)
  	`uvm_field_object(writeSeq, UVM_ALL_ON)
  `uvm_object_utils_end

   
  function new(string name="WriteTransactionWithSameIdTagSeq");
    super.new(name);
    `uvm_create(writeSeq);
  endfunction // new

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
  
    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence WriteTransactionWithSameIdTagSeq started", UVM_LOW);
    #1000;

    `uvm_info(get_type_name(), "Sending a Write transaction from master 0 and master 1 to slave 0 ", UVM_LOW);

     `uvm_info(get_type_name(), "First Sending a Write transaction from master 0 to slave 0 ", UVM_LOW);
//@listitem Send a write burst to a specific address.     
    `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr, {
        writeSeq.address == same_address;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })
    
    // After the completion of the Write sequence, the updated transaction can
    // be accessed in the sequence's field 'response' 

	w_data = new[writeSeq.response.Data.size()];
	for (int i=0; i<writeSeq.response.Data.size(); i++) begin 
    	w_data[i] = writeSeq.response.Data[i];
      $display("writeSeq.response.Data.size():: %0d",writeSeq.response.Data.size());
      $display("wdata value::%0h",w_data[i]);
    end 

 `uvm_info(get_type_name(), "Sending a Write transaction to slave 1", UVM_LOW);
   `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr1, {
        writeSeq.address == 64'h1800;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })
    
    // After the completion of the Write sequence, the updated transaction can
    // be accessed in the sequence's field 'response' 
	w_data = new[writeSeq.response.Data.size()];
	for (int i=0; i<writeSeq.response.Data.size(); i++) begin 
    	w_data[i] = writeSeq.response.Data[i];
      $display("writeSeq.response.Data.size():: %0d",writeSeq.response.Data.size());
      $display("wdata value::%0h",w_data[i]);
    end   
// #10ns;
      
    `uvm_info(get_type_name(), "Finished body of WriteTransactionWithSameIdTagSeq", UVM_LOW);

  endtask // body
endclass // WriteTransactionWithSameIdTag


class ReadAxiSeq extends axi4UvmVirtualSequence;
  // axi4UvmBlockingWriteSeq writeseq;
  axi4UvmBlockingReadSeq readSeq;

  reg [63:0] same_address = 64'h304;
  reg [7:0] same_length = 4;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_INCR;
  denaliCdn_axiSecureModeT same_secure = DENALI_CDN_AXI_SECUREMODE_NONSECURE;

  reg [7:0] w_data[];

  `uvm_object_utils_begin(ReadAxiSeq)
  	`uvm_field_object(readSeq, UVM_ALL_ON)
    // `uvm_field_object(writeseq, UVM_ALL_ON)
  `uvm_object_utils_end

   
  function new(string name="ReadAxiSeq");
    super.new(name);
    `uvm_create(readSeq);
    // `uvm_create(writeseq);
  endfunction // new

  virtual task body();
  
    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence ReadAxiSeq started", UVM_LOW);
    #1000;
    `uvm_info(get_type_name(), "Sending a Read transaction to slave 0", UVM_LOW);
//@listitem Send a Read burst to a specific address.     
`uvm_do_on_with(readSeq, p_sequencer.masterSeqr, {
        readSeq.address == same_address;
        readSeq.length  == same_length;
        readSeq.size    == same_size;
        readSeq.kind    == same_kind;
        readSeq.secure  == same_secure;
    })
    
`uvm_info(get_type_name(), "Sending a Read transaction to slave 1", UVM_LOW);
  `uvm_do_on_with(readSeq, p_sequencer.masterSeqr, {
        readSeq.address == 64'h2020;
        readSeq.length  == same_length;
        readSeq.size    == same_size;
        readSeq.kind    == same_kind;
        readSeq.secure  == same_secure;
    })  
    `uvm_info(get_type_name(), "Finished body of ReadAxiSeq", UVM_LOW);

  endtask // body


endclass // ReadAxiSeq



class WriteBurstSeq extends axi4UvmVirtualSequence;
    
  axi4UvmBlockingWriteSeq writeSeq;

  reg [63:0] same_address = 64'h200;
  reg [7:0] same_length = 4;
  denaliCdn_axiTransferSizeT same_size = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
  denaliCdn_axiBurstKindT same_kind = DENALI_CDN_AXI_BURSTKIND_WRAP;
  denaliCdn_axiSecureModeT same_secure = DENALI_CDN_AXI_SECUREMODE_NONSECURE;

  reg [7:0] w_data[];

  `uvm_object_utils_begin(WriteBurstSeq)
  	`uvm_field_object(writeSeq, UVM_ALL_ON)
  `uvm_object_utils_end

   
  function new(string name="WriteBurstSeq");
    super.new(name);
    `uvm_create(writeSeq);
  endfunction // new

//@para <b>Test Requirements:</b> None
//@para <b>Test Scenario:</b>

//@olist
  virtual task body();
  
    `uvm_info(get_type_name(), "VIRTUAL_SEQUENCE_IDENTIFIER - Virtual sequence WriteAxiSeq started", UVM_LOW);
    #1000;

    `uvm_info(get_type_name(), "Sending a Write transaction to slave 1", UVM_LOW);

//@listitem Send a write burst to a specific address.  
for(int i=0; i<10;i++ )begin   
    `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr, {
        writeSeq.address == same_address;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })
    same_address = same_address + 4;
end
    
    // After the completion of the Write sequence, the updated transaction can
    // be accessed in the sequence's field 'response' 

 /*`uvm_info(get_type_name(), "Sending a Write transaction to slave 0", UVM_LOW);
   `uvm_do_on_with(writeSeq, p_sequencer.masterSeqr, {
        writeSeq.address == 64'h2020;
        writeSeq.length  == same_length;
        writeSeq.size    == same_size;
        writeSeq.kind    == same_kind;
        writeSeq.secure  == same_secure;
    })*/
      
    `uvm_info(get_type_name(), "Finished body of WriteAxiSeq", UVM_LOW);

  endtask // body
endclass // WriteBurstSeq




