`ifndef _USER_CDN_AXI_SEQ_LIB
`define _USER_CDN_AXI_SEQ_LIB

class myAxiTransaction extends denaliCdn_axiTransaction;

	`uvm_object_utils(myAxiTransaction)

	axi4UvmUserConfig cfg;

	//Chosen Segment Index
	rand int chosenSegmentIndex;

	function new(string name = "myAxiTransaction");
		super.new(name);       
	endfunction : new 

	function void pre_randomize();
		cdnAxiUvmSequencer seqr;
		super.pre_randomize();      
		
		if (!$cast(seqr,get_sequencer())) begin
			`uvm_fatal(get_type_name(),"failed $cast(seqr,get_sequencer())");
		end

		if (!$cast(cfg,seqr.pAgent.cfg)) begin
			`uvm_fatal(get_type_name(),"failed $cast(cfg,seqr.pAgent.cfg))");
		end

		this.SpecVer = (cfg.spec_ver == CDN_AXI_CFG_SPEC_VER_AMBA4 ? DENALI_CDN_AXI_SPECVERSION_AMBA4 :DENALI_CDN_AXI_SPECVERSION_AMBA3);    
		this.SpecSubtype = (cfg.spec_subtype == CDN_AXI_CFG_SPEC_SUBTYPE_ACE ? DENALI_CDN_AXI_SPECSUBTYPE_ACE : DENALI_CDN_AXI_SPECSUBTYPE_BASE);
		this.SpecInterface = (cfg.spec_interface == CDN_AXI_CFG_SPEC_INTERFACE_FULL ?  DENALI_CDN_AXI_SPECINTERFACE_FULL : DENALI_CDN_AXI_SPECINTERFACE_LITE);

		if (cfg.pins.rdata.size >= 1024 || cfg.pins.wdata.size >= 1024) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_K_BITS;
		end
		else if (cfg.pins.rdata.size >= 512 || cfg.pins.wdata.size >= 512) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_SIXTEEN_WORDS;
		end
		else if (cfg.pins.rdata.size >= 256 || cfg.pins.wdata.size >= 256) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_EIGHT_WORDS;
		end
		else if (cfg.pins.rdata.size >= 128 || cfg.pins.wdata.size >= 128) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_FOUR_WORDS;
		end
		else if (cfg.pins.rdata.size >= 64 || cfg.pins.wdata.size >= 64) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_TWO_WORDS;
		end
		else if (cfg.pins.rdata.size >= 32 || cfg.pins.wdata.size >= 32) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_WORD;
		end
		else if (cfg.pins.rdata.size >= 16 || cfg.pins.wdata.size >= 16) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_HALFWORD;
		end
		else if (cfg.pins.rdata.size >= 8 || cfg.pins.wdata.size >= 8) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
		end
		
		this.SpecVer.rand_mode(0);
		this.SpecSubtype.rand_mode(0);
		this.SpecInterface.rand_mode(0);
		this.BurstMaxSize.rand_mode(0);			

	endfunction    

	constraint burstSizeCfgConstraint {                
		BurstSize <= (cfg.pins.rdata.size/8); 
		BurstSize <= (cfg.pins.wdata.size/8);
	}

	constraint burstIdCfgConstraint {        
		IdTag < (1 <<  cfg.pins.awid.size);
		IdTag < (1 << cfg.pins.arid.size);                  
	}

	//NOTE: This constraints is not enough , it doesn't take into considerations length and size to be inside memory segment.
	constraint burstAddresscfgConstraint {  

		solve chosenSegmentIndex before StartAddress;

		chosenSegmentIndex < cfg.memory_segments.size();
		chosenSegmentIndex >= 0;

		foreach (cfg.memory_segments[ii]) {
			if (ii == chosenSegmentIndex) {
				StartAddress < cfg.memory_segments[ii].high_address;
				StartAddress >= cfg.memory_segments[ii].low_address;
			}
		}
	}

endclass

// ****************************************************************************
// Class : mySlaveResp
// Desc. : This class extends myAxiTransaction class
// ****************************************************************************
class mySlaveResp extends myAxiTransaction;
  `uvm_object_utils(mySlaveResp)

  function new(string name = "mySlaveResp");
    super.new(name);
  endfunction : new   

  constraint wr_resp_dist {
  	Resp dist { DENALI_CDN_AXI_RESPONSE_OKAY   := 50,
                DENALI_CDN_AXI_RESPONSE_SLVERR := 50 
    };        
  }
  
  constraint memory_consistency {
  	 // If data exists in main memory, return it from there and ignore the trnasaction's Data field.
  	 IgnoreConstraints == 1;
  }

endclass : mySlaveResp


