SOURCES = \
	hdl/axis_gmii_rx.v       \
	hdl/axis_gmii_tx.v       \
	hdl/eth_mac_1g_gmii.v    \
	hdl/eth_mac_1g_rgmii.v   \
	hdl/eth_mac_1g.v         \
	hdl/eth_mac_1g_wrapper.v \
	hdl/gmii_phy_if.v        \
	hdl/iddr.v               \
	hdl/lfsr.v               \
	hdl/oddr.v               \
	hdl/rgmii_phy_if.v       \
	hdl/ssio_ddr_in.v        \
	hdl/ssio_sdr_in.v        \
	hdl/ssio_sdr_out.v       \
	xdc/eth_mac_1g.xdc       \
	xgui/eth_mac_1g.gtcl     \
	xgui/eth_mac_1g.tcl

.PHONY: clean

component.xml: create_ip.tcl $(SOURCES)
	vivado -mode batch -source create_ip.tcl -notrace -nolog -nojournal

clean:
	rm -f component.xml
