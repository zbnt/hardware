/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_mac_1g_w #(parameter C_IFACE_TYPE = "GMII", parameter C_CLK_INPUT_STYLE = "BUFR", parameter C_USE_CLK90 = 0, parameter C_GTX_AS_RX_CLK = 0)
(
	// Clock signals

	input wire gtx_clk,
	input wire gtx_clk90,
	output wire rx_clk,

	// Reset

	input wire gtx_rst_n,

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
	if(C_IFACE_TYPE == "RGMII") begin
		wire [3:0] rgmii_rd_delayed;
		wire rgmii_rx_ctl_delayed;

		eth_mac_1g_rgmii
		#(
			.TARGET("XILINX"),
			.IODDR_STYLE("IODDR"),
			.CLOCK_INPUT_STYLE(C_CLK_INPUT_STYLE),
			.USE_CLK90(C_USE_CLK90 ? "TRUE" : "FALSE"),
			.ENABLE_PADDING(1),
			.MIN_FRAME_LENGTH(64)
		)
		eth_mac_1g_rgmii_inst
		(
			.gtx_clk(gtx_clk),
			.gtx_clk90(gtx_clk90),
			.gtx_rst(~gtx_rst_n),
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
			.rgmii_rxd(rgmii_rd_delayed),
			.rgmii_rx_ctl(rgmii_rx_ctl_delayed),
			.rgmii_tx_clk(rgmii_txc),
			.rgmii_txd(rgmii_td),
			.rgmii_tx_ctl(rgmii_tx_ctl),

			.tx_error_underflow(tx_error),
			.rx_error_bad_frame(rx_error[0]),
			.rx_error_bad_fcs(rx_error[1]),
			.speed(speed),

			.ifg_delay(8'd12)
		);

		for(genvar i = 0; i < 4; i = i + 1) begin
			IDELAYE2
			#(
				.IDELAY_TYPE("FIXED"),
				.IDELAY_VALUE(12)
			)
			rd_idelay_inst
			(
				.IDATAIN(rgmii_rd[i]),
				.DATAOUT(rgmii_rd_delayed[i])
			);
		end

		IDELAYE2
		#(
			.IDELAY_TYPE("FIXED"),
			.IDELAY_VALUE(12)
		)
		rx_ctl_idelay_inst
		(
			.IDATAIN(rgmii_rx_ctl),
			.DATAOUT(rgmii_rx_ctl_delayed)
		);

		assign gmii_txd = 8'd0;
		assign gmii_tx_clk = 1'b0;
		assign gmii_tx_en = 1'b0;
		assign gmii_tx_er = 1'b0;
	end else if(C_IFACE_TYPE == "GMII") begin
		if(~C_GTX_AS_RX_CLK) begin
			eth_mac_1g_gmii
			#(
				.TARGET("XILINX"),
				.IODDR_STYLE("IODDR"),
				.CLOCK_INPUT_STYLE(C_CLK_INPUT_STYLE),
				.ENABLE_PADDING(1),
				.MIN_FRAME_LENGTH(64)
			)
			eth_mac_1g_gmii_inst
			(
				.gtx_clk(gtx_clk),
				.gtx_rst(~gtx_rst_n),
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
		end else begin
			eth_mac_1g #(
				.ENABLE_PADDING(1),
				.MIN_FRAME_LENGTH(64)
			)
			eth_mac_1g_inst
			(
				.tx_clk(gtx_clk),
				.tx_rst(~gtx_rst_n),
				.rx_clk(gtx_clk),
				.rx_rst(~gtx_rst_n),

				.tx_axis_tdata(tx_axis_tdata),
				.tx_axis_tvalid(tx_axis_tvalid),
				.tx_axis_tready(tx_axis_tready),
				.tx_axis_tlast(tx_axis_tlast),
				.tx_axis_tuser(tx_axis_tuser),

				.rx_axis_tdata(rx_axis_tdata),
				.rx_axis_tvalid(rx_axis_tvalid),
				.rx_axis_tlast(rx_axis_tlast),
				.rx_axis_tuser(rx_axis_tuser),

				.gmii_rxd(gmii_rxd),
				.gmii_rx_dv(gmii_rx_dv),
				.gmii_rx_er(gmii_rx_er),
				.gmii_txd(gmii_txd),
				.gmii_tx_en(gmii_tx_en),
				.gmii_tx_er(gmii_tx_er),

				.rx_clk_enable(1'b1),
				.tx_clk_enable(1'b1),
				.rx_mii_select(1'b0),
				.tx_mii_select(1'b0),

				.tx_error_underflow(tx_error),
				.rx_error_bad_frame(rx_error[0]),
				.rx_error_bad_fcs(rx_error[1]),

				.ifg_delay(8'd12)
			);

			assign speed = 2'd0;
			assign rx_clk = gtx_clk;
			assign gmii_tx_clk = gtx_clk;
		end

		assign rgmii_td = 4'd0;
		assign rgmii_txc = 1'b0;
		assign rgmii_tx_ctl = 1'b0;
	end
endmodule
