
`ifndef _USER_CDN_AXI_SVE_TEST
`define _USER_CDN_AXI_SVE_TEST

// ****************************************************************************
// Class : axi4UvmUserSve
// Desc. : This Demo testbench(sve) instantiates the demo env and a virtual sequencer
// ****************************************************************************


class axi4UvmUserTest extends uvm_test;

	axi4UvmUserSve axiSve0;
    uvm_root uvm_top;

	`uvm_component_utils_begin(axi4UvmUserTest)
	`uvm_component_utils_end

	function new(string name = "axi4UvmUserTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
    // To enable the waveform debugger  
    uvm_config_db#(int)::set(this,"*activeMaster.inst", "waveformDebuggerMonEnable", 1);
 //   uvm_config_db#(int)::set(this,"*passiveMaster.inst", "waveformDebuggerMonEnable", 1);
 //   uvm_config_db#(int)::set(this,"*passiveSlave.inst", "waveformDebuggerMonEnable", 1);
    uvm_config_db#(int)::set(this,"*activeSlave.inst", "waveformDebuggerMonEnable", 1);
		super.build_phase(phase); 
		set_type_override_by_type(denaliCdn_axiTransaction::get_type(),myAxiTransaction::get_type());
		axiSve0 = axi4UvmUserSve::type_id::create("axiSve0", this);
        // instead of implicit uvm_top, use an explicit variable (works for all UVM versions)
        uvm_top = uvm_root::get();		
	endfunction : build_phase
	
	virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
        
    uvm_top.print_topology();
  endfunction 

endclass : axi4UvmUserTest

class basicTest extends axi4UvmUserTest;

	`uvm_component_utils_begin(basicTest)
	`uvm_component_utils_end

	function new(string name = "basicTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.axiEnv0.activeMaster.sequencer.run_phase", "default_sequence",userSimpleSeq::type_id::get());
		
	endfunction : build_phase

endclass : basicTest

class perChannalDelayTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(perChannalDelayTest)
	`uvm_component_utils_end

	function new(string name = "perChannalDelayTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",perChannalDelaySeq::type_id::get());
		
	endfunction : build_phase 

endclass : perChannalDelayTest

class perTransactionDelayTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(perTransactionDelayTest)
	`uvm_component_utils_end

	function new(string name = "perTransactionDelayTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",perTransactionDelaySeq::type_id::get());
		
	endfunction : build_phase 

endclass : perTransactionDelayTest

class cross4kBoundaryTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(cross4kBoundaryTest)
	`uvm_component_utils_end

	function new(string name = "cross4kBoundaryTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",cross4kBoundarySeq::type_id::get());
		
	endfunction : build_phase
	
	virtual function void end_of_elaboration_phase(uvm_phase phase);      
      super.end_of_elaboration_phase(phase);     
      // change check to warning
   //   axiSve0.axiEnv0.passiveMaster.monitor.set_report_severity_id_override(UVM_FATAL,"CDN_AXI_FATAL_ERR_VR_AXI128_READ_CROSS_4K_BOUNDARY",UVM_WARNING);
  endfunction

endclass : cross4kBoundaryTest

class IdBasedReorderingTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(IdBasedReorderingTest)
	`uvm_component_utils_end

	function new(string name = "IdBasedReorderingTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",IdBasedReorderingSeq::type_id::get());
		
	endfunction : build_phase 

endclass : IdBasedReorderingTest

class blockingNonBlockingTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(blockingNonBlockingTest)
	`uvm_component_utils_end

	function new(string name = "blockingNonBlockingTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",blockingNonBlockingSeq::type_id::get());
		
	endfunction : build_phase 

endclass : blockingNonBlockingTest

class readAfterWriteTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(readAfterWriteTest)
	`uvm_component_utils_end

	function new(string name = "readAfterWriteTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",readAfterWriteSeq::type_id::get());
		
	endfunction : build_phase 

endclass : readAfterWriteTest

class wrRespReorderTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(wrRespReorderTest)
	`uvm_component_utils_end

	function new(string name = "wrRespReorderTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",wr_resp_reorder_seq::type_id::get());
		
	endfunction : build_phase 

endclass : wrRespReorderTest

class exclusiveTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(exclusiveTest)
	`uvm_component_utils_end

	function new(string name = "exclusiveTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",exclusive_seq::type_id::get());
		
	endfunction : build_phase 

endclass : exclusiveTest

class ModifyTransactionTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(ModifyTransactionTest)
	`uvm_component_utils_end

	function new(string name = "ModifyTransactionTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",modifyTransactionSeq::type_id::get());
		
	endfunction : build_phase 

endclass : ModifyTransactionTest

class UnalignedTransferTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(UnalignedTransferTest)
	`uvm_component_utils_end

	function new(string name = "UnalignedTransferTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",unaligned_transfer_seq::type_id::get());
		
	endfunction : build_phase 

endclass : UnalignedTransferTest

class ReadReorderingTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(ReadReorderingTest)
	`uvm_component_utils_end

	function new(string name = "ReadReorderingTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",read_reordering_seq::type_id::get());
		
	endfunction : build_phase 

endclass : ReadReorderingTest

class WriteAddressOffsetTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(WriteAddressOffsetTest)
	`uvm_component_utils_end

	function new(string name = "WriteAddressOffsetTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",WriteAddressOffsetSeq::type_id::get());
		
	endfunction : build_phase 

endclass : WriteAddressOffsetTest

class AccessTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(AccessTest)
	`uvm_component_utils_end

	function new(string name = "AccessTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",access_seq::type_id::get());
		
	endfunction : build_phase 

endclass : AccessTest

class AxcacheAttrTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(AxcacheAttrTest)
	`uvm_component_utils_end

	function new(string name = "AxcacheAttrTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",axcache_attr_seq::type_id::get());
		
	endfunction : build_phase 

endclass : AxcacheAttrTest

class BurstDelayTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(BurstDelayTest)
	`uvm_component_utils_end

	function new(string name = "BurstDelayTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",burst_delay_seq::type_id::get());
		
	endfunction : build_phase 

endclass : BurstDelayTest

class RandomAuserTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(RandomAuserTest)
	`uvm_component_utils_end

	function new(string name = "RandomAuserTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",random_auser_seq::type_id::get());
		
	endfunction : build_phase 

endclass : RandomAuserTest

class MultiByteBackdoorTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(MultiByteBackdoorTest)
	`uvm_component_utils_end

	function new(string name = "MultiByteBackdoorTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",MultiBytesBackdoorSeq::type_id::get());
		
	endfunction : build_phase 

endclass : MultiByteBackdoorTest

class seqLibraryTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(seqLibraryTest)
	`uvm_component_utils_end

	function new(string name = "seqLibraryTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",axi4_seq_lib::type_id::get());
		
	endfunction : build_phase 

endclass : seqLibraryTest

class allVirtualSequencesTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(allVirtualSequencesTest)
	`uvm_component_utils_end

	function new(string name = "allVirtualSequencesTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",allVirtualSequences::type_id::get());
		
	endfunction : build_phase 
	virtual function void end_of_elaboration_phase(uvm_phase phase);      
      super.end_of_elaboration_phase(phase);     
      // change check to warning
     // axiSve0.axiEnv0.passiveMaster.monitor.set_report_severity_id_override(UVM_FATAL,"CDN_AXI_FATAL_ERR_VR_AXI128_READ_CROSS_4K_BOUNDARY",UVM_WARNING);
	endfunction
	

endclass : allVirtualSequencesTest

class allSequencesTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(allSequencesTest)
	`uvm_component_utils_end

	function new(string name = "allSequencesTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",allSequences::type_id::get());
		
	endfunction : build_phase 

endclass : allSequencesTest

class WriteFromMaster0toSlave0Test extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(WriteFromMaster0toSlave0Test)
	`uvm_component_utils_end

	function new(string name = "WriteFromMaster0toSlave0Test",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",writeFromMaster0toSlave0Seq::type_id::get());
		
	endfunction : build_phase 

endclass : WriteFromMaster0toSlave0Test

class WriteFromMaster0ToSlave1Test extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(WriteFromMaster0ToSlave1Test)
	`uvm_component_utils_end

	function new(string name = "WriteFromMaster0ToSlave1Test",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",WriteFromMaster0ToSlave1Seq::type_id::get());
		
	endfunction : build_phase 

endclass : WriteFromMaster0ToSlave1Test

class WriteFromMaster1ToSlave0Test extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(WriteFromMaster1ToSlave0Test)
	`uvm_component_utils_end

	function new(string name = "WriteFromMaster1ToSlave0Test",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",WriteFromMaster1ToSlave0Seq::type_id::get());
		
	endfunction : build_phase 

endclass : WriteFromMaster1ToSlave0Test

class WriteFromMaster1ToSlave1Test extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(WriteFromMaster1ToSlave1Test)
	`uvm_component_utils_end

	function new(string name = "WriteFromMaster1ToSlave1Test",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",WriteFromMaster1ToSlave1Seq::type_id::get());
		
	endfunction : build_phase 

endclass : WriteFromMaster1ToSlave1Test

class WriteFromMaster0toSlave0AndSlave1Test extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(WriteFromMaster0toSlave0AndSlave1Test)
	`uvm_component_utils_end

	function new(string name = "WriteFromMaster0toSlave0AndSlave1Test",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",writeFromMaster0toSlave0AndSlave1Seq::type_id::get());
		
	endfunction : build_phase 

endclass : WriteFromMaster0toSlave0AndSlave1Test

class WriteUsingSameIdTagTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(WriteUsingSameIdTagTest)
	`uvm_component_utils_end

	function new(string name = "WriteUsingSameIdTagTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",WriteTransactionWithSameIdTagSeq::type_id::get());
		
	endfunction : build_phase 

endclass : WriteUsingSameIdTagTest


class ReadAxiTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(ReadAxiTest)
	`uvm_component_utils_end

	function new(string name = "ReadAxiTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",ReadAxiSeq::type_id::get());
		
	endfunction : build_phase 

endclass : ReadAxiTest


class WriteBurstTest extends axi4UvmUserTest;
	
	`uvm_component_utils_begin(WriteBurstTest)
	`uvm_component_utils_end

	function new(string name = "WriteBurstTest",uvm_component parent);
		super.new(name,parent); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); 
		
		//set the starting sequence to system      
		 uvm_config_db#(uvm_object_wrapper)::set(this, "axiSve0.vs.run_phase", "default_sequence",WriteBurstSeq::type_id::get());
		
	endfunction : build_phase 

endclass : WriteBurstTest


`endif // _USER_CDN_AXI_SVE_TEST