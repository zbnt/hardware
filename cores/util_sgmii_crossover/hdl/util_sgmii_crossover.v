/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module util_sgmii_crossover
(
	// S_SGMII_A

	input wire s_sgmii_a_txp,
	input wire s_sgmii_a_txn,
	output wire s_sgmii_a_rxp,
	output wire s_sgmii_a_rxn,

	// S_SGMII_B

	input wire s_sgmii_b_txp,
	input wire s_sgmii_b_txn,
	output wire s_sgmii_b_rxp,
	output wire s_sgmii_b_rxn,

	// M_SGMII_A

	output wire m_sgmii_a_txp,
	output wire m_sgmii_a_txn,
	input wire m_sgmii_a_rxp,
	input wire m_sgmii_a_rxn,

	// M_SGMII_B

	output wire m_sgmii_b_txp,
	output wire m_sgmii_b_txn,
	input wire m_sgmii_b_rxp,
	input wire m_sgmii_b_rxn
);
	assign m_sgmii_a_txp = s_sgmii_a_txp;
	assign m_sgmii_a_txn = s_sgmii_a_txn;
	assign m_sgmii_b_txp = s_sgmii_b_txp;
	assign m_sgmii_b_txn = s_sgmii_b_txn;

	assign s_sgmii_a_rxp = m_sgmii_b_rxp;
	assign s_sgmii_a_rxn = m_sgmii_b_rxn;
	assign s_sgmii_b_rxp = m_sgmii_a_rxp;
	assign s_sgmii_b_rxn = m_sgmii_a_rxn;
endmodule
