# Procedures for creating and packaging IP

namespace eval ip {
	proc create_core { vendor lib ip_name version } {
		set core [ipx::create_core $vendor $lib $ip_name $version]

		set_property DISPLAY_NAME $ip_name $core
		set_property DESCRIPTION $ip_name $core
		set_property CORE_REVISION [clock seconds] $core
		set_property IPI_DRC {ignore_freq_hz true} $core

		ipx::add_file_group -type synthesis {} $core
		ipx::add_file_group -type simulation {} $core
		ipx::add_file_group -type implementation {} $core
		ipx::add_file_group -type gui {} $core
		ipx::add_file_group -type utility {} $core

		return $core
	}

	proc set_disp_name { core name } {
		set_property DISPLAY_NAME $name $core
	}

	proc set_description { core description } {
		set_property DESCRIPTION $description $core
	}

	proc tag_as_library { core } {
		set_property HIDE_IN_GUI 1 $core
	}

	proc set_categories { core categories } {
		set_property TAXONOMY $categories $core
	}

	proc set_supported_families { core families } {
		set_property SUPPORTED_FAMILIES $families $core
	}

	proc add_sources { core sources } {
		add_synth_sources $core $sources
		add_simulation_sources $core $sources
	}

	proc add_synth_sources { core sources } {
		set group [ipx::get_file_groups -of_objects $core xilinx_anylanguagesynthesis]

		foreach f $sources {
			ipx::add_file $f $group
		}
	}

	proc add_simulation_sources { core sources } {
		set group [ipx::get_file_groups -of_objects $core xilinx_anylanguagebehavioralsimulation]

		foreach f $sources {
			ipx::add_file $f $group
		}
	}

	proc add_implementation_sources { core sources } {
		set group [ipx::get_file_groups -of_objects $core xilinx_implementation]

		foreach f $sources {
			ipx::add_file $f $group
		}
	}

	proc add_gui_script { core gui } {
		set group [ipx::get_file_groups -of_objects $core xilinx_xpgui]
		set script [ipx::add_file $gui $group]

		set_property ENV_IDS :vivado.xilinx.com:xgui.ui $group
		set_property XGUI_VERSION 2 $script
	}

	proc add_gui_utils { core sources } {
		set group [ipx::get_file_groups -of_objects $core xilinx_utilityxitfiles]

		foreach f $sources {
			ipx::add_file $f $group
		}
	}

	proc add_subcore { core subcore } {
		set group_synth [ipx::get_file_groups -of_objects $core xilinx_anylanguagesynthesis]
		set group_simulation [ipx::get_file_groups -of_objects $core xilinx_anylanguagebehavioralsimulation]

		ipx::add_subcore $subcore $group_synth
		ipx::add_subcore $subcore $group_simulation
	}

	proc set_top { core top_module top_file } {
		set_synth_top $core $top_module $top_file
		set_simulation_top $core $top_module
	}

	proc set_synth_top { core top_module top_file } {
		set group [ipx::get_file_groups -of_objects $core xilinx_anylanguagesynthesis]
		set_property MODEL_NAME $top_module $group

		ipx::remove_all_port $core
		ipx::add_ports_from_hdl -top_level_hdl_file $top_file -top_module_name $top_module $core

		ipx::remove_all_hdl_parameter -remove_inferred_params $core
		ipx::add_model_parameters_from_hdl -top_level_hdl_file $top_file -top_module_name $top_module $core
		ipx::infer_user_parameters $core
	}

	proc set_simulation_top { core top_module } {
		set group [ipx::get_file_groups -of_objects $core xilinx_anylanguagebehavioralsimulation]
		set_property MODEL_NAME $top_module $group
	}

	proc add_param { core name fmt value } {
		set param [ipx::add_user_parameter $name $core]

		set_property VALUE $value $param
		set_property VALUE_FORMAT $fmt $param

		return $param
	}

	proc set_param_disp_name { core param name } {
		set param [ipx::get_user_parameters -of_objects $core $param]
		set_property DISPLAY_NAME $name $param
	}

	proc set_param_format { core param fmt } {
		set param_hdl [ipx::get_hdl_parameters -of_objects $core $param]
		set param_usr [ipx::get_user_parameters -of_objects $core $param]

		set_property VALUE_FORMAT $fmt $param_hdl
		set_property VALUE_FORMAT $fmt $param_usr
	}

	proc set_param_value { core param value } {
		set param_hdl [ipx::get_hdl_parameters -of_objects $core $param]
		set param_usr [ipx::get_user_parameters -of_objects $core $param]

		set_property VALUE $value $param_hdl
		set_property VALUE $value $param_usr
	}

	proc set_param_bit_len { core param length } {
		set param_hdl [ipx::get_hdl_parameters -of_objects $core $param]
		set param_usr [ipx::get_user_parameters -of_objects $core $param]

		set_property VALUE_BIT_STRING_LENGTH $length $param_hdl
		set_property VALUE_BIT_STRING_LENGTH $length $param_usr
	}

	proc set_param_range { core param min max } {
		set param [ipx::get_user_parameters -of_objects $core $param]

		set_property VALUE_VALIDATION_TYPE range_long $param
		set_property VALUE_VALIDATION_RANGE_MINIMUM $min $param
		set_property VALUE_VALIDATION_RANGE_MAXIMUM $max $param
	}

	proc set_param_list { core param values } {
		set param [ipx::get_user_parameters -of_objects $core $param]
		set value_pairs [list]

		foreach v $values {
			lappend value_pairs $v
			lappend value_pairs $v
		}

		set_property VALUE_VALIDATION_TYPE pairs $param
		set_property VALUE_VALIDATION_LIST $values $param
		set_property VALUE_VALIDATION_PAIRS $value_pairs $param
	}

