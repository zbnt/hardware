/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop
(
	input logic clk,
	input logic rst_n,

	// M_AXIS : AXI4-Stream master interface

	input logic m_axis_clk,

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tuser,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready,

	output logic [15:0] pause_val,
	output logic pause_req,

	// S_AXIS : AXI4-Stream slave interface

	input logic s_axis_clk,

	input logic [7:0] s_axis_tdata,
	input logic s_axis_tuser,
	input logic s_axis_tlast,
	input logic s_axis_tvalid
);
	// m_axis_clk clock domain: Read and write to FIFO

	logic fifo_prog_full, fifo_prog_empty;

	always_comb begin
		m_axis_tuser = 1'b0;
	end

	loop_fifo U0
	(
		.m_aclk(m_axis_clk),
		.s_aclk(s_axis_clk),
		.s_aresetn(1'b1),

		.axis_prog_full(fifo_prog_full),
		.axis_prog_empty(fifo_prog_empty),

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tready(),

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);

	// clk clock domain: Generate pause requests

	logic fifo_prog_full_cdc, fifo_prog_empty_cdc;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			pause_val[0] <= 16'd0;
			pause_req <= 1'b0;
		end else begin
			pause_val[0] <= (pause_val[0] | fifo_prog_full_cdc) & (~pause_val[0] | ~fifo_prog_empty_cdc);
			pause_req <= pause_val[0] ^ ((pause_val[0] | fifo_prog_full_cdc) & (~pause_val[0] | ~fifo_prog_empty_cdc));
		end
	end

	always_comb begin
		pause_val[15:1] = {15{pause_val[0]}};
	end

	sync_ffs #(2, 2) U1
	(
		.clk(clk),
		.data_in({fifo_prog_full, fifo_prog_empty}),
		.data_out({fifo_prog_full_cdc, fifo_prog_empty_cdc})
	);
endmodule
