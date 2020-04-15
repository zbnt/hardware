
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
oscar-rc.dev:zbnt_hw:bpi_flash:1.0\
xilinx.com:ip:util_idelay_ctrl:1.0\
oscar-rc.dev:zbnt_hw:rp_wrapper_netfpga_1g_cml:1.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:util_ds_buf:2.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:mig_7series:4.2\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:pr_decoupler:1.0\
xilinx.com:ip:axi_dwidth_converter:2.1\
alexforencich.com:verilog-ethernet:eth_mac_1g:1.0\
xilinx.com:ip:axi_pcie:2.9\
xilinx.com:ip:axi_clock_converter:2.1\
oscar-rc.dev:zbnt_hw:util_icap:1.0\
xilinx.com:ip:prc:1.3\
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

proc write_mig_file_bd_static_controller_0 { str_mig_prj_filepath } {

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
# End of write_mig_file_bd_static_controller_0()



##################################################################
# DESIGN PROCs
##################################################################


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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_mem
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_reg

  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir O decouple
  create_bd_pin -dir I -type clk icap_clk
  create_bd_pin -dir I -type rst icap_reset
  create_bd_pin -dir I -from 0 -to 0 -type data rp_active
  create_bd_pin -dir O -from 0 -to 0 rp_active_st
  create_bd_pin -dir I rp_shutdown_ack
  create_bd_pin -dir O rp_shutdown_req
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir O rst_rp_n

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

  # Create instance: pr_controller, and set properties
  set pr_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:prc:1.3 pr_controller ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_AXI_LITE_IF 1 RESET_ACTIVE_LEVEL 0 CP_FIFO_DEPTH 32 CP_FIFO_TYPE lutram CDC_STAGES 6 VS {0 {ID 0 NAME 0 RM {rp {ID 0 NAME rp BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} RESET_REQUIRED low RESET_DURATION 10 SHUTDOWN_REQUIRED hw}} POR_RM rp START_IN_SHUTDOWN 1}} CP_FAMILY 7series DIRTY 0 CP_COMPRESSION 1} \
   CONFIG.GUI_CP_COMPRESSION {1} \
   CONFIG.GUI_CP_FIFO_TYPE {lutram} \
   CONFIG.GUI_HAS_AXI_LITE {true} \
   CONFIG.GUI_RM_NEW_NAME {rp} \
   CONFIG.GUI_RM_RESET_DURATION {10} \
   CONFIG.GUI_RM_RESET_REQUIRED {low} \
   CONFIG.GUI_RM_SHUTDOWN_TYPE {hw} \
   CONFIG.GUI_VS_NEW_NAME {0} \
   CONFIG.GUI_VS_START_IN_SHUTDOWN {true} \
 ] $pr_controller

  # Create interface connections
  connect_bd_intf_net -intf_net axi_interconnect_M01_AXI [get_bd_intf_pins s_axi_reg] [get_bd_intf_pins pr_controller/s_axi_reg]
  connect_bd_intf_net -intf_net pr_controller_ICAP [get_bd_intf_pins icap/ICAP] [get_bd_intf_pins pr_controller/ICAP]
  connect_bd_intf_net -intf_net pr_controller_m_axi_mem [get_bd_intf_pins m_axi_mem] [get_bd_intf_pins pr_controller/m_axi_mem]

  # Create port connections
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins clk] [get_bd_pins pr_controller/clk]
  connect_bd_net -net clocks_rst_100M_n [get_bd_pins icap_reset] [get_bd_pins pr_controller/icap_reset]
  connect_bd_net -net dcm_eth_clk_100M [get_bd_pins icap_clk] [get_bd_pins pr_controller/icap_clk]
  connect_bd_net -net decoupler_s_active_DATA [get_bd_pins rp_active_st] [get_bd_pins decoupler/s_active_DATA]
  connect_bd_net -net pr_controller_vsm_0_rm_decouple [get_bd_pins decouple] [get_bd_pins decoupler/decouple] [get_bd_pins pr_controller/vsm_0_rm_decouple]
  connect_bd_net -net pr_controller_vsm_0_rm_reset [get_bd_pins rst_rp_n] [get_bd_pins pr_controller/vsm_0_rm_reset]
  connect_bd_net -net pr_controller_vsm_0_rm_shutdown_req [get_bd_pins rp_shutdown_req] [get_bd_pins pr_controller/vsm_0_rm_shutdown_req]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_pins rst_n] [get_bd_pins pr_controller/reset]
  connect_bd_net -net rp_active_1 [get_bd_pins rp_active] [get_bd_pins decoupler/rp_active_DATA]
  connect_bd_net -net rp_shutdown_ack_1 [get_bd_pins rp_shutdown_ack] [get_bd_pins pr_controller/vsm_0_rm_shutdown_ack]

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

  # Create pins
  create_bd_pin -dir I decouple
  create_bd_pin -dir I irq
  create_bd_pin -dir O -type clk m_axi_aclk
  create_bd_pin -dir O -from 0 -to 0 m_axi_aresetn
  create_bd_pin -dir I -from 0 -to 0 -type clk pcie_clk_n
  create_bd_pin -dir I -from 0 -to 0 -type clk pcie_clk_p
  create_bd_pin -dir I -type rst pcie_perstn
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: axi_bridge, and set properties
  set axi_bridge [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_pcie:2.9 axi_bridge ]
  set_property -dict [ list \
   CONFIG.AXIBAR2PCIEBAR_0 {0x00000000} \
   CONFIG.AXIBAR_AS_0 {true} \
   CONFIG.BAR0_SCALE {Megabytes} \
   CONFIG.BAR0_SIZE {16} \
   CONFIG.BAR1_ENABLED {true} \
   CONFIG.BAR1_SCALE {Megabytes} \
   CONFIG.BAR1_SIZE {4} \
   CONFIG.BAR1_TYPE {Memory} \
   CONFIG.BAR2_ENABLED {true} \
   CONFIG.BAR2_SCALE {Megabytes} \
   CONFIG.BAR2_SIZE {128} \
   CONFIG.BAR2_TYPE {Memory} \
   CONFIG.BAR_64BIT {true} \
   CONFIG.BASE_CLASS_MENU {Device_was_built_before_Class_Code_definitions_were_finalized} \
   CONFIG.CLASS_CODE {0x118000} \
   CONFIG.DEVICE_ID {0x7024} \
   CONFIG.ENABLE_CLASS_CODE {true} \
   CONFIG.INTERRUPT_PIN {false} \
   CONFIG.MAX_LINK_SPEED {5.0_GT/s} \
   CONFIG.M_AXI_ADDR_WIDTH {32} \
   CONFIG.M_AXI_DATA_WIDTH {128} \
   CONFIG.NO_OF_LANES {X4} \
   CONFIG.NUM_MSI_REQ {1} \
   CONFIG.PCIEBAR2AXIBAR_1 {0x40000000} \
   CONFIG.PCIEBAR2AXIBAR_2 {0x80000000} \
   CONFIG.SUBSYSTEM_ID {0x6E74} \
   CONFIG.SUB_CLASS_INTERFACE_MENU {All_currently_implemented_devices_except_VGA-compatible_devices} \
   CONFIG.S_AXI_DATA_WIDTH {128} \
   CONFIG.S_AXI_SUPPORTS_NARROW_BURST {false} \
   CONFIG.en_ext_clk {false} \
   CONFIG.enable_jtag_dbg {false} \
   CONFIG.shared_logic_in_core {false} \
 ] $axi_bridge

  # Create instance: axi_cc, and set properties
  set axi_cc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 axi_cc ]

  # Create instance: axi_decoupler, and set properties
  set axi_decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 axi_decoupler ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {s_axi_pcie {ID 0 VLNV xilinx.com:interface:aximm_rtl:1.0 SIGNALS {ARVALID {PRESENT 0 WIDTH 1} ARREADY {PRESENT 0 WIDTH 1} AWVALID {PRESENT 1 WIDTH 1} AWREADY {PRESENT 1 WIDTH 1} BVALID {PRESENT 1 WIDTH 1} BREADY {PRESENT 1 WIDTH 1} RVALID {PRESENT 0 WIDTH 1} RREADY {PRESENT 0 WIDTH 1} WVALID {PRESENT 1 WIDTH 1} WREADY {PRESENT 1 WIDTH 1} AWID {PRESENT 0 WIDTH 0} AWADDR {PRESENT 1 WIDTH 32} AWLEN {PRESENT 1 WIDTH 8} AWSIZE {PRESENT 1 WIDTH 3} AWBURST {PRESENT 1 WIDTH 2} AWLOCK {PRESENT 1 WIDTH 1} AWCACHE {PRESENT 1 WIDTH 4} AWPROT {PRESENT 1 WIDTH 3} AWREGION {PRESENT 1 WIDTH 4} AWQOS {PRESENT 1 WIDTH 4} AWUSER {PRESENT 0 WIDTH 0} WID {PRESENT 0 WIDTH 0} WDATA {PRESENT 1 WIDTH 128} WSTRB {PRESENT 1 WIDTH 16} WLAST {PRESENT 1 WIDTH 1} WUSER {PRESENT 0 WIDTH 0} BID {PRESENT 0 WIDTH 0} BRESP {PRESENT 1 WIDTH 2} BUSER {PRESENT 0 WIDTH 0} ARID {PRESENT 0 WIDTH 0} ARADDR {PRESENT 0 WIDTH 32} ARLEN {PRESENT 0 WIDTH 8} ARSIZE {PRESENT 0 WIDTH 3} ARBURST {PRESENT 0 WIDTH 2} ARLOCK {PRESENT 0 WIDTH 1} ARCACHE {PRESENT 0 WIDTH 4} ARPROT {PRESENT 0 WIDTH 3} ARREGION {PRESENT 0 WIDTH 4} ARQOS {PRESENT 0 WIDTH 4} ARUSER {PRESENT 0 WIDTH 0} RID {PRESENT 0 WIDTH 0} RDATA {PRESENT 0 WIDTH 128} RRESP {PRESENT 0 WIDTH 2} RLAST {PRESENT 0 WIDTH 1} RUSER {PRESENT 0 WIDTH 0}}}} IPI_PROP_COUNT 2} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {0} \
   CONFIG.GUI_INTERFACE_NAME {s_axi_pcie} \
   CONFIG.GUI_INTERFACE_PROTOCOL {axi4} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
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
   CONFIG.GUI_SIGNAL_PRESENT_0 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_1 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_2 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_3 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_4 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_5 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_6 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_7 {false} \
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
 ] $axi_decoupler

  # Create instance: irq_decoupler, and set properties
  set irq_decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 irq_decoupler ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {irq {ID 0 VLNV xilinx.com:signal:interrupt_rtl:1.0 SIGNALS {INTERRUPT {PRESENT 1 WIDTH 1}}}} IPI_PROP_COUNT 3} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {irq} \
   CONFIG.GUI_INTERFACE_PROTOCOL {none} \
   CONFIG.GUI_SELECT_INTERFACE {0} \
   CONFIG.GUI_SELECT_VLNV {xilinx.com:signal:interrupt_rtl:1.0} \
   CONFIG.GUI_SIGNAL_DECOUPLED_0 {true} \
   CONFIG.GUI_SIGNAL_DECOUPLED_1 {false} \
   CONFIG.GUI_SIGNAL_DECOUPLED_2 {false} \
   CONFIG.GUI_SIGNAL_DECOUPLED_3 {false} \
   CONFIG.GUI_SIGNAL_DECOUPLED_4 {false} \
   CONFIG.GUI_SIGNAL_DECOUPLED_5 {false} \
   CONFIG.GUI_SIGNAL_DECOUPLED_6 {false} \
   CONFIG.GUI_SIGNAL_DECOUPLED_7 {false} \
   CONFIG.GUI_SIGNAL_DECOUPLED_8 {false} \
   CONFIG.GUI_SIGNAL_DECOUPLED_9 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_0 {true} \
   CONFIG.GUI_SIGNAL_PRESENT_1 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_2 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_3 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_4 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_5 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_6 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_7 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_8 {false} \
   CONFIG.GUI_SIGNAL_PRESENT_9 {false} \
   CONFIG.GUI_SIGNAL_SELECT_0 {INTERRUPT} \
   CONFIG.GUI_SIGNAL_SELECT_1 {-1} \
   CONFIG.GUI_SIGNAL_SELECT_2 {-1} \
   CONFIG.GUI_SIGNAL_SELECT_3 {-1} \
   CONFIG.GUI_SIGNAL_SELECT_4 {-1} \
   CONFIG.GUI_SIGNAL_SELECT_5 {-1} \
   CONFIG.GUI_SIGNAL_SELECT_6 {-1} \
   CONFIG.GUI_SIGNAL_SELECT_7 {-1} \
   CONFIG.GUI_SIGNAL_SELECT_8 {-1} \
   CONFIG.GUI_SIGNAL_SELECT_9 {-1} \
 ] $irq_decoupler

  # Create instance: refclk_bufg, and set properties
  set refclk_bufg [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 refclk_bufg ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {BUFG} \
 ] $refclk_bufg

  # Create instance: refclk_ibufds, and set properties
  set refclk_ibufds [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 refclk_ibufds ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $refclk_ibufds

  # Create instance: reset, and set properties
  set reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset ]

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_decoupler/rp_s_axi_pcie]
  connect_bd_intf_net -intf_net axi_pcie_0_pcie_7x_mgt [get_bd_intf_pins PCIE] [get_bd_intf_pins axi_bridge/pcie_7x_mgt]
  connect_bd_intf_net -intf_net axi_pcie_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins axi_bridge/M_AXI]
  connect_bd_intf_net -intf_net axi_pcie_cc_M_AXI [get_bd_intf_pins axi_bridge/S_AXI] [get_bd_intf_pins axi_cc/M_AXI]
  connect_bd_intf_net -intf_net decoupler_s_s_axi_pcie [get_bd_intf_pins axi_cc/S_AXI] [get_bd_intf_pins axi_decoupler/s_s_axi_pcie]

  # Create port connections
  connect_bd_net -net IBUF_DS_N_0_1 [get_bd_pins pcie_clk_n] [get_bd_pins refclk_ibufds/IBUF_DS_N]
  connect_bd_net -net IBUF_DS_P_0_1 [get_bd_pins pcie_clk_p] [get_bd_pins refclk_ibufds/IBUF_DS_P]
  connect_bd_net -net aux_reset_in_0_1 [get_bd_pins pcie_perstn] [get_bd_pins reset/aux_reset_in]
  connect_bd_net -net axi_pcie_0_axi_aclk_out [get_bd_pins m_axi_aclk] [get_bd_pins axi_bridge/axi_aclk_out] [get_bd_pins axi_cc/m_axi_aclk] [get_bd_pins reset/slowest_sync_clk]
  connect_bd_net -net axi_pcie_mmcm_lock [get_bd_pins axi_bridge/mmcm_lock] [get_bd_pins reset/dcm_locked]
  connect_bd_net -net decouple_1 [get_bd_pins decouple] [get_bd_pins axi_decoupler/decouple] [get_bd_pins irq_decoupler/decouple]
  connect_bd_net -net irq_1 [get_bd_pins irq] [get_bd_pins irq_decoupler/rp_irq_INTERRUPT]
  connect_bd_net -net irq_decoupler_s_irq_INTERRUPT [get_bd_pins axi_bridge/INTX_MSI_Request] [get_bd_pins irq_decoupler/s_irq_INTERRUPT]
  connect_bd_net -net refclk_ibufds_IBUF_OUT [get_bd_pins refclk_bufg/BUFG_I] [get_bd_pins refclk_ibufds/IBUF_OUT]
  connect_bd_net -net reset_pcie_interconnect_aresetn [get_bd_pins m_axi_aresetn] [get_bd_pins axi_bridge/axi_aresetn] [get_bd_pins axi_cc/m_axi_aresetn] [get_bd_pins reset/interconnect_aresetn]
  connect_bd_net -net rst_n_1 [get_bd_pins rst_n] [get_bd_pins reset/ext_reset_in]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins axi_cc/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins axi_cc/s_axi_aresetn]
  connect_bd_net -net util_ds_buf_0_BUFG_O [get_bd_pins axi_bridge/REFCLK] [get_bd_pins refclk_bufg/BUFG_O]

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

  # Create instance: mac_eth0, and set properties
  set mac_eth0 [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac_eth0 ]
  set_property -dict [ list \
   CONFIG.C_IFACE_TYPE {RGMII} \
   CONFIG.C_USE_CLK90 {true} \
 ] $mac_eth0

  # Create instance: mac_eth1, and set properties
  set mac_eth1 [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac_eth1 ]
  set_property -dict [ list \
   CONFIG.C_IFACE_TYPE {RGMII} \
   CONFIG.C_USE_CLK90 {true} \
 ] $mac_eth1

  # Create instance: mac_eth2, and set properties
  set mac_eth2 [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac_eth2 ]
  set_property -dict [ list \
   CONFIG.C_IFACE_TYPE {RGMII} \
   CONFIG.C_USE_CLK90 {true} \
 ] $mac_eth2

  # Create instance: mac_eth3, and set properties
  set mac_eth3 [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac_eth3 ]
  set_property -dict [ list \
   CONFIG.C_IFACE_TYPE {RGMII} \
   CONFIG.C_USE_CLK90 {true} \
 ] $mac_eth3

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_ETH0_1 [get_bd_intf_pins S_AXIS_ETH0] [get_bd_intf_pins decoupler/rp_eth0]
  connect_bd_intf_net -intf_net S_AXIS_ETH1_1 [get_bd_intf_pins S_AXIS_ETH1] [get_bd_intf_pins decoupler/rp_eth1]
  connect_bd_intf_net -intf_net S_AXIS_ETH2_1 [get_bd_intf_pins S_AXIS_ETH2] [get_bd_intf_pins decoupler/rp_eth2]
  connect_bd_intf_net -intf_net S_AXIS_ETH3_1 [get_bd_intf_pins S_AXIS_ETH3] [get_bd_intf_pins decoupler/rp_eth3]
  connect_bd_intf_net -intf_net mac_eth0_RGMII [get_bd_intf_pins phy0_rgmii] [get_bd_intf_pins mac_eth0/RGMII]
  connect_bd_intf_net -intf_net mac_eth0_RX_AXIS [get_bd_intf_pins M_AXIS_ETH0] [get_bd_intf_pins mac_eth0/RX_AXIS]
  connect_bd_intf_net -intf_net mac_eth1_RGMII [get_bd_intf_pins phy1_rgmii] [get_bd_intf_pins mac_eth1/RGMII]
  connect_bd_intf_net -intf_net mac_eth1_RX_AXIS [get_bd_intf_pins M_AXIS_ETH1] [get_bd_intf_pins mac_eth1/RX_AXIS]
  connect_bd_intf_net -intf_net mac_eth2_RGMII [get_bd_intf_pins phy2_rgmii] [get_bd_intf_pins mac_eth2/RGMII]
  connect_bd_intf_net -intf_net mac_eth2_RX_AXIS [get_bd_intf_pins M_AXIS_ETH2] [get_bd_intf_pins mac_eth2/RX_AXIS]
  connect_bd_intf_net -intf_net mac_eth3_RGMII [get_bd_intf_pins phy3_rgmii] [get_bd_intf_pins mac_eth3/RGMII]
  connect_bd_intf_net -intf_net mac_eth3_RX_AXIS [get_bd_intf_pins M_AXIS_ETH3] [get_bd_intf_pins mac_eth3/RX_AXIS]
  connect_bd_intf_net -intf_net pr_decoupler_0_s_eth0 [get_bd_intf_pins decoupler/s_eth0] [get_bd_intf_pins mac_eth0/TX_AXIS]
  connect_bd_intf_net -intf_net pr_decoupler_0_s_eth1 [get_bd_intf_pins decoupler/s_eth1] [get_bd_intf_pins mac_eth1/TX_AXIS]
  connect_bd_intf_net -intf_net pr_decoupler_0_s_eth2 [get_bd_intf_pins decoupler/s_eth2] [get_bd_intf_pins mac_eth2/TX_AXIS]
  connect_bd_intf_net -intf_net pr_decoupler_0_s_eth3 [get_bd_intf_pins decoupler/s_eth3] [get_bd_intf_pins mac_eth3/TX_AXIS]

  # Create port connections
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins gtx_clk] [get_bd_pins mac_eth0/gtx_clk] [get_bd_pins mac_eth1/gtx_clk] [get_bd_pins mac_eth2/gtx_clk] [get_bd_pins mac_eth3/gtx_clk]
  connect_bd_net -net dcm_eth_clk_125M_90 [get_bd_pins gtx_clk90] [get_bd_pins mac_eth0/gtx_clk90] [get_bd_pins mac_eth1/gtx_clk90] [get_bd_pins mac_eth2/gtx_clk90] [get_bd_pins mac_eth3/gtx_clk90]
  connect_bd_net -net decouple_1 [get_bd_pins decouple] [get_bd_pins decoupler/decouple]
  connect_bd_net -net mac_eth0_rx_clk [get_bd_pins clk_rx0] [get_bd_pins mac_eth0/rx_clk]
  connect_bd_net -net mac_eth1_rx_clk [get_bd_pins clk_rx1] [get_bd_pins mac_eth1/rx_clk]
  connect_bd_net -net mac_eth2_rx_clk [get_bd_pins clk_rx2] [get_bd_pins mac_eth2/rx_clk]
  connect_bd_net -net mac_eth3_rx_clk [get_bd_pins clk_rx3] [get_bd_pins mac_eth3/rx_clk]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_pins gtx_rst_n] [get_bd_pins mac_eth0/gtx_rst_n] [get_bd_pins mac_eth1/gtx_rst_n] [get_bd_pins mac_eth2/gtx_rst_n] [get_bd_pins mac_eth3/gtx_rst_n]

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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M04_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -type clk clk_125M
  create_bd_pin -dir I -type clk clk_50M
  create_bd_pin -dir I decouple
  create_bd_pin -dir I -type rst rst_125M_n
  create_bd_pin -dir I -type rst rst_50M_n
  create_bd_pin -dir I -type rst rst_n

  # Create instance: axi_interconnect, and set properties
  set axi_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {0} \
   CONFIG.M00_HAS_REGSLICE {0} \
   CONFIG.M01_HAS_REGSLICE {0} \
   CONFIG.NUM_MI {5} \
 ] $axi_interconnect

  # Create instance: decoupler, and set properties
  set decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 decoupler ]
  set_property -dict [ list \
   CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {m_axi_pcie {ID 0 VLNV xilinx.com:interface:aximm_rtl:1.0 MODE slave SIGNALS {ARVALID {PRESENT 1 WIDTH 1} ARREADY {PRESENT 1 WIDTH 1} AWVALID {PRESENT 1 WIDTH 1} AWREADY {PRESENT 1 WIDTH 1} BVALID {PRESENT 1 WIDTH 1} BREADY {PRESENT 1 WIDTH 1} RVALID {PRESENT 1 WIDTH 1} RREADY {PRESENT 1 WIDTH 1} WVALID {PRESENT 1 WIDTH 1} WREADY {PRESENT 1 WIDTH 1} AWID {PRESENT 0 WIDTH 0} AWADDR {PRESENT 1 WIDTH 32} AWLEN {PRESENT 1 WIDTH 8} AWSIZE {PRESENT 1 WIDTH 3} AWBURST {PRESENT 1 WIDTH 2} AWLOCK {PRESENT 1 WIDTH 1} AWCACHE {PRESENT 1 WIDTH 4} AWPROT {PRESENT 1 WIDTH 3} AWREGION {PRESENT 1 WIDTH 4} AWQOS {PRESENT 1 WIDTH 4} AWUSER {PRESENT 0 WIDTH 0} WID {PRESENT 0 WIDTH 0} WDATA {PRESENT 1 WIDTH 128} WSTRB {PRESENT 1 WIDTH 16} WLAST {PRESENT 1 WIDTH 1} WUSER {PRESENT 0 WIDTH 0} BID {PRESENT 0 WIDTH 0} BRESP {PRESENT 1 WIDTH 2} BUSER {PRESENT 0 WIDTH 0} ARID {PRESENT 0 WIDTH 0} ARADDR {PRESENT 1 WIDTH 32} ARLEN {PRESENT 1 WIDTH 8} ARSIZE {PRESENT 1 WIDTH 3} ARBURST {PRESENT 1 WIDTH 2} ARLOCK {PRESENT 1 WIDTH 1} ARCACHE {PRESENT 1 WIDTH 4} ARPROT {PRESENT 1 WIDTH 3} ARREGION {PRESENT 1 WIDTH 4} ARQOS {PRESENT 1 WIDTH 4} ARUSER {PRESENT 0 WIDTH 0} RID {PRESENT 0 WIDTH 0} RDATA {PRESENT 1 WIDTH 128} RRESP {PRESENT 1 WIDTH 2} RLAST {PRESENT 1 WIDTH 1} RUSER {PRESENT 0 WIDTH 0}}}} IPI_PROP_COUNT 4} \
   CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
   CONFIG.GUI_INTERFACE_NAME {m_axi_pcie} \
   CONFIG.GUI_INTERFACE_PROTOCOL {axi4} \
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

  # Create instance: width_converter, and set properties
  set width_converter [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dwidth_converter:2.1 width_converter ]
  set_property -dict [ list \
   CONFIG.MI_DATA_WIDTH {64} \
   CONFIG.SI_DATA_WIDTH {128} \
 ] $width_converter

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M04_AXI] [get_bd_intf_pins axi_interconnect/M04_AXI]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_M00_AXI [get_bd_intf_pins axi_interconnect/M00_AXI] [get_bd_intf_pins decoupler/s_m_axi_pcie]
  connect_bd_intf_net -intf_net axi_interconnect_M01_AXI [get_bd_intf_pins M01_AXI] [get_bd_intf_pins axi_interconnect/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_M02_AXI [get_bd_intf_pins M02_AXI] [get_bd_intf_pins axi_interconnect/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_M03_AXI [get_bd_intf_pins M03_AXI] [get_bd_intf_pins axi_interconnect/M03_AXI]
  connect_bd_intf_net -intf_net decoupler_rp_m_axi_pcie [get_bd_intf_pins decoupler/rp_m_axi_pcie] [get_bd_intf_pins width_converter/S_AXI]
  connect_bd_intf_net -intf_net width_converter_M_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins width_converter/M_AXI]

  # Create port connections
  connect_bd_net -net axi_pcie_0_axi_aclk_out [get_bd_pins clk] [get_bd_pins axi_interconnect/ACLK] [get_bd_pins axi_interconnect/S00_ACLK]
  connect_bd_net -net clk_125M_1 [get_bd_pins clk_125M] [get_bd_pins axi_interconnect/M00_ACLK] [get_bd_pins axi_interconnect/M01_ACLK] [get_bd_pins axi_interconnect/M03_ACLK] [get_bd_pins axi_interconnect/M04_ACLK] [get_bd_pins width_converter/s_axi_aclk]
  connect_bd_net -net clk_50M_1 [get_bd_pins clk_50M] [get_bd_pins axi_interconnect/M02_ACLK]
  connect_bd_net -net decouple_1 [get_bd_pins decouple] [get_bd_pins decoupler/decouple]
  connect_bd_net -net pcie_axi_pcie_rst_n [get_bd_pins rst_n] [get_bd_pins axi_interconnect/ARESETN] [get_bd_pins axi_interconnect/S00_ARESETN]
  connect_bd_net -net rst_125M_n_1 [get_bd_pins rst_125M_n] [get_bd_pins axi_interconnect/M00_ARESETN] [get_bd_pins axi_interconnect/M01_ARESETN] [get_bd_pins axi_interconnect/M03_ARESETN] [get_bd_pins axi_interconnect/M04_ARESETN] [get_bd_pins width_converter/s_axi_aresetn]
  connect_bd_net -net rst_50M_n_1 [get_bd_pins rst_50M_n] [get_bd_pins axi_interconnect/M02_ARESETN]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: id_bram
proc create_hier_cell_id_bram { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_id_bram() - Empty argument(s)!"}
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
   CONFIG.Coe_File {../../../../../../../../id_bram_contents.coe} \
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

# Hierarchical cell: ddr3
proc create_hier_cell_ddr3 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_ddr3() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_PCIE
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_PRC

  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir O ready
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: controller, and set properties
  set controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 controller ]

  # Generate the PRJ File for MIG
  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $controller ] ] ]
  set str_mig_file_name mig_a.prj
  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}

  write_mig_file_bd_static_controller_0 $str_mig_file_path

  set_property -dict [ list \
   CONFIG.BOARD_MIG_PARAM {Custom} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.XML_INPUT_FILE {mig_a.prj} \
 ] $controller

  # Create instance: interconnect, and set properties
  set interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
   CONFIG.S00_HAS_DATA_FIFO {2} \
   CONFIG.S01_HAS_DATA_FIFO {2} \
   CONFIG.S01_HAS_REGSLICE {4} \
   CONFIG.S02_HAS_DATA_FIFO {2} \
   CONFIG.S02_HAS_REGSLICE {4} \
   CONFIG.STRATEGY {2} \
 ] $interconnect

  # Create instance: reset, and set properties
  set reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S_AXI_PCIE] [get_bd_intf_pins interconnect/S01_AXI]
  connect_bd_intf_net -intf_net S_AXI_ST_1 [get_bd_intf_pins S_AXI_PRC] [get_bd_intf_pins interconnect/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins controller/S_AXI] [get_bd_intf_pins interconnect/M00_AXI]
  connect_bd_intf_net -intf_net ddr3_controller_DDR3 [get_bd_intf_pins DDR3] [get_bd_intf_pins controller/DDR3]

  # Create port connections
  connect_bd_net -net M00_ARESETN_1 [get_bd_pins interconnect/M00_ARESETN] [get_bd_pins reset/peripheral_aresetn]
  connect_bd_net -net clocks_clk_200M [get_bd_pins clk] [get_bd_pins controller/clk_ref_i] [get_bd_pins controller/sys_clk_i]
  connect_bd_net -net clocks_rst_200M_n [get_bd_pins rst_n] [get_bd_pins controller/aresetn] [get_bd_pins controller/sys_rst]
  connect_bd_net -net controller_init_calib_complete [get_bd_pins ready] [get_bd_pins controller/init_calib_complete]
  connect_bd_net -net controller_mmcm_locked [get_bd_pins controller/mmcm_locked] [get_bd_pins reset/dcm_locked]
  connect_bd_net -net controller_ui_clk_sync_rst [get_bd_pins controller/ui_clk_sync_rst] [get_bd_pins reset/ext_reset_in]
  connect_bd_net -net ddr3_controller_ui_clk [get_bd_pins controller/ui_clk] [get_bd_pins interconnect/M00_ACLK] [get_bd_pins reset/slowest_sync_clk]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins interconnect/ACLK] [get_bd_pins interconnect/S00_ACLK] [get_bd_pins interconnect/S01_ACLK]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins interconnect/ARESETN] [get_bd_pins interconnect/S00_ARESETN] [get_bd_pins interconnect/S01_ARESETN] [get_bd_pins reset/aux_reset_in]

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
  create_bd_pin -dir O -from 0 -to 0 clk_200M
  create_bd_pin -dir O clk_50M
  create_bd_pin -dir O -from 0 -to 0 rst_100M_n
  create_bd_pin -dir O -from 0 -to 0 rst_125M_n
  create_bd_pin -dir O -from 0 -to 0 rst_200M
  create_bd_pin -dir O -from 0 -to 0 rst_200M_n
  create_bd_pin -dir O -from 0 -to 0 rst_50M_n
  create_bd_pin -dir I rst_n

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
  connect_bd_net -net reset_200M_peripheral_aresetn [get_bd_pins rst_200M_n] [get_bd_pins reset_200M/peripheral_aresetn]
  connect_bd_net -net reset_200M_peripheral_reset [get_bd_pins rst_200M] [get_bd_pins reset_200M/peripheral_reset]
  connect_bd_net -net reset_50M_peripheral_aresetn [get_bd_pins rst_50M_n] [get_bd_pins reset_50M/peripheral_aresetn]
  connect_bd_net -net rst_n_1 [get_bd_pins rst_n] [get_bd_pins reset_100M/ext_reset_in] [get_bd_pins reset_125M/ext_reset_in] [get_bd_pins reset_200M/ext_reset_in] [get_bd_pins reset_50M/ext_reset_in]
  connect_bd_net -net util_ds_buf_0_BUFG_O [get_bd_pins clk_200M] [get_bd_pins dcm/clk_in1] [get_bd_pins input_bufg/BUFG_O] [get_bd_pins reset_200M/slowest_sync_clk]

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
  set led_0 [ create_bd_port -dir O led_0 ]
  set led_1 [ create_bd_port -dir O led_1 ]
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

  # Create instance: bpi_controller, and set properties
  set bpi_controller [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:bpi_flash:1.0 bpi_controller ]

  # Create instance: clocks
  create_hier_cell_clocks [current_bd_instance .] clocks

  # Create instance: ddr3
  create_hier_cell_ddr3 [current_bd_instance .] ddr3

  # Create instance: id_bram
  create_hier_cell_id_bram [current_bd_instance .] id_bram

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
  set_property -dict [ list \
   CONFIG.C_ENABLE_DDR3 {false} \
 ] $rp_wrapper

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins interconnect/S_AXI] [get_bd_intf_pins pcie/M_AXI]
  connect_bd_intf_net -intf_net S_AXIS_ETH0_1 [get_bd_intf_pins macs/S_AXIS_ETH0] [get_bd_intf_pins rp_wrapper/M_AXIS_ETH0]
  connect_bd_intf_net -intf_net S_AXIS_ETH2_1 [get_bd_intf_pins macs/S_AXIS_ETH2] [get_bd_intf_pins rp_wrapper/M_AXIS_ETH2]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins pcie/S_AXI] [get_bd_intf_pins rp_wrapper/M_AXI_PCIE]
  connect_bd_intf_net -intf_net axi_interconnect_M00_AXI [get_bd_intf_pins bpi_controller/S_AXI] [get_bd_intf_pins interconnect/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_M01_AXI [get_bd_intf_pins interconnect/M03_AXI] [get_bd_intf_pins pr_ctrl/s_axi_reg]
  connect_bd_intf_net -intf_net axi_interconnect_M03_AXI [get_bd_intf_pins id_bram/S_AXI] [get_bd_intf_pins interconnect/M01_AXI]
  connect_bd_intf_net -intf_net axi_pcie_0_pcie_7x_mgt [get_bd_intf_ports pcie] [get_bd_intf_pins pcie/PCIE]
  connect_bd_intf_net -intf_net bpi_controller_BPI [get_bd_intf_ports bpi] [get_bd_intf_pins bpi_controller/BPI]
  connect_bd_intf_net -intf_net ddr3_controller_DDR3 [get_bd_intf_ports ddr3] [get_bd_intf_pins ddr3/DDR3]
  connect_bd_intf_net -intf_net interconnect_M00_AXI [get_bd_intf_pins interconnect/M00_AXI] [get_bd_intf_pins rp_wrapper/S_AXI_PCIE]
  connect_bd_intf_net -intf_net interconnect_M04_AXI [get_bd_intf_pins ddr3/S_AXI_PCIE] [get_bd_intf_pins interconnect/M04_AXI]
  connect_bd_intf_net -intf_net mac_eth0_RGMII [get_bd_intf_ports phy0_rgmii] [get_bd_intf_pins macs/phy0_rgmii]
  connect_bd_intf_net -intf_net mac_eth1_RGMII [get_bd_intf_ports phy1_rgmii] [get_bd_intf_pins macs/phy1_rgmii]
  connect_bd_intf_net -intf_net mac_eth2_RGMII [get_bd_intf_ports phy2_rgmii] [get_bd_intf_pins macs/phy2_rgmii]
  connect_bd_intf_net -intf_net mac_eth3_RGMII [get_bd_intf_ports phy3_rgmii] [get_bd_intf_pins macs/phy3_rgmii]
  connect_bd_intf_net -intf_net macs_M_AXIS_ETH0 [get_bd_intf_pins macs/M_AXIS_ETH0] [get_bd_intf_pins rp_wrapper/S_AXIS_ETH0]
  connect_bd_intf_net -intf_net macs_M_AXIS_ETH1 [get_bd_intf_pins macs/M_AXIS_ETH1] [get_bd_intf_pins rp_wrapper/S_AXIS_ETH1]
  connect_bd_intf_net -intf_net macs_M_AXIS_ETH2 [get_bd_intf_pins macs/M_AXIS_ETH2] [get_bd_intf_pins rp_wrapper/S_AXIS_ETH2]
  connect_bd_intf_net -intf_net macs_M_AXIS_ETH3 [get_bd_intf_pins macs/M_AXIS_ETH3] [get_bd_intf_pins rp_wrapper/S_AXIS_ETH3]
  connect_bd_intf_net -intf_net pr_controller_m_axi_mem [get_bd_intf_pins ddr3/S_AXI_PRC] [get_bd_intf_pins pr_ctrl/m_axi_mem]
  connect_bd_intf_net -intf_net rp_wrapper_M_AXIS_ETH1 [get_bd_intf_pins macs/S_AXIS_ETH1] [get_bd_intf_pins rp_wrapper/M_AXIS_ETH1]
  connect_bd_intf_net -intf_net rp_wrapper_M_AXIS_ETH3 [get_bd_intf_pins macs/S_AXIS_ETH3] [get_bd_intf_pins rp_wrapper/M_AXIS_ETH3]
  connect_bd_intf_net -intf_net system_1 [get_bd_intf_ports system] [get_bd_intf_pins clocks/system]

  # Create port connections
  connect_bd_net -net IBUF_DS_N_0_1 [get_bd_ports pcie_clk_n] [get_bd_pins pcie/pcie_clk_n]
  connect_bd_net -net IBUF_DS_P_0_1 [get_bd_ports pcie_clk_p] [get_bd_pins pcie/pcie_clk_p]
  connect_bd_net -net Net [get_bd_ports bpi_dq] [get_bd_pins bpi_controller/bpi_dq_io]
  connect_bd_net -net aux_reset_in_0_1 [get_bd_ports pcie_perstn] [get_bd_pins pcie/pcie_perstn]
  connect_bd_net -net axi_pcie_0_axi_aclk_out [get_bd_pins interconnect/clk] [get_bd_pins pcie/m_axi_aclk]
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins clocks/clk_125M] [get_bd_pins ddr3/s_axi_aclk] [get_bd_pins id_bram/s_axi_aclk] [get_bd_pins interconnect/clk_125M] [get_bd_pins macs/gtx_clk] [get_bd_pins pcie/s_axi_aclk] [get_bd_pins pr_ctrl/clk] [get_bd_pins rp_wrapper/clk]
  connect_bd_net -net clocks_clk_200M [get_bd_pins clocks/clk_200M] [get_bd_pins ddr3/clk] [get_bd_pins idelay_ctrl/ref_clk]
  connect_bd_net -net clocks_clk_50M [get_bd_pins bpi_controller/clk] [get_bd_pins clocks/clk_50M] [get_bd_pins interconnect/clk_50M]
  connect_bd_net -net clocks_rst_100M_n [get_bd_pins clocks/rst_100M_n] [get_bd_pins pr_ctrl/icap_reset]
  connect_bd_net -net clocks_rst_200M [get_bd_pins clocks/rst_200M] [get_bd_pins idelay_ctrl/rst]
  connect_bd_net -net clocks_rst_200M_n [get_bd_pins clocks/rst_200M_n] [get_bd_pins ddr3/rst_n]
  connect_bd_net -net clocks_rst_50M_n [get_bd_pins bpi_controller/rst_n] [get_bd_pins clocks/rst_50M_n] [get_bd_pins interconnect/rst_50M_n]
  connect_bd_net -net dcm_eth_clk_100M [get_bd_pins clocks/clk_100M] [get_bd_pins pr_ctrl/icap_clk]
  connect_bd_net -net dcm_eth_clk_125M_90 [get_bd_pins clocks/clk_125M_90] [get_bd_pins macs/gtx_clk90]
  connect_bd_net -net ddr3_ready [get_bd_ports led_0] [get_bd_pins ddr3/ready]
  connect_bd_net -net idelay_ctrl_rdy [get_bd_ports led_1] [get_bd_pins idelay_ctrl/rdy]
  connect_bd_net -net macs_clk_rx0 [get_bd_pins macs/clk_rx0] [get_bd_pins rp_wrapper/clk_rx0]
  connect_bd_net -net macs_clk_rx1 [get_bd_pins macs/clk_rx1] [get_bd_pins rp_wrapper/clk_rx1]
  connect_bd_net -net macs_clk_rx2 [get_bd_pins macs/clk_rx2] [get_bd_pins rp_wrapper/clk_rx2]
  connect_bd_net -net macs_clk_rx3 [get_bd_pins macs/clk_rx3] [get_bd_pins rp_wrapper/clk_rx3]
  connect_bd_net -net pcie_axi_pcie_rst_n [get_bd_ports led_2] [get_bd_pins interconnect/rst_n] [get_bd_pins pcie/m_axi_aresetn]
  connect_bd_net -net pr_controller_vsm_vs_rm_decouple [get_bd_pins interconnect/decouple] [get_bd_pins macs/decouple] [get_bd_pins pcie/decouple] [get_bd_pins pr_ctrl/decouple]
  connect_bd_net -net pr_ctrl_rp_active_st [get_bd_ports led_3] [get_bd_pins pr_ctrl/rp_active_st]
  connect_bd_net -net pr_ctrl_rp_shutdown_req [get_bd_pins pr_ctrl/rp_shutdown_req] [get_bd_pins rp_wrapper/shutdown_req]
  connect_bd_net -net pr_ctrl_rst_rp_n [get_bd_pins pr_ctrl/rst_rp_n] [get_bd_pins rp_wrapper/rst_prc_n]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_ports phy0_rstn] [get_bd_ports phy1_rstn] [get_bd_ports phy2_rstn] [get_bd_ports phy3_rstn] [get_bd_pins clocks/rst_125M_n] [get_bd_pins ddr3/s_axi_aresetn] [get_bd_pins id_bram/s_axi_aresetn] [get_bd_pins interconnect/rst_125M_n] [get_bd_pins macs/gtx_rst_n] [get_bd_pins pcie/s_axi_aresetn] [get_bd_pins pr_ctrl/rst_n] [get_bd_pins rp_wrapper/rst_pcie_n]
  connect_bd_net -net rp_active_1 [get_bd_pins pr_ctrl/rp_active] [get_bd_pins rp_wrapper/active]
  connect_bd_net -net rp_shutdown_ack_1 [get_bd_pins pr_ctrl/rp_shutdown_ack] [get_bd_pins rp_wrapper/shutdown_ack]
  connect_bd_net -net rp_wrapper_irq [get_bd_pins pcie/irq] [get_bd_pins rp_wrapper/irq]
  connect_bd_net -net rst_n_1 [get_bd_ports rst_n] [get_bd_pins clocks/rst_n] [get_bd_pins pcie/rst_n]

  # Create address segments
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces rp_wrapper/M_AXI_PCIE] [get_bd_addr_segs pcie/axi_bridge/S_AXI/BAR0] SEG_axi_bridge_BAR0
  create_bd_addr_seg -range 0x08000000 -offset 0x80000000 [get_bd_addr_spaces pcie/axi_bridge/M_AXI] [get_bd_addr_segs bpi_controller/S_AXI/S_AXI_ADDR] SEG_bpi_controller_S_AXI_ADDR
  create_bd_addr_seg -range 0x00002000 -offset 0x00000000 [get_bd_addr_spaces pcie/axi_bridge/M_AXI] [get_bd_addr_segs id_bram/controller/S_AXI/Mem0] SEG_controller_Mem0
  create_bd_addr_seg -range 0x00800000 -offset 0x00800000 [get_bd_addr_spaces pcie/axi_bridge/M_AXI] [get_bd_addr_segs ddr3/controller/memmap/memaddr] SEG_controller_memaddr
  create_bd_addr_seg -range 0x00002000 -offset 0x00002000 [get_bd_addr_spaces pcie/axi_bridge/M_AXI] [get_bd_addr_segs pr_ctrl/pr_controller/s_axi_reg/Reg] SEG_pr_controller_Reg
  create_bd_addr_seg -range 0x40000000 -offset 0x40000000 [get_bd_addr_spaces pcie/axi_bridge/M_AXI] [get_bd_addr_segs rp_wrapper/S_AXI_PCIE/reg0] SEG_rp_wrapper_reg0


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


