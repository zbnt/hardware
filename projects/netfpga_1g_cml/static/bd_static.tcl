
################################################################
# This is a generated script based on design: bd_static
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source bd_static_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7k325tffg676-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name bd_static

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:util_idelay_ctrl:1.0\
oscar-rc.dev:zbnt_hw:rp_wrapper_netfpga_1g_cml:1.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:util_ds_buf:2.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axis_register_slice:1.1\
oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0\
xilinx.com:ip:pr_decoupler:1.0\
oscar-rc.dev:zbnt_hw:util_irq2axis:1.0\
oscar-rc.dev:zbnt_hw:circular_dma:1.1\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:jtag_axi:1.2\
xilinx.com:ip:pr_axi_shutdown_manager:1.0\
xilinx.com:ip:axi_pcie:2.9\
oscar-rc.dev:zbnt_hw:util_axis2msi:1.0\
oscar-rc.dev:zbnt_hw:util_cdc_array_single:1.0\
oscar-rc.dev:zbnt_hw:util_icap:1.0\
xilinx.com:ip:prc:1.3\
xilinx.com:ip:util_reduced_logic:2.0\
xilinx.com:ip:fifo_generator:13.2\
alexforencich.com:verilog-ethernet:eth_mac_1g:1.0\
xilinx.com:ip:axi_clock_converter:2.1\
oscar-rc.dev:zbnt_hw:bpi_flash:1.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:mig_7series:4.2\
oscar-rc.dev:zbnt_hw:pr_bitstream_copy:1.0\
oscar-rc.dev:zbnt_hw:util_startup:1.0\
xilinx.com:ip:util_vector_logic:2.0\
oscar-rc.dev:zbnt_hw:util_regslice:1.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}


##################################################################
# MIG PRJ FILE TCL PROCs
##################################################################

proc write_mig_file_bd_static_ddr_controller_0 { str_mig_prj_filepath } {

   file mkdir [ file dirname "$str_mig_prj_filepath" ]
   set mig_prj_file [open $str_mig_prj_filepath  w+]

   puts $mig_prj_file {﻿<?xml version="1.0" encoding="UTF-8" standalone="no" ?>}
   puts $mig_prj_file {<Project NoOfControllers="1">}
   puts $mig_prj_file {  <ModuleName>bd_static_mig_7series_0_0</ModuleName>}
   puts $mig_prj_file {  <dci_inouts_inputs>1</dci_inouts_inputs>}
   puts $mig_prj_file {  <dci_inputs>1</dci_inputs>}
   puts $mig_prj_file {  <Debug_En>OFF</Debug_En>}
   puts $mig_prj_file {  <DataDepth_En>1024</DataDepth_En>}
   puts $mig_prj_file {  <LowPower_En>ON</LowPower_En>}
   puts $mig_prj_file {  <XADC_En>Enabled</XADC_En>}
   puts $mig_prj_file {  <TargetFPGA>xc7k325t-ffg676/-1</TargetFPGA>}
   puts $mig_prj_file {  <Version>4.2</Version>}
   puts $mig_prj_file {  <SystemClock>No Buffer</SystemClock>}
   puts $mig_prj_file {  <ReferenceClock>No Buffer</ReferenceClock>}
   puts $mig_prj_file {  <SysResetPolarity>ACTIVE LOW</SysResetPolarity>}
   puts $mig_prj_file {  <BankSelectionFlag>FALSE</BankSelectionFlag>}
   puts $mig_prj_file {  <InternalVref>0</InternalVref>}
   puts $mig_prj_file {  <dci_hr_inouts_inputs>50 Ohms</dci_hr_inouts_inputs>}
   puts $mig_prj_file {  <dci_cascade>0</dci_cascade>}
   puts $mig_prj_file {  <Controller number="0">}
   puts $mig_prj_file {    <MemoryDevice>DDR3_SDRAM/Components/MT41K512M8XX-125</MemoryDevice>}
   puts $mig_prj_file {    <TimePeriod>1250</TimePeriod>}
   puts $mig_prj_file {    <VccAuxIO>2.0V</VccAuxIO>}
   puts $mig_prj_file {    <PHYRatio>4:1</PHYRatio>}
   puts $mig_prj_file {    <InputClkFreq>200</InputClkFreq>}
   puts $mig_prj_file {    <UIExtraClocks>0</UIExtraClocks>}
   puts $mig_prj_file {    <MMCM_VCO>800</MMCM_VCO>}
   puts $mig_prj_file {    <MMCMClkOut0> 1.000</MMCMClkOut0>}
   puts $mig_prj_file {    <MMCMClkOut1>1</MMCMClkOut1>}
   puts $mig_prj_file {    <MMCMClkOut2>1</MMCMClkOut2>}
   puts $mig_prj_file {    <MMCMClkOut3>1</MMCMClkOut3>}
   puts $mig_prj_file {    <MMCMClkOut4>1</MMCMClkOut4>}
   puts $mig_prj_file {    <DataWidth>8</DataWidth>}
   puts $mig_prj_file {    <DeepMemory>1</DeepMemory>}
   puts $mig_prj_file {    <DataMask>1</DataMask>}
   puts $mig_prj_file {    <ECC>Disabled</ECC>}
   puts $mig_prj_file {    <Ordering>Normal</Ordering>}
   puts $mig_prj_file {    <BankMachineCnt>4</BankMachineCnt>}
   puts $mig_prj_file {    <CustomPart>FALSE</CustomPart>}
   puts $mig_prj_file {    <NewPartName></NewPartName>}
   puts $mig_prj_file {    <RowAddress>16</RowAddress>}
   puts $mig_prj_file {    <ColAddress>10</ColAddress>}
   puts $mig_prj_file {    <BankAddress>3</BankAddress>}
   puts $mig_prj_file {    <MemoryVoltage>1.5V</MemoryVoltage>}
   puts $mig_prj_file {    <C0_MEM_SIZE>536870912</C0_MEM_SIZE>}
   puts $mig_prj_file {    <UserMemoryAddressMap>BANK_ROW_COLUMN</UserMemoryAddressMap>}
   puts $mig_prj_file {    <PinSelection>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y3" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AD6" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y1" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AC3" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="V2" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AC1" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[14]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AD5" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[15]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y2" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="W3" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="W5" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AB2" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="W1" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AC2" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U2" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AB1" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="V1" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AA5" SLEW="FAST" VCCAUX_IO="" name="ddr3_ba[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AC4" SLEW="FAST" VCCAUX_IO="" name="ddr3_ba[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="V4" SLEW="FAST" VCCAUX_IO="" name="ddr3_ba[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y5" SLEW="FAST" VCCAUX_IO="" name="ddr3_cas_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="AB4" SLEW="FAST" VCCAUX_IO="" name="ddr3_ck_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="AA4" SLEW="FAST" VCCAUX_IO="" name="ddr3_ck_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AB5" SLEW="FAST" VCCAUX_IO="" name="ddr3_cke[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U6" SLEW="FAST" VCCAUX_IO="" name="ddr3_cs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AE6" SLEW="FAST" VCCAUX_IO="" name="ddr3_dm[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="AE5" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="AE3" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="AD4" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="AF3" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="AE1" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="AF2" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="AD1" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="AE2" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AF4" SLEW="FAST" VCCAUX_IO="" name="ddr3_dqs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="AF5" SLEW="FAST" VCCAUX_IO="" name="ddr3_dqs_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U7" SLEW="FAST" VCCAUX_IO="" name="ddr3_odt[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y6" SLEW="FAST" VCCAUX_IO="" name="ddr3_ras_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="LVCMOS15" PADName="U1" SLEW="FAST" VCCAUX_IO="" name="ddr3_reset_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U5" SLEW="FAST" VCCAUX_IO="" name="ddr3_we_n"/>}
   puts $mig_prj_file {    </PinSelection>}
   puts $mig_prj_file {    <System_Control>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="sys_rst"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="init_calib_complete"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="tg_compare_error"/>}
   puts $mig_prj_file {    </System_Control>}
   puts $mig_prj_file {    <TimingParameters>}
   puts $mig_prj_file {      <Parameters tcke="5" tfaw="30" tras="35" trcd="13.75" trefi="7.8" trfc="260" trp="13.75" trrd="6" trtp="7.5" twtr="7.5"/>}
   puts $mig_prj_file {    </TimingParameters>}
   puts $mig_prj_file {    <mrBurstLength name="Burst Length">8 - Fixed</mrBurstLength>}
   puts $mig_prj_file {    <mrBurstType name="Read Burst Type and Length">Sequential</mrBurstType>}
   puts $mig_prj_file {    <mrCasLatency name="CAS Latency">11</mrCasLatency>}
   puts $mig_prj_file {    <mrMode name="Mode">Normal</mrMode>}
   puts $mig_prj_file {    <mrDllReset name="DLL Reset">No</mrDllReset>}
   puts $mig_prj_file {    <mrPdMode name="DLL control for precharge PD">Slow Exit</mrPdMode>}
   puts $mig_prj_file {    <emrDllEnable name="DLL Enable">Enable</emrDllEnable>}
   puts $mig_prj_file {    <emrOutputDriveStrength name="Output Driver Impedance Control">RZQ/7</emrOutputDriveStrength>}
   puts $mig_prj_file {    <emrMirrorSelection name="Address Mirroring">Disable</emrMirrorSelection>}
   puts $mig_prj_file {    <emrCSSelection name="Controller Chip Select Pin">Enable</emrCSSelection>}
   puts $mig_prj_file {    <emrRTT name="RTT (nominal) - On Die Termination (ODT)">RZQ/4</emrRTT>}
   puts $mig_prj_file {    <emrPosted name="Additive Latency (AL)">0</emrPosted>}
   puts $mig_prj_file {    <emrOCD name="Write Leveling Enable">Disabled</emrOCD>}
   puts $mig_prj_file {    <emrDQS name="TDQS enable">Enabled</emrDQS>}
   puts $mig_prj_file {    <emrRDQS name="Qoff">Output Buffer Enabled</emrRDQS>}
   puts $mig_prj_file {    <mr2PartialArraySelfRefresh name="Partial-Array Self Refresh">Full Array</mr2PartialArraySelfRefresh>}
   puts $mig_prj_file {    <mr2CasWriteLatency name="CAS write latency">8</mr2CasWriteLatency>}
   puts $mig_prj_file {    <mr2AutoSelfRefresh name="Auto Self Refresh">Enabled</mr2AutoSelfRefresh>}
   puts $mig_prj_file {    <mr2SelfRefreshTempRange name="High Temparature Self Refresh Rate">Normal</mr2SelfRefreshTempRange>}
   puts $mig_prj_file {    <mr2RTTWR name="RTT_WR - Dynamic On Die Termination (ODT)">Dynamic ODT off</mr2RTTWR>}
   puts $mig_prj_file {    <PortInterface>AXI</PortInterface>}
   puts $mig_prj_file {    <AXIParameters>}
   puts $mig_prj_file {      <C0_C_RD_WR_ARB_ALGORITHM>RD_PRI_REG</C0_C_RD_WR_ARB_ALGORITHM>}
   puts $mig_prj_file {      <C0_S_AXI_ADDR_WIDTH>29</C0_S_AXI_ADDR_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_DATA_WIDTH>64</C0_S_AXI_DATA_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_ID_WIDTH>1</C0_S_AXI_ID_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_SUPPORTS_NARROW_BURST>1</C0_S_AXI_SUPPORTS_NARROW_BURST>}
   puts $mig_prj_file {    </AXIParameters>}
   puts $mig_prj_file {  </Controller>}
   puts $mig_prj_file {</Project>}

   close $mig_prj_file
}
# End of write_mig_file_bd_static_ddr_controller_0()



##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: test_empty
proc create_hier_cell_test_empty { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_test_empty() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I clk_axi
  create_bd_pin -dir I clk_axis
  create_bd_pin -dir I ext_fifo_empty
  create_bd_pin -dir O -from 0 -to 0 fifo_empty
  create_bd_pin -dir I -from 13 -to 0 occupancy0
  create_bd_pin -dir I -from 13 -to 0 occupancy1
  create_bd_pin -dir I rst_axi_n

  # Create instance: cdc_0, and set properties
  set cdc_0 [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:util_cdc_array_single:1.0 cdc_0 ]
  set_property -dict [ list \
   CONFIG.C_WIDTH {2} \
 ] $cdc_0

  # Create instance: concat_0, and set properties
  set concat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {2} \
 ] $concat_0

  # Create instance: concat_1, and set properties
  set concat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_1 ]

  # Create instance: not_0, and set properties
  set not_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 not_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $not_0

  # Create instance: or_1, and set properties
  set or_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 or_1 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {14} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $or_1

  # Create instance: or_2, and set properties
  set or_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 or_2 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {14} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $or_2

  # Create instance: or_3, and set properties
  set or_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 or_3 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {3} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $or_3

  # Create instance: regslice_0, and set properties
  set regslice_0 [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:util_regslice:1.0 regslice_0 ]
  set_property -dict [ list \
   CONFIG.C_NUM_STAGES {1} \
   CONFIG.C_WIDTH {1} \
 ] $regslice_0

  # Create instance: regslice_1, and set properties
  set regslice_1 [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:util_regslice:1.0 regslice_1 ]
  set_property -dict [ list \
   CONFIG.C_NUM_STAGES {1} \
   CONFIG.C_WIDTH {1} \
 ] $regslice_1

  # Create port connections
  connect_bd_net -net cdc_data_dst [get_bd_pins cdc_0/data_dst] [get_bd_pins concat_1/In0]
  connect_bd_net -net clk_axi_1 [get_bd_pins clk_axi] [get_bd_pins cdc_0/clk_dst] [get_bd_pins regslice_0/clk] [get_bd_pins regslice_1/clk]
  connect_bd_net -net clk_axis_1 [get_bd_pins clk_axis] [get_bd_pins cdc_0/clk_src]
  connect_bd_net -net concat1_dout [get_bd_pins concat_1/dout] [get_bd_pins or_3/Op1]
  connect_bd_net -net ext_fifo_empty_1 [get_bd_pins ext_fifo_empty] [get_bd_pins concat_0/In0]
  connect_bd_net -net fifo_0_axis_data_count [get_bd_pins occupancy0] [get_bd_pins or_1/Op1]
  connect_bd_net -net fifo_2_axis_rd_data_count [get_bd_pins occupancy1] [get_bd_pins or_2/Op1]
  connect_bd_net -net not_0_Res [get_bd_pins not_0/Res] [get_bd_pins regslice_1/data_in]
  connect_bd_net -net or1_Res [get_bd_pins concat_0/In1] [get_bd_pins or_1/Res]
  connect_bd_net -net or2_Res [get_bd_pins or_2/Res] [get_bd_pins regslice_0/data_in]
  connect_bd_net -net regslice_1_data_out [get_bd_pins fifo_empty] [get_bd_pins regslice_1/data_out]
  connect_bd_net -net regslice_data_out [get_bd_pins concat_1/In1] [get_bd_pins regslice_0/data_out]
  connect_bd_net -net rst_axi_n_1 [get_bd_pins rst_axi_n] [get_bd_pins regslice_0/rst_n] [get_bd_pins regslice_1/rst_n]
  connect_bd_net -net util_reduced_logic_0_Res [get_bd_pins not_0/Op1] [get_bd_pins or_3/Res]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins cdc_0/data_src] [get_bd_pins concat_0/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: memory
proc create_hier_cell_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:emc_rtl:1.0 bpi
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3

  # Create pins
  create_bd_pin -dir IO -from 15 -to 0 bpi_dq
  create_bd_pin -dir I clk
  create_bd_pin -dir I -type clk clk_bpi
  create_bd_pin -dir I -type clk clk_ddr
  create_bd_pin -dir I -type rst rst_bpi_n
  create_bd_pin -dir I -type rst rst_ddr_n
  create_bd_pin -dir I rst_n

  # Create instance: bpi_axi_cc, and set properties
  set bpi_axi_cc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 bpi_axi_cc ]
  set_property -dict [ list \
   CONFIG.ACLK_ASYNC {1} \
 ] $bpi_axi_cc

  # Create instance: bpi_controller, and set properties
  set bpi_controller [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:bpi_flash:1.0 bpi_controller ]
  set_property -dict [ list \
   CONFIG.C_AXI_RD_FIFO_DEPTH {512} \
   CONFIG.C_AXI_WIDTH {32} \
   CONFIG.C_AXI_WR_FIFO_DEPTH {512} \
   CONFIG.C_OEL_TO_DQ_TIME {12} \
   CONFIG.C_READ_BURST_ALIGNMENT {4} \
 ] $bpi_controller

  # Create instance: constant_ce, and set properties
  set constant_ce [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 constant_ce ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $constant_ce

  # Create instance: ddr_controller, and set properties
  set ddr_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 ddr_controller ]

  # Generate the PRJ File for MIG
  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $ddr_controller ] ] ]
  set str_mig_file_name mig_a.prj
  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}

  write_mig_file_bd_static_ddr_controller_0 $str_mig_file_path

  set_property -dict [ list \
   CONFIG.BOARD_MIG_PARAM {Custom} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.XML_INPUT_FILE {mig_a.prj} \
 ] $ddr_controller

  # Create instance: ddr_interconnect, and set properties
  set ddr_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ddr_interconnect ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {0} \
   CONFIG.M00_HAS_REGSLICE {3} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
   CONFIG.S00_HAS_REGSLICE {3} \
   CONFIG.S01_HAS_REGSLICE {3} \
   CONFIG.STRATEGY {1} \
 ] $ddr_interconnect

  # Create instance: ddr_reset, and set properties
  set ddr_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 ddr_reset ]

  # Create instance: pr_copy, and set properties
  set pr_copy [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_bitstream_copy:1.0 pr_copy ]

  # Create instance: startup_clk, and set properties
  set startup_clk [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:util_startup:1.0 startup_clk ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins bpi] [get_bd_intf_pins bpi_controller/BPI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins ddr3] [get_bd_intf_pins ddr_controller/DDR3]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins ddr_interconnect/S00_AXI] [get_bd_intf_pins pr_copy/M_AXI_DST]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_pins ddr_interconnect/S01_AXI] [get_bd_intf_pins pr_copy/M_AXI_PRC]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins pr_copy/S_AXI_PRC]
  connect_bd_intf_net -intf_net axi_clock_converter_0_M_AXI [get_bd_intf_pins bpi_axi_cc/M_AXI] [get_bd_intf_pins bpi_controller/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins ddr_controller/S_AXI] [get_bd_intf_pins ddr_interconnect/M00_AXI]
  connect_bd_intf_net -intf_net pr_copy_M_AXI_SRC [get_bd_intf_pins bpi_axi_cc/S_AXI] [get_bd_intf_pins pr_copy/M_AXI_SRC]

  # Create port connections
  connect_bd_net -net M00_ARESETN_1 [get_bd_pins ddr_interconnect/M00_ARESETN] [get_bd_pins ddr_reset/peripheral_aresetn]
  connect_bd_net -net Net [get_bd_pins bpi_dq] [get_bd_pins bpi_controller/bpi_dq_io]
  connect_bd_net -net clk_1 [get_bd_pins clk_ddr] [get_bd_pins ddr_controller/clk_ref_i] [get_bd_pins ddr_controller/sys_clk_i]
  connect_bd_net -net clk_2 [get_bd_pins clk] [get_bd_pins bpi_axi_cc/s_axi_aclk] [get_bd_pins ddr_interconnect/ACLK] [get_bd_pins ddr_interconnect/S00_ACLK] [get_bd_pins ddr_interconnect/S01_ACLK] [get_bd_pins pr_copy/clk]
  connect_bd_net -net clk_bpi_1 [get_bd_pins clk_bpi] [get_bd_pins bpi_axi_cc/m_axi_aclk] [get_bd_pins bpi_controller/clk] [get_bd_pins startup_clk/usrcclko]
  connect_bd_net -net constant_ce_dout [get_bd_pins constant_ce/dout] [get_bd_pins startup_clk/usrcclkts]
  connect_bd_net -net ddr_controller_mmcm_locked [get_bd_pins ddr_controller/mmcm_locked] [get_bd_pins ddr_reset/dcm_locked]
  connect_bd_net -net ddr_controller_ui_clk [get_bd_pins ddr_controller/ui_clk] [get_bd_pins ddr_interconnect/M00_ACLK] [get_bd_pins ddr_reset/slowest_sync_clk]
  connect_bd_net -net rst_bpi_n_1 [get_bd_pins rst_bpi_n] [get_bd_pins bpi_axi_cc/m_axi_aresetn] [get_bd_pins bpi_controller/rst_n]
  connect_bd_net -net rst_n_1 [get_bd_pins rst_ddr_n] [get_bd_pins ddr_controller/aresetn] [get_bd_pins ddr_controller/sys_rst] [get_bd_pins ddr_reset/ext_reset_in]
  connect_bd_net -net rst_n_2 [get_bd_pins rst_n] [get_bd_pins bpi_axi_cc/s_axi_aresetn] [get_bd_pins ddr_interconnect/ARESETN] [get_bd_pins ddr_interconnect/S00_ARESETN] [get_bd_pins ddr_interconnect/S01_ARESETN] [get_bd_pins pr_copy/rst_n]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: eth3
