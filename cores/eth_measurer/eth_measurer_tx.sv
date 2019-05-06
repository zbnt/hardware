/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_measurer_tx #(parameter src_mac, parameter identifier)
(
	input logic clk,
	input logic rst,
	input logic trigger,
	output logic tx_begin,

	// Config

	input logic [15:0] padding_size,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [1:0] {ST_WAIT_TRIGGER, ST_SEND_HEADERS, ST_SEND_PADDING} state, state_next;

	logic [15:0] count, count_next;
	logic [143:0] tx_buffer, tx_buffer_next;

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= ST_WAIT_TRIGGER;
			count <= 16'd0;
			tx_buffer <= '0;
		end else begin
			state <= state_next;
			count <= count_next;
			tx_buffer <= tx_buffer_next;
		end
	end

	always_comb begin
		state_next = state;
		count_next = count;
		tx_buffer_next = tx_buffer;

		m_axis_tvalid = 1'b0;
		m_axis_tdata = 8'd0;
		m_axis_tlast = 1'b0;
		m_axis_tkeep = 1'b1;

		tx_begin = (state == ST_SEND_HEADERS && count == 16'd0 && m_axis_tready);

		if(~rst) begin
			case(state)
				ST_WAIT_TRIGGER: begin
					m_axis_tvalid = 1'b0;
					m_axis_tdata = 8'd0;
					m_axis_tlast = 1'b0;

					if(trigger) begin
						state_next = ST_SEND_HEADERS;
						count_next = 16'd0;
						tx_buffer_next = {48'hFF_FF_FF_FF_FF_FF, src_mac, padding_size + 16'd4, identifier};
					end
				end

				ST_SEND_HEADERS: begin
					m_axis_tvalid = 1'b1;
					m_axis_tdata = tx_buffer[143:136];
					m_axis_tlast = 1'b0;

					if(m_axis_tready) begin
						count_next = count + 16'd1;
						tx_buffer_next = {tx_buffer[135:0], 8'd0};

						if(count >= 16'd17) begin
							count_next = 16'd0;

							if(padding_size != 16'd0) begin
								state_next = ST_SEND_PADDING;
							end else begin
								state_next = ST_WAIT_TRIGGER;
							end
						end
					end
				end

				ST_SEND_PADDING: begin
					m_axis_tvalid = 1'b1;
					m_axis_tdata = 8'h20;
					m_axis_tlast = (count >= padding_size - 16'd1);

					if(m_axis_tready) begin
						count_next = count + 16'd1;

						if(count >= padding_size - 16'd1) begin
							count_next = 16'd0;
							state_next = ST_WAIT_TRIGGER;
						end
					end
				end

				default: begin
					state_next = ST_WAIT_TRIGGER;
				end
			endcase
		end
	end
endmodule
