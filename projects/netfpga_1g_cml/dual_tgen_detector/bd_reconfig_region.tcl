
################################################################
# This is a generated script based on design: bd_reconfig_region
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
# source bd_reconfig_region_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7k325tffg676-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name bd_reconfig_region

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
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:util_reduced_logic:2.0\
xilinx.com:ip:xlconcat:2.1\
oscar-rc.dev:zbnt_hw:simple_timer:1.1\
xilinx.com:ip:axis_register_slice:1.1\
xilinx.com:ip:fifo_generator:13.2\
oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0\
xilinx.com:ip:axis_switch:1.1\
oscar-rc.dev:zbnt_hw:eth_stats_collector:1.1\
oscar-rc.dev:zbnt_hw:eth_traffic_gen:1.1\
xilinx.com:ip:pr_axi_shutdown_manager:1.0\
oscar-rc.dev:zbnt_hw:eth_frame_detector:1.1\
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


# Hierarchical cell: mitm
proc create_hier_cell_mitm { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_mitm() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_A
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_B
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_A
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_B
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 axis_detector_a
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 axis_detector_b
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 axis_stats_a
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 axis_stats_b
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_detector
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_stats_loop
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_stats_main

  # Create pins
  create_bd_pin -dir I -type clk clk_125M
  create_bd_pin -dir I clk_rx_a
  create_bd_pin -dir I clk_rx_b
  create_bd_pin -dir I -from 63 -to 0 current_time
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir O shutdown_ack
  create_bd_pin -dir I shutdown_req
  create_bd_pin -dir I time_running

  # Create instance: detector, and set properties
  set detector [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_frame_detector:1.1 detector ]
  set_property -dict [ list \
   CONFIG.C_AXIS_LOG_WIDTH {128} \
   CONFIG.C_AXI_WIDTH {64} \
   CONFIG.C_LOOP_FIFO_A_SIZE {8192} \
   CONFIG.C_LOOP_FIFO_B_SIZE {1024} \
   CONFIG.C_SHARED_TX_CLK {true} \
 ] $detector

  # Create instance: rx_shutdown_a, and set properties
  set rx_shutdown_a [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 rx_shutdown_a ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TREADY {false} \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_AXIS_TUSER_WIDTH {1} \
   CONFIG.C_CDC_STAGES {4} \
 ] $rx_shutdown_a

  # Create instance: rx_shutdown_b, and set properties
  set rx_shutdown_b [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 rx_shutdown_b ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TREADY {false} \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_AXIS_TUSER_WIDTH {1} \
   CONFIG.C_CDC_STAGES {4} \
 ] $rx_shutdown_b

  # Create instance: shutdown_and, and set properties
  set shutdown_and [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 shutdown_and ]
  set_property -dict [ list \
   CONFIG.C_SIZE {4} \
 ] $shutdown_and

  # Create instance: shutdown_concat, and set properties
  set shutdown_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 shutdown_concat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {4} \
 ] $shutdown_concat

  # Create instance: stats_a, and set properties
  set stats_a [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_stats_collector:1.1 stats_a ]
  set_property -dict [ list \
   CONFIG.C_AXIS_LOG_WIDTH {128} \
   CONFIG.C_AXI_WIDTH {64} \
 ] $stats_a

  # Create instance: stats_b, and set properties
  set stats_b [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_stats_collector:1.1 stats_b ]
  set_property -dict [ list \
   CONFIG.C_AXIS_LOG_WIDTH {128} \
   CONFIG.C_AXI_WIDTH {64} \
 ] $stats_b

  # Create instance: tx_shutdown_a, and set properties
  set tx_shutdown_a [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 tx_shutdown_a ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
 ] $tx_shutdown_a

  # Create instance: tx_shutdown_b, and set properties
  set tx_shutdown_b [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 tx_shutdown_b ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
 ] $tx_shutdown_b

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_A_1 [get_bd_intf_pins detector/S_AXIS_A] [get_bd_intf_pins rx_shutdown_a/M_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets S_AXIS_A_1] [get_bd_intf_pins rx_shutdown_a/M_AXIS] [get_bd_intf_pins stats_a/AXIS_RX]
  connect_bd_intf_net -intf_net S_AXIS_A_2 [get_bd_intf_pins S_AXIS_A] [get_bd_intf_pins rx_shutdown_a/S_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_B_1 [get_bd_intf_pins detector/S_AXIS_B] [get_bd_intf_pins rx_shutdown_b/M_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets S_AXIS_B_1] [get_bd_intf_pins rx_shutdown_b/M_AXIS] [get_bd_intf_pins stats_b/AXIS_RX]
  connect_bd_intf_net -intf_net S_AXIS_B_2 [get_bd_intf_pins S_AXIS_B] [get_bd_intf_pins rx_shutdown_b/S_AXIS]
  connect_bd_intf_net -intf_net detector_M_AXIS_A [get_bd_intf_pins M_AXIS_A] [get_bd_intf_pins tx_shutdown_a/M_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets detector_M_AXIS_A] [get_bd_intf_pins M_AXIS_A] [get_bd_intf_pins stats_a/AXIS_TX]
  connect_bd_intf_net -intf_net detector_M_AXIS_A1 [get_bd_intf_pins detector/M_AXIS_A] [get_bd_intf_pins tx_shutdown_a/S_AXIS]
  connect_bd_intf_net -intf_net detector_M_AXIS_B [get_bd_intf_pins M_AXIS_B] [get_bd_intf_pins tx_shutdown_b/M_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets detector_M_AXIS_B] [get_bd_intf_pins M_AXIS_B] [get_bd_intf_pins stats_b/AXIS_TX]
  connect_bd_intf_net -intf_net detector_M_AXIS_B1 [get_bd_intf_pins detector/M_AXIS_B] [get_bd_intf_pins tx_shutdown_b/S_AXIS]
  connect_bd_intf_net -intf_net detector_M_AXIS_LOG_A [get_bd_intf_pins axis_detector_a] [get_bd_intf_pins detector/M_AXIS_LOG_A]
  connect_bd_intf_net -intf_net detector_M_AXIS_LOG_B [get_bd_intf_pins axis_detector_b] [get_bd_intf_pins detector/M_AXIS_LOG_B]
  connect_bd_intf_net -intf_net s_axi_measurer_1 [get_bd_intf_pins s_axi_detector] [get_bd_intf_pins detector/S_AXI]
  connect_bd_intf_net -intf_net s_axi_stats_loop_1 [get_bd_intf_pins s_axi_stats_loop] [get_bd_intf_pins stats_b/S_AXI]
  connect_bd_intf_net -intf_net s_axi_stats_main_1 [get_bd_intf_pins s_axi_stats_main] [get_bd_intf_pins stats_a/S_AXI]
  connect_bd_intf_net -intf_net stats_M_AXIS_LOG [get_bd_intf_pins axis_stats_a] [get_bd_intf_pins stats_a/M_AXIS_LOG]
  connect_bd_intf_net -intf_net stats_b_M_AXIS_LOG [get_bd_intf_pins axis_stats_b] [get_bd_intf_pins stats_b/M_AXIS_LOG]

  # Create port connections
  connect_bd_net -net clk_rx_b_1 [get_bd_pins clk_rx_b] [get_bd_pins detector/s_axis_b_clk] [get_bd_pins rx_shutdown_b/clk] [get_bd_pins stats_b/clk_rx]
  connect_bd_net -net clk_rx_main_1 [get_bd_pins clk_rx_a] [get_bd_pins detector/s_axis_a_clk] [get_bd_pins rx_shutdown_a/clk] [get_bd_pins stats_a/clk_rx]
  connect_bd_net -net current_time_0_1 [get_bd_pins current_time] [get_bd_pins detector/current_time] [get_bd_pins stats_a/current_time] [get_bd_pins stats_b/current_time]
  connect_bd_net -net gtx_clk_0_1 [get_bd_pins clk_125M] [get_bd_pins detector/m_axis_a_clk] [get_bd_pins detector/m_axis_b_clk] [get_bd_pins detector/s_axi_clk] [get_bd_pins rx_shutdown_a/shutdown_clk] [get_bd_pins rx_shutdown_b/shutdown_clk] [get_bd_pins stats_a/clk] [get_bd_pins stats_a/clk_tx] [get_bd_pins stats_b/clk] [get_bd_pins stats_b/clk_tx] [get_bd_pins tx_shutdown_a/clk] [get_bd_pins tx_shutdown_b/clk]
  connect_bd_net -net rst_n_0_1 [get_bd_pins rst_n] [get_bd_pins detector/s_axi_resetn] [get_bd_pins rx_shutdown_a/rst_n] [get_bd_pins rx_shutdown_b/rst_n] [get_bd_pins stats_a/rst_n] [get_bd_pins stats_b/rst_n] [get_bd_pins tx_shutdown_a/rst_n] [get_bd_pins tx_shutdown_b/rst_n]
  connect_bd_net -net rx_shutdown_a_shutdown_ack [get_bd_pins rx_shutdown_a/shutdown_ack] [get_bd_pins shutdown_concat/In2]
  connect_bd_net -net rx_shutdown_b_shutdown_ack [get_bd_pins rx_shutdown_b/shutdown_ack] [get_bd_pins shutdown_concat/In3]
  connect_bd_net -net shutdown_and_Res [get_bd_pins shutdown_ack] [get_bd_pins shutdown_and/Res]
  connect_bd_net -net shutdown_concat_dout [get_bd_pins shutdown_and/Op1] [get_bd_pins shutdown_concat/dout]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins rx_shutdown_a/shutdown_req] [get_bd_pins rx_shutdown_b/shutdown_req] [get_bd_pins tx_shutdown_a/shutdown_req] [get_bd_pins tx_shutdown_b/shutdown_req]
  connect_bd_net -net time_running_0_1 [get_bd_pins time_running] [get_bd_pins detector/time_running] [get_bd_pins stats_a/time_running] [get_bd_pins stats_b/time_running]
  connect_bd_net -net tx_shutdown_a_shutdown_ack [get_bd_pins shutdown_concat/In0] [get_bd_pins tx_shutdown_a/shutdown_ack]
  connect_bd_net -net tx_shutdown_b_shutdown_ack [get_bd_pins shutdown_concat/In1] [get_bd_pins tx_shutdown_b/shutdown_ack]

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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M05_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M06_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M07_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M08_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_PCIE

  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir O shutdown_ack
  create_bd_pin -dir I shutdown_req

  # Create instance: axi_interconnect, and set properties
  set axi_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {9} \
 ] $axi_interconnect

  # Create instance: shutdown, and set properties
  set shutdown [ create_bd_cell -type ip -vlnv xilinx.com:ip:pr_axi_shutdown_manager:1.0 shutdown ]
  set_property -dict [ list \
   CONFIG.DP_AXI_RESP {2} \
   CONFIG.RP_IS_MASTER {false} \
 ] $shutdown

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_LITE_1 [get_bd_intf_pins M08_AXI] [get_bd_intf_pins axi_interconnect/M08_AXI]
  connect_bd_intf_net -intf_net S_AXI_PCIE_1 [get_bd_intf_pins S_AXI_PCIE] [get_bd_intf_pins shutdown/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_M03_AXI [get_bd_intf_pins M03_AXI] [get_bd_intf_pins axi_interconnect/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_M05_AXI [get_bd_intf_pins M05_AXI] [get_bd_intf_pins axi_interconnect/M05_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_M07_AXI [get_bd_intf_pins M07_AXI] [get_bd_intf_pins axi_interconnect/M07_AXI]
  connect_bd_intf_net -intf_net s_axi_detector_1 [get_bd_intf_pins M04_AXI] [get_bd_intf_pins axi_interconnect/M04_AXI]
  connect_bd_intf_net -intf_net s_axi_stats_1 [get_bd_intf_pins M00_AXI] [get_bd_intf_pins axi_interconnect/M00_AXI]
  connect_bd_intf_net -intf_net s_axi_stats_2 [get_bd_intf_pins M02_AXI] [get_bd_intf_pins axi_interconnect/M02_AXI]
  connect_bd_intf_net -intf_net s_axi_stats_main_1 [get_bd_intf_pins M06_AXI] [get_bd_intf_pins axi_interconnect/M06_AXI]
  connect_bd_intf_net -intf_net s_axi_tgen_1 [get_bd_intf_pins M01_AXI] [get_bd_intf_pins axi_interconnect/M01_AXI]
  connect_bd_intf_net -intf_net shutdown_M_AXI [get_bd_intf_pins axi_interconnect/S00_AXI] [get_bd_intf_pins shutdown/M_AXI]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins rst_n] [get_bd_pins axi_interconnect/ARESETN] [get_bd_pins axi_interconnect/M00_ARESETN] [get_bd_pins axi_interconnect/M01_ARESETN] [get_bd_pins axi_interconnect/M02_ARESETN] [get_bd_pins axi_interconnect/M03_ARESETN] [get_bd_pins axi_interconnect/M04_ARESETN] [get_bd_pins axi_interconnect/M05_ARESETN] [get_bd_pins axi_interconnect/M06_ARESETN] [get_bd_pins axi_interconnect/M07_ARESETN] [get_bd_pins axi_interconnect/M08_ARESETN] [get_bd_pins axi_interconnect/S00_ARESETN] [get_bd_pins shutdown/resetn]
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_pins clk] [get_bd_pins axi_interconnect/ACLK] [get_bd_pins axi_interconnect/M00_ACLK] [get_bd_pins axi_interconnect/M01_ACLK] [get_bd_pins axi_interconnect/M02_ACLK] [get_bd_pins axi_interconnect/M03_ACLK] [get_bd_pins axi_interconnect/M04_ACLK] [get_bd_pins axi_interconnect/M05_ACLK] [get_bd_pins axi_interconnect/M06_ACLK] [get_bd_pins axi_interconnect/M07_ACLK] [get_bd_pins axi_interconnect/M08_ACLK] [get_bd_pins axi_interconnect/S00_ACLK] [get_bd_pins shutdown/clk]
  connect_bd_net -net shutdown_in_shutdown [get_bd_pins shutdown_ack] [get_bd_pins shutdown/in_shutdown]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins shutdown/request_shutdown]

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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 axis_stats
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_stats
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_tgen

  # Create pins
  create_bd_pin -dir I -type clk clk_125M
  create_bd_pin -dir I clk_rx
  create_bd_pin -dir I -from 63 -to 0 current_time
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir O shutdown_ack
  create_bd_pin -dir I shutdown_req
  create_bd_pin -dir I time_running

  # Create instance: rx_shutdown, and set properties
  set rx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 rx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TREADY {false} \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_AXIS_TUSER_WIDTH {1} \
   CONFIG.C_CDC_STAGES {4} \
 ] $rx_shutdown

  # Create instance: shutdown_and, and set properties
  set shutdown_and [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 shutdown_and ]
  set_property -dict [ list \
   CONFIG.C_SIZE {2} \
 ] $shutdown_and

  # Create instance: shutdown_concat, and set properties
  set shutdown_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 shutdown_concat ]

  # Create instance: stats, and set properties
  set stats [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_stats_collector:1.1 stats ]
  set_property -dict [ list \
   CONFIG.C_AXIS_LOG_WIDTH {128} \
   CONFIG.C_AXI_WIDTH {64} \
 ] $stats

  # Create instance: tgen, and set properties
  set tgen [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_traffic_gen:1.1 tgen ]
  set_property -dict [ list \
   CONFIG.axi_width {64} \
 ] $tgen

  # Create instance: tx_shutdown, and set properties
  set tx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 tx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_AXIS_TUSER_WIDTH {1} \
 ] $tx_shutdown

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins rx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins s_axi_tgen] [get_bd_intf_pins tgen/S_AXI]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins s_axi_stats] [get_bd_intf_pins stats/S_AXI]
  connect_bd_intf_net -intf_net rx_shutdown_M_AXIS [get_bd_intf_pins rx_shutdown/M_AXIS] [get_bd_intf_pins stats/AXIS_RX]
  connect_bd_intf_net -intf_net stats_M_AXIS_LOG [get_bd_intf_pins axis_stats] [get_bd_intf_pins stats/M_AXIS_LOG]
  connect_bd_intf_net -intf_net tgen_M_AXIS [get_bd_intf_pins tgen/M_AXIS] [get_bd_intf_pins tx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets tgen_M_AXIS] [get_bd_intf_pins stats/AXIS_TX] [get_bd_intf_pins tgen/M_AXIS]
  connect_bd_intf_net -intf_net tx_shutdown_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins tx_shutdown/M_AXIS]

  # Create port connections
  connect_bd_net -net clk_rx_1 [get_bd_pins clk_rx] [get_bd_pins rx_shutdown/clk] [get_bd_pins stats/clk_rx]
  connect_bd_net -net current_time_0_1 [get_bd_pins current_time] [get_bd_pins stats/current_time]
  connect_bd_net -net gtx_clk_0_1 [get_bd_pins clk_125M] [get_bd_pins rx_shutdown/shutdown_clk] [get_bd_pins stats/clk] [get_bd_pins stats/clk_tx] [get_bd_pins tgen/clk] [get_bd_pins tx_shutdown/clk]
  connect_bd_net -net rst_n_0_1 [get_bd_pins rst_n] [get_bd_pins rx_shutdown/rst_n] [get_bd_pins stats/rst_n] [get_bd_pins tgen/rst_n] [get_bd_pins tx_shutdown/rst_n]
  connect_bd_net -net rx_shutdown_shutdown_ack [get_bd_pins rx_shutdown/shutdown_ack] [get_bd_pins shutdown_concat/In0]
  connect_bd_net -net shutdown_and_Res [get_bd_pins shutdown_ack] [get_bd_pins shutdown_and/Res]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins rx_shutdown/shutdown_req] [get_bd_pins tx_shutdown/shutdown_req]
  connect_bd_net -net time_running_0_1 [get_bd_pins time_running] [get_bd_pins stats/time_running] [get_bd_pins tgen/ext_enable]
  connect_bd_net -net tx_shutdown_shutdown_ack [get_bd_pins shutdown_concat/In1] [get_bd_pins tx_shutdown/shutdown_ack]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins shutdown_and/Op1] [get_bd_pins shutdown_concat/dout]

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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 axis_stats
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_stats
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_tgen

  # Create pins
  create_bd_pin -dir I -type clk clk_125M
  create_bd_pin -dir I clk_rx
  create_bd_pin -dir I -from 63 -to 0 current_time
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir O shutdown_ack
  create_bd_pin -dir I shutdown_req
  create_bd_pin -dir I time_running

  # Create instance: rx_shutdown, and set properties
  set rx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 rx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TREADY {false} \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_AXIS_TUSER_WIDTH {1} \
   CONFIG.C_CDC_STAGES {4} \
 ] $rx_shutdown

  # Create instance: shutdown_and, and set properties
  set shutdown_and [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 shutdown_and ]
  set_property -dict [ list \
   CONFIG.C_SIZE {2} \
 ] $shutdown_and

  # Create instance: shutdown_concat, and set properties
  set shutdown_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 shutdown_concat ]

  # Create instance: stats, and set properties
  set stats [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_stats_collector:1.1 stats ]
  set_property -dict [ list \
   CONFIG.C_AXIS_LOG_WIDTH {128} \
   CONFIG.C_AXI_WIDTH {64} \
 ] $stats

  # Create instance: tgen, and set properties
  set tgen [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:eth_traffic_gen:1.1 tgen ]
  set_property -dict [ list \
   CONFIG.axi_width {64} \
 ] $tgen

  # Create instance: tx_shutdown, and set properties
  set tx_shutdown [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 tx_shutdown ]
  set_property -dict [ list \
   CONFIG.C_AXIS_HAS_TUSER {true} \
   CONFIG.C_AXIS_TDATA_WIDTH {8} \
   CONFIG.C_AXIS_TUSER_WIDTH {1} \
 ] $tx_shutdown

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins rx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins s_axi_tgen] [get_bd_intf_pins tgen/S_AXI]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins s_axi_stats] [get_bd_intf_pins stats/S_AXI]
  connect_bd_intf_net -intf_net pr_shutdown_axis_0_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins tx_shutdown/M_AXIS]
  connect_bd_intf_net -intf_net rx_shutdown_M_AXIS [get_bd_intf_pins rx_shutdown/M_AXIS] [get_bd_intf_pins stats/AXIS_RX]
  connect_bd_intf_net -intf_net stats_M_AXIS_LOG [get_bd_intf_pins axis_stats] [get_bd_intf_pins stats/M_AXIS_LOG]
  connect_bd_intf_net -intf_net tgen_M_AXIS [get_bd_intf_pins tgen/M_AXIS] [get_bd_intf_pins tx_shutdown/S_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets tgen_M_AXIS] [get_bd_intf_pins stats/AXIS_TX] [get_bd_intf_pins tgen/M_AXIS]

  # Create port connections
  connect_bd_net -net clk_rx_1 [get_bd_pins clk_rx] [get_bd_pins rx_shutdown/clk] [get_bd_pins stats/clk_rx]
  connect_bd_net -net current_time_0_1 [get_bd_pins current_time] [get_bd_pins stats/current_time]
  connect_bd_net -net gtx_clk_0_1 [get_bd_pins clk_125M] [get_bd_pins rx_shutdown/shutdown_clk] [get_bd_pins stats/clk] [get_bd_pins stats/clk_tx] [get_bd_pins tgen/clk] [get_bd_pins tx_shutdown/clk]
  connect_bd_net -net rst_n_0_1 [get_bd_pins rst_n] [get_bd_pins rx_shutdown/rst_n] [get_bd_pins stats/rst_n] [get_bd_pins tgen/rst_n] [get_bd_pins tx_shutdown/rst_n]
  connect_bd_net -net rx_shutdown_shutdown_ack [get_bd_pins rx_shutdown/shutdown_ack] [get_bd_pins shutdown_concat/In0]
  connect_bd_net -net shutdown_and_Res [get_bd_pins shutdown_ack] [get_bd_pins shutdown_and/Res]
  connect_bd_net -net shutdown_concat_dout [get_bd_pins shutdown_and/Op1] [get_bd_pins shutdown_concat/dout]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins rx_shutdown/shutdown_req] [get_bd_pins tx_shutdown/shutdown_req]
  connect_bd_net -net time_running_0_1 [get_bd_pins time_running] [get_bd_pins stats/time_running] [get_bd_pins tgen/ext_enable]
  connect_bd_net -net tx_shutdown_shutdown_ack [get_bd_pins shutdown_concat/In1] [get_bd_pins tx_shutdown/shutdown_ack]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: dma_fifos