class userSimpleSeq extends cdnAxiUvmSequence;

	// ***************************************************************
	// Use the UVM registration macro for this class.
	// ***************************************************************
	`uvm_object_utils(userSimpleSeq)  

	// ***************************************************************
	// Method : new
	// Desc.  : Call the constructor of the parent class.
	// ***************************************************************
	function new(string name = "userSimpleSeq");
		super.new(name);        
	endfunction : new

	denaliCdn_axiTransaction trans;

	virtual task pre_body();
	   `ifdef UVM_POST_VERSION_1_1
	   var uvm_phase starting_phase = get_starting_phase();
	   `endif
	   
		if (starting_phase != null) begin
			starting_phase.raise_objection(this);
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

	virtual task body();
		
		#1000;
		  `uvm_info(get_type_name(), "Running Basic Test", UVM_LOW)
		for (int i=0; i<5; i++) begin
			`uvm_do_with(trans,{
				trans.Type inside {DENALI_CDN_AXI_TR_Read, DENALI_CDN_AXI_TR_Write};
			});
			get_response(trans);     
		end
		
		// sending "BIG" bursts
		for (int i=0; i<10; i++) begin
			`uvm_do_with(trans, {
				trans.Type inside {DENALI_CDN_AXI_TR_Read, DENALI_CDN_AXI_TR_Write};
				trans.Length > 16;
			});
			get_response(trans);     
		end
		#100;  
	endtask : body

endclass

class crossing4kBoundaryModifyTransactionSeq extends cdnAxiUvmModifyTransactionSequence;

  // ***************************************************************
  // Use the UVM registration macro for this class.
  // ***************************************************************
  `uvm_object_utils(crossing4kBoundaryModifyTransactionSeq)
  
  rand denaliCdn_axiDirectionT direction;
     
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "crossing4kBoundaryModifyTransactionSeq");
    super.new(name);        
  endfunction : new
  
  myAxiTransaction trans; 
  
  virtual task pre_body();
     `ifdef UVM_POST_VERSION_1_1
	 var uvm_phase starting_phase = get_starting_phase();
      `endif    
    if (starting_phase != null) begin
      starting_phase.raise_objection(this);
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


  virtual task body();
    denaliCdn_axiTransaction response;

    `uvm_do_with(trans, {
    	trans.Direction == direction;
    })    

    //Wait till transaction is transmitted to DUT
    //   we want the sequence to end only after the transaction transmission is completed.
    //   when sequence ends no modification will take effect
    get_response(response,trans.get_transaction_id());    
        
    `uvm_info(get_type_name(), "Finished Transaction modification", UVM_LOW)
  endtask : body

  // Modify the transaction in BeofreSend callback using TransSet()
  // This is where we decide what are the transaction's attributes (fields) we want to modify 
  // and which items should it effect. 
  virtual function void modifyTransaction(denaliCdn_axiTransaction tr);
    bit status;
    //in this case we can choose to modify only a specific burst this sequence has generated.
    //if there was no condition then the modification would have occurred to any burst being sent.
    //by default only bursts created in this sequence will be affected.
    if (trans != null && tr.UserData ==  trans.UserData)    
    begin
      `uvm_info(get_type_name(), "Starting Transaction modification", UVM_LOW)      
      tr.StartAddress[11:0] = 12'hff0; // close to 4K boundary
      
      // cross 4K boundary
      tr.Kind = DENALI_CDN_AXI_BURSTKIND_INCR;
      tr.Size = DENALI_CDN_AXI_TRANSFERSIZE_FOUR_WORDS;
      tr.Length = 10;
      
      //Update the model transaction with the new values
      //   transSet() is being used to update that fields were changed.
      status = tr.transSet();
          
      `uvm_info(get_type_name(), "Finished Transaction modification", UVM_LOW)
    end
  endfunction

endclass : crossing4kBoundaryModifyTransactionSeq

class axi4UvmReadSeq extends cdnAxiUvmSequence;

  // ---------------------------------------------------------------
  // The sequence item (transaction) that will be randomized and
  // passed to the driver.
  // ---------------------------------------------cdnAxiUvmSequencer------------------
  rand myAxiTransaction trans;
  
  // ---------------------------------------------------------------
  // Possible input address to the sequence
  // ---------------------------------------------------------------
  rand reg [63:0] address;
  
  // ---------------------------------------------------------------
  // Possible input length to the sequence
  // ---------------------------------------------------------------
  rand reg[7:0] length;
  
  // ---------------------------------------------------------------
  // Possible input size to the sequence
  // ---------------------------------------------------------------
  rand denaliCdn_axiTransferSizeT size;
  
  // ---------------------------------------------------------------
  // Possible input kind to the sequence
  // ---------------------------------------------------------------
  rand denaliCdn_axiBurstKindT kind;
  
  // ---------------------------------------------------------------
  // Possible input secure to the sequence (ARPROT[1])
  // ---------------------------------------------------------------
  rand denaliCdn_axiSecureModeT secure;

  // ---------------------------------------------------------------
  // Use the UVM Sequence macro for this class.
  // ---------------------------------------------------------------
  
  
  constraint Read_Sequence_Const
  {
  	length > 0;
  	size != DENALI_CDN_AXI_TRANSFERSIZE_UNSET;
  	kind inside { DENALI_CDN_AXI_BURSTKIND_FIXED, DENALI_CDN_AXI_BURSTKIND_INCR, DENALI_CDN_AXI_BURSTKIND_WRAP };
   	kind == DENALI_CDN_AXI_BURSTKIND_WRAP -> length inside { 2, 4, 8, 16 };
   		kind == DENALI_CDN_AXI_BURSTKIND_FIXED -> length < 16 ;
   	secure != DENALI_CDN_AXI_SECUREMODE_UNSET;
  }
  
  `uvm_object_utils_begin(axi4UvmReadSeq)
    `uvm_field_object(trans, UVM_ALL_ON)
  `uvm_object_utils_end
  
  `uvm_declare_p_sequencer(cdnAxiUvmSequencer)

  // ---------------------------------------------------------------
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ---------------------------------------------------------------
  function new(string name = "axi4UvmReadSeq");
    super.new(name);
  endfunction : new

  // ---------------------------------------------------------------
  // Method : body
  // Desc.  : AXI READ Transaction.
  // ---------------------------------------------------------------
  virtual task body();
    `uvm_do_with(trans,
    	{trans.Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	trans.StartAddress == address;
    	trans.Length == length;
    	trans.Size == size;
    	trans.Kind == kind;
    	trans.Secure == secure;
    	
    });
  endtask : body
  
