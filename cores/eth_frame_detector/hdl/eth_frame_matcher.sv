/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_matcher
(
	input logic clk,
	input logic rst_n,

	output logic [2:0] match,
	output logic [1:0] match_id,
	input logic [2:0] match_en,

	// S_AXIS : AXI4-Stream slave interface

	input logic s_axis_clk,

	input logic [7:0] s_axis_tdata,
	input logic s_axis_tuser,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// MEM : DRAM with the frame patterns

	input logic [29:0] mem_data,
	output logic [10:0] mem_addr
);
	// s_axis_clk clock domain

	logic rst_n_cdc;
	logic [2:0] match_en_cdc;
	logic [2:0] match_mode_cdc;

	logic [7:0] axis_data_q;
	logic axis_last_q, axis_valid_q;

	logic [2:0] pattern_match, pattern_over;

	logic frame_end;
	logic [2:0] frame_match;
	logic [1:0] frame_match_id;

	always_ff @(posedge s_axis_clk) begin
		if(~rst_n_cdc | s_axis_tlast) begin
			mem_addr <= 11'd0;
		end else if(s_axis_tvalid) begin
			mem_addr <= mem_addr + 11'd1;
		end
	end

	for(genvar i = 0; i < 3; ++i) begin
		always_ff @(posedge s_axis_clk) begin
			if(~rst_n_cdc) begin
				frame_match[i] <= 1'b0;
				pattern_match[i] <= 1'b1;
			end else if(axis_valid_q) begin
				if(mem_data[8*i+7:8*i] != axis_data_q && ~mem_data[24+2*i] || mem_data[25+2*i] & ~axis_last_q) begin
					if(axis_last_q) begin
						frame_match[i] <= 1'b0;
						pattern_match[i] <= 1'b1;
					end else begin
						pattern_match[i] <= 1'b0;
					end
				end else if(axis_last_q) begin
					frame_match[i] <= pattern_match[i] & match_en_cdc[i];
					pattern_match[i] <= 1'b1;
				end
			end
		end
	end

	always_ff @(posedge s_axis_clk) begin
		if(~rst_n_cdc) begin
			frame_match_id <= 2'd0;
		end else if(frame_end && frame_match != 3'd0) begin
			frame_match_id <= frame_match_id + 2'd1;
		end

		frame_end <= axis_valid_q & axis_last_q;

		axis_data_q <= s_axis_tdata;
		axis_last_q <= s_axis_tlast;
		axis_valid_q <= s_axis_tvalid;
	end

	// synchronize enable and reset signals

	sync_ffs #(4, 2) U0
	(
		.clk_src(clk),
		.clk_dst(s_axis_clk),
		.data_in({rst_n, match_en}),
		.data_out({rst_n_cdc, match_en_cdc})
	);

	sync_ffs #(5, 2) U1
	(
		.clk_src(s_axis_clk),
		.clk_dst(clk),
		.data_in({frame_match, frame_match_id}),
		.data_out({match, match_id})
	);
endmodule
