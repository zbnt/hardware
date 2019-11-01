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

	logic rst_n_s;
	logic mode_s, mode_s_q;

	logic [15:0] checksum, checksum_pos;
	logic checksum_done, checksum_ready;

	logic [1:0] overflow;
	logic s_axis_tready, s_axis_tvalid_last;

	transport_checksum U0
	(
		.clk(s_axis_clk),
		.rst_n(rst_n_s),

		.checksum(checksum),
		.checksum_orig(),
		.checksum_pos(checksum_pos),
		.checksum_done(checksum_done),

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast | (s_axis_tvalid & ~s_axis_tready) | (~s_axis_tvalid_last & s_axis_tvalid & ~mode_s_q)),
		.s_axis_tvalid(mode_s_q ? (s_axis_tvalid && overflow == 2'd0) : (~s_axis_tvalid_last & s_axis_tvalid))
	);

	always_ff @(posedge s_axis_clk) begin
		if(~rst_n_s) begin
			mode_s_q <= 1'b0;
			overflow <= 2'b0;
			s_axis_tvalid_last <= 1'b0;
		end else begin
			s_axis_tvalid_last <= s_axis_tvalid;

			if(s_axis_tvalid) begin
				if(~s_axis_tready) begin
					overflow[0] <= 1'b1;
				end else if(s_axis_tlast) begin
					overflow[0] <= 1'b0;
				end
			end

			if(~checksum_ready) begin
				overflow[1] <= 1'b1;
			end else if(s_axis_tvalid & s_axis_tlast) begin
				overflow[1] <= 1'b0;
			end

			if(~s_axis_tvalid) begin
				mode_s_q <= mode_s;
			end
		end
	end

	// m_axis_clk clock domain

	logic rst_n_m;
	logic tx_enable;

	logic m_fifo_frame_tready;
	logic m_fifo_frame_tvalid;
	logic [7:0] m_fifo_frame_tdata;

	logic m_fifo_csum_tready;
	logic m_fifo_csum_tvalid;
	logic [31:0] m_fifo_csum_tdata;

	logic [15:0] checksum_m, count;
	logic [14:0] checksum_pos_m;
	logic fix_checksum_m;

	always_ff @(posedge m_axis_clk) begin
		if(~rst_n_m) begin
			count <= 16'd0;
			tx_enable <= 1'b0;

			m_fifo_csum_tready <= 1'b0;
			m_fifo_frame_tready <= 1'b0;
		end else begin
			if(~tx_enable) begin
				m_fifo_csum_tready <= 1'b1;

				if(m_fifo_csum_tvalid & m_fifo_csum_tready) begin
					count <= 16'd0;
					tx_enable <= 1'b1;

					m_fifo_csum_tready <= 1'b0;
					m_fifo_frame_tready <= 1'b1;

					checksum_m <= m_fifo_csum_tdata[31:16];
					checksum_pos_m <= m_fifo_csum_tdata[15:1];
					fix_checksum_m <= m_fifo_csum_tdata[0];
				end
			end else begin
				if(m_fifo_frame_tvalid & m_axis_tready) begin
					if(m_axis_tlast) begin
						tx_enable <= 1'b0;
						m_fifo_csum_tready <= 1'b1;
						m_fifo_frame_tready <= 1'b0;
					end else begin
						count <= count + 16'd1;
					end
				end
			end
		end
	end

	always_comb begin
		m_axis_tvalid = m_fifo_frame_tvalid & tx_enable;

		if(fix_checksum_m && checksum_m != 16'd0 && count[15:1] == checksum_pos_m) begin
			if(count[0]) begin
				m_axis_tdata = checksum_m[15:8];
			end else begin
				m_axis_tdata = checksum_m[7:0];
			end
		end else begin
			m_axis_tdata = m_fifo_frame_tdata;
		end
	end

	// CDC

	sync_ffs #(2, 2) U1
	(
		.clk_src(clk),
		.clk_dst(s_axis_clk),
		.data_in({mode, rst_n}),
		.data_out({mode_s, rst_n_s})
	);

	sync_ffs #(1, 2) U2
	(
		.clk_src(clk),
		.clk_dst(m_axis_clk),
		.data_in(rst_n),
		.data_out(rst_n_m)
	);

	loop_fifo #(C_LOOP_FIFO_SIZE) U3
	(
		.m_aclk(m_axis_clk),
		.s_aclk(s_axis_clk),
		.s_aresetn(1'b1),

		.s_axis_frame_tdata(s_axis_tdata),
		.s_axis_frame_tlast(s_axis_tlast | (s_axis_tvalid & ~s_axis_tready)),
		.s_axis_frame_tuser(s_axis_tuser[0] | (s_axis_tvalid & ~s_axis_tready)),
		.s_axis_frame_tvalid(s_axis_tvalid && overflow == 2'd0),
		.s_axis_frame_tready(s_axis_tready),

		.m_axis_frame_tdata(m_fifo_frame_tdata),
		.m_axis_frame_tlast(m_axis_tlast),
		.m_axis_frame_tuser(m_axis_tuser),
		.m_axis_frame_tvalid(m_fifo_frame_tvalid),
		.m_axis_frame_tready(m_fifo_frame_tready & m_axis_tready),

		.s_axis_csum_tdata({checksum, checksum_pos[15:1], s_axis_tuser[1] && mode_s_q && overflow == 2'd0}),
		.s_axis_csum_tvalid(checksum_done),
		.s_axis_csum_tready(checksum_ready),

		.m_axis_csum_tdata(m_fifo_csum_tdata),
		.m_axis_csum_tvalid(m_fifo_csum_tvalid),
		.m_axis_csum_tready(m_fifo_csum_tready)
	);
endmodule
