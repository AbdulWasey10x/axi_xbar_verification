# AXI4 Crossbar Verification Environment

## Project Description

This project focuses on the verification of an AXI4 Crossbar (XBAR) using Cadence AXI VIP (Verification IP). The AXI4 Crossbar is a key component in high-performance SOC designs, enabling flexible connections between multiple master and slave interfaces. The verification environment leverages the powerful features of Cadence AXI VIP to simulate and validate the crossbar functionality, ensuring that it meets design specifications.

The environment includes a structured testbench, run scripts, and coverage analysis tools, providing a comprehensive approach to verifying AXI4 transactions, protocol compliance, and performance metrics. This repository is structured to help you set up, run, and analyze the verification of the AXI4 crossbar.

## Repository Structure

- **testbench/**: Contains the testbench files that drive the verification process. This includes stimulus generation, monitoring, and checking logic to validate AXI4 transactions through the crossbar.

- **run_scripts/**: Includes scripts to compile, elaborate, and simulate the verification environment. These scripts are designed to interface with Cadence tools and run the AXI VIP in demo mode.

- **Coverage_reports/**: Stores PDF files of the coverage reports generated after the testbench execution, highlighting the areas of verification completeness and any uncovered scenarios.

## How to Run the Environment

Follow these steps to set up and run the AXI4 verification environment:

### Step 1: Clone the Design Repository

Clone the necessary design files from the AXI repository provided by PULP Platform. This repository contains the AXI design files needed for verification.

```bash
git clone https://github.com/pulp-platform/axi.git

### Step 2: Update the File List Path in the Run Script

Modify the flist path in the run script (cdn_vip_run_xrun_sv_uvm_64.sh) located in the run_scripts directory. This file list should point to the design files cloned in the previous step.

### Step 3: Run Cadence VIP in Demo Mode

Ensure Cadence VIP is configured and running in demo mode. This setup allows for the proper simulation of the AXI environment without a full license.

### Step 4: Replace Run Scripts with Demo Versions

Replace the existing run scripts in the AXI repository with those provided by the Cadence VIP demo environment. This ensures compatibility and proper execution of the verification environment.

### Step 5: Add the Testbench Path in the Script

Update the run script (cdn_vip_run_xrun_sv_uvm_64.sh) to include the correct path to the testbench files. This will ensure that the testbench is properly compiled and executed during simulation.

### Step 6: Run the Verification Environment

To execute the verification environment, follow these commands:

Source the necessary shell environment:
1. source csh
2. source cshrc
3. source cdn_vip_env_xrun_sv_uvm_64.csh
4. ./cdn_vip_run_xrun_sv_uvm_64.sh

### Step 7: Code Coverage and Merging Reports

When running the script, a code coverage UCD file is generated for every test case. To merge the coverage reports from different test cases, you can use the IMC (Integrated Metrics Center) tool in batch mode. Follow these steps to merge the coverage files:

1. **Open IMC Batch Mode**

   Launch the IMC tool in batch mode.

2. **Merge Coverage Reports**

   Use the following command to merge the coverage results from your test cases. Update the paths according to your test case names and file locations:

   ```bash
   merge -overwrite /home/wasey-10x/4interfaces_xbar/AXI_Compiled_xbar_working/VIP/cov_work/scope/WriteFromMaster0ToSlave0Test \
         /home/wasey-10x/4interfaces_xbar/AXI_Compiled_xbar_working/VIP/cov_work/scope/WriteFromMaster0ToSlave1Test \
         -out all_cov.ucd


