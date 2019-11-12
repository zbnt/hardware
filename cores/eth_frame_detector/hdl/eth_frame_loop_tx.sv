/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_tx
(
	input logic clk,
	input logic rst_n,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tuser,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready,

	// S_AXIS_FRAME

	input logic [7:0] s_axis_frame_tdata,
	input logic s_axis_frame_tuser,
	input logic s_axis_frame_tlast,
	input logic s_axis_frame_tvalid,
	output logic s_axis_frame_tready,

	// S_AXIS_CSUM

	input logic [31:0] s_axis_csum_tdata,
	input logic s_axis_csum_tvalid,
	output logic s_axis_csum_tready
);
	logic tx_enable;

	logic [15:0] checksum, count;
	logic [14:0] checksum_pos;
	logic fix_checksum;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			count <= 16'd0;
			tx_enable <= 1'b0;

			s_axis_csum_tready <= 1'b0;

			checksum <= 16'd0;
			checksum_pos <= 15'd0;
			fix_checksum <= 1'b0;
		end else begin
			if(~tx_enable) begin
				s_axis_csum_tready <= 1'b1;

				if(s_axis_csum_tvalid & s_axis_csum_tready) begin
					count <= 16'd0;
					tx_enable <= 1'b1;

					s_axis_csum_tready <= 1'b0;

					checksum <= s_axis_csum_tdata[31:16];
					checksum_pos <= s_axis_csum_tdata[15:1];
					fix_checksum <= s_axis_csum_tdata[0];
				end
			end else begin
				if(s_axis_frame_tvalid & m_axis_tready) begin
					if(m_axis_tlast) begin
						tx_enable <= 1'b0;
						s_axis_csum_tready <= 1'b1;
					end else begin
						count <= count + 16'd1;
					end
				end
			end
		end
	end

	always_comb begin
		s_axis_frame_tready = m_axis_tready & tx_enable;

		m_axis_tvalid = s_axis_frame_tvalid & tx_enable;
		m_axis_tlast = s_axis_frame_tlast;
		m_axis_tuser = s_axis_frame_tuser;

		if(fix_checksum && checksum != 16'd0 && count[15:1] == checksum_pos) begin
			if(count[0]) begin
				m_axis_tdata = checksum[15:8];
			end else begin
				m_axis_tdata = checksum[7:0];
			end
		end else begin
			m_axis_tdata = s_axis_frame_tdata;
		end
	end
endmodule