proc create_hier_cell_eth3 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_eth3() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 RGMII
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  # Create pins
  create_bd_pin -dir O -type clk clk_rx
  create_bd_pin -dir I decouple
  create_bd_pin -dir I -type clk gtx_clk
  create_bd_pin -dir I -type clk gtx_clk90
  create_bd_pin -dir I -type rst gtx_rst_n
  create_bd_pin -dir O -from 1 -to 0 shutdown_ack
  create_bd_pin -dir I shutdown_req

  # Create instance: mac, and set properties
  set mac [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac ]
  set_property -dict [ list \
   CONFIG.C_CLK_INPUT_STYLE {BUFIO} \
   CONFIG.C_IFACE_TYPE {RGMII} \
   CONFIG.C_USE_CLK90 {true} \
 ] $mac

  # Create instance: rx_shutdown, and set properties
  set rx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 rx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TREADY {false} \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_CDC_STAGES {4} \
 ] $rx_shutdown

  # Create instance: shutdown_concat, and set properties
  set shutdown_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 shutdown_concat ]

  # Create instance: tx_decoupler, and set properties
  set tx_decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 tx_decoupler ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {axis {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 MODE slave CDC_STAGES 4 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 8} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 0 WIDTH 1} TUSER {PRESENT 1 WIDTH 1} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 1} TKEEP {PRESENT 0 WIDTH 1}}}} IPI_PROP_COUNT 0} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {axis} \
   CONFIG.GUI_SELECT_CDC_STAGES {4} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
   CONFIG.GUI_SELECT_MODE {slave} \
   CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.GUI_SIGNAL_DECOUPLED_0 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_1 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_2 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_4 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_0 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_1 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_2 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_4 {true} \
   CONFIG.GUI_SIGNAL_SELECT_0 {TVALID} \
   CONFIG.GUI_SIGNAL_SELECT_1 {TREADY} \
   CONFIG.GUI_SIGNAL_SELECT_2 {TDATA} \
   CONFIG.GUI_SIGNAL_SELECT_3 {TUSER} \
   CONFIG.GUI_SIGNAL_SELECT_4 {TLAST} \
   CONFIG.GUI_SIGNAL_SELECT_5 {TID} \
   CONFIG.GUI_SIGNAL_SELECT_6 {TDEST} \
   CONFIG.GUI_SIGNAL_SELECT_7 {TSTRB} \
   CONFIG.GUI_SIGNAL_SELECT_8 {TKEEP} \
   CONFIG.GUI_SIGNAL_WIDTH_2 {8} \
   CONFIG.GUI_SIGNAL_WIDTH_7 {1} \
   CONFIG.GUI_SIGNAL_WIDTH_8 {1} \
 ] $tx_decoupler

  # Create instance: tx_reset, and set properties
  set tx_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 tx_reset ]

  # Create instance: tx_shutdown, and set properties
  set tx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 tx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_CDC_STAGES {4} \
 ] $tx_shutdown

  # Create interface connections
  connect_bd_intf_net -intf_net decoupler_s_eth0 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins tx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net mac_eth0_RGMII [get_bd_intf_pins RGMII] [get_bd_intf_pins mac/RGMII]
  connect_bd_intf_net -intf_net mac_eth0_RX_AXIS [get_bd_intf_pins mac/RX_AXIS] [get_bd_intf_pins rx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net pr_decoupler_0_rp_axis [get_bd_intf_pins M_AXIS] [get_bd_intf_pins tx_decoupler/rp_axis]
  connect_bd_intf_net -intf_net pr_shutdown_axis_0_M_AXIS [get_bd_intf_pins mac/TX_AXIS] [get_bd_intf_pins tx_shutdown/M_AXIS]
  connect_bd_intf_net -intf_net rx_shutdown_eth0_M_AXIS [get_bd_intf_pins rx_shutdown/M_AXIS] [get_bd_intf_pins tx_decoupler/s_axis]

  # Create port connections
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins gtx_clk] [get_bd_pins mac/gtx_clk] [get_bd_pins rx_shutdown/shutdown_clk] [get_bd_pins tx_decoupler/decouple_ref_clk] [get_bd_pins tx_shutdown/clk] [get_bd_pins tx_shutdown/shutdown_clk]
  connect_bd_net -net dcm_eth_clk_125M_90 [get_bd_pins gtx_clk90] [get_bd_pins mac/gtx_clk90]
  connect_bd_net -net decouple_1 [get_bd_pins decouple] [get_bd_pins tx_decoupler/decouple]
  connect_bd_net -net mac_eth0_rx_clk [get_bd_pins clk_rx] [get_bd_pins mac/rx_clk] [get_bd_pins rx_shutdown/clk] [get_bd_pins tx_decoupler/axis_ref_clk] [get_bd_pins tx_reset/slowest_sync_clk]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_pins gtx_rst_n] [get_bd_pins mac/gtx_rst_n] [get_bd_pins tx_reset/ext_reset_in] [get_bd_pins tx_shutdown/rst_n]
  connect_bd_net -net rx_shutdown_shutdown_ack [get_bd_pins rx_shutdown/shutdown_ack] [get_bd_pins shutdown_concat/In1]
  connect_bd_net -net shutdown_concat_dout [get_bd_pins shutdown_ack] [get_bd_pins shutdown_concat/dout]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins rx_shutdown/shutdown_req] [get_bd_pins tx_shutdown/shutdown_req]
  connect_bd_net -net tx_reset_peripheral_aresetn [get_bd_pins rx_shutdown/rst_n] [get_bd_pins tx_reset/peripheral_aresetn]
  connect_bd_net -net tx_shutdown_shutdown_ack [get_bd_pins shutdown_concat/In0] [get_bd_pins tx_shutdown/shutdown_ack]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: eth2
