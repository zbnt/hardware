/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_fifo
(
	input logic clk,
	input logic rst,
	input logic trigger,

	input logic [31:0] s_axis_tdata,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready,

	output logic [31:0] frame_delay
);
	logic got_delay;
	logic [31:0] next_delay;

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			got_delay <= 1'b0;
			next_delay <= 32'd0;
			frame_delay <= 32'd0;
		end else if(trigger) begin
			got_delay <= 1'b0;
			next_delay <= 32'd0;
			frame_delay <= next_delay;
		end else if(s_axis_tvalid & ~got_delay) begin
			got_delay <= 1'b1;
			next_delay <= s_axis_tdata;
		end
	end

	always_comb begin
		s_axis_tready = ~got_delay;
	end
endmodule
