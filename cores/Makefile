CORES = \
	axi_mm2s              \
	axi_s2mm              \
	axis_shutdown         \
	bpi_flash             \
	circular_dma          \
	common                \
	eth_frame_detector    \
	eth_latency_measurer  \
	eth_mac_1g            \
	eth_stats_collector   \
	eth_traffic_gen       \
	mem_streamer          \
	pr_bitstream_copy     \
	rp_wrapper            \
	simple_timer          \
	util_axis2msi         \
	util_cdc_array_single \
	util_gmii_slice       \
	util_icap             \
	util_iobuf            \
	util_irq2axis         \
	util_regslice         \
	util_sgmii_crossover  \
	util_startup

CLEAN_JOBS = $(addprefix clean_,${CORES})

.PHONY: $(CORES) $(CLEAN_JOBS) clean

cores: $(CORES)
clean: $(CLEAN_JOBS)

$(CORES):
	@$(MAKE) -C $@

$(CLEAN_JOBS): clean_%:
	@$(MAKE) -C $* clean