proc create_hier_cell_eth2 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_eth2() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 RGMII
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  # Create pins
  create_bd_pin -dir O -type clk clk_rx
  create_bd_pin -dir I decouple
  create_bd_pin -dir I -type clk gtx_clk
  create_bd_pin -dir I -type clk gtx_clk90
  create_bd_pin -dir I -type rst gtx_rst_n
  create_bd_pin -dir O -from 1 -to 0 shutdown_ack
  create_bd_pin -dir I shutdown_req

  # Create instance: mac, and set properties
  set mac [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac ]
  set_property -dict [ list \
   CONFIG.C_CLK_INPUT_STYLE {BUFIO} \
   CONFIG.C_IFACE_TYPE {RGMII} \
   CONFIG.C_USE_CLK90 {true} \
 ] $mac

  # Create instance: rx_shutdown, and set properties
  set rx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 rx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TREADY {false} \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_CDC_STAGES {4} \
 ] $rx_shutdown

  # Create instance: shutdown_concat, and set properties
  set shutdown_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 shutdown_concat ]

  # Create instance: tx_decoupler, and set properties
  set tx_decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 tx_decoupler ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {axis {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 MODE slave CDC_STAGES 4 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 8} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 0 WIDTH 1} TUSER {PRESENT 1 WIDTH 1} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 1} TKEEP {PRESENT 0 WIDTH 1}}}} IPI_PROP_COUNT 0} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {axis} \
   CONFIG.GUI_SELECT_CDC_STAGES {4} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
   CONFIG.GUI_SELECT_MODE {slave} \
   CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.GUI_SIGNAL_DECOUPLED_0 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_1 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_2 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_4 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_0 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_1 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_2 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_4 {true} \
   CONFIG.GUI_SIGNAL_SELECT_0 {TVALID} \
   CONFIG.GUI_SIGNAL_SELECT_1 {TREADY} \
   CONFIG.GUI_SIGNAL_SELECT_2 {TDATA} \
   CONFIG.GUI_SIGNAL_SELECT_3 {TUSER} \
   CONFIG.GUI_SIGNAL_SELECT_4 {TLAST} \
   CONFIG.GUI_SIGNAL_SELECT_5 {TID} \
   CONFIG.GUI_SIGNAL_SELECT_6 {TDEST} \
   CONFIG.GUI_SIGNAL_SELECT_7 {TSTRB} \
   CONFIG.GUI_SIGNAL_SELECT_8 {TKEEP} \
   CONFIG.GUI_SIGNAL_WIDTH_2 {8} \
   CONFIG.GUI_SIGNAL_WIDTH_7 {1} \
   CONFIG.GUI_SIGNAL_WIDTH_8 {1} \
 ] $tx_decoupler

  # Create instance: tx_reset, and set properties
  set tx_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 tx_reset ]

  # Create instance: tx_shutdown, and set properties
  set tx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 tx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_CDC_STAGES {4} \
 ] $tx_shutdown

  # Create interface connections
  connect_bd_intf_net -intf_net decoupler_s_eth0 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins tx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net mac_eth0_RGMII [get_bd_intf_pins RGMII] [get_bd_intf_pins mac/RGMII]
  connect_bd_intf_net -intf_net mac_eth0_RX_AXIS [get_bd_intf_pins mac/RX_AXIS] [get_bd_intf_pins rx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net pr_decoupler_0_rp_axis [get_bd_intf_pins M_AXIS] [get_bd_intf_pins tx_decoupler/rp_axis]
  connect_bd_intf_net -intf_net pr_shutdown_axis_0_M_AXIS [get_bd_intf_pins mac/TX_AXIS] [get_bd_intf_pins tx_shutdown/M_AXIS]
  connect_bd_intf_net -intf_net rx_shutdown_eth0_M_AXIS [get_bd_intf_pins rx_shutdown/M_AXIS] [get_bd_intf_pins tx_decoupler/s_axis]

  # Create port connections
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins gtx_clk] [get_bd_pins mac/gtx_clk] [get_bd_pins rx_shutdown/shutdown_clk] [get_bd_pins tx_decoupler/decouple_ref_clk] [get_bd_pins tx_shutdown/clk] [get_bd_pins tx_shutdown/shutdown_clk]
  connect_bd_net -net dcm_eth_clk_125M_90 [get_bd_pins gtx_clk90] [get_bd_pins mac/gtx_clk90]
  connect_bd_net -net decouple_1 [get_bd_pins decouple] [get_bd_pins tx_decoupler/decouple]
  connect_bd_net -net mac_eth0_rx_clk [get_bd_pins clk_rx] [get_bd_pins mac/rx_clk] [get_bd_pins rx_shutdown/clk] [get_bd_pins tx_decoupler/axis_ref_clk] [get_bd_pins tx_reset/slowest_sync_clk]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_pins gtx_rst_n] [get_bd_pins mac/gtx_rst_n] [get_bd_pins tx_reset/ext_reset_in] [get_bd_pins tx_shutdown/rst_n]
  connect_bd_net -net rx_shutdown_shutdown_ack [get_bd_pins rx_shutdown/shutdown_ack] [get_bd_pins shutdown_concat/In1]
  connect_bd_net -net shutdown_concat_dout [get_bd_pins shutdown_ack] [get_bd_pins shutdown_concat/dout]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins rx_shutdown/shutdown_req] [get_bd_pins tx_shutdown/shutdown_req]
  connect_bd_net -net tx_reset_peripheral_aresetn [get_bd_pins rx_shutdown/rst_n] [get_bd_pins tx_reset/peripheral_aresetn]
  connect_bd_net -net tx_shutdown_shutdown_ack [get_bd_pins shutdown_concat/In0] [get_bd_pins tx_shutdown/shutdown_ack]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: eth1
proc create_hier_cell_eth1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_eth1() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 RGMII
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  # Create pins
  create_bd_pin -dir O -type clk clk_rx
  create_bd_pin -dir I decouple
  create_bd_pin -dir I -type clk gtx_clk
  create_bd_pin -dir I -type clk gtx_clk90
  create_bd_pin -dir I -type rst gtx_rst_n
  create_bd_pin -dir O -from 1 -to 0 shutdown_ack
  create_bd_pin -dir I shutdown_req

  # Create instance: mac, and set properties
  set mac [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac ]
  set_property -dict [ list \
   CONFIG.C_CLK_INPUT_STYLE {BUFIO} \
   CONFIG.C_IFACE_TYPE {RGMII} \
   CONFIG.C_USE_CLK90 {true} \
 ] $mac

  # Create instance: rx_shutdown, and set properties
  set rx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 rx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TREADY {false} \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_CDC_STAGES {4} \
 ] $rx_shutdown

  # Create instance: shutdown_concat, and set properties
  set shutdown_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 shutdown_concat ]

  # Create instance: tx_decoupler, and set properties
  set tx_decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 tx_decoupler ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {axis {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 MODE slave CDC_STAGES 4 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 8} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 0 WIDTH 1} TUSER {PRESENT 1 WIDTH 1} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 1} TKEEP {PRESENT 0 WIDTH 1}}}} IPI_PROP_COUNT 0} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {axis} \
   CONFIG.GUI_SELECT_CDC_STAGES {4} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
   CONFIG.GUI_SELECT_MODE {slave} \
   CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.GUI_SIGNAL_DECOUPLED_0 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_1 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_2 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_4 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_0 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_1 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_2 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_4 {true} \
   CONFIG.GUI_SIGNAL_SELECT_0 {TVALID} \
   CONFIG.GUI_SIGNAL_SELECT_1 {TREADY} \
   CONFIG.GUI_SIGNAL_SELECT_2 {TDATA} \
   CONFIG.GUI_SIGNAL_SELECT_3 {TUSER} \
   CONFIG.GUI_SIGNAL_SELECT_4 {TLAST} \
   CONFIG.GUI_SIGNAL_SELECT_5 {TID} \
   CONFIG.GUI_SIGNAL_SELECT_6 {TDEST} \
   CONFIG.GUI_SIGNAL_SELECT_7 {TSTRB} \
   CONFIG.GUI_SIGNAL_SELECT_8 {TKEEP} \
   CONFIG.GUI_SIGNAL_WIDTH_2 {8} \
   CONFIG.GUI_SIGNAL_WIDTH_7 {1} \
   CONFIG.GUI_SIGNAL_WIDTH_8 {1} \
 ] $tx_decoupler

  # Create instance: tx_reset, and set properties
  set tx_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 tx_reset ]

  # Create instance: tx_shutdown, and set properties
  set tx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 tx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_CDC_STAGES {4} \
 ] $tx_shutdown

  # Create interface connections
  connect_bd_intf_net -intf_net decoupler_s_eth0 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins tx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net mac_eth0_RGMII [get_bd_intf_pins RGMII] [get_bd_intf_pins mac/RGMII]
  connect_bd_intf_net -intf_net mac_eth0_RX_AXIS [get_bd_intf_pins mac/RX_AXIS] [get_bd_intf_pins rx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net pr_decoupler_0_rp_axis [get_bd_intf_pins M_AXIS] [get_bd_intf_pins tx_decoupler/rp_axis]
  connect_bd_intf_net -intf_net pr_shutdown_axis_0_M_AXIS [get_bd_intf_pins mac/TX_AXIS] [get_bd_intf_pins tx_shutdown/M_AXIS]
  connect_bd_intf_net -intf_net rx_shutdown_eth0_M_AXIS [get_bd_intf_pins rx_shutdown/M_AXIS] [get_bd_intf_pins tx_decoupler/s_axis]

  # Create port connections
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins gtx_clk] [get_bd_pins mac/gtx_clk] [get_bd_pins rx_shutdown/shutdown_clk] [get_bd_pins tx_decoupler/decouple_ref_clk] [get_bd_pins tx_shutdown/clk] [get_bd_pins tx_shutdown/shutdown_clk]
  connect_bd_net -net dcm_eth_clk_125M_90 [get_bd_pins gtx_clk90] [get_bd_pins mac/gtx_clk90]
  connect_bd_net -net decouple_1 [get_bd_pins decouple] [get_bd_pins tx_decoupler/decouple]
  connect_bd_net -net mac_eth0_rx_clk [get_bd_pins clk_rx] [get_bd_pins mac/rx_clk] [get_bd_pins rx_shutdown/clk] [get_bd_pins tx_decoupler/axis_ref_clk] [get_bd_pins tx_reset/slowest_sync_clk]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_pins gtx_rst_n] [get_bd_pins mac/gtx_rst_n] [get_bd_pins tx_reset/ext_reset_in] [get_bd_pins tx_shutdown/rst_n]
  connect_bd_net -net rx_shutdown_shutdown_ack [get_bd_pins rx_shutdown/shutdown_ack] [get_bd_pins shutdown_concat/In1]
  connect_bd_net -net shutdown_concat_dout [get_bd_pins shutdown_ack] [get_bd_pins shutdown_concat/dout]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins rx_shutdown/shutdown_req] [get_bd_pins tx_shutdown/shutdown_req]
  connect_bd_net -net tx_reset_peripheral_aresetn [get_bd_pins rx_shutdown/rst_n] [get_bd_pins tx_reset/peripheral_aresetn]
  connect_bd_net -net tx_shutdown_shutdown_ack [get_bd_pins shutdown_concat/In0] [get_bd_pins tx_shutdown/shutdown_ack]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: eth0
proc create_hier_cell_eth0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_eth0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 RGMII
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  # Create pins
  create_bd_pin -dir O -type clk clk_rx
  create_bd_pin -dir I decouple
  create_bd_pin -dir I -type clk gtx_clk
  create_bd_pin -dir I -type clk gtx_clk90
  create_bd_pin -dir I -type rst gtx_rst_n
  create_bd_pin -dir O -from 1 -to 0 shutdown_ack
  create_bd_pin -dir I shutdown_req

  # Create instance: mac, and set properties
  set mac [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac ]
  set_property -dict [ list \
   CONFIG.C_CLK_INPUT_STYLE {BUFIO} \
   CONFIG.C_IFACE_TYPE {RGMII} \
   CONFIG.C_USE_CLK90 {true} \
 ] $mac

  # Create instance: rx_shutdown, and set properties
  set rx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 rx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TREADY {false} \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_CDC_STAGES {4} \
 ] $rx_shutdown

  # Create instance: shutdown_concat, and set properties
  set shutdown_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 shutdown_concat ]

  # Create instance: tx_decoupler, and set properties
  set tx_decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 tx_decoupler ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {axis {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 MODE slave CDC_STAGES 4 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 8} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 0 WIDTH 1} TUSER {PRESENT 1 WIDTH 1} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 1} TKEEP {PRESENT 0 WIDTH 1}}}} IPI_PROP_COUNT 0} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {axis} \
   CONFIG.GUI_SELECT_CDC_STAGES {4} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
   CONFIG.GUI_SELECT_MODE {slave} \
   CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.GUI_SIGNAL_DECOUPLED_0 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_1 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_2 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_4 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_0 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_1 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_2 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_4 {true} \
   CONFIG.GUI_SIGNAL_SELECT_0 {TVALID} \
   CONFIG.GUI_SIGNAL_SELECT_1 {TREADY} \
   CONFIG.GUI_SIGNAL_SELECT_2 {TDATA} \
   CONFIG.GUI_SIGNAL_SELECT_3 {TUSER} \
   CONFIG.GUI_SIGNAL_SELECT_4 {TLAST} \
   CONFIG.GUI_SIGNAL_SELECT_5 {TID} \
   CONFIG.GUI_SIGNAL_SELECT_6 {TDEST} \
   CONFIG.GUI_SIGNAL_SELECT_7 {TSTRB} \
   CONFIG.GUI_SIGNAL_SELECT_8 {TKEEP} \
   CONFIG.GUI_SIGNAL_WIDTH_2 {8} \
   CONFIG.GUI_SIGNAL_WIDTH_7 {1} \
   CONFIG.GUI_SIGNAL_WIDTH_8 {1} \
 ] $tx_decoupler

  # Create instance: tx_reset, and set properties
  set tx_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 tx_reset ]

  # Create instance: tx_shutdown, and set properties
  set tx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 tx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_CDC_STAGES {4} \
 ] $tx_shutdown

  # Create interface connections
  connect_bd_intf_net -intf_net decoupler_s_eth0 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins tx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net mac_eth0_RGMII [get_bd_intf_pins RGMII] [get_bd_intf_pins mac/RGMII]
  connect_bd_intf_net -intf_net mac_eth0_RX_AXIS [get_bd_intf_pins mac/RX_AXIS] [get_bd_intf_pins rx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net pr_decoupler_0_rp_axis [get_bd_intf_pins M_AXIS] [get_bd_intf_pins tx_decoupler/rp_axis]
  connect_bd_intf_net -intf_net pr_shutdown_axis_0_M_AXIS [get_bd_intf_pins mac/TX_AXIS] [get_bd_intf_pins tx_shutdown/M_AXIS]
  connect_bd_intf_net -intf_net rx_shutdown_eth0_M_AXIS [get_bd_intf_pins rx_shutdown/M_AXIS] [get_bd_intf_pins tx_decoupler/s_axis]

  # Create port connections
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins gtx_clk] [get_bd_pins mac/gtx_clk] [get_bd_pins rx_shutdown/shutdown_clk] [get_bd_pins tx_decoupler/decouple_ref_clk] [get_bd_pins tx_shutdown/clk] [get_bd_pins tx_shutdown/shutdown_clk]
  connect_bd_net -net dcm_eth_clk_125M_90 [get_bd_pins gtx_clk90] [get_bd_pins mac/gtx_clk90]
  connect_bd_net -net decouple_1 [get_bd_pins decouple] [get_bd_pins tx_decoupler/decouple]
  connect_bd_net -net mac_eth0_rx_clk [get_bd_pins clk_rx] [get_bd_pins mac/rx_clk] [get_bd_pins rx_shutdown/clk] [get_bd_pins tx_decoupler/axis_ref_clk] [get_bd_pins tx_reset/slowest_sync_clk]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_pins gtx_rst_n] [get_bd_pins mac/gtx_rst_n] [get_bd_pins tx_reset/ext_reset_in] [get_bd_pins tx_shutdown/rst_n]
  connect_bd_net -net rx_shutdown_shutdown_ack [get_bd_pins rx_shutdown/shutdown_ack] [get_bd_pins shutdown_concat/In1]
  connect_bd_net -net shutdown_concat_dout [get_bd_pins shutdown_ack] [get_bd_pins shutdown_concat/dout]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins rx_shutdown/shutdown_req] [get_bd_pins tx_shutdown/shutdown_req]
  connect_bd_net -net tx_reset_peripheral_aresetn [get_bd_pins rx_shutdown/rst_n] [get_bd_pins tx_reset/peripheral_aresetn]
  connect_bd_net -net tx_shutdown_shutdown_ack [get_bd_pins shutdown_concat/In0] [get_bd_pins tx_shutdown/shutdown_ack]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: fifo_chain
