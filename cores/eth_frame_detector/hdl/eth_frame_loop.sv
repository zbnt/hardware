/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop #(parameter C_LOOP_FIFO_SIZE = 2048)
(
	input logic clk,
	input logic rst_n,

	input logic mode,

	// M_AXIS : AXI4-Stream master interface

	input logic m_axis_clk,

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tuser,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready,

	// S_AXIS : AXI4-Stream slave interface

	input logic s_axis_clk,

	input logic [7:0] s_axis_tdata,
	input logic [1:0] s_axis_tuser,
	input logic s_axis_tlast,
	input logic s_axis_tvalid
);
	// s_axis_clk clock domain

	logic [15:0] checksum, checksum_pos;
	logic checksum_done, fix_checksum;
	logic overflow, overflow_ack;
	logic tx_trigger, tx_ack;
	logic mode_s, mode_s_q;
	logic rst_n_s;

	logic s_axis_tready;

	transport_checksum U0
	(
		.clk(s_axis_clk),
		.rst_n(rst_n_s),

		.checksum(checksum),
		.checksum_orig(),
		.checksum_pos(checksum_pos),
		.checksum_done(checksum_done),

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast | (s_axis_tvalid & ~s_axis_tready) | overflow),
		.s_axis_tvalid(s_axis_tvalid & ~overflow_ack)
	);

	always_ff @(posedge s_axis_clk) begin
		if(~rst_n_s) begin
			fix_checksum <= 1'b0;
			tx_trigger <= 1'b0;
			overflow <= 1'b0;
			overflow_ack <= 1'b0;
			mode_s_q <= 1'b0;
		end else begin
			if(s_axis_tvalid) begin
				if(s_axis_tlast & ~overflow) begin
					fix_checksum <= s_axis_tuser[1] & mode_s_q;
				end

				if(~s_axis_tready) begin
					overflow <= 1'b1;
					overflow_ack <= 1'b0;
					fix_checksum <= 1'b0;
				end else if(s_axis_tlast) begin
					overflow <= 1'b0;
					overflow_ack <= 1'b0;
				end
			end

			if(s_axis_tvalid & s_axis_tlast) begin
				mode_s_q <= mode_s;
			end

			if(overflow & s_axis_tready) begin
				overflow_ack <= 1'b1;
			end

			if(~mode_s_q | checksum_done) begin
				tx_trigger <= 1'b1;
			end

			if(mode_s_q & tx_ack) begin
				tx_trigger <= 1'b0;
			end
		end
	end

	// m_axis_clk clock domain

	logic rst_n_m;
	logic tx_enable, tx_trigger_m;

	logic m_fifo_tvalid;
	logic [7:0] m_fifo_tdata;

	logic [15:0] checksum_m, checksum_pos_m, count;
	logic fix_checksum_m;

	always_ff @(posedge m_axis_clk) begin
		if(~rst_n_m) begin
			count <= 16'd0;
			tx_enable <= 1'b0;
		end else begin
			if(tx_trigger_m) begin
				tx_enable <= 1'b1;
			end

			if(m_axis_tvalid) begin
				if(m_axis_tlast) begin
					tx_enable <= 1'b0;
					count <= 16'd0;
				end else if(tx_enable) begin
					count <= count + 16'd1;
				end
			end
		end
	end

	always_comb begin
		m_axis_tvalid = m_fifo_tvalid & tx_enable;

		if(fix_checksum_m && checksum_m != 16'd0 && count[15:1] == checksum_pos_m[15:1]) begin
			if(count[0]) begin
				m_axis_tdata = checksum_m[7:0];
			end else begin
				m_axis_tdata = checksum_m[15:8];
			end
		end else begin
			m_axis_tdata = m_fifo_tdata;
		end
	end

	// CDC

	sync_ffs #(2, 2) U1
	(
		.clk_src(clk),
		.clk_dst(s_axis_clk),
		.data_in({rst_n, mode}),
		.data_out({rst_n_s, mode_s})
	);

	sync_ffs #(1, 2) U2
	(
		.clk_src(clk),
		.clk_dst(m_axis_clk),
		.data_in(rst_n),
		.data_out(rst_n_m)
	);

	sync_ffs #(1, 2) U3
	(
		.clk_src(s_axis_clk),
		.clk_dst(m_axis_clk),
		.data_in(tx_trigger),
		.data_out(tx_trigger_m)
	);

	sync_ffs #(1, 2) U4
	(
		.clk_src(m_axis_clk),
		.clk_dst(s_axis_clk),
		.data_in(tx_trigger_m),
		.data_out(tx_ack)
	);

	bus_cdc #(33, 2, 1) U5
	(
		.clk_src(s_axis_clk),
		.clk_dst(m_axis_clk),
		.trigger(checksum_done),
		.data_in({checksum, checksum_pos, fix_checksum}),
		.data_out({checksum_m, checksum_pos_m, fix_checksum_m})
	);

	loop_fifo #(C_LOOP_FIFO_SIZE) U6
	(
		.m_aclk(m_axis_clk),
		.s_aclk(s_axis_clk),
		.s_aresetn(1'b1),

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast | (s_axis_tvalid & ~s_axis_tready) | overflow),
		.s_axis_tuser(s_axis_tuser[0] | (s_axis_tvalid & ~s_axis_tready) | overflow),
		.s_axis_tvalid(s_axis_tvalid & ~overflow_ack),
		.s_axis_tready(s_axis_tready),

		.m_axis_tdata(m_fifo_tdata),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tuser(m_axis_tuser),
		.m_axis_tvalid(m_fifo_tvalid),
		.m_axis_tready((m_axis_tready & tx_enable) | ~rst_n_m)
	);
endmodule
