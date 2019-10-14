/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_matcher
(
	input logic clk,
	input logic rst_n,

	output logic [3:0] match,
	output logic [1:0] match_id,
	output logic [4:0] match_ext_num,
	output logic [127:0] match_ext_data,
	input logic [3:0] match_en,

	// S_AXIS : Data from TEMAC

	input logic s_axis_clk,

	input logic [7:0] s_axis_tdata,
	input logic s_axis_tuser,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// M_AXIS : Modified data

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tuser,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,

	// Pattern data and flags

	output logic [10:0] pattern_addr,
	input logic [31:0] pattern_data,
	input logic [31:0] pattern_flags
);
	// s_axis_clk clock domain

	logic rst_n_cdc;
	logic [3:0] match_en_cdc;

	logic [7:0] axis_data_q;
	logic axis_last_q, axis_valid_q, axis_user_q;

	logic pattern_end;
	logic [3:0] pattern_match;

	logic frame_end;
	logic [3:0] frame_match;
	logic [1:0] frame_match_id;
	logic [4:0] frame_match_ext_num;
	logic [127:0] frame_match_ext_data;

	logic [3:0] repl_req;
	logic [7:0] repl_data[0:3];
	logic [7:0] lfsr_val;

	always_ff @(posedge s_axis_clk) begin
		if(~rst_n_cdc | s_axis_tlast) begin
			pattern_addr <= 11'd0;
		end else if(s_axis_tvalid && pattern_addr != 11'd2047) begin
			pattern_addr <= pattern_addr + 11'd1;
		end
	end

	always_ff @(posedge s_axis_clk) begin
		if(~rst_n_cdc | axis_last_q) begin
			pattern_end <= 1'b0;
		end else if(axis_valid_q && pattern_addr == 11'd2047) begin
			pattern_end <= 1'b1;
		end
	end

	always_ff @(posedge s_axis_clk) begin
		if(~rst_n_cdc) begin
			frame_match <= 4'd0;
			frame_match_id <= 2'd0;
		end else if(frame_end && (pattern_match & match_en_cdc) != 3'd0) begin
			frame_match <= (pattern_match & match_en_cdc);
			frame_match_id <= frame_match_id + 2'd1;
		end

		frame_end <= axis_valid_q & axis_last_q;

		axis_data_q <= s_axis_tdata;
		axis_last_q <= s_axis_tlast;
		axis_user_q <= s_axis_tuser;
		axis_valid_q <= s_axis_tvalid;
	end

	for(genvar i = 0; i < 4; ++i) begin
		always_ff @(posedge s_axis_clk) begin
			if(~rst_n_cdc | frame_end) begin
				pattern_match[i] <= 1'b1;
			end else if(axis_valid_q & ~pattern_end) begin
				if(pattern_data[8*i+7:8*i] != axis_data_q && ~pattern_flags[8*i]) begin
					pattern_match[i] <= 1'b0;
				end

				if(pattern_flags[8*i+1] & ~axis_last_q) begin
					pattern_match[i] <= 1'b0;
				end
			end
		end

		always_comb begin
			repl_req[i] = 1'b0;
			repl_data[i] = 8'd0;

			if(rst_n_cdc & axis_valid_q & ~pattern_end & pattern_match[i]) begin
				if(pattern_flags[8*i+2]) begin
					repl_req[i] = 1'b1;
					repl_data[i] = pattern_data[8*i+7:8*i];
				end else if(pattern_flags[8*i+3]) begin
					repl_req[i] = 1'b1;
					repl_data[i] = lfsr_val;
				end
			end
		end
	end

	always_ff @(posedge s_axis_clk) begin
		if(~rst_n_cdc | frame_end) begin
			frame_match_ext_num <= 5'd0;
			frame_match_ext_data <= 128'd0;
		end else if(axis_valid_q & ~pattern_end) begin
			if(pattern_flags[4] | pattern_flags[12] | pattern_flags[20] | pattern_flags[28]) begin
				case(frame_match_ext_num)
					5'd0: frame_match_ext_data[7:0] <= axis_data_q;
					5'd1: frame_match_ext_data[15:8] <= axis_data_q;
					5'd2: frame_match_ext_data[23:16] <= axis_data_q;
					5'd3: frame_match_ext_data[31:24] <= axis_data_q;
					5'd4: frame_match_ext_data[39:32] <= axis_data_q;
					5'd5: frame_match_ext_data[47:40] <= axis_data_q;
					5'd6: frame_match_ext_data[55:48] <= axis_data_q;
					5'd7: frame_match_ext_data[63:56] <= axis_data_q;
					5'd8: frame_match_ext_data[71:64] <= axis_data_q;
					5'd9: frame_match_ext_data[79:72] <= axis_data_q;
					5'd10: frame_match_ext_data[87:80] <= axis_data_q;
					5'd11: frame_match_ext_data[95:88] <= axis_data_q;
					5'd12: frame_match_ext_data[103:96] <= axis_data_q;
					5'd13: frame_match_ext_data[111:104] <= axis_data_q;
					5'd14: frame_match_ext_data[119:112] <= axis_data_q;
					5'd15: frame_match_ext_data[127:120] <= axis_data_q;
				endcase

				if(frame_match_ext_num != 5'd16) begin
					frame_match_ext_num <= frame_match_ext_num + 5'd1;
				end
			end
		end
	end

	always_comb begin
		m_axis_tdata = axis_data_q;
		m_axis_tuser = axis_user_q;
		m_axis_tlast = axis_last_q;
		m_axis_tvalid = axis_valid_q;

		if(repl_req[0]) begin
			m_axis_tdata = repl_data[0];
		end else if(repl_req[1]) begin
			m_axis_tdata = repl_data[1];
		end else if(repl_req[2]) begin
			m_axis_tdata = repl_data[2];
		end else if(repl_req[3]) begin
			m_axis_tdata = repl_data[3];
		end
	end

	// lfsr

	lfsr #(8, 4, 7, 5, 4, 3) U0
	(
		.clk(s_axis_clk),
		.rst(~rst_n_cdc),
		.enable(s_axis_tvalid),
		.value_in(8'd11),
		.value_out(lfsr_val)
	);

	// synchronize enable and reset signals

	sync_ffs #(5, 2) U1
	(
		.clk_src(clk),
		.clk_dst(s_axis_clk),
		.data_in({rst_n, match_en}),
		.data_out({rst_n_cdc, match_en_cdc})
	);

	sync_ffs #(139, 2) U2
	(
		.clk_src(s_axis_clk),
		.clk_dst(clk),
		.data_in({frame_match, frame_match_id, frame_match_ext_num, frame_match_ext_data}),
		.data_out({match, match_id, match_ext_num, match_ext_data})
	);
endmodule
