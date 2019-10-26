/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module util_gmii_slice
(
	// S_GMII

	input wire [7:0] s_gmii_txd,
	input wire s_gmii_tx_er,
	input wire s_gmii_tx_en,

	output wire [7:0] s_gmii_rxd,
	output wire s_gmii_rx_er,
	output wire s_gmii_rx_dv,

	// M_GMII_TX

	output wire [7:0] m_gmii_tx_txd,
	output wire m_gmii_tx_tx_er,
	output wire m_gmii_tx_tx_en,

	input wire [7:0] m_gmii_tx_rxd,
	input wire m_gmii_tx_rx_er,
	input wire m_gmii_tx_rx_dv,

	// M_GMII_RX

	output wire [7:0] m_gmii_rx_txd,
	output wire m_gmii_rx_tx_er,
	output wire m_gmii_rx_tx_en,

	input wire [7:0] m_gmii_rx_rxd,
	input wire m_gmii_rx_rx_er,
	input wire m_gmii_rx_rx_dv
);
	assign m_gmii_tx_txd = s_gmii_txd;
	assign m_gmii_tx_tx_er = s_gmii_tx_er;
	assign m_gmii_tx_tx_en = s_gmii_tx_en;

	assign s_gmii_rxd = m_gmii_rx_rxd;
	assign s_gmii_rx_er = m_gmii_rx_rx_er;
	assign s_gmii_rx_dv = m_gmii_rx_rx_dv;

	assign m_gmii_rx_txd = 8'd0;
	assign m_gmii_rx_tx_er = 1'd0;
	assign m_gmii_rx_tx_en = 1'd0;
endmodule
