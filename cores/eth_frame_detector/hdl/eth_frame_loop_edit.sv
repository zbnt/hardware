/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_edit #(parameter C_NUM_SCRIPTS = 4)
(
	input logic clk,
	input logic rst_n,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic [17*C_NUM_SCRIPTS:0] s_axis_tuser,  // {C_NUM_SCRIPTS * {PARAM_B, INSTR_B, MATCHED}, FCS_INVALID}
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic [1:0] m_axis_tuser, // {DROP_FRAME, FCS_INVALID}
	output logic m_axis_tlast,
	output logic m_axis_tvalid
);
	always_ff @(posedge clk) begin
		if(~rst_n) begin
			m_axis_tdata <= 8'd0;
			m_axis_tuser <= 2'b0;
			m_axis_tlast <= 1'b0;
			m_axis_tvalid <= 1'b0;
		end else begin
			m_axis_tdata <= s_axis_tdata;
			m_axis_tuser <= {1'b0, s_axis_tuser[0]};
			m_axis_tlast <= s_axis_tlast;
			m_axis_tvalid <= s_axis_tvalid;
		end
	end

	// TODO
endmodule
