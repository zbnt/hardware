/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module tcp_traffic_gen_tx(
	input logic clk,
	input logic rst_n,

	input logic enable,

	input logic [31:0] frame_headers[0:13],
	input logic [31:0] ip_options[0:10],
	input logic [3:0] num_options,
	input logic [15:0] data_len,
	input logic [15:0] word_cycles,

	// M_AXIS_TXD : AXI4-Stream master interface (data)

	output logic [31:0] m_axis_txd_tdata,
	output logic [3:0] m_axis_txd_tkeep,
	output logic m_axis_txd_tlast,
	output logic m_axis_txd_tvalid,
	input logic m_axis_txd_tready,

	// M_AXIS_TXC : AXI4-Stream master interface (control)

	output logic [31:0] m_axis_txc_tdata,
	output logic [3:0] m_axis_txc_tkeep,
	output logic m_axis_txc_tlast,
	output logic m_axis_txc_tvalid,
	input logic m_axis_txc_tready
);
	enum logic [1:0] {ST_IDLE, ST_TX_HEADERS, ST_TX_TCP_OPTS, ST_TX_DATA} state, state_next;

	logic [15:0] count_c, count_c_next;
	logic [15:0] count_w, count_w_next;
	logic word_sent, word_sent_next;

	logic [31:0] m_axis_txd_tdata_next;
	logic [3:0] m_axis_txd_tkeep_next;
	logic m_axis_txd_tlast_next;
	logic m_axis_txd_tvalid_next;

	logic [31:0] lfsr_val;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			state <= ST_IDLE;
			count_c <= 16'd0;
			count_w <= 16'd0;
			word_sent <= 0;

			m_axis_txd_tdata <= 32'd0;
			m_axis_txd_tkeep <= 4'd0;
			m_axis_txd_tlast <= 0;
			m_axis_txd_tvalid <= 0;
		end else begin
			state <= state_next;
			count_c <= count_c_next;
			count_w <= count_w_next;
			word_sent <= word_sent_next;

			m_axis_txd_tdata <= m_axis_txd_tdata_next;
			m_axis_txd_tkeep <= m_axis_txd_tkeep_next;
			m_axis_txd_tlast <= m_axis_txd_tlast_next;
			m_axis_txd_tvalid <= m_axis_txd_tvalid_next;
		end
	end

	always_comb begin
		state_next = state;
		count_c_next = count_c + 15'd1;
		count_w_next = count_w;
		word_sent_next = word_sent;

		m_axis_txd_tdata_next = m_axis_txd_tdata;
		m_axis_txd_tkeep_next = m_axis_txd_tkeep;
		m_axis_txd_tlast_next = m_axis_txd_tlast;
		m_axis_txd_tvalid_next = m_axis_txd_tvalid;

		case(state)
			ST_IDLE: begin
				if(enable) begin
					state_next = ST_TX_HEADERS;

					count_w_next = 16'd1;
					count_c_next = 16'd0;
					word_sent_next = 0;

					m_axis_txd_tdata_next = frame_headers[0];
					m_axis_txd_tkeep_next = 4'hF;
					m_axis_txd_tlast_next = 0;
					m_axis_txd_tvalid_next = 1;
				end else begin
					m_axis_txd_tvalid_next = 0;
				end
			end

			ST_TX_HEADERS: begin
				if(m_axis_txd_tready | word_sent) begin
					if(count_c >= word_cycles) begin
						word_sent_next = 0;
						count_c_next = 16'd0;
						m_axis_txd_tvalid_next = 1;

						if(count_w <= 16'd12) begin
							count_w_next = count_w + 16'd1;
							m_axis_txd_tdata_next = frame_headers[count_w];
						end else if(num_options != 4'd0) begin
							state_next = ST_TX_TCP_OPTS;
							count_w_next = 16'd1;

							m_axis_txd_tdata_next = {ip_options[0][23:16], ip_options[0][31:24], frame_headers[13][15:0]};
						end else if(data_len > 4'd2) begin
							state_next = ST_TX_DATA;
							count_w_next = data_len - 4'd2;

							m_axis_txd_tdata_next = {lfsr_val[15:0], frame_headers[13][15:0]};
						end else begin
							state_next = ST_IDLE;

							m_axis_txd_tdata_next = {lfsr_val[15:0], frame_headers[13][15:0]};
							m_axis_txd_tkeep_next = {data_len == 16'd2, data_len >= 16'd1, 2'b11};
							m_axis_txd_tlast_next = 1;
						end
					end else begin
						word_sent_next = 1;
						m_axis_txd_tvalid_next = 0;
					end
				end
			end

			ST_TX_TCP_OPTS: begin
				if(m_axis_txd_tready | word_sent) begin
					if(count_c >= word_cycles) begin
						word_sent_next = 0;
						count_c_next = 16'd0;
						m_axis_txd_tvalid_next = 1;

						if(count_w < num_options) begin
							count_w_next = count_w + 16'd1;
							m_axis_txd_tdata_next = {ip_options[count_w][23:16], ip_options[count_w][31:24], ip_options[count_w-1][7:0], ip_options[count_w-1][15:8]};
						end else if(data_len > 4'd2) begin
							state_next = ST_TX_DATA;
							count_w_next = data_len - 4'd2;

							m_axis_txd_tdata_next = {lfsr_val[15:0], ip_options[count_w][23:16], ip_options[count_w][31:24]};
						end else begin
							state_next = ST_IDLE;

							m_axis_txd_tdata_next = {lfsr_val[15:0], ip_options[count_w][23:16], ip_options[count_w][31:24]};
							m_axis_txd_tkeep_next = {data_len == 16'd2, data_len >= 16'd1, 2'b11};
							m_axis_txd_tlast_next = 1;
						end
					end else begin
						word_sent_next = 1;
						m_axis_txd_tvalid_next = 0;
					end
				end
			end

			ST_TX_DATA: begin
				if(m_axis_txd_tready | word_sent) begin
					if(count_c >= word_cycles) begin
						word_sent_next = 0;
						count_c_next = 16'd0;
						m_axis_txd_tvalid_next = 1;
						m_axis_txd_tdata_next = lfsr_val;

						case(count_w)
							4'd1: begin
								m_axis_txd_tkeep_next = 4'b0001;
							end

							4'd2: begin
								m_axis_txd_tkeep_next = 4'b0011;
							end

							4'd3: begin
								m_axis_txd_tkeep_next = 4'b0111;
							end

							default: begin
								m_axis_txd_tkeep_next = 4'b1111;
							end
						endcase

						if(count_w <= 4'd4) begin
							state_next = ST_IDLE;
							count_w_next = 16'd0;
							m_axis_txd_tlast_next = 1;
						end else begin
							count_w_next = count_w - 16'd4;
						end
					end else begin
						word_sent_next = 1;
						m_axis_txd_tvalid_next = 0;
					end
				end
			end
		endcase
	end

	lfsr_32 U0
	(
		.clk(clk),
		.rst(~rst_n),
		.value(lfsr_val)
	);

	tcp_traffic_gen_ctl_tx U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.enable(state == ST_IDLE && enable),

		.m_axis_txc_tdata(m_axis_txc_tdata),
		.m_axis_txc_tkeep(m_axis_txc_tkeep),
		.m_axis_txc_tlast(m_axis_txc_tlast),
		.m_axis_txc_tvalid(m_axis_txc_tvalid),
		.m_axis_txc_tready(m_axis_txc_tready)
	);
endmodule
