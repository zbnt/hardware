
PROJECT_BUILD_SCRIPTS = $(wildcard projects/*/build_bitstream.tcl)
PROJECT_VIVADO_DIRS = $(wildcard projects/*/vivado)

.PHONY: bitstreams clean

bitstreams:
	for p in ${PROJECT_BUILD_SCRIPTS}; \
	do \
		vivado -mode batch -source $$p -nolog -nojournal; \
	done;

clean:
	-rm -r ${PROJECT_VIVADO_DIRS}
