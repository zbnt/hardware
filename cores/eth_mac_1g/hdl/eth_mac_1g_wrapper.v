/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_mac_1g_w #(parameter iface_type = "RGMII", parameter family_name = "7-Series", parameter use_clk90 = 1)
(
	// Clock signals

	input wire gtx_clk,
	input wire gtx_clk90,
	output wire rx_clk,

	// Reset

	input wire gtx_rst,

	// Status

	output wire tx_error,
	output wire [1:0] rx_error,
	output wire [1:0] speed,

	// TX_AXIS

	input wire [7:0] tx_axis_tdata,
	input wire tx_axis_tvalid,
	input wire tx_axis_tlast,
	input wire tx_axis_tuser,
	output wire tx_axis_tready,

	// RX_AXIS

	output wire [7:0] rx_axis_tdata,
	output wire rx_axis_tvalid,
	output wire rx_axis_tlast,
	output wire rx_axis_tuser,

	// RGMII

	input wire [3:0] rgmii_rd,
	input wire rgmii_rxc,
	input wire rgmii_rx_ctl,

	output wire [3:0] rgmii_td,
	output wire rgmii_txc,
	output wire rgmii_tx_ctl,

	// GMII

	input wire [7:0] gmii_rxd,
	input wire gmii_rx_clk,
	input wire gmii_rx_dv,
	input wire gmii_rx_er,
	input wire mii_tx_clk,

	output wire [7:0] gmii_txd,
	output wire gmii_tx_clk,
	output wire gmii_tx_en,
	output wire gmii_tx_er
);
	if(iface_type == "RGMII") begin
		eth_mac_1g_rgmii
		#(
			.TARGET("XILINX"),
			.IODDR_STYLE("IODDR"),
			.CLOCK_INPUT_STYLE(family_name != "7-Series" ? "BUFG" : "BUFR"),
			.USE_CLK90(use_clk90 ? "TRUE" : "FALSE"),
			.ENABLE_PADDING(1),
			.MIN_FRAME_LENGTH(64)
		)
		eth_mac_1g_rgmii_inst
		(
			.gtx_clk(gtx_clk),
			.gtx_clk90(gtx_clk90),
			.gtx_rst(gtx_rst),
			.rx_clk(rx_clk),

			.tx_axis_tdata(tx_axis_tdata),
			.tx_axis_tvalid(tx_axis_tvalid),
			.tx_axis_tready(tx_axis_tready),
			.tx_axis_tlast(tx_axis_tlast),
			.tx_axis_tuser(tx_axis_tuser),

			.rx_axis_tdata(rx_axis_tdata),
			.rx_axis_tvalid(rx_axis_tvalid),
			.rx_axis_tlast(rx_axis_tlast),
			.rx_axis_tuser(rx_axis_tuser),

			.rgmii_rx_clk(rgmii_rxc),
			.rgmii_rxd(rgmii_rd),
			.rgmii_rx_ctl(rgmii_rx_ctl),
			.rgmii_tx_clk(rgmii_txc),
			.rgmii_txd(rgmii_td),
			.rgmii_tx_ctl(rgmii_tx_ctl),

			.tx_error_underflow(tx_error),
			.rx_error_bad_frame(rx_error[0]),
			.rx_error_bad_fcs(rx_error[1]),
			.speed(speed),

			.ifg_delay(8'd12)
		);

		assign gmii_txd = 8'd0;
		assign gmii_tx_clk = 1'b0;
		assign gmii_tx_en = 1'b0;
		assign gmii_tx_er = 1'b0;
	end else if(iface_type == "GMII") begin
		eth_mac_1g_gmii
		#(
			.TARGET("XILINX"),
			.IODDR_STYLE("IODDR"),
			.CLOCK_INPUT_STYLE(family_name != "7-Series" ? "BUFG" : "BUFR"),
			.ENABLE_PADDING(1),
			.MIN_FRAME_LENGTH(64)
		)
		eth_mac_1g_gmii_inst
		(
			.gtx_clk(gtx_clk),
			.gtx_rst(gtx_rst),
			.rx_clk(rx_clk),

			.tx_axis_tdata(tx_axis_tdata),
			.tx_axis_tvalid(tx_axis_tvalid),
			.tx_axis_tready(tx_axis_tready),
			.tx_axis_tlast(tx_axis_tlast),
			.tx_axis_tuser(tx_axis_tuser),

			.rx_axis_tdata(rx_axis_tdata),
			.rx_axis_tvalid(rx_axis_tvalid),
			.rx_axis_tlast(rx_axis_tlast),
			.rx_axis_tuser(rx_axis_tuser),

			.gmii_rx_clk(gmii_rx_clk),
			.gmii_rxd(gmii_rxd),
			.gmii_rx_dv(gmii_rx_dv),
			.gmii_rx_er(gmii_rx_er),
			.mii_tx_clk(mii_tx_clk),
			.gmii_tx_clk(gmii_tx_clk),
			.gmii_txd(gmii_txd),
			.gmii_tx_en(gmii_tx_en),
			.gmii_tx_er(gmii_tx_er),

			.tx_error_underflow(tx_error),
			.rx_error_bad_frame(rx_error[0]),
			.rx_error_bad_fcs(rx_error[1]),
			.speed(speed),

			.ifg_delay(8'd12)
		);

		assign rgmii_td = 4'd0;
		assign rgmii_txc = 1'b0;
		assign rgmii_tx_ctl = 1'b0;
	end
endmodule