endclass



// ----------------------------------------------------------------------------
// Class : axi4UvmBlockingReadSeq
// This class extends the uvm_sequence and implements a blocking Read Transaction.
// The sequence finishes only once the Read transaction in done.
// ----------------------------------------------------------------------------
class axi4UvmBlockingReadSeq extends axi4UvmReadSeq;
    
  // ---------------------------------------------------------------
  // The sequence item (transaction) that will is returned
  // with the Ended callback once the transaction in done.
  // ---------------------------------------------------------------
  denaliCdn_axiTransaction response;
  uvm_sequence_item item;
  
  // ---------------------------------------------------------------
  // Use the UVM Sequence macro for this class.
  // ---------------------------------------------------------------
  `uvm_object_utils_begin(axi4UvmBlockingReadSeq)
    `uvm_field_object(response, UVM_ALL_ON)
  `uvm_object_utils_end
  
  // ---------------------------------------------------------------
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ---------------------------------------------------------------
  function new(string name = "axi4UvmBlockingReadSeq");
    super.new(name);
  endfunction : new
	
  virtual task body();
    `uvm_do_with(trans,
    	{trans.Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	trans.StartAddress == address;
    	trans.Length == length;
    	trans.Size == size;
    	trans.Kind == kind;
    	trans.Secure == secure;
    });
    
    // Blocking sequence. wait until response.   
    get_response(item, trans.get_transaction_id());
    if (!$cast(response, item)) 
    	`uvm_fatal(get_type_name(), "$cast(response, item) call failed!");
    
  endtask : body
  
endclass

// ----------------------------------------------------------------------------
// Class : axi4UvmWriteSeq
// This class extends the uvm_sequence and implements a Write Transaction.
// ----------------------------------------------------------------------------
class axi4UvmWriteSeq extends cdnAxiUvmSequence;

  // ---------------------------------------------------------------
  // The sequence item (transaction) that will be randomized and
  // passed to the driver.
  // ---------------------------------------------------------------
  rand myAxiTransaction trans;
  
  // ---------------------------------------------------------------
  // Possible input address to the sequence
  // ---------------------------------------------------------------
  rand reg [63:0] address;
  
  // ---------------------------------------------------------------
  // Possible input length to the sequence
  // ---------------------------------------------------------------
  rand reg[7:0] length;
  
  // ---------------------------------------------------------------
  // Possible input size to the sequence
  // ---------------------------------------------------------------
  rand denaliCdn_axiTransferSizeT size;
  
  // ---------------------------------------------------------------
  // Possible input kind to the sequence
  // ---------------------------------------------------------------
  rand denaliCdn_axiBurstKindT kind;
  
  // ---------------------------------------------------------------
  // Possible input secure to the sequence (AWPROT[1])
  // ---------------------------------------------------------------
  rand denaliCdn_axiSecureModeT secure;
  
  constraint Write_Sequence_Const
  {
  	length > 0;
  	size != DENALI_CDN_AXI_TRANSFERSIZE_UNSET;
  	kind inside { DENALI_CDN_AXI_BURSTKIND_FIXED, DENALI_CDN_AXI_BURSTKIND_INCR, DENALI_CDN_AXI_BURSTKIND_WRAP };
   	kind == DENALI_CDN_AXI_BURSTKIND_WRAP -> length inside { 2, 4, 8, 16 };
   	kind == DENALI_CDN_AXI_BURSTKIND_FIXED -> length < 16 ;
   	secure != DENALI_CDN_AXI_SECUREMODE_UNSET;
  }
  
  // ---------------------------------------------------------------
  // Use the UVM Sequence macro for this class.
  // ---------------------------------------------------------------
  `uvm_object_utils_begin(axi4UvmWriteSeq)
    `uvm_field_object(trans, UVM_ALL_ON)
  `uvm_object_utils_end
  
  `uvm_declare_p_sequencer(cdnAxiUvmSequencer)

  // ---------------------------------------------------------------
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ---------------------------------------------------------------
  function new(string name = "axi4UvmWriteSeq");
    super.new(name);
  endfunction : new

  // ---------------------------------------------------------------
  // Method : body
  // Desc.  : AXI Write Transaction.
  // ---------------------------------------------------------------
  virtual task body();
    `uvm_do_with(trans,
    	{trans.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	trans.StartAddress == address;
    	trans.Length == length;
    	trans.Size == size;
    	trans.Kind == kind;
    	trans.Secure == secure;
    });
  endtask : body