proc create_hier_cell_fifo_chain { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_fifo_chain() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  # Create pins
  create_bd_pin -dir I -type clk clk_axi
  create_bd_pin -dir I -type clk clk_axis
  create_bd_pin -dir I ext_fifo_empty
  create_bd_pin -dir O -from 0 -to 0 fifo_empty
  create_bd_pin -dir O -from 13 -to 0 occupancy
  create_bd_pin -dir I rst_axi_n
  create_bd_pin -dir I -type rst rst_axis_n

  # Create instance: fifo_0, and set properties
  set fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_0 ]
  set_property -dict [ list \
   CONFIG.Clock_Type_AXI {Common_Clock} \
   CONFIG.Empty_Threshold_Assert_Value_axis {8190} \
   CONFIG.Empty_Threshold_Assert_Value_rach {14} \
   CONFIG.Empty_Threshold_Assert_Value_rdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wach {14} \
   CONFIG.Empty_Threshold_Assert_Value_wdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wrch {14} \
   CONFIG.Enable_Data_Counts_axis {true} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Enable_TLAST {true} \
   CONFIG.FIFO_Implementation_axis {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_wdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value_axis {8191} \
   CONFIG.Full_Threshold_Assert_Value_rach {15} \
   CONFIG.Full_Threshold_Assert_Value_wach {15} \
   CONFIG.Full_Threshold_Assert_Value_wrch {15} \
   CONFIG.INTERFACE_TYPE {AXI_STREAM} \
   CONFIG.Input_Depth_axis {8192} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TKEEP_WIDTH {16} \
   CONFIG.TSTRB_WIDTH {16} \
   CONFIG.TUSER_WIDTH {0} \
   CONFIG.Use_Embedded_Registers_axis {true} \
   CONFIG.synchronization_stages_axi {4} \
 ] $fifo_0

  # Create instance: fifo_1, and set properties
  set fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_1 ]
  set_property -dict [ list \
   CONFIG.Clock_Type_AXI {Independent_Clock} \
   CONFIG.Empty_Threshold_Assert_Value_axis {8189} \
   CONFIG.Empty_Threshold_Assert_Value_rach {13} \
   CONFIG.Empty_Threshold_Assert_Value_rdch {1021} \
   CONFIG.Empty_Threshold_Assert_Value_wach {13} \
   CONFIG.Empty_Threshold_Assert_Value_wdch {1021} \
   CONFIG.Empty_Threshold_Assert_Value_wrch {13} \
   CONFIG.Enable_Data_Counts_axis {true} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Enable_TLAST {true} \
   CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} \
   CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} \
   CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} \
   CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} \
   CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value_axis {8191} \
   CONFIG.Full_Threshold_Assert_Value_rach {15} \
   CONFIG.Full_Threshold_Assert_Value_wach {15} \
   CONFIG.Full_Threshold_Assert_Value_wrch {15} \
   CONFIG.INTERFACE_TYPE {AXI_STREAM} \
   CONFIG.Input_Depth_axis {8192} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TKEEP_WIDTH {16} \
   CONFIG.TSTRB_WIDTH {16} \
   CONFIG.TUSER_WIDTH {0} \
   CONFIG.Use_Embedded_Registers_axis {true} \
   CONFIG.synchronization_stages_axi {4} \
 ] $fifo_1

  # Create instance: test_empty
  create_hier_cell_test_empty $hier_obj test_empty

  # Create interface connections
  connect_bd_intf_net -intf_net axis_regslice_M_AXIS [get_bd_intf_pins S_AXIS] [get_bd_intf_pins fifo_0/S_AXIS]
  connect_bd_intf_net -intf_net fifo_0_M_AXIS [get_bd_intf_pins fifo_0/M_AXIS] [get_bd_intf_pins fifo_1/S_AXIS]
  connect_bd_intf_net -intf_net fifo_2_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins fifo_1/M_AXIS]

  # Create port connections
  connect_bd_net -net check_empty_fifo_empty [get_bd_pins fifo_empty] [get_bd_pins test_empty/fifo_empty]
  connect_bd_net -net clk_axi_1 [get_bd_pins clk_axi] [get_bd_pins fifo_1/m_aclk] [get_bd_pins test_empty/clk_axi]
  connect_bd_net -net clk_axis_1 [get_bd_pins clk_axis] [get_bd_pins fifo_0/s_aclk] [get_bd_pins fifo_1/s_aclk] [get_bd_pins test_empty/clk_axis]
  connect_bd_net -net ext_fifo_empty_1 [get_bd_pins ext_fifo_empty] [get_bd_pins test_empty/ext_fifo_empty]
  connect_bd_net -net fifo_0_axis_data_count [get_bd_pins fifo_0/axis_data_count] [get_bd_pins test_empty/occupancy0]
  connect_bd_net -net fifo_2_axis_rd_data_count [get_bd_pins occupancy] [get_bd_pins fifo_1/axis_rd_data_count] [get_bd_pins test_empty/occupancy1]
  connect_bd_net -net rst_axi_n_1 [get_bd_pins rst_axi_n] [get_bd_pins test_empty/rst_axi_n]
  connect_bd_net -net rst_n_axis_1 [get_bd_pins rst_axis_n] [get_bd_pins fifo_0/s_aresetn] [get_bd_pins fifo_1/s_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: pr_ctrl
proc create_hier_cell_pr_ctrl { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_pr_ctrl() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:emc_rtl:1.0 bpi
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_reg

  # Create pins
  create_bd_pin -dir IO -from 15 -to 0 bpi_dq
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -type clk clk_bpi
  create_bd_pin -dir I -type clk clk_ddr
  create_bd_pin -dir I clk_rp
  create_bd_pin -dir O -from 0 -to 0 decouple
  create_bd_pin -dir I -from 0 -to 0 -type data rp_active
  create_bd_pin -dir O -from 0 -to 0 rp_active_st
  create_bd_pin -dir I -type rst rst_bpi_n
  create_bd_pin -dir I -type rst rst_ddr_n
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir O rst_rp_n
  create_bd_pin -dir I -from 9 -to 0 shutdown_ack
  create_bd_pin -dir O -from 0 -to 0 shutdown_req

  # Create instance: decouple_cdc, and set properties
  set decouple_cdc [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:util_cdc_array_single:1.0 decouple_cdc ]
  set_property -dict [ list \
   CONFIG.C_NUM_STAGES {2} \
 ] $decouple_cdc

  # Create instance: decoupler, and set properties
  set decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 decoupler ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {active {ID 0 VLNV xilinx.com:signal:data_rtl:1.0 SIGNALS {DATA {PRESENT 1 WIDTH 1}}}} IPI_PROP_COUNT 2} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {active} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
   CONFIG.GUI_SELECT_VLNV {xilinx.com:signal:data_rtl:1.0} \
   CONFIG.GUI_SIGNAL_DECOUPLED_0 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_0 {true} \
   CONFIG.GUI_SIGNAL_SELECT_0 {DATA} \
 ] $decoupler

  # Create instance: icap, and set properties
  set icap [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:util_icap:1.0 icap ]

  # Create instance: memory
  create_hier_cell_memory $hier_obj memory

  # Create instance: pr_controller, and set properties
  set pr_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:prc:1.3 pr_controller ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_AXI_LITE_IF 1 RESET_ACTIVE_LEVEL 0 CP_FIFO_DEPTH 32 CP_FIFO_TYPE lutram CDC_STAGES 6 VS {0 {ID 0 NAME 0 RM {dual_detector {ID 0 NAME dual_detector BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} RESET_REQUIRED low RESET_DURATION 10 SHUTDOWN_REQUIRED hw} dual_tgen_detector {ID 1 NAME dual_tgen_detector BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED hw RESET_REQUIRED low RESET_DURATION 10} dual_tgen_latency {ID 2 NAME dual_tgen_latency BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED hw RESET_REQUIRED low RESET_DURATION 10} quad_tgen {ID 3 NAME quad_tgen BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED hw RESET_REQUIRED low RESET_DURATION 10}} POR_RM dual_detector START_IN_SHUTDOWN 1 SKIP_RM_STARTUP_AFTER_RESET 0 NUM_HW_TRIGGERS 0 NUM_TRIGGERS_ALLOCATED 4 TRIGGER_TO_RM {0 dual_detector 1 dual_tgen_detector 2 dual_tgen_latency 3 quad_tgen} HAS_AXIS_STATUS 0}} CP_FAMILY 7series DIRTY 2 CP_COMPRESSION 0} \
   CONFIG.GUI_CP_COMPRESSION {0} \
   CONFIG.GUI_CP_FIFO_TYPE {lutram} \
   CONFIG.GUI_HAS_AXI_LITE {true} \
   CONFIG.GUI_LOCK_TRIGGER_0 {true} \
   CONFIG.GUI_LOCK_TRIGGER_1 {true} \
   CONFIG.GUI_LOCK_TRIGGER_2 {true} \
   CONFIG.GUI_LOCK_TRIGGER_3 {true} \
   CONFIG.GUI_RM_NEW_NAME {dual_detector} \
   CONFIG.GUI_RM_RESET_DURATION {10} \
   CONFIG.GUI_RM_RESET_REQUIRED {low} \
   CONFIG.GUI_RM_SHUTDOWN_TYPE {hw} \
   CONFIG.GUI_SELECT_RM {0} \
   CONFIG.GUI_SELECT_TRIGGER_0 {0} \
   CONFIG.GUI_SELECT_TRIGGER_1 {1} \
   CONFIG.GUI_SELECT_TRIGGER_2 {2} \
   CONFIG.GUI_SELECT_TRIGGER_3 {3} \
   CONFIG.GUI_SELECT_VS {0} \
   CONFIG.GUI_VS_HAS_AXIS_STATUS {false} \
   CONFIG.GUI_VS_NEW_NAME {0} \
   CONFIG.GUI_VS_NUM_HW_TRIGGERS {0} \
   CONFIG.GUI_VS_NUM_RMS_ALLOCATED {4} \
   CONFIG.GUI_VS_NUM_TRIGGERS_ALLOCATED {4} \
   CONFIG.GUI_VS_POR_RM {0} \
   CONFIG.GUI_VS_SKIP_RM_STARTUP_AFTER_RESET {false} \
   CONFIG.GUI_VS_START_IN_SHUTDOWN {true} \
 ] $pr_controller

  # Create instance: shutdown_ack, and set properties
  set shutdown_ack [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:util_cdc_array_single:1.0 shutdown_ack ]
  set_property -dict [ list \
   CONFIG.C_NUM_STAGES {2} \
 ] $shutdown_ack

  # Create instance: shutdown_and, and set properties
  set shutdown_and [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 shutdown_and ]
  set_property -dict [ list \
   CONFIG.C_SIZE {10} \
 ] $shutdown_and

  # Create instance: shutdown_req_cdc, and set properties
  set shutdown_req_cdc [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:util_cdc_array_single:1.0 shutdown_req_cdc ]
  set_property -dict [ list \
   CONFIG.C_NUM_STAGES {2} \
 ] $shutdown_req_cdc

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins bpi] [get_bd_intf_pins memory/bpi]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins ddr3] [get_bd_intf_pins memory/ddr3]
  connect_bd_intf_net -intf_net pr_controller_ICAP [get_bd_intf_pins icap/ICAP] [get_bd_intf_pins pr_controller/ICAP]
  connect_bd_intf_net -intf_net pr_controller_m_axi_mem [get_bd_intf_pins memory/S_AXI] [get_bd_intf_pins pr_controller/m_axi_mem]
  connect_bd_intf_net -intf_net s_axi_reg_1 [get_bd_intf_pins s_axi_reg] [get_bd_intf_pins pr_controller/s_axi_reg]

  # Create port connections
  connect_bd_net -net Net [get_bd_pins bpi_dq] [get_bd_pins memory/bpi_dq]
  connect_bd_net -net clk_1 [get_bd_pins clk_ddr] [get_bd_pins memory/clk_ddr]
  connect_bd_net -net clk_bpi_1 [get_bd_pins clk_bpi] [get_bd_pins memory/clk_bpi]
  connect_bd_net -net clk_rp_1 [get_bd_pins clk_rp] [get_bd_pins decouple_cdc/clk_dst] [get_bd_pins shutdown_ack/clk_src] [get_bd_pins shutdown_req_cdc/clk_dst]
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins clk] [get_bd_pins decouple_cdc/clk_src] [get_bd_pins icap/clk] [get_bd_pins memory/clk] [get_bd_pins pr_controller/clk] [get_bd_pins pr_controller/icap_clk] [get_bd_pins shutdown_ack/clk_dst] [get_bd_pins shutdown_req_cdc/clk_src]
  connect_bd_net -net decouple_cdc_data_dst [get_bd_pins decouple] [get_bd_pins decouple_cdc/data_dst] [get_bd_pins decoupler/decouple]
  connect_bd_net -net decoupler_s_active_DATA [get_bd_pins rp_active_st] [get_bd_pins decoupler/s_active_DATA]
  connect_bd_net -net pr_controller_vsm_0_rm_decouple [get_bd_pins decouple_cdc/data_src] [get_bd_pins pr_controller/vsm_0_rm_decouple]
  connect_bd_net -net pr_controller_vsm_0_rm_reset [get_bd_pins rst_rp_n] [get_bd_pins pr_controller/vsm_0_rm_reset]
  connect_bd_net -net pr_controller_vsm_0_rm_shutdown_req [get_bd_pins pr_controller/vsm_0_rm_shutdown_req] [get_bd_pins shutdown_req_cdc/data_src]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_pins rst_n] [get_bd_pins memory/rst_n] [get_bd_pins pr_controller/icap_reset] [get_bd_pins pr_controller/reset]
  connect_bd_net -net rp_active_1 [get_bd_pins rp_active] [get_bd_pins decoupler/rp_active_DATA]
  connect_bd_net -net rst_bpi_n_1 [get_bd_pins rst_bpi_n] [get_bd_pins memory/rst_bpi_n]
  connect_bd_net -net rst_n_1 [get_bd_pins rst_ddr_n] [get_bd_pins memory/rst_ddr_n]
  connect_bd_net -net shutdown_ack_1 [get_bd_pins shutdown_ack] [get_bd_pins shutdown_and/Op1]
  connect_bd_net -net shutdown_ack_data_dst [get_bd_pins pr_controller/vsm_0_rm_shutdown_ack] [get_bd_pins shutdown_ack/data_dst]
  connect_bd_net -net shutdown_and_Res [get_bd_pins shutdown_ack/data_src] [get_bd_pins shutdown_and/Res]
  connect_bd_net -net shutdown_req_cdc_data_dst [get_bd_pins shutdown_req] [get_bd_pins shutdown_req_cdc/data_dst]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: pcie
