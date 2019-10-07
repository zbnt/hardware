
################################################################
# This is a generated script based on design: bd_quad_tgen
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
# source bd_quad_tgen_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7k325tffg676-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name bd_quad_tgen

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
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:axi_hwicap:3.0\
xilinx.com:ip:util_idelay_ctrl:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
oscar-rc.dev:zbnt_hw:simple_timer:1.1\
alexforencich.com:verilog-ethernet:eth_mac_1g:1.0\
oscar-rc.dev:zbnt_hw:eth_stats_collector:1.1\
oscar-rc.dev:zbnt_hw:eth_traffic_gen:1.1\
xilinx.com:ip:axi_pcie:2.9\
xilinx.com:ip:util_ds_buf:2.1\
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
# DESIGN PROCs
##################################################################


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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x

  # Create pins
  create_bd_pin -dir O -type clk axi_aclk_out
  create_bd_pin -dir I -from 0 -to 0 -type clk pcie_clk_n
  create_bd_pin -dir I -from 0 -to 0 -type clk pcie_clk_p
  create_bd_pin -dir I -type rst pcie_perstn
  create_bd_pin -dir I -type rst rst_n

  # Create instance: axi_pcie, and set properties
  set axi_pcie [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_pcie:2.9 axi_pcie ]
  set_property -dict [ list \
   CONFIG.BAR0_SCALE {Megabytes} \
   CONFIG.BAR0_SIZE {4} \
   CONFIG.BAR1_ENABLED {false} \
   CONFIG.BAR1_SCALE {N/A} \
   CONFIG.BAR1_SIZE {8} \
   CONFIG.BAR1_TYPE {N/A} \
   CONFIG.BAR_64BIT {true} \
   CONFIG.BASE_CLASS_MENU {Device_was_built_before_Class_Code_definitions_were_finalized} \
   CONFIG.CLASS_CODE {0x118000} \
   CONFIG.DEVICE_ID {0x7024} \
   CONFIG.ENABLE_CLASS_CODE {true} \
   CONFIG.MAX_LINK_SPEED {5.0_GT/s} \
   CONFIG.M_AXI_DATA_WIDTH {128} \
   CONFIG.NO_OF_LANES {X4} \
   CONFIG.PCIEBAR2AXIBAR_1 {0xFFFFFFFF} \
   CONFIG.SUBSYSTEM_ID {0x6E74} \
   CONFIG.SUB_CLASS_INTERFACE_MENU {All_currently_implemented_devices_except_VGA-compatible_devices} \
   CONFIG.S_AXI_DATA_WIDTH {128} \
   CONFIG.enable_jtag_dbg {false} \
   CONFIG.shared_logic_in_core {false} \
 ] $axi_pcie

  # Create instance: pcie_refclk_ibufds, and set properties
  set pcie_refclk_ibufds [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 pcie_refclk_ibufds ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $pcie_refclk_ibufds

  # Create instance: reset_pcie_clk, and set properties
  set reset_pcie_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset_pcie_clk ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_pcie_0_pcie_7x_mgt [get_bd_intf_pins pcie_7x] [get_bd_intf_pins axi_pcie/pcie_7x_mgt]
  connect_bd_intf_net -intf_net axi_pcie_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins axi_pcie/M_AXI]

  # Create port connections
  connect_bd_net -net IBUF_DS_N_0_1 [get_bd_pins pcie_clk_n] [get_bd_pins pcie_refclk_ibufds/IBUF_DS_N]
  connect_bd_net -net IBUF_DS_P_0_1 [get_bd_pins pcie_clk_p] [get_bd_pins pcie_refclk_ibufds/IBUF_DS_P]
  connect_bd_net -net aux_reset_in_0_1 [get_bd_pins pcie_perstn] [get_bd_pins reset_pcie_clk/aux_reset_in]
  connect_bd_net -net axi_pcie_0_axi_aclk_out [get_bd_pins axi_aclk_out] [get_bd_pins axi_pcie/axi_aclk_out] [get_bd_pins reset_pcie_clk/slowest_sync_clk]
  connect_bd_net -net axi_pcie_mmcm_lock [get_bd_pins axi_pcie/mmcm_lock] [get_bd_pins reset_pcie_clk/dcm_locked]
  connect_bd_net -net reset_pcie_interconnect_aresetn [get_bd_pins axi_pcie/axi_aresetn] [get_bd_pins reset_pcie_clk/interconnect_aresetn]
  connect_bd_net -net rst_n_1 [get_bd_pins rst_n] [get_bd_pins reset_pcie_clk/ext_reset_in]
  connect_bd_net -net util_ds_buf_0_IBUF_OUT [get_bd_pins axi_pcie/REFCLK] [get_bd_pins pcie_refclk_ibufds/IBUF_OUT]

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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_stats
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_tgen

  # Create pins
  create_bd_pin -dir I -type clk clk_125M
  create_bd_pin -dir I -type clk clk_125M_90
  create_bd_pin -dir I -from 63 -to 0 current_time
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir I time_running

  # Create instance: mac, and set properties
  set mac [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac ]
  set_property -dict [ list \
   CONFIG.iface_type {RGMII} \
   CONFIG.use_clk90 {true} \
 ] $mac

  # Create instance: stats, and set properties
  set stats [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_stats_collector:1.1 stats ]
  set_property -dict [ list \
   CONFIG.C_AXI_WIDTH {64} \
 ] $stats

  # Create instance: tgen, and set properties
  set tgen [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_traffic_gen:1.1 tgen ]
  set_property -dict [ list \
   CONFIG.axi_width {64} \
 ] $tgen

  # Create interface connections
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins s_axi_tgen] [get_bd_intf_pins tgen/S_AXI]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins s_axi_stats] [get_bd_intf_pins stats/S_AXI]
  connect_bd_intf_net -intf_net mac_RGMII [get_bd_intf_pins rgmii] [get_bd_intf_pins mac/RGMII]
  connect_bd_intf_net -intf_net mac_RX_AXIS [get_bd_intf_pins mac/RX_AXIS] [get_bd_intf_pins stats/AXIS_RX]
  connect_bd_intf_net -intf_net tgen_M_AXIS [get_bd_intf_pins mac/TX_AXIS] [get_bd_intf_pins tgen/M_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets tgen_M_AXIS] [get_bd_intf_pins stats/AXIS_TX] [get_bd_intf_pins tgen/M_AXIS]

  # Create port connections
  connect_bd_net -net clk_125M_90_1 [get_bd_pins clk_125M_90] [get_bd_pins mac/gtx_clk90]
  connect_bd_net -net current_time_0_1 [get_bd_pins current_time] [get_bd_pins stats/current_time]
  connect_bd_net -net gtx_clk_0_1 [get_bd_pins clk_125M] [get_bd_pins mac/gtx_clk] [get_bd_pins stats/clk] [get_bd_pins stats/clk_tx] [get_bd_pins tgen/clk]
  connect_bd_net -net mac_rx_clk [get_bd_pins mac/rx_clk] [get_bd_pins stats/clk_rx]
  connect_bd_net -net rst_n_0_1 [get_bd_pins rst_n] [get_bd_pins mac/gtx_rst_n] [get_bd_pins stats/rst_n] [get_bd_pins tgen/rst_n]
  connect_bd_net -net time_running_0_1 [get_bd_pins time_running] [get_bd_pins stats/time_running] [get_bd_pins tgen/ext_enable]

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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_stats
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_tgen

  # Create pins
  create_bd_pin -dir I -type clk clk_125M
  create_bd_pin -dir I -type clk clk_125M_90
  create_bd_pin -dir I -from 63 -to 0 current_time
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir I time_running

  # Create instance: mac, and set properties
  set mac [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac ]
  set_property -dict [ list \
   CONFIG.iface_type {RGMII} \
   CONFIG.use_clk90 {true} \
 ] $mac

  # Create instance: stats, and set properties
  set stats [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_stats_collector:1.1 stats ]
  set_property -dict [ list \
   CONFIG.C_AXI_WIDTH {64} \
 ] $stats

  # Create instance: tgen, and set properties
  set tgen [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_traffic_gen:1.1 tgen ]
  set_property -dict [ list \
   CONFIG.axi_width {64} \
 ] $tgen

  # Create interface connections
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins s_axi_tgen] [get_bd_intf_pins tgen/S_AXI]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins s_axi_stats] [get_bd_intf_pins stats/S_AXI]
  connect_bd_intf_net -intf_net mac_RGMII [get_bd_intf_pins rgmii] [get_bd_intf_pins mac/RGMII]
  connect_bd_intf_net -intf_net mac_RX_AXIS [get_bd_intf_pins mac/RX_AXIS] [get_bd_intf_pins stats/AXIS_RX]
  connect_bd_intf_net -intf_net tgen_M_AXIS [get_bd_intf_pins mac/TX_AXIS] [get_bd_intf_pins tgen/M_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets tgen_M_AXIS] [get_bd_intf_pins stats/AXIS_TX] [get_bd_intf_pins tgen/M_AXIS]

  # Create port connections
  connect_bd_net -net clk_125M_90_1 [get_bd_pins clk_125M_90] [get_bd_pins mac/gtx_clk90]
  connect_bd_net -net current_time_0_1 [get_bd_pins current_time] [get_bd_pins stats/current_time]
  connect_bd_net -net gtx_clk_0_1 [get_bd_pins clk_125M] [get_bd_pins mac/gtx_clk] [get_bd_pins stats/clk] [get_bd_pins stats/clk_tx] [get_bd_pins tgen/clk]
  connect_bd_net -net mac_rx_clk [get_bd_pins mac/rx_clk] [get_bd_pins stats/clk_rx]
  connect_bd_net -net rst_n_0_1 [get_bd_pins rst_n] [get_bd_pins mac/gtx_rst_n] [get_bd_pins stats/rst_n] [get_bd_pins tgen/rst_n]
  connect_bd_net -net time_running_0_1 [get_bd_pins time_running] [get_bd_pins stats/time_running] [get_bd_pins tgen/ext_enable]

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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_stats
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_tgen

  # Create pins
  create_bd_pin -dir I -type clk clk_125M
  create_bd_pin -dir I -type clk clk_125M_90
  create_bd_pin -dir I -from 63 -to 0 current_time
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir I time_running

  # Create instance: mac, and set properties
  set mac [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac ]
  set_property -dict [ list \
   CONFIG.iface_type {RGMII} \
   CONFIG.use_clk90 {true} \
 ] $mac

  # Create instance: stats, and set properties
  set stats [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_stats_collector:1.1 stats ]
  set_property -dict [ list \
   CONFIG.C_AXI_WIDTH {64} \
 ] $stats

  # Create instance: tgen, and set properties
  set tgen [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_traffic_gen:1.1 tgen ]
  set_property -dict [ list \
   CONFIG.axi_width {64} \
 ] $tgen

  # Create interface connections
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins s_axi_tgen] [get_bd_intf_pins tgen/S_AXI]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins s_axi_stats] [get_bd_intf_pins stats/S_AXI]
  connect_bd_intf_net -intf_net mac_RGMII [get_bd_intf_pins rgmii] [get_bd_intf_pins mac/RGMII]
  connect_bd_intf_net -intf_net mac_RX_AXIS [get_bd_intf_pins mac/RX_AXIS] [get_bd_intf_pins stats/AXIS_RX]
  connect_bd_intf_net -intf_net tgen_M_AXIS [get_bd_intf_pins mac/TX_AXIS] [get_bd_intf_pins tgen/M_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets tgen_M_AXIS] [get_bd_intf_pins stats/AXIS_TX] [get_bd_intf_pins tgen/M_AXIS]

  # Create port connections
  connect_bd_net -net clk_125M_90_1 [get_bd_pins clk_125M_90] [get_bd_pins mac/gtx_clk90]
  connect_bd_net -net current_time_0_1 [get_bd_pins current_time] [get_bd_pins stats/current_time]
  connect_bd_net -net gtx_clk_0_1 [get_bd_pins clk_125M] [get_bd_pins mac/gtx_clk] [get_bd_pins stats/clk] [get_bd_pins stats/clk_tx] [get_bd_pins tgen/clk]
  connect_bd_net -net mac_rx_clk [get_bd_pins mac/rx_clk] [get_bd_pins stats/clk_rx]
  connect_bd_net -net rst_n_0_1 [get_bd_pins rst_n] [get_bd_pins mac/gtx_rst_n] [get_bd_pins stats/rst_n] [get_bd_pins tgen/rst_n]
  connect_bd_net -net time_running_0_1 [get_bd_pins time_running] [get_bd_pins stats/time_running] [get_bd_pins tgen/ext_enable]

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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_stats
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_tgen

  # Create pins
  create_bd_pin -dir I -type clk clk_125M
  create_bd_pin -dir I -type clk clk_125M_90
  create_bd_pin -dir I -from 63 -to 0 current_time
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir I time_running

  # Create instance: mac, and set properties
  set mac [ create_bd_cell -type ip -vlnv alexforencich.com:verilog-ethernet:eth_mac_1g:1.0 mac ]
  set_property -dict [ list \
   CONFIG.iface_type {RGMII} \
   CONFIG.use_clk90 {true} \
 ] $mac

  # Create instance: stats, and set properties
  set stats [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_stats_collector:1.1 stats ]
  set_property -dict [ list \
   CONFIG.C_AXI_WIDTH {64} \
 ] $stats

  # Create instance: tgen, and set properties
  set tgen [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_traffic_gen:1.1 tgen ]
  set_property -dict [ list \
   CONFIG.axi_width {64} \
 ] $tgen

  # Create interface connections
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins s_axi_tgen] [get_bd_intf_pins tgen/S_AXI]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins s_axi_stats] [get_bd_intf_pins stats/S_AXI]
  connect_bd_intf_net -intf_net mac_RGMII [get_bd_intf_pins rgmii] [get_bd_intf_pins mac/RGMII]
  connect_bd_intf_net -intf_net mac_RX_AXIS [get_bd_intf_pins mac/RX_AXIS] [get_bd_intf_pins stats/AXIS_RX]
  connect_bd_intf_net -intf_net tgen_M_AXIS [get_bd_intf_pins mac/TX_AXIS] [get_bd_intf_pins tgen/M_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets tgen_M_AXIS] [get_bd_intf_pins stats/AXIS_TX] [get_bd_intf_pins tgen/M_AXIS]

  # Create port connections
  connect_bd_net -net clk_125M_90_1 [get_bd_pins clk_125M_90] [get_bd_pins mac/gtx_clk90]
  connect_bd_net -net current_time_0_1 [get_bd_pins current_time] [get_bd_pins stats/current_time]
  connect_bd_net -net gtx_clk_0_1 [get_bd_pins clk_125M] [get_bd_pins mac/gtx_clk] [get_bd_pins stats/clk] [get_bd_pins stats/clk_tx] [get_bd_pins tgen/clk]
  connect_bd_net -net mac_rx_clk [get_bd_pins mac/rx_clk] [get_bd_pins stats/clk_rx]
  connect_bd_net -net rst_n_0_1 [get_bd_pins rst_n] [get_bd_pins mac/gtx_rst_n] [get_bd_pins stats/rst_n] [get_bd_pins tgen/rst_n]
  connect_bd_net -net time_running_0_1 [get_bd_pins time_running] [get_bd_pins stats/time_running] [get_bd_pins tgen/ext_enable]

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
  set led [ create_bd_port -dir O -from 3 -to 0 led ]
  set pcie_clk_n [ create_bd_port -dir I -from 0 -to 0 -type clk pcie_clk_n ]
  set pcie_clk_p [ create_bd_port -dir I -from 0 -to 0 -type clk pcie_clk_p ]
  set pcie_perstn [ create_bd_port -dir I -type rst pcie_perstn ]
  set phy0_rstn [ create_bd_port -dir O -from 0 -to 0 phy0_rstn ]
  set phy1_rstn [ create_bd_port -dir O -from 0 -to 0 phy1_rstn ]
  set phy2_rstn [ create_bd_port -dir O -from 0 -to 0 phy2_rstn ]
  set phy3_rstn [ create_bd_port -dir O -from 0 -to 0 phy3_rstn ]
  set rst_n [ create_bd_port -dir I -type rst rst_n ]

  # Create instance: axi_smartconnect, and set properties
  set axi_smartconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smartconnect ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {    __view__ { clocking { M04_Exit { ASSOCIATED_CLK aclk1 } } }   } \
   CONFIG.NUM_CLKS {3} \
   CONFIG.NUM_MI {10} \
   CONFIG.NUM_SI {1} \
 ] $axi_smartconnect

  # Create instance: constant_leds, and set properties
  set constant_leds [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 constant_leds ]
  set_property -dict [ list \
   CONFIG.CONST_WIDTH {4} \
 ] $constant_leds

  # Create instance: dcm_eth, and set properties
  set dcm_eth [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 dcm_eth ]
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
   CONFIG.CLKOUT4_JITTER {98.146} \
   CONFIG.CLKOUT4_PHASE_ERROR {89.971} \
   CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.CLK_OUT1_PORT {clk_125M} \
   CONFIG.CLK_OUT2_PORT {clk_125M_90} \
   CONFIG.CLK_OUT3_PORT {clk_100M} \
   CONFIG.CLK_OUT4_PORT {clk_200M} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
   CONFIG.MMCM_CLKIN1_PERIOD {5.000} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {8} \
   CONFIG.MMCM_CLKOUT1_PHASE {90.000} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {10} \
   CONFIG.MMCM_CLKOUT3_DIVIDE {5} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {4} \
   CONFIG.PRIM_IN_FREQ {200.000} \
   CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
   CONFIG.USE_RESET {false} \
 ] $dcm_eth

  # Create instance: eth0
  create_hier_cell_eth0 [current_bd_instance .] eth0

  # Create instance: eth1
  create_hier_cell_eth1 [current_bd_instance .] eth1

  # Create instance: eth2
  create_hier_cell_eth2 [current_bd_instance .] eth2

  # Create instance: eth3
  create_hier_cell_eth3 [current_bd_instance .] eth3

  # Create instance: hwicap, and set properties
  set hwicap [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_hwicap:3.0 hwicap ]
  set_property -dict [ list \
   CONFIG.C_ICAP_EXTERNAL {0} \
   CONFIG.C_INCLUDE_STARTUP {1} \
   CONFIG.C_MODE {0} \
   CONFIG.C_NOREAD {0} \
   CONFIG.C_OPERATION {0} \
   CONFIG.C_SHARED_STARTUP {0} \
 ] $hwicap

  # Create instance: idelay_ctrl, and set properties
  set idelay_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_idelay_ctrl:1.0 idelay_ctrl ]

  # Create instance: pcie
  create_hier_cell_pcie [current_bd_instance .] pcie

  # Create instance: reset_cfg_clk, and set properties
  set reset_cfg_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset_cfg_clk ]

  # Create instance: reset_sys_clk, and set properties
  set reset_sys_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset_sys_clk ]

  # Create instance: simple_timer, and set properties
  set simple_timer [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:simple_timer:1.1 simple_timer ]
  set_property -dict [ list \
   CONFIG.axi_width {64} \
 ] $simple_timer

  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN1_D_0_1 [get_bd_intf_ports system] [get_bd_intf_pins dcm_eth/CLK_IN1_D]
  connect_bd_intf_net -intf_net axi_pcie_0_pcie_7x_mgt [get_bd_intf_ports pcie] [get_bd_intf_pins pcie/pcie_7x]
  connect_bd_intf_net -intf_net axi_pcie_M_AXI [get_bd_intf_pins axi_smartconnect/S00_AXI] [get_bd_intf_pins pcie/M_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_M08_AXI [get_bd_intf_pins axi_smartconnect/M08_AXI] [get_bd_intf_pins simple_timer/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_M09_AXI [get_bd_intf_pins axi_smartconnect/M09_AXI] [get_bd_intf_pins hwicap/S_AXI_LITE]
  connect_bd_intf_net -intf_net eth0_rgmii [get_bd_intf_ports phy0_rgmii] [get_bd_intf_pins eth0/rgmii]
  connect_bd_intf_net -intf_net eth1_rgmii [get_bd_intf_ports phy1_rgmii] [get_bd_intf_pins eth1/rgmii]
  connect_bd_intf_net -intf_net eth2_rgmii [get_bd_intf_ports phy2_rgmii] [get_bd_intf_pins eth2/rgmii]
  connect_bd_intf_net -intf_net eth3_rgmii [get_bd_intf_ports phy3_rgmii] [get_bd_intf_pins eth3/rgmii]
  connect_bd_intf_net -intf_net s_axi_stats_1 [get_bd_intf_pins axi_smartconnect/M00_AXI] [get_bd_intf_pins eth0/s_axi_stats]
  connect_bd_intf_net -intf_net s_axi_stats_2 [get_bd_intf_pins axi_smartconnect/M02_AXI] [get_bd_intf_pins eth1/s_axi_stats]
  connect_bd_intf_net -intf_net s_axi_stats_3 [get_bd_intf_pins axi_smartconnect/M04_AXI] [get_bd_intf_pins eth2/s_axi_stats]
  connect_bd_intf_net -intf_net s_axi_stats_4 [get_bd_intf_pins axi_smartconnect/M06_AXI] [get_bd_intf_pins eth3/s_axi_stats]
  connect_bd_intf_net -intf_net s_axi_tgen_1 [get_bd_intf_pins axi_smartconnect/M01_AXI] [get_bd_intf_pins eth0/s_axi_tgen]
  connect_bd_intf_net -intf_net s_axi_tgen_2 [get_bd_intf_pins axi_smartconnect/M03_AXI] [get_bd_intf_pins eth1/s_axi_tgen]
  connect_bd_intf_net -intf_net s_axi_tgen_3 [get_bd_intf_pins axi_smartconnect/M05_AXI] [get_bd_intf_pins eth2/s_axi_tgen]
  connect_bd_intf_net -intf_net s_axi_tgen_4 [get_bd_intf_pins axi_smartconnect/M07_AXI] [get_bd_intf_pins eth3/s_axi_tgen]

  # Create port connections
  connect_bd_net -net IBUF_DS_N_0_1 [get_bd_ports pcie_clk_n] [get_bd_pins pcie/pcie_clk_n]
  connect_bd_net -net IBUF_DS_P_0_1 [get_bd_ports pcie_clk_p] [get_bd_pins pcie/pcie_clk_p]
  connect_bd_net -net aux_reset_in_0_1 [get_bd_ports pcie_perstn] [get_bd_pins pcie/pcie_perstn]
  connect_bd_net -net axi_pcie_0_axi_aclk_out [get_bd_pins axi_smartconnect/aclk] [get_bd_pins pcie/axi_aclk_out]
  connect_bd_net -net clk_125M_90_1 [get_bd_pins dcm_eth/clk_125M_90] [get_bd_pins eth0/clk_125M_90] [get_bd_pins eth1/clk_125M_90] [get_bd_pins eth2/clk_125M_90] [get_bd_pins eth3/clk_125M_90]
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins axi_smartconnect/aclk1] [get_bd_pins dcm_eth/clk_125M] [get_bd_pins eth0/clk_125M] [get_bd_pins eth1/clk_125M] [get_bd_pins eth2/clk_125M] [get_bd_pins eth3/clk_125M] [get_bd_pins reset_sys_clk/slowest_sync_clk] [get_bd_pins simple_timer/clk]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins dcm_eth/locked] [get_bd_pins reset_cfg_clk/dcm_locked] [get_bd_pins reset_sys_clk/dcm_locked]
  connect_bd_net -net constant_leds_dout [get_bd_ports led] [get_bd_pins constant_leds/dout]
  connect_bd_net -net dcm_eth_clk_100M [get_bd_pins axi_smartconnect/aclk2] [get_bd_pins dcm_eth/clk_100M] [get_bd_pins hwicap/icap_clk] [get_bd_pins hwicap/s_axi_aclk] [get_bd_pins reset_cfg_clk/slowest_sync_clk]
  connect_bd_net -net dcm_eth_clk_200M [get_bd_pins dcm_eth/clk_200M] [get_bd_pins idelay_ctrl/ref_clk]
  connect_bd_net -net reset_cfg_clk_peripheral_reset [get_bd_pins idelay_ctrl/rst] [get_bd_pins reset_cfg_clk/peripheral_reset]
  connect_bd_net -net reset_icap_clk_peripheral_aresetn [get_bd_pins hwicap/s_axi_aresetn] [get_bd_pins reset_cfg_clk/peripheral_aresetn]
  connect_bd_net -net reset_sys_clk_interconnect_aresetn [get_bd_ports phy0_rstn] [get_bd_ports phy1_rstn] [get_bd_ports phy2_rstn] [get_bd_ports phy3_rstn] [get_bd_pins axi_smartconnect/aresetn] [get_bd_pins reset_sys_clk/interconnect_aresetn]
  connect_bd_net -net reset_sys_clk_peripheral_aresetn [get_bd_pins eth0/rst_n] [get_bd_pins eth1/rst_n] [get_bd_pins eth2/rst_n] [get_bd_pins eth3/rst_n] [get_bd_pins reset_sys_clk/peripheral_aresetn] [get_bd_pins simple_timer/rst_n]
  connect_bd_net -net rst_n_1 [get_bd_ports rst_n] [get_bd_pins pcie/rst_n] [get_bd_pins reset_cfg_clk/ext_reset_in] [get_bd_pins reset_sys_clk/ext_reset_in]
  connect_bd_net -net simple_timer_current_time [get_bd_pins eth0/current_time] [get_bd_pins eth1/current_time] [get_bd_pins eth2/current_time] [get_bd_pins eth3/current_time] [get_bd_pins simple_timer/current_time]
  connect_bd_net -net simple_timer_time_running [get_bd_pins eth0/time_running] [get_bd_pins eth1/time_running] [get_bd_pins eth2/time_running] [get_bd_pins eth3/time_running] [get_bd_pins simple_timer/time_running]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x00100000 [get_bd_addr_spaces pcie/axi_pcie/M_AXI] [get_bd_addr_segs hwicap/S_AXI_LITE/Reg] SEG_hwicap_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces pcie/axi_pcie/M_AXI] [get_bd_addr_segs simple_timer/S_AXI/S_AXI_ADDR] SEG_simple_timer_0_S_AXI_ADDR
  create_bd_addr_seg -range 0x00010000 -offset 0x00010000 [get_bd_addr_spaces pcie/axi_pcie/M_AXI] [get_bd_addr_segs eth0/stats/S_AXI/S_AXI_ADDR] SEG_stats_S_AXI_ADDR
  create_bd_addr_seg -range 0x00010000 -offset 0x00020000 [get_bd_addr_spaces pcie/axi_pcie/M_AXI] [get_bd_addr_segs eth1/stats/S_AXI/S_AXI_ADDR] SEG_stats_S_AXI_ADDR1
  create_bd_addr_seg -range 0x00010000 -offset 0x00030000 [get_bd_addr_spaces pcie/axi_pcie/M_AXI] [get_bd_addr_segs eth2/stats/S_AXI/S_AXI_ADDR] SEG_stats_S_AXI_ADDR2
  create_bd_addr_seg -range 0x00010000 -offset 0x00040000 [get_bd_addr_spaces pcie/axi_pcie/M_AXI] [get_bd_addr_segs eth3/stats/S_AXI/S_AXI_ADDR] SEG_stats_S_AXI_ADDR3
  create_bd_addr_seg -range 0x00010000 -offset 0x00050000 [get_bd_addr_spaces pcie/axi_pcie/M_AXI] [get_bd_addr_segs eth0/tgen/S_AXI/S_AXI_ADDR] SEG_tgen_S_AXI_ADDR
  create_bd_addr_seg -range 0x00010000 -offset 0x00060000 [get_bd_addr_spaces pcie/axi_pcie/M_AXI] [get_bd_addr_segs eth1/tgen/S_AXI/S_AXI_ADDR] SEG_tgen_S_AXI_ADDR1
  create_bd_addr_seg -range 0x00010000 -offset 0x00070000 [get_bd_addr_spaces pcie/axi_pcie/M_AXI] [get_bd_addr_segs eth2/tgen/S_AXI/S_AXI_ADDR] SEG_tgen_S_AXI_ADDR2
  create_bd_addr_seg -range 0x00010000 -offset 0x00080000 [get_bd_addr_spaces pcie/axi_pcie/M_AXI] [get_bd_addr_segs eth3/tgen/S_AXI/S_AXI_ADDR] SEG_tgen_S_AXI_ADDR3


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


