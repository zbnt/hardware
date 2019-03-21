/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module tcp_traffic_gen_ctl_tx(
	input logic clk,
	input logic rst_n,

	input logic enable,

	output logic [31:0] m_axis_txc_tdata,
	output logic [3:0] m_axis_txc_tkeep,
	output logic m_axis_txc_tlast,
	output logic m_axis_txc_tvalid,
	input logic m_axis_txc_tready
);
	logic [2:0] count, count_next;

	logic [31:0] m_axis_txc_tdata_next;
	logic m_axis_txc_tlast_next;
	logic m_axis_txc_tvalid_next;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			count <= 3'd0;

			m_axis_txc_tdata <= 32'd0;
			m_axis_txc_tlast <= 0;
			m_axis_txc_tvalid <= 0;
		end else begin
			count <= count_next;

			m_axis_txc_tdata <= m_axis_txc_tdata_next;
			m_axis_txc_tlast <= m_axis_txc_tlast_next;
			m_axis_txc_tvalid <= m_axis_txc_tvalid_next;
		end
	end

	always_comb begin
		count_next = count;

		m_axis_txc_tkeep = 4'hF;
		m_axis_txc_tlast_next = 0;
		m_axis_txc_tdata_next = m_axis_txc_tdata;
		m_axis_txc_tvalid_next = m_axis_txc_tvalid;

		case(count)
			3'd0: begin
				if(enable) begin
					count_next = 3'd1;
					m_axis_txc_tdata_next = {4'b1010, 28'd0};
					m_axis_txc_tvalid_next = 1;
				end
			end

			3'd1: begin
				if(m_axis_txc_tready) begin
					count_next = 3'd2;
					m_axis_txc_tdata_next = {30'd0, 2'b10};
				end
			end

			3'd2: begin
				if(m_axis_txc_tready) begin
					count_next = 3'd3;
					m_axis_txc_tdata_next = {16'd26, 16'd50};
				end
			end

			3'd3: begin
				if(m_axis_txc_tready) begin
					count_next = 3'd4;
					m_axis_txc_tdata_next = 32'd0;
				end
			end

			3'd4: begin
				if(m_axis_txc_tready) begin
					count_next = 3'd5;
					m_axis_txc_tdata_next = 32'd0;
					m_axis_txc_tlast_next = 1;
				end
			end

			3'd5: begin
				if(m_axis_txc_tready) begin
					count_next = 3'd0;
					m_axis_txc_tvalid_next = 0;
				end
			end
		endcase
	end
endmodule