proc create_hier_cell_pcie { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_pcie() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 PCIE
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_IRQ

  # Create pins
  create_bd_pin -dir O -type clk m_axi_aclk
  create_bd_pin -dir O -from 0 -to 0 m_axi_aresetn
  create_bd_pin -dir I -from 0 -to 0 -type clk pcie_clk_n
  create_bd_pin -dir I -from 0 -to 0 -type clk pcie_clk_p
  create_bd_pin -dir I -type rst pcie_perstn
  create_bd_pin -dir I -type rst rst_n

  # Create instance: axi_bridge, and set properties
  set axi_bridge [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_pcie:2.9 axi_bridge ]
  set_property -dict [ list \
   CONFIG.AXIBAR2PCIEBAR_0 {0x00000000} \
   CONFIG.AXIBAR_AS_0 {true} \
   CONFIG.BAR0_SCALE {Kilobytes} \
   CONFIG.BAR0_SIZE {16} \
   CONFIG.BAR1_ENABLED {true} \
   CONFIG.BAR1_SCALE {Megabytes} \
   CONFIG.BAR1_SIZE {4} \
   CONFIG.BAR1_TYPE {Memory} \
   CONFIG.BAR2_ENABLED {false} \
   CONFIG.BAR2_SCALE {N/A} \
   CONFIG.BAR2_SIZE {8} \
   CONFIG.BAR2_TYPE {N/A} \
   CONFIG.BAR_64BIT {true} \
   CONFIG.BASE_CLASS_MENU {Device_was_built_before_Class_Code_definitions_were_finalized} \
   CONFIG.CLASS_CODE {0xFF0000} \
   CONFIG.DEVICE_ID {0x7A62} \
   CONFIG.ENABLE_CLASS_CODE {true} \
   CONFIG.INTERRUPT_PIN {false} \
   CONFIG.MAX_LINK_SPEED {5.0_GT/s} \
   CONFIG.M_AXI_ADDR_WIDTH {32} \
   CONFIG.M_AXI_DATA_WIDTH {128} \
   CONFIG.NO_OF_LANES {X4} \
   CONFIG.NUM_MSI_REQ {1} \
   CONFIG.PCIEBAR2AXIBAR_1 {0x40000000} \
   CONFIG.PCIEBAR2AXIBAR_2 {0xFFFFFFFF} \
   CONFIG.REV_ID {0x02} \
   CONFIG.SUBSYSTEM_ID {0x6E74} \
   CONFIG.SUB_CLASS_INTERFACE_MENU {All_currently_implemented_devices_except_VGA-compatible_devices} \
   CONFIG.S_AXI_DATA_WIDTH {128} \
   CONFIG.S_AXI_SUPPORTS_NARROW_BURST {false} \
   CONFIG.en_ext_clk {false} \
   CONFIG.enable_jtag_dbg {false} \
   CONFIG.shared_logic_in_core {false} \
 ] $axi_bridge

  # Create instance: axis2msi, and set properties
  set axis2msi [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:util_axis2msi:1.0 axis2msi ]

  # Create instance: refclk_ibufds, and set properties
  set refclk_ibufds [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 refclk_ibufds ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $refclk_ibufds

  # Create instance: reset, and set properties
  set reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset ]

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_IRQ_1 [get_bd_intf_pins S_AXIS_IRQ] [get_bd_intf_pins axis2msi/S_AXIS]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_bridge/S_AXI]
  connect_bd_intf_net -intf_net axi_pcie_0_pcie_7x_mgt [get_bd_intf_pins PCIE] [get_bd_intf_pins axi_bridge/pcie_7x_mgt]
  connect_bd_intf_net -intf_net axi_pcie_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins axi_bridge/M_AXI]

  # Create port connections
  connect_bd_net -net IBUF_DS_N_0_1 [get_bd_pins pcie_clk_n] [get_bd_pins refclk_ibufds/IBUF_DS_N]
  connect_bd_net -net IBUF_DS_P_0_1 [get_bd_pins pcie_clk_p] [get_bd_pins refclk_ibufds/IBUF_DS_P]
  connect_bd_net -net aux_reset_in_0_1 [get_bd_pins pcie_perstn] [get_bd_pins reset/aux_reset_in]
  connect_bd_net -net axi_bridge_INTX_MSI_Grant [get_bd_pins axi_bridge/INTX_MSI_Grant] [get_bd_pins axis2msi/msi_grant]
  connect_bd_net -net axi_pcie_0_axi_aclk_out [get_bd_pins m_axi_aclk] [get_bd_pins axi_bridge/axi_aclk_out] [get_bd_pins axis2msi/clk] [get_bd_pins reset/slowest_sync_clk]
  connect_bd_net -net axi_pcie_mmcm_lock [get_bd_pins axi_bridge/mmcm_lock] [get_bd_pins reset/dcm_locked]
  connect_bd_net -net axis2msi_msi_num [get_bd_pins axi_bridge/MSI_Vector_Num] [get_bd_pins axis2msi/msi_num]
  connect_bd_net -net axis2msi_msi_req [get_bd_pins axi_bridge/INTX_MSI_Request] [get_bd_pins axis2msi/msi_req]
  connect_bd_net -net refclk_ibufds_IBUF_OUT [get_bd_pins axi_bridge/REFCLK] [get_bd_pins refclk_ibufds/IBUF_OUT]
  connect_bd_net -net reset_pcie_interconnect_aresetn [get_bd_pins m_axi_aresetn] [get_bd_pins axi_bridge/axi_aresetn] [get_bd_pins axis2msi/rst_n] [get_bd_pins reset/interconnect_aresetn]
  connect_bd_net -net rst_n_1 [get_bd_pins rst_n] [get_bd_pins reset/ext_reset_in]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: macs
proc create_hier_cell_macs { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_macs() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_ETH0
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_ETH1
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_ETH2
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_ETH3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_ETH0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_ETH1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_ETH2
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_ETH3
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 phy0_rgmii
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 phy1_rgmii
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 phy2_rgmii
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 phy3_rgmii

  # Create pins
  create_bd_pin -dir O -type clk clk_rx0
  create_bd_pin -dir O -type clk clk_rx1
  create_bd_pin -dir O -type clk clk_rx2
  create_bd_pin -dir O -type clk clk_rx3
  create_bd_pin -dir I decouple
  create_bd_pin -dir I -type clk gtx_clk
  create_bd_pin -dir I -type clk gtx_clk90
  create_bd_pin -dir I -type rst gtx_rst_n
  create_bd_pin -dir O -from 7 -to 0 shutdown_ack
  create_bd_pin -dir I shutdown_req

  # Create instance: decoupler, and set properties
  set decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 decoupler ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {INTF {eth0 {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 SIGNALS {TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TDATA {PRESENT 1 WIDTH 8} TUSER {PRESENT 1 WIDTH 1} TLAST {PRESENT 1 WIDTH 1} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 1} TKEEP {PRESENT 0 WIDTH 1}}} eth1 {ID 1 VLNV xilinx.com:interface:axis_rtl:1.0 SIGNALS {TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TDATA {PRESENT 1 WIDTH 8} TUSER {PRESENT 1 WIDTH 1} TLAST {PRESENT 1 WIDTH 1} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 1} TKEEP {PRESENT 0 WIDTH 1}}} eth2 {ID 2 VLNV xilinx.com:interface:axis_rtl:1.0 SIGNALS {TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TDATA {PRESENT 1 WIDTH 8} TUSER {PRESENT 1 WIDTH 1} TLAST {PRESENT 1 WIDTH 1} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 1} TKEEP {PRESENT 0 WIDTH 1}}} eth3 {ID 3 VLNV xilinx.com:interface:axis_rtl:1.0 SIGNALS {TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TDATA {PRESENT 1 WIDTH 8} TUSER {PRESENT 1 WIDTH 1} TLAST {PRESENT 1 WIDTH 1} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 1} TKEEP {PRESENT 0 WIDTH 1}}}} IPI_PROP_COUNT 0 HAS_SIGNAL_STATUS 0} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {eth0} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
   CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.GUI_SIGNAL_DECOUPLED_0 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_1 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_0 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_1 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_2 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_4 {true} \
   CONFIG.GUI_SIGNAL_SELECT_0 {TVALID} \
   CONFIG.GUI_SIGNAL_SELECT_1 {TREADY} \
   CONFIG.GUI_SIGNAL_SELECT_2 {TDATA} \
   CONFIG.GUI_SIGNAL_SELECT_3 {TUSER} \
   CONFIG.GUI_SIGNAL_SELECT_4 {TLAST} \
   CONFIG.GUI_SIGNAL_SELECT_5 {TID} \
   CONFIG.GUI_SIGNAL_SELECT_6 {TDEST} \
   CONFIG.GUI_SIGNAL_SELECT_7 {TSTRB} \
   CONFIG.GUI_SIGNAL_SELECT_8 {TKEEP} \
   CONFIG.GUI_SIGNAL_WIDTH_2 {8} \
   CONFIG.GUI_SIGNAL_WIDTH_7 {1} \
   CONFIG.GUI_SIGNAL_WIDTH_8 {1} \
 ] $decoupler

  # Create instance: eth0
  create_hier_cell_eth0 $hier_obj eth0

  # Create instance: eth1
  create_hier_cell_eth1 $hier_obj eth1

  # Create instance: eth2
  create_hier_cell_eth2 $hier_obj eth2

  # Create instance: eth3
  create_hier_cell_eth3 $hier_obj eth3

  # Create instance: shutdown_concat, and set properties
  set shutdown_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 shutdown_concat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {4} \
 ] $shutdown_concat

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_pins decoupler/s_eth1] [get_bd_intf_pins eth1/S_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_2 [get_bd_intf_pins decoupler/s_eth2] [get_bd_intf_pins eth2/S_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_3 [get_bd_intf_pins decoupler/s_eth3] [get_bd_intf_pins eth3/S_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_ETH0_1 [get_bd_intf_pins S_AXIS_ETH0] [get_bd_intf_pins decoupler/rp_eth0]
  connect_bd_intf_net -intf_net S_AXIS_ETH1_1 [get_bd_intf_pins S_AXIS_ETH1] [get_bd_intf_pins decoupler/rp_eth1]
  connect_bd_intf_net -intf_net S_AXIS_ETH2_1 [get_bd_intf_pins S_AXIS_ETH2] [get_bd_intf_pins decoupler/rp_eth2]
  connect_bd_intf_net -intf_net S_AXIS_ETH3_1 [get_bd_intf_pins S_AXIS_ETH3] [get_bd_intf_pins decoupler/rp_eth3]
  connect_bd_intf_net -intf_net decoupler_s_eth0 [get_bd_intf_pins decoupler/s_eth0] [get_bd_intf_pins eth0/S_AXIS]
  connect_bd_intf_net -intf_net eth1_M_AXIS [get_bd_intf_pins M_AXIS_ETH1] [get_bd_intf_pins eth1/M_AXIS]
  connect_bd_intf_net -intf_net eth1_RGMII [get_bd_intf_pins phy1_rgmii] [get_bd_intf_pins eth1/RGMII]
  connect_bd_intf_net -intf_net eth2_M_AXIS [get_bd_intf_pins M_AXIS_ETH2] [get_bd_intf_pins eth2/M_AXIS]
  connect_bd_intf_net -intf_net eth2_RGMII [get_bd_intf_pins phy2_rgmii] [get_bd_intf_pins eth2/RGMII]
  connect_bd_intf_net -intf_net eth3_M_AXIS [get_bd_intf_pins M_AXIS_ETH3] [get_bd_intf_pins eth3/M_AXIS]
  connect_bd_intf_net -intf_net eth3_RGMII [get_bd_intf_pins phy3_rgmii] [get_bd_intf_pins eth3/RGMII]
  connect_bd_intf_net -intf_net mac_eth0_RGMII [get_bd_intf_pins phy0_rgmii] [get_bd_intf_pins eth0/RGMII]
  connect_bd_intf_net -intf_net pr_decoupler_0_rp_axis [get_bd_intf_pins M_AXIS_ETH0] [get_bd_intf_pins eth0/M_AXIS]

  # Create port connections
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins gtx_clk] [get_bd_pins eth0/gtx_clk] [get_bd_pins eth1/gtx_clk] [get_bd_pins eth2/gtx_clk] [get_bd_pins eth3/gtx_clk]
  connect_bd_net -net dcm_eth_clk_125M_90 [get_bd_pins gtx_clk90] [get_bd_pins eth0/gtx_clk90] [get_bd_pins eth1/gtx_clk90] [get_bd_pins eth2/gtx_clk90] [get_bd_pins eth3/gtx_clk90]
  connect_bd_net -net decouple_1 [get_bd_pins decouple] [get_bd_pins decoupler/decouple] [get_bd_pins eth0/decouple] [get_bd_pins eth1/decouple] [get_bd_pins eth2/decouple] [get_bd_pins eth3/decouple]
  connect_bd_net -net eth0_shutdown_ack [get_bd_pins eth0/shutdown_ack] [get_bd_pins shutdown_concat/In0]
  connect_bd_net -net eth1_clk_rx [get_bd_pins clk_rx1] [get_bd_pins eth1/clk_rx]
  connect_bd_net -net eth1_shutdown_ack [get_bd_pins eth1/shutdown_ack] [get_bd_pins shutdown_concat/In1]
  connect_bd_net -net eth2_clk_rx [get_bd_pins clk_rx2] [get_bd_pins eth2/clk_rx]
  connect_bd_net -net eth2_shutdown_ack [get_bd_pins eth2/shutdown_ack] [get_bd_pins shutdown_concat/In2]
  connect_bd_net -net eth3_clk_rx [get_bd_pins clk_rx3] [get_bd_pins eth3/clk_rx]
  connect_bd_net -net eth3_shutdown_ack [get_bd_pins eth3/shutdown_ack] [get_bd_pins shutdown_concat/In3]
  connect_bd_net -net mac_eth0_rx_clk [get_bd_pins clk_rx0] [get_bd_pins eth0/clk_rx]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_pins gtx_rst_n] [get_bd_pins eth0/gtx_rst_n] [get_bd_pins eth1/gtx_rst_n] [get_bd_pins eth2/gtx_rst_n] [get_bd_pins eth3/gtx_rst_n]
  connect_bd_net -net shutdown_concat_dout [get_bd_pins shutdown_ack] [get_bd_pins shutdown_concat/dout]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins eth0/shutdown_req] [get_bd_pins eth1/shutdown_req] [get_bd_pins eth2/shutdown_req] [get_bd_pins eth3/shutdown_req]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: interconnect