endclass


class axi4UvmBlockingWriteSeq extends axi4UvmWriteSeq;
    
  // ---------------------------------------------------------------
  // The sequence item (transaction) that will is returned
  // with the Ended callback once the transaction in done.
  // ---------------------------------------------------------------
  denaliCdn_axiTransaction response;
  uvm_sequence_item item;
  
  // ---------------------------------------------------------------
  // Use the UVM Sequence macro for this class.
  // ---------------------------------------------------------------
  `uvm_object_utils_begin(axi4UvmBlockingWriteSeq)
    `uvm_field_object(response, UVM_ALL_ON)
  `uvm_object_utils_end
  
  // ---------------------------------------------------------------
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ---------------------------------------------------------------
  function new(string name = "axi4UvmBlockingWriteSeq");
    super.new(name);
  endfunction : new
	
  virtual task body();
    `uvm_do_with(trans,
    	{trans.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	trans.StartAddress == address;
    	trans.Length == length;
    	trans.Size == size;
    	trans.Kind == kind;
    	trans.Secure == secure; 
    });
   
    
    // Blocking sequence. wait until response.   
    get_response(item, trans.get_transaction_id());
    if (!$cast(response, item)) 
    	`uvm_fatal(get_type_name(), "$cast(response, item) call failed!");
    	
  endtask : body

endclass 

class writeTranswithSameIdTag extends axi4UvmWriteSeq;
    
  // ---------------------------------------------------------------
  // The sequence item (transaction) that will is returned
  // with the Ended callback once the transaction in done.
  // ---------------------------------------------------------------
  denaliCdn_axiTransaction response;
  uvm_sequence_item item;
  
  // ---------------------------------------------------------------
  // Use the UVM Sequence macro for this class.
  // ---------------------------------------------------------------
  `uvm_object_utils_begin(writeTranswithSameIdTag)
    `uvm_field_object(response, UVM_ALL_ON)
  `uvm_object_utils_end
  
  // ---------------------------------------------------------------
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ---------------------------------------------------------------
  function new(string name = "writeTranswithSameIdTag");
    super.new(name);
  endfunction : new
	
  virtual task body();
    `uvm_do_with(trans,
    	{trans.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	trans.StartAddress == address;
    	trans.Length == length;
    	trans.Size == size;
    	trans.Kind == kind;
    	trans.Secure == secure;
      trans.IdTag == 5;  
    });
   
    
    // Blocking sequence. wait until response.   
    get_response(item, trans.get_transaction_id());
    if (!$cast(response, item)) 
    	`uvm_fatal(get_type_name(), "$cast(response, item) call failed!");
    	
  endtask : body

endclass : writeTranswithSameIdTag