proc create_hier_cell_dma_fifos { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_dma_fifos() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S00_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S01_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S02_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S03_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S04_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S05_AXIS

  # Create pins
  create_bd_pin -dir I clk
  create_bd_pin -dir I rst_n
  create_bd_pin -dir O shutdown_ack
  create_bd_pin -dir I shutdown_req

  # Create instance: axis_regslice, and set properties
  set axis_regslice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_regslice ]
  set_property -dict [ list \
   CONFIG.REG_CONFIG {8} \
 ] $axis_regslice

  # Create instance: fifo_0, and set properties
  set fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_0 ]
  set_property -dict [ list \
   CONFIG.Clock_Type_AXI {Common_Clock} \
   CONFIG.Empty_Threshold_Assert_Value_axis {62} \
   CONFIG.Empty_Threshold_Assert_Value_rach {14} \
   CONFIG.Empty_Threshold_Assert_Value_rdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wach {14} \
   CONFIG.Empty_Threshold_Assert_Value_wdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wrch {14} \
   CONFIG.Enable_Data_Counts_axis {false} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Enable_TLAST {true} \
   CONFIG.FIFO_Implementation_axis {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_wdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value_axis {63} \
   CONFIG.Full_Threshold_Assert_Value_rach {15} \
   CONFIG.Full_Threshold_Assert_Value_wach {15} \
   CONFIG.Full_Threshold_Assert_Value_wrch {15} \
   CONFIG.INTERFACE_TYPE {AXI_STREAM} \
   CONFIG.Input_Depth_axis {64} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TKEEP_WIDTH {16} \
   CONFIG.TSTRB_WIDTH {16} \
   CONFIG.TUSER_WIDTH {0} \
   CONFIG.Use_Embedded_Registers_axis {false} \
   CONFIG.synchronization_stages_axi {3} \
 ] $fifo_0

  # Create instance: fifo_1, and set properties
  set fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_1 ]
  set_property -dict [ list \
   CONFIG.Clock_Type_AXI {Common_Clock} \
   CONFIG.Empty_Threshold_Assert_Value_axis {62} \
   CONFIG.Empty_Threshold_Assert_Value_rach {14} \
   CONFIG.Empty_Threshold_Assert_Value_rdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wach {14} \
   CONFIG.Empty_Threshold_Assert_Value_wdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wrch {14} \
   CONFIG.Enable_Data_Counts_axis {false} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Enable_TLAST {true} \
   CONFIG.FIFO_Implementation_axis {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_wdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value_axis {63} \
   CONFIG.Full_Threshold_Assert_Value_rach {15} \
   CONFIG.Full_Threshold_Assert_Value_wach {15} \
   CONFIG.Full_Threshold_Assert_Value_wrch {15} \
   CONFIG.INTERFACE_TYPE {AXI_STREAM} \
   CONFIG.Input_Depth_axis {64} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TKEEP_WIDTH {16} \
   CONFIG.TSTRB_WIDTH {16} \
   CONFIG.TUSER_WIDTH {0} \
   CONFIG.Use_Embedded_Registers_axis {false} \
   CONFIG.synchronization_stages_axi {3} \
 ] $fifo_1

  # Create instance: fifo_2, and set properties
  set fifo_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_2 ]
  set_property -dict [ list \
   CONFIG.Clock_Type_AXI {Common_Clock} \
   CONFIG.Empty_Threshold_Assert_Value_axis {62} \
   CONFIG.Empty_Threshold_Assert_Value_rach {14} \
   CONFIG.Empty_Threshold_Assert_Value_rdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wach {14} \
   CONFIG.Empty_Threshold_Assert_Value_wdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wrch {14} \
   CONFIG.Enable_Data_Counts_axis {false} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Enable_TLAST {true} \
   CONFIG.FIFO_Implementation_axis {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_wdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value_axis {63} \
   CONFIG.Full_Threshold_Assert_Value_rach {15} \
   CONFIG.Full_Threshold_Assert_Value_wach {15} \
   CONFIG.Full_Threshold_Assert_Value_wrch {15} \
   CONFIG.INTERFACE_TYPE {AXI_STREAM} \
   CONFIG.Input_Depth_axis {64} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TKEEP_WIDTH {16} \
   CONFIG.TSTRB_WIDTH {16} \
   CONFIG.TUSER_WIDTH {0} \
   CONFIG.Use_Embedded_Registers_axis {false} \
   CONFIG.synchronization_stages_axi {3} \
 ] $fifo_2

  # Create instance: fifo_3, and set properties
  set fifo_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_3 ]
  set_property -dict [ list \
   CONFIG.Clock_Type_AXI {Common_Clock} \
   CONFIG.Empty_Threshold_Assert_Value_axis {62} \
   CONFIG.Empty_Threshold_Assert_Value_rach {14} \
   CONFIG.Empty_Threshold_Assert_Value_rdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wach {14} \
   CONFIG.Empty_Threshold_Assert_Value_wdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wrch {14} \
   CONFIG.Enable_Data_Counts_axis {false} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Enable_TLAST {true} \
   CONFIG.FIFO_Implementation_axis {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_wdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value_axis {63} \
   CONFIG.Full_Threshold_Assert_Value_rach {15} \
   CONFIG.Full_Threshold_Assert_Value_wach {15} \
   CONFIG.Full_Threshold_Assert_Value_wrch {15} \
   CONFIG.INTERFACE_TYPE {AXI_STREAM} \
   CONFIG.Input_Depth_axis {64} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TKEEP_WIDTH {16} \
   CONFIG.TSTRB_WIDTH {16} \
   CONFIG.TUSER_WIDTH {0} \
   CONFIG.Use_Embedded_Registers_axis {false} \
   CONFIG.synchronization_stages_axi {3} \
 ] $fifo_3

  # Create instance: fifo_4, and set properties
  set fifo_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_4 ]
  set_property -dict [ list \
   CONFIG.Clock_Type_AXI {Common_Clock} \
   CONFIG.Empty_Threshold_Assert_Value_axis {4094} \
   CONFIG.Empty_Threshold_Assert_Value_rach {14} \
   CONFIG.Empty_Threshold_Assert_Value_rdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wach {14} \
   CONFIG.Empty_Threshold_Assert_Value_wdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wrch {14} \
   CONFIG.Enable_Data_Counts_axis {false} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Enable_TLAST {true} \
   CONFIG.FIFO_Implementation_axis {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_wdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value_axis {4095} \
   CONFIG.Full_Threshold_Assert_Value_rach {15} \
   CONFIG.Full_Threshold_Assert_Value_wach {15} \
   CONFIG.Full_Threshold_Assert_Value_wrch {15} \
   CONFIG.INTERFACE_TYPE {AXI_STREAM} \
   CONFIG.Input_Depth_axis {4096} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TKEEP_WIDTH {16} \
   CONFIG.TSTRB_WIDTH {16} \
   CONFIG.TUSER_WIDTH {0} \
   CONFIG.Use_Embedded_Registers_axis {true} \
   CONFIG.synchronization_stages_axi {3} \
 ] $fifo_4

  # Create instance: fifo_5, and set properties
  set fifo_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_5 ]
  set_property -dict [ list \
   CONFIG.Clock_Type_AXI {Common_Clock} \
   CONFIG.Empty_Threshold_Assert_Value_axis {4094} \
   CONFIG.Empty_Threshold_Assert_Value_rach {14} \
   CONFIG.Empty_Threshold_Assert_Value_rdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wach {14} \
   CONFIG.Empty_Threshold_Assert_Value_wdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wrch {14} \
   CONFIG.Enable_Data_Counts_axis {false} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Enable_TLAST {true} \
   CONFIG.FIFO_Implementation_axis {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_wdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value_axis {4095} \
   CONFIG.Full_Threshold_Assert_Value_rach {15} \
   CONFIG.Full_Threshold_Assert_Value_wach {15} \
   CONFIG.Full_Threshold_Assert_Value_wrch {15} \
   CONFIG.INTERFACE_TYPE {AXI_STREAM} \
   CONFIG.Input_Depth_axis {4096} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TKEEP_WIDTH {16} \
   CONFIG.TSTRB_WIDTH {16} \
   CONFIG.TUSER_WIDTH {0} \
   CONFIG.Use_Embedded_Registers_axis {true} \
   CONFIG.synchronization_stages_axi {3} \
 ] $fifo_5

  # Create instance: fifo_6, and set properties
  set fifo_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_6 ]
  set_property -dict [ list \
   CONFIG.Clock_Type_AXI {Common_Clock} \
   CONFIG.Empty_Threshold_Assert_Value_axis {126} \
   CONFIG.Empty_Threshold_Assert_Value_rach {14} \
   CONFIG.Empty_Threshold_Assert_Value_rdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wach {14} \
   CONFIG.Empty_Threshold_Assert_Value_wdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wrch {14} \
   CONFIG.Enable_Data_Counts_axis {false} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Enable_TLAST {true} \
   CONFIG.FIFO_Implementation_axis {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_wdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value_axis {127} \
   CONFIG.Full_Threshold_Assert_Value_rach {15} \
   CONFIG.Full_Threshold_Assert_Value_wach {15} \
   CONFIG.Full_Threshold_Assert_Value_wrch {15} \
   CONFIG.INTERFACE_TYPE {AXI_STREAM} \
   CONFIG.Input_Depth_axis {128} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TKEEP_WIDTH {16} \
   CONFIG.TSTRB_WIDTH {16} \
   CONFIG.TUSER_WIDTH {0} \
   CONFIG.Use_Embedded_Registers_axis {false} \
   CONFIG.synchronization_stages_axi {3} \
 ] $fifo_6

  # Create instance: fifo_7, and set properties
  set fifo_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_7 ]
  set_property -dict [ list \
   CONFIG.Clock_Type_AXI {Common_Clock} \
   CONFIG.Empty_Threshold_Assert_Value_axis {16382} \
   CONFIG.Empty_Threshold_Assert_Value_rach {14} \
   CONFIG.Empty_Threshold_Assert_Value_rdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wach {14} \
   CONFIG.Empty_Threshold_Assert_Value_wdch {1022} \
   CONFIG.Empty_Threshold_Assert_Value_wrch {14} \
   CONFIG.Enable_Data_Counts_axis {false} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Enable_TLAST {true} \
   CONFIG.FIFO_Implementation_axis {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_rdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} \
   CONFIG.FIFO_Implementation_wdch {Common_Clock_Block_RAM} \
   CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value_axis {16383} \
   CONFIG.Full_Threshold_Assert_Value_rach {15} \
   CONFIG.Full_Threshold_Assert_Value_wach {15} \
   CONFIG.Full_Threshold_Assert_Value_wrch {15} \
   CONFIG.INTERFACE_TYPE {AXI_STREAM} \
   CONFIG.Input_Depth_axis {16384} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TKEEP_WIDTH {16} \
   CONFIG.TSTRB_WIDTH {16} \
   CONFIG.TUSER_WIDTH {0} \
   CONFIG.Use_Embedded_Registers_axis {true} \
   CONFIG.synchronization_stages_axi {3} \
 ] $fifo_7

  # Create instance: shutdown_axis, and set properties
  set shutdown_axis [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:pr_shutdown_axis:1.0 shutdown_axis ]
  set_property -dict [ list \
   CONFIG.C_AXIS_TDATA_WIDTH {128} \
 ] $shutdown_axis

  # Create instance: switch_main, and set properties
  set switch_main [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 switch_main ]
  set_property -dict [ list \
   CONFIG.ARB_ALGORITHM {3} \
   CONFIG.ARB_ON_MAX_XFERS {0} \
   CONFIG.ARB_ON_TLAST {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.NUM_SI {3} \
 ] $switch_main

  # Create instance: switch_sc, and set properties
  set switch_sc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 switch_sc ]
  set_property -dict [ list \
   CONFIG.ARB_ALGORITHM {3} \
   CONFIG.ARB_ON_MAX_XFERS {0} \
   CONFIG.ARB_ON_TLAST {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.NUM_SI {4} \
 ] $switch_sc

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXIS_1 [get_bd_intf_pins S00_AXIS] [get_bd_intf_pins fifo_0/S_AXIS]
  connect_bd_intf_net -intf_net S01_AXIS_1 [get_bd_intf_pins S01_AXIS] [get_bd_intf_pins fifo_1/S_AXIS]
  connect_bd_intf_net -intf_net S02_AXIS_1 [get_bd_intf_pins S02_AXIS] [get_bd_intf_pins fifo_2/S_AXIS]
  connect_bd_intf_net -intf_net S03_AXIS_1 [get_bd_intf_pins S03_AXIS] [get_bd_intf_pins fifo_3/S_AXIS]
  connect_bd_intf_net -intf_net S04_AXIS_1 [get_bd_intf_pins S04_AXIS] [get_bd_intf_pins fifo_4/S_AXIS]
  connect_bd_intf_net -intf_net S05_AXIS_1 [get_bd_intf_pins S05_AXIS] [get_bd_intf_pins fifo_5/S_AXIS]
  connect_bd_intf_net -intf_net fifo_0_M_AXIS [get_bd_intf_pins fifo_0/M_AXIS] [get_bd_intf_pins switch_sc/S00_AXIS]
  connect_bd_intf_net -intf_net fifo_1_M_AXIS [get_bd_intf_pins fifo_1/M_AXIS] [get_bd_intf_pins switch_sc/S01_AXIS]
  connect_bd_intf_net -intf_net fifo_2_M_AXIS [get_bd_intf_pins fifo_2/M_AXIS] [get_bd_intf_pins switch_sc/S02_AXIS]
  connect_bd_intf_net -intf_net fifo_3_M_AXIS [get_bd_intf_pins fifo_3/M_AXIS] [get_bd_intf_pins switch_sc/S03_AXIS]
  connect_bd_intf_net -intf_net fifo_4_M_AXIS [get_bd_intf_pins fifo_4/M_AXIS] [get_bd_intf_pins switch_main/S00_AXIS]
  connect_bd_intf_net -intf_net fifo_5_M_AXIS [get_bd_intf_pins fifo_5/M_AXIS] [get_bd_intf_pins switch_main/S01_AXIS]
  connect_bd_intf_net -intf_net fifo_6_M_AXIS1 [get_bd_intf_pins fifo_6/M_AXIS] [get_bd_intf_pins switch_main/S02_AXIS]
  connect_bd_intf_net -intf_net fifo_7_M_AXIS [get_bd_intf_pins fifo_7/M_AXIS] [get_bd_intf_pins shutdown_axis/S_AXIS]
  connect_bd_intf_net -intf_net reg_slice_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins axis_regslice/M_AXIS]
  connect_bd_intf_net -intf_net shutdown_axis_M_AXIS [get_bd_intf_pins axis_regslice/S_AXIS] [get_bd_intf_pins shutdown_axis/M_AXIS]
  connect_bd_intf_net -intf_net switch_M00_AXIS [get_bd_intf_pins fifo_7/S_AXIS] [get_bd_intf_pins switch_main/M00_AXIS]
  connect_bd_intf_net -intf_net switch_sc_M00_AXIS [get_bd_intf_pins fifo_6/S_AXIS] [get_bd_intf_pins switch_sc/M00_AXIS]

  # Create port connections
  connect_bd_net -net clk_1 [get_bd_pins clk] [get_bd_pins axis_regslice/aclk] [get_bd_pins fifo_0/s_aclk] [get_bd_pins fifo_1/s_aclk] [get_bd_pins fifo_2/s_aclk] [get_bd_pins fifo_3/s_aclk] [get_bd_pins fifo_4/s_aclk] [get_bd_pins fifo_5/s_aclk] [get_bd_pins fifo_6/s_aclk] [get_bd_pins fifo_7/s_aclk] [get_bd_pins shutdown_axis/clk] [get_bd_pins switch_main/aclk] [get_bd_pins switch_sc/aclk]
  connect_bd_net -net rst_n_1 [get_bd_pins rst_n] [get_bd_pins axis_regslice/aresetn] [get_bd_pins fifo_0/s_aresetn] [get_bd_pins fifo_1/s_aresetn] [get_bd_pins fifo_2/s_aresetn] [get_bd_pins fifo_3/s_aresetn] [get_bd_pins fifo_4/s_aresetn] [get_bd_pins fifo_5/s_aresetn] [get_bd_pins fifo_6/s_aresetn] [get_bd_pins fifo_7/s_aresetn] [get_bd_pins shutdown_axis/rst_n] [get_bd_pins switch_main/aresetn] [get_bd_pins switch_sc/aresetn]
  connect_bd_net -net shutdown_axis_shutdown_ack [get_bd_pins shutdown_ack] [get_bd_pins shutdown_axis/shutdown_ack]
  connect_bd_net -net shutdown_req_1 [get_bd_pins shutdown_req] [get_bd_pins shutdown_axis/shutdown_req]

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
  set M_AXIS_DMA [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DMA ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_dcm_eth_0_clk_125M} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.PHASE {0.0} \
   ] $M_AXIS_DMA
  set M_AXIS_ETH0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_ETH0 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_dcm_eth_0_clk_125M} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.PHASE {0.0} \
   ] $M_AXIS_ETH0
  set M_AXIS_ETH1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_ETH1 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_dcm_eth_0_clk_125M} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.PHASE {0.0} \
   ] $M_AXIS_ETH1
  set M_AXIS_ETH2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_ETH2 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_dcm_eth_0_clk_125M} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.PHASE {0.0} \
   ] $M_AXIS_ETH2
  set M_AXIS_ETH3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_ETH3 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_dcm_eth_0_clk_125M} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.PHASE {0.0} \
   ] $M_AXIS_ETH3
  set S_AXIS_ETH0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_ETH0 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_mac_0_rx_clk} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {0} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {1} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {1} \
   ] $S_AXIS_ETH0
  set S_AXIS_ETH1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_ETH1 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_mac_0_rx_clk} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {0} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {1} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {1} \
   ] $S_AXIS_ETH1
  set S_AXIS_ETH2 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_ETH2 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_mac_2_rx_clk} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {0} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {1} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {1} \
   ] $S_AXIS_ETH2
  set S_AXIS_ETH3 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_ETH3 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_mac_2_rx_clk} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {0} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {1} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {1} \
   ] $S_AXIS_ETH3
  set S_AXI_PCIE [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_PCIE ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {30} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_dcm_eth_0_clk_125M} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {0} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {0} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PHASE {0.0} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_PCIE

  # Create ports
  set active [ create_bd_port -dir O -from 0 -to 0 active ]
  set clk [ create_bd_port -dir I -type clk clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M_AXIS_ETH0:M_AXIS_ETH1:M_AXIS_ETH2:M_AXIS_ETH3:S_AXI_PCIE:M_AXIS_DMA} \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_dcm_eth_0_clk_125M} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.PHASE {0.0} \
 ] $clk
  set clk_rx0 [ create_bd_port -dir I -type clk clk_rx0 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXIS_ETH0} \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_mac_0_rx_clk} \
   CONFIG.FREQ_HZ {125000000} \
 ] $clk_rx0
  set clk_rx1 [ create_bd_port -dir I -type clk clk_rx1 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXIS_ETH1} \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_mac_0_rx_clk} \
   CONFIG.FREQ_HZ {125000000} \
 ] $clk_rx1
  set clk_rx2 [ create_bd_port -dir I -type clk clk_rx2 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_mac_2_rx_clk} \
   CONFIG.FREQ_HZ {125000000} \
 ] $clk_rx2
  set clk_rx3 [ create_bd_port -dir I -type clk clk_rx3 ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {bd_reconfig_region_mac_2_rx_clk} \
   CONFIG.FREQ_HZ {125000000} \
 ] $clk_rx3
  set rst_pcie_n [ create_bd_port -dir I -type rst rst_pcie_n ]
  set rst_prc_n [ create_bd_port -dir I -type rst rst_prc_n ]
  set shutdown_ack [ create_bd_port -dir O shutdown_ack ]
  set shutdown_req [ create_bd_port -dir I shutdown_req ]

  # Create instance: active_constant, and set properties
  set active_constant [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 active_constant ]

  # Create instance: dma_fifos
  create_hier_cell_dma_fifos [current_bd_instance .] dma_fifos

  # Create instance: eth0
  create_hier_cell_eth0 [current_bd_instance .] eth0

  # Create instance: eth1
  create_hier_cell_eth1 [current_bd_instance .] eth1

  # Create instance: interconnect
  create_hier_cell_interconnect [current_bd_instance .] interconnect

  # Create instance: mitm
  create_hier_cell_mitm [current_bd_instance .] mitm

  # Create instance: reset, and set properties
  set reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 reset ]

  # Create instance: shutdown_and, and set properties
  set shutdown_and [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 shutdown_and ]
  set_property -dict [ list \
   CONFIG.C_SIZE {5} \
 ] $shutdown_and

  # Create instance: shutdown_concat, and set properties
  set shutdown_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 shutdown_concat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {5} \
 ] $shutdown_concat

  # Create instance: simple_timer, and set properties
  set simple_timer [ create_bd_cell -type ip -vlnv oscar-rc.dev:zbnt_hw:simple_timer:1.1 simple_timer ]
  set_property -dict [ list \
   CONFIG.axi_width {64} \
 ] $simple_timer

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_0_1 [get_bd_intf_ports S_AXIS_ETH0] [get_bd_intf_pins eth0/S_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_1_1 [get_bd_intf_ports S_AXIS_ETH1] [get_bd_intf_pins eth1/S_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_A_1 [get_bd_intf_ports S_AXIS_ETH2] [get_bd_intf_pins mitm/S_AXIS_A]
  connect_bd_intf_net -intf_net S_AXIS_B_1 [get_bd_intf_ports S_AXIS_ETH3] [get_bd_intf_pins mitm/S_AXIS_B]
  connect_bd_intf_net -intf_net S_AXI_PCIE_1 [get_bd_intf_ports S_AXI_PCIE] [get_bd_intf_pins interconnect/S_AXI_PCIE]
  connect_bd_intf_net -intf_net axi_interconnect_M03_AXI [get_bd_intf_pins eth1/s_axi_tgen] [get_bd_intf_pins interconnect/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_M05_AXI [get_bd_intf_pins interconnect/M05_AXI] [get_bd_intf_pins mitm/s_axi_stats_loop]
  connect_bd_intf_net -intf_net axi_interconnect_M07_AXI [get_bd_intf_pins interconnect/M07_AXI] [get_bd_intf_pins simple_timer/S_AXI]
  connect_bd_intf_net -intf_net dma_fifos_M_AXIS [get_bd_intf_ports M_AXIS_DMA] [get_bd_intf_pins dma_fifos/M_AXIS]
  connect_bd_intf_net -intf_net eth0_AXIS_TX [get_bd_intf_ports M_AXIS_ETH0] [get_bd_intf_pins eth0/M_AXIS]
  connect_bd_intf_net -intf_net eth0_axis_stats [get_bd_intf_pins dma_fifos/S00_AXIS] [get_bd_intf_pins eth0/axis_stats]
  connect_bd_intf_net -intf_net eth1_AXIS_TX [get_bd_intf_ports M_AXIS_ETH1] [get_bd_intf_pins eth1/M_AXIS]
  connect_bd_intf_net -intf_net eth1_axis_stats [get_bd_intf_pins dma_fifos/S01_AXIS] [get_bd_intf_pins eth1/axis_stats]
  connect_bd_intf_net -intf_net mitm_M_AXIS_A [get_bd_intf_ports M_AXIS_ETH2] [get_bd_intf_pins mitm/M_AXIS_A]
  connect_bd_intf_net -intf_net mitm_M_AXIS_B [get_bd_intf_ports M_AXIS_ETH3] [get_bd_intf_pins mitm/M_AXIS_B]
  connect_bd_intf_net -intf_net mitm_axis_detector_a [get_bd_intf_pins dma_fifos/S04_AXIS] [get_bd_intf_pins mitm/axis_detector_a]
  connect_bd_intf_net -intf_net mitm_axis_detector_b [get_bd_intf_pins dma_fifos/S05_AXIS] [get_bd_intf_pins mitm/axis_detector_b]
  connect_bd_intf_net -intf_net mitm_axis_stats_a [get_bd_intf_pins dma_fifos/S02_AXIS] [get_bd_intf_pins mitm/axis_stats_a]
  connect_bd_intf_net -intf_net mitm_axis_stats_b [get_bd_intf_pins dma_fifos/S03_AXIS] [get_bd_intf_pins mitm/axis_stats_b]
  connect_bd_intf_net -intf_net s_axi_detector_1 [get_bd_intf_pins interconnect/M04_AXI] [get_bd_intf_pins mitm/s_axi_detector]
  connect_bd_intf_net -intf_net s_axi_stats_1 [get_bd_intf_pins eth0/s_axi_stats] [get_bd_intf_pins interconnect/M00_AXI]
  connect_bd_intf_net -intf_net s_axi_stats_2 [get_bd_intf_pins eth1/s_axi_stats] [get_bd_intf_pins interconnect/M02_AXI]
  connect_bd_intf_net -intf_net s_axi_stats_main_1 [get_bd_intf_pins interconnect/M06_AXI] [get_bd_intf_pins mitm/s_axi_stats_main]
  connect_bd_intf_net -intf_net s_axi_tgen_1 [get_bd_intf_pins eth0/s_axi_tgen] [get_bd_intf_pins interconnect/M01_AXI]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins interconnect/rst_n] [get_bd_pins reset/interconnect_aresetn]
  connect_bd_net -net active_constant_dout [get_bd_ports active] [get_bd_pins active_constant/dout]
  connect_bd_net -net clk_rx_1 [get_bd_ports clk_rx0] [get_bd_pins eth0/clk_rx]
  connect_bd_net -net clk_rx_2 [get_bd_ports clk_rx1] [get_bd_pins eth1/clk_rx]
  connect_bd_net -net clk_rx_a_1 [get_bd_ports clk_rx2] [get_bd_pins mitm/clk_rx_a]
  connect_bd_net -net clk_rx_b_1 [get_bd_ports clk_rx3] [get_bd_pins mitm/clk_rx_b]
  connect_bd_net -net clk_wiz_0_clk_125M [get_bd_ports clk] [get_bd_pins dma_fifos/clk] [get_bd_pins eth0/clk_125M] [get_bd_pins eth1/clk_125M] [get_bd_pins interconnect/clk] [get_bd_pins mitm/clk_125M] [get_bd_pins reset/slowest_sync_clk] [get_bd_pins simple_timer/clk]
  connect_bd_net -net dma_fifos_shutdown_ack [get_bd_pins dma_fifos/shutdown_ack] [get_bd_pins shutdown_concat/In0]
  connect_bd_net -net eth0_shutdown_ack [get_bd_pins eth0/shutdown_ack] [get_bd_pins shutdown_concat/In2]
  connect_bd_net -net eth1_shutdown_ack [get_bd_pins eth1/shutdown_ack] [get_bd_pins shutdown_concat/In4]
  connect_bd_net -net interconnect_shutdown_ack [get_bd_pins interconnect/shutdown_ack] [get_bd_pins shutdown_concat/In3]
  connect_bd_net -net mitm_shutdown_ack [get_bd_pins mitm/shutdown_ack] [get_bd_pins shutdown_concat/In1]
  connect_bd_net -net reset_sys_clk_interconnect_aresetn [get_bd_pins dma_fifos/rst_n] [get_bd_pins eth0/rst_n] [get_bd_pins eth1/rst_n] [get_bd_pins mitm/rst_n] [get_bd_pins reset/peripheral_aresetn] [get_bd_pins simple_timer/rst_n]
  connect_bd_net -net rst_pcie_n_1 [get_bd_ports rst_pcie_n] [get_bd_pins reset/ext_reset_in]
  connect_bd_net -net rst_prc_n_1 [get_bd_ports rst_prc_n] [get_bd_pins reset/aux_reset_in]
  connect_bd_net -net shutdown_and_Res [get_bd_ports shutdown_ack] [get_bd_pins shutdown_and/Res]
  connect_bd_net -net shutdown_concat_dout [get_bd_pins shutdown_and/Op1] [get_bd_pins shutdown_concat/dout]
  connect_bd_net -net shutdown_req_0_1 [get_bd_ports shutdown_req] [get_bd_pins dma_fifos/shutdown_req] [get_bd_pins eth0/shutdown_req] [get_bd_pins eth1/shutdown_req] [get_bd_pins interconnect/shutdown_req] [get_bd_pins mitm/shutdown_req]
  connect_bd_net -net simple_timer_current_time [get_bd_pins eth0/current_time] [get_bd_pins eth1/current_time] [get_bd_pins mitm/current_time] [get_bd_pins simple_timer/current_time]
  connect_bd_net -net simple_timer_time_running [get_bd_pins eth0/time_running] [get_bd_pins eth1/time_running] [get_bd_pins mitm/time_running] [get_bd_pins simple_timer/time_running]

  # Create address segments
  create_bd_addr_seg -range 0x00020000 -offset 0x00100000 [get_bd_addr_spaces S_AXI_PCIE] [get_bd_addr_segs mitm/detector/S_AXI/S_AXI_ADDR] SEG_detector_S_AXI_ADDR
  create_bd_addr_seg -range 0x00001000 -offset 0x00020000 [get_bd_addr_spaces S_AXI_PCIE] [get_bd_addr_segs simple_timer/S_AXI/S_AXI_ADDR] SEG_simple_timer_S_AXI_ADDR
  create_bd_addr_seg -range 0x00001000 -offset 0x00040000 [get_bd_addr_spaces S_AXI_PCIE] [get_bd_addr_segs eth0/stats/S_AXI/S_AXI_ADDR] SEG_stats_S_AXI_ADDR
  create_bd_addr_seg -range 0x00001000 -offset 0x00060000 [get_bd_addr_spaces S_AXI_PCIE] [get_bd_addr_segs eth1/stats/S_AXI/S_AXI_ADDR] SEG_stats_S_AXI_ADDR1
  create_bd_addr_seg -range 0x00001000 -offset 0x00080000 [get_bd_addr_spaces S_AXI_PCIE] [get_bd_addr_segs mitm/stats_a/S_AXI/S_AXI_ADDR] SEG_stats_a_S_AXI_ADDR
  create_bd_addr_seg -range 0x00001000 -offset 0x000A0000 [get_bd_addr_spaces S_AXI_PCIE] [get_bd_addr_segs mitm/stats_b/S_AXI/S_AXI_ADDR] SEG_stats_b_S_AXI_ADDR
  create_bd_addr_seg -range 0x00002000 -offset 0x000C0000 [get_bd_addr_spaces S_AXI_PCIE] [get_bd_addr_segs eth0/tgen/S_AXI/S_AXI_ADDR] SEG_tgen_S_AXI_ADDR
  create_bd_addr_seg -range 0x00002000 -offset 0x000E0000 [get_bd_addr_spaces S_AXI_PCIE] [get_bd_addr_segs eth1/tgen/S_AXI/S_AXI_ADDR] SEG_tgen_S_AXI_ADDR1


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