proc create_hier_cell_interconnect { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_interconnect() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M02_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M03_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I clk_100M
  create_bd_pin -dir I -type clk clk_125M
  create_bd_pin -dir I decouple
  create_bd_pin -dir I -type rst rst_100M_n
  create_bd_pin -dir I -type rst rst_125M_n
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir O shutdown_ack
  create_bd_pin -dir I shutdown_req

  # Create instance: decoupler, and set properties
  set decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 decoupler ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {axi {ID 0 VLNV xilinx.com:interface:aximm_rtl:1.0 MODE slave SIGNALS {ARVALID {PRESENT 1 WIDTH 1} ARREADY {PRESENT 1 WIDTH 1} AWVALID {PRESENT 1 WIDTH 1} AWREADY {PRESENT 1 WIDTH 1} BVALID {PRESENT 1 WIDTH 1} BREADY {PRESENT 1 WIDTH 1} RVALID {PRESENT 1 WIDTH 1} RREADY {PRESENT 1 WIDTH 1} WVALID {PRESENT 1 WIDTH 1} WREADY {PRESENT 1 WIDTH 1} AWID {PRESENT 0 WIDTH 0} AWADDR {PRESENT 1 WIDTH 22} AWLEN {PRESENT 0 WIDTH 8} AWSIZE {PRESENT 0 WIDTH 3} AWBURST {PRESENT 0 WIDTH 2} AWLOCK {PRESENT 0 WIDTH 1} AWCACHE {PRESENT 0 WIDTH 4} AWPROT {PRESENT 1 WIDTH 3} AWREGION {PRESENT 1 WIDTH 4} AWQOS {PRESENT 1 WIDTH 4} AWUSER {PRESENT 0 WIDTH 0} WID {PRESENT 0 WIDTH 0} WDATA {PRESENT 1 WIDTH 64} WSTRB {PRESENT 1 WIDTH 8} WLAST {PRESENT 0 WIDTH 1} WUSER {PRESENT 0 WIDTH 0} BID {PRESENT 0 WIDTH 0} BRESP {PRESENT 1 WIDTH 2} BUSER {PRESENT 0 WIDTH 0} ARID {PRESENT 0 WIDTH 0} ARADDR {PRESENT 1 WIDTH 22} ARLEN {PRESENT 0 WIDTH 8} ARSIZE {PRESENT 0 WIDTH 3} ARBURST {PRESENT 0 WIDTH 2} ARLOCK {PRESENT 0 WIDTH 1} ARCACHE {PRESENT 0 WIDTH 4} ARPROT {PRESENT 1 WIDTH 3} ARREGION {PRESENT 1 WIDTH 4} ARQOS {PRESENT 1 WIDTH 4} ARUSER {PRESENT 0 WIDTH 0} RID {PRESENT 0 WIDTH 0} RDATA {PRESENT 1 WIDTH 64} RRESP {PRESENT 1 WIDTH 2} RLAST {PRESENT 0 WIDTH 1} RUSER {PRESENT 0 WIDTH 0}} PROTOCOL axi4lite}} IPI_PROP_COUNT 2} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {axi} \
   CONFIG.GUI_INTERFACE_PROTOCOL {axi4lite} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
   CONFIG.GUI_SELECT_MODE {slave} \
   CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:aximm_rtl:1.0} \
   CONFIG.GUI_SIGNAL_DECOUPLED_0 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_1 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_2 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_3 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_4 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_5 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_6 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_7 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_8 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_9 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_0 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_1 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_2 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_3 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_4 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_5 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_6 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_7 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_8 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_9 {true} \
   CONFIG.GUI_SIGNAL_SELECT_0 {ARVALID} \
   CONFIG.GUI_SIGNAL_SELECT_1 {ARREADY} \
   CONFIG.GUI_SIGNAL_SELECT_2 {AWVALID} \
   CONFIG.GUI_SIGNAL_SELECT_3 {AWREADY} \
   CONFIG.GUI_SIGNAL_SELECT_4 {BVALID} \
   CONFIG.GUI_SIGNAL_SELECT_5 {BREADY} \
   CONFIG.GUI_SIGNAL_SELECT_6 {RVALID} \
   CONFIG.GUI_SIGNAL_SELECT_7 {RREADY} \
   CONFIG.GUI_SIGNAL_SELECT_8 {WVALID} \
   CONFIG.GUI_SIGNAL_SELECT_9 {WREADY} \
 ] $decoupler

  # Create instance: interconnect, and set properties
  set interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 interconnect ]
  set_property -dict [ list \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.M02_HAS_REGSLICE {4} \
   CONFIG.M03_HAS_REGSLICE {4} \
   CONFIG.M04_HAS_REGSLICE {4} \
   CONFIG.NUM_MI {4} \
   CONFIG.NUM_SI {2} \
   CONFIG.S00_HAS_DATA_FIFO {0} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.S01_HAS_DATA_FIFO {0} \
   CONFIG.S01_HAS_REGSLICE {4} \
   CONFIG.S02_HAS_DATA_FIFO {0} \
   CONFIG.S02_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {1} \
 ] $interconnect

  # Create instance: jtag_axi, and set properties
  set jtag_axi [ create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi:1.2 jtag_axi ]
  set_property -dict [ list \
   CONFIG.M_HAS_BURST {0} \
   CONFIG.RD_TXN_QUEUE_LENGTH {4} \
   CONFIG.WR_TXN_QUEUE_LENGTH {4} \
 ] $jtag_axi

  # Create instance: shutdown, and set properties
  set shutdown [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_axi_shutdown_manager:1.0 shutdown ]
  set_property -dict [ list \
   CONFIG.DP_AXI_ADDR_WIDTH {22} \
   CONFIG.DP_AXI_DATA_WIDTH {64} \
   CONFIG.DP_AXI_RESP {2} \
   CONFIG.DP_PROTOCOL {AXI4LITE} \
   CONFIG.RP_IS_MASTER {false} \
 ] $shutdown

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins interconnect/S00_AXI]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_pins interconnect/S01_AXI] [get_bd_intf_pins jtag_axi/M_AXI]
  connect_bd_intf_net -intf_net decoupler_rp_axi [get_bd_intf_pins M00_AXI] [get_bd_intf_pins decoupler/rp_axi]
  connect_bd_intf_net -intf_net interconnect_M00_AXI [get_bd_intf_pins interconnect/M00_AXI] [get_bd_intf_pins shutdown/S_AXI]
  connect_bd_intf_net -intf_net interconnect_M01_AXI [get_bd_intf_pins M01_AXI] [get_bd_intf_pins interconnect/M01_AXI]
  connect_bd_intf_net -intf_net interconnect_M02_AXI [get_bd_intf_pins M02_AXI] [get_bd_intf_pins interconnect/M02_AXI]
  connect_bd_intf_net -intf_net interconnect_M03_AXI [get_bd_intf_pins M03_AXI] [get_bd_intf_pins interconnect/M03_AXI]
  connect_bd_intf_net -intf_net shutdown_M_AXI [get_bd_intf_pins decoupler/s_axi] [get_bd_intf_pins shutdown/M_AXI]

  # Create port connections
  connect_bd_net -net clk_1 [get_bd_pins clk] [get_bd_pins interconnect/ACLK] [get_bd_pins interconnect/M03_ACLK] [get_bd_pins interconnect/S00_ACLK]
  connect_bd_net -net clk_100M_1 [get_bd_pins clk_100M] [get_bd_pins interconnect/M02_ACLK] [get_bd_pins interconnect/S01_ACLK] [get_bd_pins jtag_axi/aclk]
  connect_bd_net -net clk_125M_1 [get_bd_pins clk_125M] [get_bd_pins interconnect/M00_ACLK] [get_bd_pins interconnect/M01_ACLK] [get_bd_pins shutdown/clk]
  connect_bd_net -net decouple_1 [get_bd_pins decouple] [get_bd_pins decoupler/decouple]
  connect_bd_net -net rst_100M_n_1 [get_bd_pins rst_100M_n] [get_bd_pins interconnect/M02_ARESETN] [get_bd_pins interconnect/S01_ARESETN] [get_bd_pins jtag_axi/aresetn]
  connect_bd_net -net rst_125M_n_1 [get_bd_pins rst_125M_n] [get_bd_pins interconnect/M00_ARESETN] [get_bd_pins interconnect/M01_ARESETN] [get_bd_pins shutdown/resetn]
  connect_bd_net -net rst_n_1 [get_bd_pins rst_n] [get_bd_pins interconnect/ARESETN] [get_bd_pins interconnect/M03_ARESETN] [get_bd_pins interconnect/S00_ARESETN]
  connect_bd_net -net shutdown_in_shutdown [get_bd_pins shutdown_ack] [get_bd_pins shutdown/in_shutdown]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins shutdown/request_shutdown]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: dtb_rom