	proc set_param_pairs { core param pairs } {
		set param [ipx::get_user_parameters -of_objects $core $param]
		set value_list [list]

		foreach {k v} $pairs {
			lappend value_list $k:$v
		}

		set_property VALUE_VALIDATION_TYPE pairs $param
		set_property VALUE_VALIDATION_LIST $value_list $param
		set_property VALUE_VALIDATION_PAIRS $pairs $param
	}

	proc add_bus_interface { core name mode abstraction type map } {
		set bus [ipx::add_bus_interface $name $core]

		set_property BUS_TYPE_VLNV $type $bus
		set_property ABSTRACTION_TYPE_VLNV $abstraction $bus
		set_property INTERFACE_MODE $mode $bus

		foreach {k v} $map {
			set port_map [ipx::add_port_map $k $bus]
			set_property PHYSICAL_NAME $v $port_map
		}

		return $bus
	}

	proc add_axi_interface { core name mode ports } {
		set map [list]

		foreach {k v} $ports {
			foreach p $v {
				lappend map [string toupper $k$p]
				lappend map [string tolower ${name}_$k$p]
			}
		}

		set iface [add_bus_interface $core $name $mode "xilinx.com:interface:aximm_rtl:1.0" "xilinx.com:interface:aximm:1.0" $map]

		if {$mode == "slave"} {
			ipx::infer_memory_address_block $iface
			set_property NAME ${name}_ADDR [ipx::get_address_blocks -of_objects [ipx::get_memory_maps $name]]
			set_property SLAVE_MEMORY_MAP_REF $name $iface
		}

		if {$mode == "master"} {
			ipx::infer_address_space $iface
			set_property MASTER_ADDRESS_SPACE_REF $name $iface
		}
	}

	proc add_axis_interface { core name mode ports } {
		set map [list]

		foreach v $ports {
			lappend map [string toupper t$v]
			lappend map [string tolower ${name}_t$v]
		}

		add_bus_interface $core $name $mode "xilinx.com:interface:axis_rtl:1.0" "xilinx.com:interface:axis:1.0" $map
	}

	proc add_gmii_interface { core name mode ports } {
		set map [list]

		foreach v $ports {
			lappend map [string toupper $v]
			lappend map [string tolower ${name}_$v]
		}

		add_bus_interface $core $name $mode "xilinx.com:interface:gmii_rtl:1.0" "xilinx.com:interface:gmii:1.0" $map
	}

	proc add_sgmii_interface { core name mode ports } {
		set map [list]

		foreach v $ports {
			lappend map [string toupper $v]
			lappend map [string tolower ${name}_$v]
		}

		add_bus_interface $core $name $mode "xilinx.com:interface:sgmii_rtl:1.0" "xilinx.com:interface:sgmii:1.0" $map
	}

	proc add_clk_interface { core name mode freq assoc_rst assoc_bus } {
		set iface [add_bus_interface $core $name $mode "xilinx.com:signal:clock_rtl:1.0" "xilinx.com:signal:clock:1.0" [list CLK $name]]

		if {$freq != ""} {
			set param [ipx::add_bus_parameter FREQ_HZ $iface]
			set_property VALUE $freq $param
		}

		if {$assoc_rst != ""} {
			set param [ipx::add_bus_parameter ASSOCIATED_RESET $iface]
			set_property VALUE $assoc_rst $param
		}

		if {$assoc_bus != ""} {
			set param [ipx::add_bus_parameter ASSOCIATED_BUSIF $iface]
			set_property VALUE $assoc_bus $param
		}
	}

	proc add_rst_interface { core name mode polarity } {
		set iface [add_bus_interface $core $name $mode "xilinx.com:signal:reset_rtl:1.0" "xilinx.com:signal:reset:1.0" [list RST $name]]

		set param [ipx::add_bus_parameter POLARITY $iface]
		set_property VALUE $polarity $param
	}

	proc add_irq_interface { core name mode sensitivity } {
		set iface [add_bus_interface $core $name $mode "xilinx.com:signal:interrupt_rtl:1.0" "xilinx.com:signal:interrupt:1.0" [list INTERRUPT $name]]

		set param [ipx::add_bus_parameter SENSITIVITY $iface]
		set_property VALUE $sensitivity $param
	}

	proc set_iface_parameters { core iface parameters } {
		set iface [ipx::get_bus_interfaces -of_objects $core $iface]

		foreach {k v} $parameters {
			set param [ipx::add_bus_parameter $k $iface]
			set_property VALUE $v $param
		}
	}

	proc set_iface_dependency { core iface dependency } {
		set iface [ipx::get_bus_interfaces -of_objects $core $iface]
		set_property ENABLEMENT_DEPENDENCY $dependency $iface
	}

	proc set_iface_dependencies { core dependencies } {
		foreach {p d} $dependencies {
			set_iface_dependency $core $p $d
		}
	}

	proc set_port_dependency { core port dependency } {
		set port [ipx::get_ports -of_objects $core $port]
		set_property ENABLEMENT_DEPENDENCY $dependency $port
	}

	proc set_port_dependencies { core dependencies } {
		foreach {p d} $dependencies {
			set_port_dependency $core $p $d
		}
	}

	proc set_port_driver { core port driver } {
		set port [ipx::get_ports -of_objects $core $port]
		set_property DRIVER_VALUE $driver $port
	}

	proc set_port_drivers { core drivers } {
		foreach {p d} $drivers {
			set_port_driver $core $p $d
		}
	}

	proc save_core { core } {
		ipx::save_core $core
		close_project
	}
}
