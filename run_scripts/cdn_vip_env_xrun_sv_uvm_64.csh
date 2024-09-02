#!/bin/tcsh -f 
#Cadence VIP environment setup for XRUN in mode 2s (64-bit mode)
#Usage:
#	${CDN_VIP_ROOT}/bin/cdn_vip_setup_env -cdn_vip_root ${CDN_VIP_ROOT} \
#		-sim xrun -mode 2s -method sv_uvm -uvmver ieee -cdn_vip_lib $CDN_VIP_LIB_PATH -cdnautotest -64 -csh \
#		-install "axi" \
#		-sim_root ${CDS_INST_DIR}

#IES installation
setenv CDS_INST_DIR /home/icdesign/cadence/installs/XCELIUM2303

#CDN_VIP_ROOT:: Environment variable pointing to Cadence VIP installation
setenv CDN_VIP_ROOT /work/AbdulWasey/VIP_CAT/vipcat_11.30.094-08_Dec_2023_08_15_05

#CDS_ARCH:: Platform for Cadence VIP libraries
#This is obtained from: ${CDN_VIP_ROOT}/bin/cds_plat
set CDS_ARCH=lnx86

#DENALI:: Environment variable pointing to Cadence VIP base libraries
setenv DENALI ${CDN_VIP_ROOT}/tools.${CDS_ARCH}/denali_64bit

#CDN_VIP_LIB_PATH:: Location of Cadence VIP compiled libraries
#This is a user-specified directory.
#IMPORTANT:: The libraries must be recompiled (-install option)
#after each new VIP download (and after each IES installation upgrade).
set CDN_VIP_LIB_PATH=/work/AbdulWasey/AXI_Compiled_xbar/VIP/vip_lib

#SPECMAN_PATH:: Environment variable dictating locations (and search order)
#for multiple Cadence VIP components: Virtual Machine, compiled libraries
setenv SPECMAN_PATH ${CDN_VIP_ROOT}/packages:${CDN_VIP_LIB_PATH}/64bit

#Additional components in ${PATH} to ensure necessary executables are available
setenv PATH ${CDS_INST_DIR}/tools.${CDS_ARCH}/bin/64bit:${CDN_VIP_ROOT}/tools.${CDS_ARCH}/bin/64bit:${PATH}

#Additional components in ${LD_LIBRARY_PATH} to ensure necessary libraries are available
	#The following line accounts for (extremely rare) users with no LD_LIBRARY_PATH
	if (! ${?LD_LIBRARY_PATH}) setenv LD_LIBRARY_PATH ""
setenv LD_LIBRARY_PATH ${CDN_VIP_LIB_PATH}/64bit:${DENALI}/verilog:${CDS_INST_DIR}/tools.${CDS_ARCH}/specman/lib/64bit:${CDS_INST_DIR}/tools.${CDS_ARCH}/lib/64bit:${LD_LIBRARY_PATH}

# Disable automatic nc to xm remapping
setenv CDN_VIP_DISABLE_REMAP_NC_XM  