class axi4UvmUserModifyTransactionSeq extends cdnAxiUvmModifyTransactionSequence;

  // ***************************************************************
  // Use the UVM registration macro for this class.
  // ***************************************************************
  `uvm_object_utils(axi4UvmUserModifyTransactionSeq)
     
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "axi4UvmUserModifyTransactionSeq");
    super.new(name);        
  endfunction : new
  
  myAxiTransaction trans; 
  
  virtual task pre_body();
	   `ifdef UVM_POST_VERSION_1_1
		   var uvm_phase starting_phase = get_starting_phase();
	   `endif
    if (starting_phase != null) begin
      starting_phase.raise_objection(this);
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


  virtual task body();
    denaliCdn_axiTransaction response;

    `uvm_do_with(trans,
    {trans.Direction == DENALI_CDN_AXI_DIRECTION_READ;
      trans.StartAddress < 64'h1001;
      trans.IdTag < (1 << 4);
      trans.Size == DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
      trans.Length == 8;
      trans.Kind == DENALI_CDN_AXI_BURSTKIND_INCR;
    })    

    //Wait till transaction is transmitted to DUT
    //   we want the sequence to end only after the transaction transmission is completed.
    //   when sequence ends no modification will take effect
    get_response(response,trans.get_transaction_id());    
        
    `uvm_info(get_type_name(), "Finished Transaction modification", UVM_LOW)
  endtask : body

  // Modify the transaction in BeofreSend callback using TransSet()
  // This is where we decide what are the transaction's attributes (fields) we want to modify 
  // and which items should it effect. 
  virtual function void modifyTransaction(denaliCdn_axiTransaction tr);
    bit status;
    //in this case we can choose to modify only a specific burst this sequence has generated.
    //if there was no condition then the modification would have occurred to any burst being sent.
    //by default only bursts created in this sequence will be affected.
    if (trans != null && tr.UserData ==  trans.UserData)    
    begin
      `uvm_info(get_type_name(), "Starting Transaction modification", UVM_LOW)      
      tr.Kind = DENALI_CDN_AXI_BURSTKIND_WRAP;
      tr.StartAddress = 64'h2500;
      tr.TransmitDelay = 10;
      tr.IdTag = 'h30;
      /*for (int i=0; i<tr.TransfersChannelDelay.size(); i++) begin 
      	tr.TransfersChannelDelay[i] = 2;
      end*/
      //Update the model transaction with the new values
      //   transSet() is being used to update that fields were changed.
      status = tr.transSet();
          
      `uvm_info(get_type_name(), "Finished Transaction modification", UVM_LOW)
    end
  endfunction

endclass


// ----------------------------------------------------------------------------
// Class : axi4UvmExclusiveSeq
// sends an exclusive read burst followed by a matching write burst
// ----------------------------------------------------------------------------
class axi4UvmExclusiveSeq extends cdnAxiUvmSequence;

  rand myAxiTransaction transRead;
  rand myAxiTransaction transWrite;
  
  // ---------------------------------------------------------------
  // Possible input address range
  // ---------------------------------------------------------------
  rand reg [63:0] addressMax;
  rand reg [63:0] addressMin;
  constraint address_const
  {
  	addressMax >=addressMin;
  }
  rand reg [31:0] length;
  constraint length_range_const
  {
   length inside { 1, 2, 4, 8, 16 };
  }
  // ---------------------------------------------------------------
  // Possible ID for the seq
  // ---------------------------------------------------------------
  rand reg [13:0] idTag;

  denaliCdn_axiTransaction response;
  uvm_sequence_item item;
  
  // ---------------------------------------------------------------
  // Use the UVM Sequence macro for this class.
  // ---------------------------------------------------------------
  `uvm_object_utils_begin(axi4UvmExclusiveSeq)
    `uvm_field_object(transRead, UVM_ALL_ON)
    `uvm_field_object(transWrite, UVM_ALL_ON)
  `uvm_object_utils_end
  
  // ---------------------------------------------------------------
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ---------------------------------------------------------------
  function new(string name = "axi4UvmExclusiveSeq");
    super.new(name);
  endfunction : new
	
  virtual task body();
  	`uvm_create(transRead);
  	`uvm_create(transWrite);
  	// turn off burst type constraint 
  	transRead.normal_access_const.constraint_mode(0);
  	transWrite.normal_access_const.constraint_mode(0);
  	
  	// send read burst  	
    `uvm_rand_send_with(transRead,
    	{transRead.Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	transRead.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transRead.StartAddress <= addressMax;
    	transRead.StartAddress >= addressMin;
    	transRead.IdTag == idTag;
    	transRead.Length == length;
    });
    
    // Blocking sequence. wait untill read is finished before sending the write 
    get_response(item, transRead.get_transaction_id());
    if (!$cast(response, item)) 
    	`uvm_fatal(get_type_name(), "$cast(response, item) call failed!");
    	
    	
    #1000;
    // send the matching write burst
    `uvm_rand_send_with(transWrite,
    	{transWrite.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	transWrite.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transWrite.StartAddress == transRead.StartAddress;
    	transWrite.Length == transRead.Length;
    	transWrite.Size == transRead.Size;
    	transWrite.Kind == transRead.Kind;
    	transWrite.IdTag == transRead.IdTag;
    	transWrite.Cacheable == transRead.Cacheable;
    	transWrite.Privileged == transRead.Privileged;
    	transWrite.Secure == transRead.Secure;
    	transWrite.DataInstr == transRead.DataInstr;
    	transWrite.Bufferable == transRead.Bufferable;
    	transWrite.Qos == transRead.Qos;
    });
    
    
    transRead.normal_access_const.constraint_mode(1);
  	transWrite.normal_access_const.constraint_mode(1);

    
  endtask : body