proc create_hier_cell_dtb_rom { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_dtb_rom() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir I s_axi_aclk
  create_bd_pin -dir I s_axi_aresetn

  # Create instance: controller, and set properties
  set controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 controller ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.ECC_TYPE {0} \
   CONFIG.SINGLE_PORT_BRAM {1} \
   CONFIG.USE_ECC {0} \
 ] $controller

  # Create instance: mem, and set properties
  set mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 mem ]
  set_property -dict [ list \
   CONFIG.Coe_File {../../../../../../dtb.coe} \
   CONFIG.Load_Init_File {true} \
   CONFIG.Memory_Type {Single_Port_ROM} \
   CONFIG.Port_A_Write_Rate {0} \
   CONFIG.Use_Byte_Write_Enable {false} \
 ] $mem

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins controller/S_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins controller/BRAM_PORTA] [get_bd_intf_pins mem/BRAM_PORTA]

  # Create port connections
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins controller/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins controller/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: dma
proc create_hier_cell_dma { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_dma() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_IRQ
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_PCIE
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_MSG_DMA

  # Create pins
  create_bd_pin -dir I clk_axis
  create_bd_pin -dir I clk_pcie
  create_bd_pin -dir I decouple
  create_bd_pin -dir I ext_fifo_empty
  create_bd_pin -dir I rst_axi_n
  create_bd_pin -dir I rst_axis_n
  create_bd_pin -dir O shutdown_ack
  create_bd_pin -dir I shutdown_req

  # Create instance: axis_regslice, and set properties
  set axis_regslice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_regslice ]
  set_property -dict [ list \
   CONFIG.REG_CONFIG {8} \
 ] $axis_regslice

  # Create instance: axis_shutdown, and set properties
  set axis_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 axis_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_TDATA_WIDTH {128} \
 ] $axis_shutdown

  # Create instance: decoupler_0, and set properties
  set decoupler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 decoupler_0 ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {axis_dma {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 128} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TUSER {PRESENT 0 WIDTH 0} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 16} TKEEP {PRESENT 0 WIDTH 16}}}} IPI_PROP_COUNT 0} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {axis_dma} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
   CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.GUI_SIGNAL_DECOUPLED_0 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_1 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_2 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_4 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_0 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_1 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_2 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_4 {true} \
   CONFIG.GUI_SIGNAL_SELECT_0 {TVALID} \
   CONFIG.GUI_SIGNAL_SELECT_1 {TREADY} \
   CONFIG.GUI_SIGNAL_SELECT_2 {TDATA} \
   CONFIG.GUI_SIGNAL_SELECT_3 {TUSER} \
   CONFIG.GUI_SIGNAL_SELECT_4 {TLAST} \
   CONFIG.GUI_SIGNAL_SELECT_5 {TID} \
   CONFIG.GUI_SIGNAL_SELECT_6 {TDEST} \
   CONFIG.GUI_SIGNAL_SELECT_7 {TSTRB} \
   CONFIG.GUI_SIGNAL_SELECT_8 {TKEEP} \
   CONFIG.GUI_SIGNAL_WIDTH_2 {128} \
   CONFIG.GUI_SIGNAL_WIDTH_7 {16} \
   CONFIG.GUI_SIGNAL_WIDTH_8 {16} \
 ] $decoupler_0

  # Create instance: decoupler_1, and set properties
  set decoupler_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 decoupler_1 ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {intf {ID 0 VLNV xilinx.com:signal:data_rtl:1.0 SIGNALS {DATA {PRESENT 1 WIDTH 1 DECOUPLED_VALUE 0x1}}}} IPI_PROP_COUNT 0} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {intf} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
   CONFIG.GUI_SELECT_VLNV {xilinx.com:signal:data_rtl:1.0} \
   CONFIG.GUI_SIGNAL_DECOUPLED_0 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_VALUE_0 {0x1} \
   CONFIG.GUI_SIGNAL_PRESENT_0 {true} \
   CONFIG.GUI_SIGNAL_SELECT_0 {DATA} \
 ] $decoupler_1

  # Create instance: fifo_chain
  create_hier_cell_fifo_chain $hier_obj fifo_chain

  # Create instance: irq_axis, and set properties
  set irq_axis [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:util_irq2axis:1.0 irq_axis ]
  set_property -dict [ list \
   CONFIG.C_IRQ_NUMBER {0} \
 ] $irq_axis

  # Create instance: msg_dma, and set properties
  set msg_dma [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:circular_dma:1.1 msg_dma ]
  set_property -dict [ list \
   CONFIG.C_AXIS_OCCUP_WIDTH {14} \
   CONFIG.C_AXIS_WIDTH {128} \
   CONFIG.C_AXI_WIDTH {64} \
 ] $msg_dma

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins decoupler_0/rp_axis_dma]
  connect_bd_intf_net -intf_net S_AXIS_2 [get_bd_intf_pins axis_shutdown/M_AXIS] [get_bd_intf_pins fifo_chain/S_AXIS]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI_MSG_DMA] [get_bd_intf_pins msg_dma/S_AXI]
  connect_bd_intf_net -intf_net axis_regslice_M_AXIS [get_bd_intf_pins axis_regslice/M_AXIS] [get_bd_intf_pins axis_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net axis_shutdown_M_AXIS [get_bd_intf_pins fifo_chain/M_AXIS] [get_bd_intf_pins msg_dma/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net decoupler_s_axis_dma [get_bd_intf_pins axis_regslice/S_AXIS] [get_bd_intf_pins decoupler_0/s_axis_dma]
  connect_bd_intf_net -intf_net irq_M_AXIS_IRQ [get_bd_intf_pins M_AXIS_IRQ] [get_bd_intf_pins irq_axis/M_AXIS]
  connect_bd_intf_net -intf_net msg_dma_M_AXI [get_bd_intf_pins M_AXI_PCIE] [get_bd_intf_pins msg_dma/M_AXI]

  # Create port connections
  connect_bd_net -net clk_axi_1 [get_bd_pins clk_pcie] [get_bd_pins fifo_chain/clk_axi] [get_bd_pins irq_axis/clk] [get_bd_pins msg_dma/clk]
  connect_bd_net -net clk_axis_1 [get_bd_pins clk_axis] [get_bd_pins axis_regslice/aclk] [get_bd_pins axis_shutdown/clk] [get_bd_pins fifo_chain/clk_axis]
  connect_bd_net -net decouple_1 [get_bd_pins decouple] [get_bd_pins decoupler_0/decouple] [get_bd_pins decoupler_1/decouple]
  connect_bd_net -net ext_fifo_empty_1 [get_bd_pins ext_fifo_empty] [get_bd_pins decoupler_1/rp_intf_DATA]
  connect_bd_net -net ext_fifo_empty_2 [get_bd_pins decoupler_1/s_intf_DATA] [get_bd_pins fifo_chain/ext_fifo_empty]
  connect_bd_net -net fifo_2_axis_rd_data_count [get_bd_pins fifo_chain/occupancy] [get_bd_pins msg_dma/fifo_occupancy]
  connect_bd_net -net fifo_chain_fifo_empty [get_bd_pins fifo_chain/fifo_empty] [get_bd_pins msg_dma/fifo_flush_ack]
  connect_bd_net -net msg_dma_irq [get_bd_pins irq_axis/irq] [get_bd_pins msg_dma/irq]
  connect_bd_net -net pr_shutdown_shutdown_ack [get_bd_pins shutdown_ack] [get_bd_pins axis_shutdown/shutdown_ack]
  connect_bd_net -net rst_axi_n_1 [get_bd_pins rst_axi_n] [get_bd_pins fifo_chain/rst_axi_n] [get_bd_pins irq_axis/rst_n] [get_bd_pins msg_dma/rst_n]
  connect_bd_net -net rst_n_axis_1 [get_bd_pins rst_axis_n] [get_bd_pins axis_regslice/aresetn] [get_bd_pins axis_shutdown/rst_n] [get_bd_pins fifo_chain/rst_axis_n]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins axis_shutdown/shutdown_req]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: clocks
proc create_hier_cell_clocks { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_clocks() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 system

  # Create pins
  create_bd_pin -dir O -type clk clk_100M
  create_bd_pin -dir O -type clk clk_125M
  create_bd_pin -dir O -type clk clk_125M_90
  create_bd_pin -dir O clk_50M
  create_bd_pin -dir O -from 0 -to 0 clk_sys
  create_bd_pin -dir O -from 0 -to 0 rst_100M_n
  create_bd_pin -dir O -from 0 -to 0 rst_125M_n
  create_bd_pin -dir O -from 0 -to 0 rst_50M_n
  create_bd_pin -dir I rst_n
  create_bd_pin -dir O -from 0 -to 0 rst_sys
  create_bd_pin -dir O -from 0 -to 0 rst_sys_n

  # Create instance: dcm, and set properties
  set dcm [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 dcm ]
  set_property -dict [ list \
   CONFIG.CLKIN1_JITTER_PS {50.0} \
   CONFIG.CLKOUT1_JITTER {107.523} \
   CONFIG.CLKOUT1_PHASE_ERROR {89.971} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125.000} \
   CONFIG.CLKOUT2_JITTER {107.523} \
   CONFIG.CLKOUT2_PHASE_ERROR {89.971} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125.000} \
   CONFIG.CLKOUT2_REQUESTED_PHASE {90.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {112.316} \
   CONFIG.CLKOUT3_PHASE_ERROR {89.971} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {100.000} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_JITTER {129.198} \
   CONFIG.CLKOUT4_PHASE_ERROR {89.971} \
   CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {50.000} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.CLKOUT5_JITTER {112.316} \
   CONFIG.CLKOUT5_PHASE_ERROR {89.971} \
   CONFIG.CLKOUT5_USED {false} \
   CONFIG.CLK_OUT1_PORT {clk_125M} \
   CONFIG.CLK_OUT2_PORT {clk_125M_90} \
   CONFIG.CLK_OUT3_PORT {clk_100M} \
   CONFIG.CLK_OUT4_PORT {clk_50M} \
   CONFIG.CLK_OUT5_PORT {clk_out5} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
   CONFIG.MMCM_CLKIN1_PERIOD {5.000} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {8} \
   CONFIG.MMCM_CLKOUT1_PHASE {90.000} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {10} \
   CONFIG.MMCM_CLKOUT3_DIVIDE {20} \
   CONFIG.MMCM_CLKOUT4_DIVIDE {1} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {4} \
   CONFIG.PRIM_IN_FREQ {200.000} \
   CONFIG.PRIM_SOURCE {No_buffer} \
   CONFIG.USE_RESET {false} \
 ] $dcm

  # Create instance: input_bufds, and set properties
  set input_bufds [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 input_bufds ]

  # Create instance: input_bufg, and set properties
  set input_bufg [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 input_bufg ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {BUFG} \
 ] $input_bufg

  # Create instance: reset_100M, and set properties
  set reset_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset_100M ]

  # Create instance: reset_125M, and set properties
  set reset_125M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset_125M ]

  # Create instance: reset_200M, and set properties
  set reset_200M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset_200M ]

  # Create instance: reset_50M, and set properties
  set reset_50M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset_50M ]

  # Create interface connections
  connect_bd_intf_net -intf_net system_1 [get_bd_intf_pins system] [get_bd_intf_pins input_bufds/CLK_IN_D]

  # Create port connections
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins clk_125M] [get_bd_pins dcm/clk_125M] [get_bd_pins reset_125M/slowest_sync_clk]
  connect_bd_net -net dcm_clk_50M [get_bd_pins clk_50M] [get_bd_pins dcm/clk_50M] [get_bd_pins reset_50M/slowest_sync_clk]
  connect_bd_net -net dcm_eth_clk_100M [get_bd_pins clk_100M] [get_bd_pins dcm/clk_100M] [get_bd_pins reset_100M/slowest_sync_clk]
  connect_bd_net -net dcm_eth_clk_125M_90 [get_bd_pins clk_125M_90] [get_bd_pins dcm/clk_125M_90]
  connect_bd_net -net dcm_locked [get_bd_pins dcm/locked] [get_bd_pins reset_125M/dcm_locked]
  connect_bd_net -net input_bufds_IBUF_OUT [get_bd_pins input_bufds/IBUF_OUT] [get_bd_pins input_bufg/BUFG_I]
  connect_bd_net -net reset_100M_peripheral_aresetn [get_bd_pins rst_100M_n] [get_bd_pins reset_100M/peripheral_aresetn]
  connect_bd_net -net reset_125M_peripheral_aresetn [get_bd_pins rst_125M_n] [get_bd_pins reset_125M/peripheral_aresetn]
  connect_bd_net -net reset_200M_peripheral_aresetn [get_bd_pins rst_sys_n] [get_bd_pins reset_200M/peripheral_aresetn]
  connect_bd_net -net reset_200M_peripheral_reset [get_bd_pins rst_sys] [get_bd_pins reset_200M/peripheral_reset]
  connect_bd_net -net reset_50M_peripheral_aresetn [get_bd_pins rst_50M_n] [get_bd_pins reset_50M/peripheral_aresetn]
  connect_bd_net -net rst_n_1 [get_bd_pins rst_n] [get_bd_pins reset_100M/ext_reset_in] [get_bd_pins reset_125M/ext_reset_in] [get_bd_pins reset_200M/ext_reset_in] [get_bd_pins reset_50M/ext_reset_in]
  connect_bd_net -net util_ds_buf_0_BUFG_O [get_bd_pins clk_sys] [get_bd_pins dcm/clk_in1] [get_bd_pins input_bufg/BUFG_O] [get_bd_pins reset_200M/slowest_sync_clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set bpi [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:emc_rtl:1.0 bpi ]
  set ddr3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3 ]
  set pcie [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie ]
  set phy0_rgmii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 phy0_rgmii ]
  set phy1_rgmii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 phy1_rgmii ]
  set phy2_rgmii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 phy2_rgmii ]
  set phy3_rgmii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 phy3_rgmii ]
  set system [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 system ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $system

  # Create ports
  set bpi_dq [ create_bd_port -dir IO -from 15 -to 0 bpi_dq ]
  set led_0 [ create_bd_port -dir O -from 0 -to 0 led_0 ]
  set led_1 [ create_bd_port -dir O -from 0 -to 0 led_1 ]
  set led_2 [ create_bd_port -dir O -from 0 -to 0 led_2 ]
  set led_3 [ create_bd_port -dir O -from 0 -to 0 led_3 ]
  set pcie_clk_n [ create_bd_port -dir I -from 0 -to 0 -type clk pcie_clk_n ]
  set pcie_clk_p [ create_bd_port -dir I -from 0 -to 0 -type clk pcie_clk_p ]
  set pcie_perstn [ create_bd_port -dir I -type rst pcie_perstn ]
  set phy0_rstn [ create_bd_port -dir O -from 0 -to 0 phy0_rstn ]
  set phy1_rstn [ create_bd_port -dir O -from 0 -to 0 phy1_rstn ]
  set phy2_rstn [ create_bd_port -dir O -from 0 -to 0 phy2_rstn ]
  set phy3_rstn [ create_bd_port -dir O -from 0 -to 0 phy3_rstn ]
  set rst_n [ create_bd_port -dir I -type rst rst_n ]

  # Create instance: clocks
  create_hier_cell_clocks [current_bd_instance .] clocks

  # Create instance: dma
  create_hier_cell_dma [current_bd_instance .] dma

  # Create instance: dtb_rom
  create_hier_cell_dtb_rom [current_bd_instance .] dtb_rom

  # Create instance: idelay_ctrl, and set properties
  set idelay_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_idelay_ctrl:1.0 idelay_ctrl ]

  # Create instance: interconnect
  create_hier_cell_interconnect [current_bd_instance .] interconnect

  # Create instance: macs
  create_hier_cell_macs [current_bd_instance .] macs

  # Create instance: pcie
  create_hier_cell_pcie [current_bd_instance .] pcie

  # Create instance: pr_ctrl
  create_hier_cell_pr_ctrl [current_bd_instance .] pr_ctrl

  # Create instance: rp_wrapper, and set properties
  set rp_wrapper [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:rp_wrapper_netfpga_1g_cml:1.0 rp_wrapper ]

  # Create instance: shutdown_concat, and set properties
  set shutdown_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 shutdown_concat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $shutdown_concat

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins interconnect/S00_AXI] [get_bd_intf_pins pcie/M_AXI]
  connect_bd_intf_net -intf_net S_AXIS_ETH3_1 [get_bd_intf_pins macs/S_AXIS_ETH3] [get_bd_intf_pins rp_wrapper/M_AXIS_ETH3]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins dma/M_AXI_PCIE] [get_bd_intf_pins pcie/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_M01_AXI [get_bd_intf_pins interconnect/M02_AXI] [get_bd_intf_pins pr_ctrl/s_axi_reg]
  connect_bd_intf_net -intf_net axi_interconnect_M03_AXI [get_bd_intf_pins dtb_rom/S_AXI] [get_bd_intf_pins interconnect/M01_AXI]
  connect_bd_intf_net -intf_net axi_pcie_0_pcie_7x_mgt [get_bd_intf_ports pcie] [get_bd_intf_pins pcie/PCIE]
  connect_bd_intf_net -intf_net dma_M_AXIS_IRQ [get_bd_intf_pins dma/M_AXIS_IRQ] [get_bd_intf_pins pcie/S_AXIS_IRQ]
  connect_bd_intf_net -intf_net interconnect_M00_AXI [get_bd_intf_pins interconnect/M00_AXI] [get_bd_intf_pins rp_wrapper/S_AXI_PCIE]
  connect_bd_intf_net -intf_net interconnect_M04_AXI [get_bd_intf_pins dma/S_AXI_MSG_DMA] [get_bd_intf_pins interconnect/M03_AXI]
  connect_bd_intf_net -intf_net mac_eth0_RGMII [get_bd_intf_ports phy0_rgmii] [get_bd_intf_pins macs/phy0_rgmii]
  connect_bd_intf_net -intf_net mac_eth1_RGMII [get_bd_intf_ports phy1_rgmii] [get_bd_intf_pins macs/phy1_rgmii]
  connect_bd_intf_net -intf_net mac_eth2_RGMII [get_bd_intf_ports phy2_rgmii] [get_bd_intf_pins macs/phy2_rgmii]
  connect_bd_intf_net -intf_net mac_eth3_RGMII [get_bd_intf_ports phy3_rgmii] [get_bd_intf_pins macs/phy3_rgmii]
  connect_bd_intf_net -intf_net macs_M_AXIS_ETH0 [get_bd_intf_pins macs/M_AXIS_ETH0] [get_bd_intf_pins rp_wrapper/S_AXIS_ETH0]
  connect_bd_intf_net -intf_net macs_M_AXIS_ETH1 [get_bd_intf_pins macs/M_AXIS_ETH1] [get_bd_intf_pins rp_wrapper/S_AXIS_ETH1]
  connect_bd_intf_net -intf_net macs_M_AXIS_ETH2 [get_bd_intf_pins macs/M_AXIS_ETH2] [get_bd_intf_pins rp_wrapper/S_AXIS_ETH2]
  connect_bd_intf_net -intf_net macs_M_AXIS_ETH3 [get_bd_intf_pins macs/M_AXIS_ETH3] [get_bd_intf_pins rp_wrapper/S_AXIS_ETH3]
  connect_bd_intf_net -intf_net pr_ctrl_bpi1 [get_bd_intf_ports bpi] [get_bd_intf_pins pr_ctrl/bpi]
  connect_bd_intf_net -intf_net pr_ctrl_ddr4 [get_bd_intf_ports ddr3] [get_bd_intf_pins pr_ctrl/ddr3]
  connect_bd_intf_net -intf_net rp_wrapper_M_AXIS_DMA [get_bd_intf_pins dma/S_AXIS] [get_bd_intf_pins rp_wrapper/M_AXIS_DMA]
  connect_bd_intf_net -intf_net rp_wrapper_M_AXIS_ETH0 [get_bd_intf_pins macs/S_AXIS_ETH0] [get_bd_intf_pins rp_wrapper/M_AXIS_ETH0]
  connect_bd_intf_net -intf_net rp_wrapper_M_AXIS_ETH1 [get_bd_intf_pins macs/S_AXIS_ETH1] [get_bd_intf_pins rp_wrapper/M_AXIS_ETH1]
  connect_bd_intf_net -intf_net rp_wrapper_M_AXIS_ETH2 [get_bd_intf_pins macs/S_AXIS_ETH2] [get_bd_intf_pins rp_wrapper/M_AXIS_ETH2]
  connect_bd_intf_net -intf_net system_1 [get_bd_intf_ports system] [get_bd_intf_pins clocks/system]

  # Create port connections
  connect_bd_net -net IBUF_DS_N_0_1 [get_bd_ports pcie_clk_n] [get_bd_pins pcie/pcie_clk_n]
  connect_bd_net -net IBUF_DS_P_0_1 [get_bd_ports pcie_clk_p] [get_bd_pins pcie/pcie_clk_p]
  connect_bd_net -net Net [get_bd_ports bpi_dq] [get_bd_pins pr_ctrl/bpi_dq]
  connect_bd_net -net aux_reset_in_0_1 [get_bd_ports pcie_perstn] [get_bd_pins pcie/pcie_perstn]
  connect_bd_net -net axi_pcie_0_axi_aclk_out [get_bd_pins dma/clk_pcie] [get_bd_pins interconnect/clk] [get_bd_pins pcie/m_axi_aclk]
  connect_bd_net -net clk_1 [get_bd_pins clocks/clk_100M] [get_bd_pins interconnect/clk_100M] [get_bd_pins pr_ctrl/clk]
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins clocks/clk_125M] [get_bd_pins dma/clk_axis] [get_bd_pins dtb_rom/s_axi_aclk] [get_bd_pins interconnect/clk_125M] [get_bd_pins macs/gtx_clk] [get_bd_pins pr_ctrl/clk_rp] [get_bd_pins rp_wrapper/clk]
  connect_bd_net -net clocks_clk_200M [get_bd_pins clocks/clk_sys] [get_bd_pins idelay_ctrl/ref_clk] [get_bd_pins pr_ctrl/clk_ddr]
  connect_bd_net -net clocks_clk_50M [get_bd_pins clocks/clk_50M] [get_bd_pins pr_ctrl/clk_bpi]
  connect_bd_net -net clocks_rst_100M_n [get_bd_pins clocks/rst_100M_n] [get_bd_pins interconnect/rst_100M_n] [get_bd_pins pr_ctrl/rst_n]
  connect_bd_net -net clocks_rst_200M [get_bd_pins clocks/rst_sys] [get_bd_pins idelay_ctrl/rst]
  connect_bd_net -net clocks_rst_sys_n [get_bd_pins clocks/rst_sys_n] [get_bd_pins pr_ctrl/rst_ddr_n]
  connect_bd_net -net dcm_eth_clk_125M_90 [get_bd_pins clocks/clk_125M_90] [get_bd_pins macs/gtx_clk90]
  connect_bd_net -net dma_shutdown_ack [get_bd_pins dma/shutdown_ack] [get_bd_pins shutdown_concat/In2]
  connect_bd_net -net interconnect_shutdown_ack [get_bd_pins interconnect/shutdown_ack] [get_bd_pins shutdown_concat/In1]
  connect_bd_net -net macs_clk_rx0 [get_bd_pins macs/clk_rx0] [get_bd_pins rp_wrapper/clk_rx0]
  connect_bd_net -net macs_clk_rx1 [get_bd_pins macs/clk_rx1] [get_bd_pins rp_wrapper/clk_rx1]
  connect_bd_net -net macs_clk_rx2 [get_bd_pins macs/clk_rx2] [get_bd_pins rp_wrapper/clk_rx2]
  connect_bd_net -net macs_clk_rx3 [get_bd_pins macs/clk_rx3] [get_bd_pins rp_wrapper/clk_rx3]
  connect_bd_net -net macs_shutdown_ack [get_bd_pins macs/shutdown_ack] [get_bd_pins shutdown_concat/In0]
  connect_bd_net -net pcie_axi_pcie_rst_n [get_bd_ports led_0] [get_bd_pins dma/rst_axi_n] [get_bd_pins interconnect/rst_n] [get_bd_pins pcie/m_axi_aresetn]
  connect_bd_net -net pr_controller_vsm_vs_rm_decouple [get_bd_ports led_2] [get_bd_pins dma/decouple] [get_bd_pins interconnect/decouple] [get_bd_pins macs/decouple] [get_bd_pins pr_ctrl/decouple]
  connect_bd_net -net pr_ctrl_rp_active_st [get_bd_ports led_3] [get_bd_pins pr_ctrl/rp_active_st]
  connect_bd_net -net pr_ctrl_rp_shutdown_req [get_bd_ports led_1] [get_bd_pins dma/shutdown_req] [get_bd_pins interconnect/shutdown_req] [get_bd_pins macs/shutdown_req] [get_bd_pins pr_ctrl/shutdown_req]
  connect_bd_net -net pr_ctrl_rst_rp_n [get_bd_pins pr_ctrl/rst_rp_n] [get_bd_pins rp_wrapper/rst_prc_n]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_ports phy0_rstn] [get_bd_ports phy1_rstn] [get_bd_ports phy2_rstn] [get_bd_ports phy3_rstn] [get_bd_pins clocks/rst_125M_n] [get_bd_pins dma/rst_axis_n] [get_bd_pins dtb_rom/s_axi_aresetn] [get_bd_pins interconnect/rst_125M_n] [get_bd_pins macs/gtx_rst_n] [get_bd_pins rp_wrapper/rst_n]
  connect_bd_net -net rp_active_1 [get_bd_pins pr_ctrl/rp_active] [get_bd_pins rp_wrapper/active]
  connect_bd_net -net rp_wrapper_fifo_empty [get_bd_pins dma/ext_fifo_empty] [get_bd_pins rp_wrapper/fifo_empty]
  connect_bd_net -net rst_bpi_n_1 [get_bd_pins clocks/rst_50M_n] [get_bd_pins pr_ctrl/rst_bpi_n]
  connect_bd_net -net rst_n_1 [get_bd_ports rst_n] [get_bd_pins clocks/rst_n] [get_bd_pins pcie/rst_n]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins pr_ctrl/shutdown_ack] [get_bd_pins shutdown_concat/dout]

  # Create address segments
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces dma/msg_dma/M_AXI] [get_bd_addr_segs pcie/axi_bridge/S_AXI/BAR0] SEG_axi_bridge_BAR0
  create_bd_addr_seg -range 0x00001000 -offset 0x00000000 [get_bd_addr_spaces interconnect/jtag_axi/Data] [get_bd_addr_segs dtb_rom/controller/S_AXI/Mem0] SEG_controller_Mem0
  create_bd_addr_seg -range 0x00001000 -offset 0x00002000 [get_bd_addr_spaces interconnect/jtag_axi/Data] [get_bd_addr_segs dma/msg_dma/S_AXI/S_AXI_ADDR] SEG_msg_dma_S_AXI_ADDR
  create_bd_addr_seg -range 0x00001000 -offset 0x00001000 [get_bd_addr_spaces interconnect/jtag_axi/Data] [get_bd_addr_segs pr_ctrl/pr_controller/s_axi_reg/Reg] SEG_pr_controller_Reg
  create_bd_addr_seg -range 0x00400000 -offset 0x40000000 [get_bd_addr_spaces interconnect/jtag_axi/Data] [get_bd_addr_segs rp_wrapper/S_AXI_PCIE/reg0] SEG_rp_wrapper_reg0
  create_bd_addr_seg -range 0x00001000 -offset 0x00000000 [get_bd_addr_spaces pcie/axi_bridge/M_AXI] [get_bd_addr_segs dtb_rom/controller/S_AXI/Mem0] SEG_controller_Mem0
  create_bd_addr_seg -range 0x00001000 -offset 0x00002000 [get_bd_addr_spaces pcie/axi_bridge/M_AXI] [get_bd_addr_segs dma/msg_dma/S_AXI/S_AXI_ADDR] SEG_dma_S_AXI_ADDR
  create_bd_addr_seg -range 0x00001000 -offset 0x00001000 [get_bd_addr_spaces pcie/axi_bridge/M_AXI] [get_bd_addr_segs pr_ctrl/pr_controller/s_axi_reg/Reg] SEG_pr_controller_Reg
  create_bd_addr_seg -range 0x00400000 -offset 0x40000000 [get_bd_addr_spaces pcie/axi_bridge/M_AXI] [get_bd_addr_segs rp_wrapper/S_AXI_PCIE/reg0] SEG_rp_wrapper_reg0
  create_bd_addr_seg -range 0x08000000 -offset 0x00000000 [get_bd_addr_spaces pr_ctrl/memory/pr_copy/M_AXI_SRC] [get_bd_addr_segs pr_ctrl/memory/bpi_controller/S_AXI/S_AXI_ADDR] SEG_bpi_controller_S_AXI_ADDR
  create_bd_addr_seg -range 0x20000000 -offset 0x00000000 [get_bd_addr_spaces pr_ctrl/memory/pr_copy/M_AXI_DST] [get_bd_addr_segs pr_ctrl/memory/ddr_controller/memmap/memaddr] SEG_ddr_controller_memaddr
  create_bd_addr_seg -range 0x20000000 -offset 0x00000000 [get_bd_addr_spaces pr_ctrl/memory/pr_copy/M_AXI_PRC] [get_bd_addr_segs pr_ctrl/memory/ddr_controller/memmap/memaddr] SEG_ddr_controller_memaddr


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


