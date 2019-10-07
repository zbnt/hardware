
write_cfgmem -force -format mcs -size 128 -interface BPIx16 -checksum -file "hw/netfpga_1g_cml.mcs" -loadbit {
	up 0x00000000 "hw/quad_tgen.bit"
	up 0x00800000 "hw/dual_tgen_latency.bit"
	up 0x01000000 "hw/dual_tgen_detector.bit"
}