endclass : axi4UvmExclusiveSeq	
// ----------------------------------------------------------------------------
// Class : axi4UvmExclusiveSeqSpacial
// his is a unique sequence used to feel coverage holes. the sequences sends 
// several co-exising bursts
// ----------------------------------------------------------------------------
class axi4UvmExclusiveSeqSpacial extends cdnAxiUvmSequence;

  rand myAxiTransaction transRead;
  rand myAxiTransaction transWrite;
  rand myAxiTransaction transRead2;
  rand myAxiTransaction transWrite2;
  rand myAxiTransaction transRead3;
  rand myAxiTransaction transWrite3;
  rand myAxiTransaction transRead4;
  rand myAxiTransaction transWrite4;
  
  // ---------------------------------------------------------------
  // Possible input address range
  // ---------------------------------------------------------------
  rand reg [63:0] addressMax;
  rand reg [63:0] addressMin;
  constraint address_const
  {
  	addressMax >=addressMin;
  }
  rand reg [31:0] length;
  constraint length_range_const
  {
   length inside { 1, 2, 4, 8, 16 };
  }
  // ---------------------------------------------------------------
  // Possible ID for the seq
  // ---------------------------------------------------------------

  denaliCdn_axiTransaction response;
  uvm_sequence_item item;
  
  // ---------------------------------------------------------------
  // Use the UVM Sequence macro for this class.
  // ---------------------------------------------------------------
  `uvm_object_utils_begin(axi4UvmExclusiveSeqSpacial)
    `uvm_field_object(transRead, UVM_ALL_ON)
    `uvm_field_object(transWrite, UVM_ALL_ON)
  `uvm_object_utils_end
  
  // ---------------------------------------------------------------
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ---------------------------------------------------------------
  function new(string name = "axi4UvmExclusiveSeqSpacial");
    super.new(name);
  endfunction : new
	
  virtual task body();
  	`uvm_create(transRead);
  	`uvm_create(transWrite);
  	  	`uvm_create(transRead2);
  	`uvm_create(transWrite2);
  	  	`uvm_create(transRead3);
  	`uvm_create(transWrite3);
  	  	`uvm_create(transRead4);
  	`uvm_create(transWrite4);
  	// turn off burst type constraint 
  	transRead.normal_access_const.constraint_mode(0);
  	transWrite.normal_access_const.constraint_mode(0);
  	transRead2.normal_access_const.constraint_mode(0);
  	transWrite2.normal_access_const.constraint_mode(0);
  	transRead3.normal_access_const.constraint_mode(0);
  	transWrite3.normal_access_const.constraint_mode(0);
  	transRead4.normal_access_const.constraint_mode(0);
  	transWrite4.normal_access_const.constraint_mode(0);
  	
  	// send read burst  	
    `uvm_rand_send_with(transRead,
    	{transRead.Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	transRead.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transRead.StartAddress <= addressMax;
    	transRead.StartAddress >= addressMin;
    	transRead.IdTag == 1;
    	transRead.Length == length;
    });
    `uvm_rand_send_with(transRead2,
    	{transRead2.Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	transRead2.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transRead2.StartAddress <= addressMax;
    	transRead2.StartAddress >= addressMin;
    	transRead2.IdTag == 2;
    	transRead2.Length == length;
    });
    `uvm_rand_send_with(transRead3,
    	{transRead3.Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	transRead3.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transRead3.StartAddress <= addressMax;
    	transRead3.StartAddress >= addressMin;
    	transRead3.IdTag == 3;
    	transRead3.Length == length;
    });
    `uvm_rand_send_with(transRead4,
    	{transRead4.Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	transRead4.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transRead4.StartAddress <= addressMax;
    	transRead4.StartAddress >= addressMin;
    	transRead4.IdTag == 1;
    	transRead4.Length == length;
    });
    
    // Blocking sequence. wait untill read is finished before sending the write 
    get_response(item, transRead.get_transaction_id());
       `uvm_rand_send_with(transRead,
    	{transRead.Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	transRead.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transRead.StartAddress <= addressMax;
    	transRead.StartAddress >= addressMin;
    	transRead.IdTag == 4;
    	transRead.Length == length;
    });
    get_response(item, transRead.get_transaction_id());
    get_response(item, transRead2.get_transaction_id());
    get_response(item, transRead3.get_transaction_id());
    get_response(item, transRead4.get_transaction_id());
    
    	
    	
    #1000;
    // send the matching write burst
    `uvm_rand_send_with(transWrite,
    	{transWrite.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	transWrite.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transWrite.StartAddress == transRead.StartAddress;
    	transWrite.Length == transRead.Length;
    	transWrite.Size == transRead.Size;
    	transWrite.Kind == transRead.Kind;
    	transWrite.IdTag == transRead.IdTag;
    	transWrite.Cacheable == transRead.Cacheable;
    	transWrite.Privileged == transRead.Privileged;
    	transWrite.Secure == transRead.Secure;
    	transWrite.DataInstr == transRead.DataInstr;
    	transWrite.Bufferable == transRead.Bufferable;
    	transWrite.Qos == transRead.Qos;
    });
        `uvm_rand_send_with(transWrite2,
    	{transWrite2.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	transWrite2.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transWrite2.StartAddress == transRead2.StartAddress;
    	transWrite2.Length == transRead2.Length;
    	transWrite2.Size == transRead2.Size;
    	transWrite2.Kind == transRead2.Kind;
    	transWrite2.IdTag == transRead2.IdTag;
    	transWrite2.Cacheable == transRead2.Cacheable;
    	transWrite2.Privileged == transRead2.Privileged;
    	transWrite2.Secure == transRead2.Secure;
    	transWrite2.DataInstr == transRead2.DataInstr;
    	transWrite2.Bufferable == transRead2.Bufferable;
    	transWrite2.Qos == transRead2.Qos;
    });
        `uvm_rand_send_with(transWrite3,
    	{transWrite3.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	transWrite3.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transWrite3.StartAddress == transRead3.StartAddress;
    	transWrite3.Length == transRead3.Length;
    	transWrite3.Size == transRead3.Size;
    	transWrite3.Kind == transRead3.Kind;
    	transWrite3.IdTag == transRead3.IdTag;
    	transWrite3.Cacheable == transRead3.Cacheable;
    	transWrite3.Privileged == transRead3.Privileged;
    	transWrite3.Secure == transRead3.Secure;
    	transWrite3.DataInstr == transRead3.DataInstr;
    	transWrite3.Bufferable == transRead3.Bufferable;
    	transWrite3.Qos == transRead3.Qos;
    });
        `uvm_rand_send_with(transWrite4,
    	{transWrite4.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	transWrite4.Access == DENALI_CDN_AXI_ACCESS_EXCLUSIVE;
    	transWrite4.StartAddress == transRead4.StartAddress;
    	transWrite4.Length == transRead4.Length;
    	transWrite4.Size == transRead4.Size;
    	transWrite4.Kind == transRead4.Kind;
    	transWrite4.IdTag == transRead4.IdTag;
    	transWrite4.Cacheable == transRead4.Cacheable;
    	transWrite4.Privileged == transRead4.Privileged;
    	transWrite4.Secure == transRead4.Secure;
    	transWrite4.DataInstr == transRead4.DataInstr;
    	transWrite4.Bufferable == transRead4.Bufferable;
    	transWrite4.Qos == transRead4.Qos;
    });
    get_response(item, transWrite.get_transaction_id());
    get_response(item, transWrite2.get_transaction_id());
    get_response(item, transWrite3.get_transaction_id());
    get_response(item, transWrite4.get_transaction_id());
    
    transRead.normal_access_const.constraint_mode(1);
  	transWrite.normal_access_const.constraint_mode(1);
  	    transRead2.normal_access_const.constraint_mode(1);
  	transWrite2.normal_access_const.constraint_mode(1);
  	    transRead3.normal_access_const.constraint_mode(1);
  	transWrite3.normal_access_const.constraint_mode(1);
  	    transRead4.normal_access_const.constraint_mode(1);
  	transWrite4.normal_access_const.constraint_mode(1);

    
  endtask : body
endclass : axi4UvmExclusiveSeqSpacial	



// ----------------------------------------------------------------------------
// Class : axi4UvmWriteOffsetSeq
// the class sends a WRITE burst with a write offset (data before address)
// ----------------------------------------------------------------------------
class axi4UvmWriteOffsetSeq extends cdnAxiUvmSequence;
    // ---------------------------------------------------------------
  // The sequence item (transaction) that will be randomized and
  // passed to the driver.
  // ---------------------------------------------------------------
  rand myAxiTransaction trans;
  
  // ---------------------------------------------------------------
  // Possible input address to the sequence
  // ---------------------------------------------------------------
  rand reg [63:0] address;
  
  // ---------------------------------------------------------------
  // Possible input length to the sequence
  // ---------------------------------------------------------------
  rand reg[31:0] length;
  
  // ---------------------------------------------------------------
  // Possible burst id
  // ---------------------------------------------------------------
  rand reg[13:0] idTag;
  // ---------------------------------------------------------------
  // Possible input size to the sequence
  // ---------------------------------------------------------------
  rand denaliCdn_axiTransferSizeT size;
  
  // ---------------------------------------------------------------
  // Possible input kind to the sequence
  // ---------------------------------------------------------------
  rand denaliCdn_axiBurstKindT kind;
  
  // ---------------------------------------------------------------
  // Possible write address offset
  // ---------------------------------------------------------------
  rand int writeAddressOffset;
  
  // ---------------------------------------------------------------
  // Possible transimition delay
  // ---------------------------------------------------------------
  rand int transmitDelay;
	
  constraint Write_Address_offset_const
  {
  	length <30;
  	length > 0;
  	writeAddressOffset <= length;
  	writeAddressOffset >= 0;
  	transmitDelay >=0;
  	transmitDelay <=200;
  	
  }
  // ---------------------------------------------------------------
  // Use the UVM Sequence macro for this class.
  // ---------------------------------------------------------------
  `uvm_object_utils_begin(axi4UvmWriteOffsetSeq)
    `uvm_field_object(trans, UVM_ALL_ON)
  `uvm_object_utils_end
  
  `uvm_declare_p_sequencer(cdnAxiUvmSequencer)

  // ---------------------------------------------------------------
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ---------------------------------------------------------------
  function new(string name = "axi4UvmWriteOffsetSeq");
    super.new(name);
  endfunction : new

  // ---------------------------------------------------------------
  // Method : body
  // Desc.  : AXI Write Transaction.
  // ---------------------------------------------------------------
  virtual task body();
    
    `uvm_create(trans);
    // Turn off pre-defined constraints	
  	trans.DisableWriteAddressOffset_const.constraint_mode(0);
	trans.TransmitDelay_const.constraint_mode(0);
    // send the burst
    `uvm_rand_send_with(trans,
            {
            trans.StartAddress == address;
            trans.IdTag == idTag;
            trans.Length == length;
            trans.WriteAddressOffset == writeAddressOffset;
            trans.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
            trans.TransmitDelay == transmitDelay;
    });
   
  	trans.DisableWriteAddressOffset_const.constraint_mode(1);
	trans.TransmitDelay_const.constraint_mode(1);
        
  endtask : body

endclass

class axi4UvmUserModifyResponseSeq extends cdnAxiUvmModifyTransactionSequence;

  // ***************************************************************
  // Use the UVM registration macro for this class.
  // ***************************************************************
  `uvm_object_utils(axi4UvmUserModifyResponseSeq)
     
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "axi4UvmUserModifyResponseSeq");
    super.new(name);        
  endfunction : new
  
  mySlaveResp resp; 
  
  rand denaliCdn_axiResponseT response;
  constraint default_resp_is_okey {
  	 response dist { 
        DENALI_CDN_AXI_RESPONSE_OKAY :/ 32'h7fffffff, 
        [DENALI_CDN_AXI_RESPONSE_EXOKAY:DENALI_CDN_AXI_RESPONSE_DECERR]:= 1
    };
   }
  
  virtual task pre_body();
	   `ifdef UVM_POST_VERSION_1_1
		   var uvm_phase starting_phase = get_starting_phase();
	   `endif
    if (starting_phase != null) begin
      starting_phase.raise_objection(this);
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


  virtual task body();
  	denaliCdn_axiTransaction response;

  	// generate a template slave response
    `uvm_do(resp)  
    
    //Wait till transaction is ended
    //   we want the sequence to end only after the transaction transmission is completed.
    //   after the sequence ends no modification will take effect
   get_response(response,resp.get_transaction_id());   
          
  endtask : body

  // Modify the transaction in BeofreSendResponse callback using TransSet()
  // This is where we decide what are the transaction's attributes (fields) we want to modify 
  // and which items should it effect. 
  virtual function void modifyTransaction(denaliCdn_axiTransaction tr);
    bit status;
    //in this case we can choose to modify only a specific burst this sequence has generated.
    //if there was no condition then the modification would have occurred to any burst being sent.
    //by default only bursts created in this sequence will be affected.
    if (resp != null )//&& tr.UserData ==  resp.UserData)    
    begin
      `uvm_info(get_type_name(), "Starting Response modification", UVM_LOW)      
      //tr.Resp = response;
      for (int i=0; i<tr.TransfersResp.size(); ++i) begin
      	tr.TransfersResp[i] = response;
      end
      for (int i=0; i<tr.TransfersChannelDelay.size(); i++) begin 
      	tr.TransfersChannelDelay[i] = 50;
      end
      //Update the model transaction with the new values
      //   transSet() is being used to update that fields were changed.
      status = tr.transSet();
          
      `uvm_info(get_type_name(), "Finished Response modification", UVM_LOW)
    end
  endfunction

endclass


`endif //  `ifndef _USER_CDN_AXI_SEQ_LIB
