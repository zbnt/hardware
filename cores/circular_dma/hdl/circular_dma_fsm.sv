/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module circular_dma_fsm #(parameter C_ADDR_WIDTH = 32, parameter C_AXIS_WIDTH = 64, parameter C_MAX_BURST = 16)
(
	input logic clk,
	input logic rst_n,

	input logic enable,
	input logic [1:0] clear_irq,
	input logic [1:0] enable_irq,

	output logic [1:0] irq,
	output logic [3:0] status_flags,

	input logic [C_ADDR_WIDTH-1:0] mem_base,
	input logic [31:0] mem_size,
	output logic [31:0] bytes_written,
	output logic [31:0] last_msg_end,
	input logic [31:0] timeout,

	// S_AXIS_S2MM

	input logic [C_AXIS_WIDTH-1:0] s_axis_s2mm_tdata,
	input logic s_axis_s2mm_tlast,
	input logic s_axis_s2mm_tvalid,
	output logic s_axis_s2mm_tready,

	// S_AXIS_S2MM_STS

	input logic [7:0] s_axis_s2mm_sts_tdata,
	input logic [0:0] s_axis_s2mm_sts_tkeep,
	input logic s_axis_s2mm_sts_tlast,
	input logic s_axis_s2mm_sts_tvalid,
	output logic s_axis_s2mm_sts_tready,

	// M_AXIS_S2MM

	output logic [C_AXIS_WIDTH-1:0] m_axis_s2mm_tdata,
	output logic m_axis_s2mm_tlast,
	output logic m_axis_s2mm_tvalid,
	input logic m_axis_s2mm_tready,

	// M_AXIS_S2MM_CMD

	output logic [C_ADDR_WIDTH+47:0] m_axis_s2mm_cmd_tdata,
	output logic m_axis_s2mm_cmd_tvalid,
	input logic m_axis_s2mm_cmd_tready
);
	enum logic {ST_WAIT_ENABLE, ST_WRITE} state;
	logic [C_ADDR_WIDTH-1:0] mem_ptr;
	logic [31:0] bytes_left, mem_size_q, timeout_count;

	localparam C_MAX_BYTES = C_MAX_BURST * (C_AXIS_WIDTH / 8);

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_ENABLE;
			irq <= 2'b0;
			mem_ptr <= '0;
			bytes_left <= 32'd0;
			bytes_written <= 32'd0;
			last_msg_end <= 32'd0;
			status_flags <= 4'd0;

			m_axis_s2mm_cmd_tdata <= '0;
			m_axis_s2mm_cmd_tvalid <= 1'b0;
		end else begin
			irq <= irq & ~clear_irq & enable_irq;

			if(s_axis_s2mm_sts_tvalid) begin
				status_flags <= {s_axis_s2mm_sts_tdata[6:4], s_axis_s2mm_sts_tdata[7]};
			end

			case(state)
				ST_WAIT_ENABLE: begin
					if(enable && irq == 2'd0 && mem_size != 'd0) begin
						state <= ST_WRITE;
						mem_ptr <= mem_base;
						mem_size_q <= mem_size - C_AXIS_WIDTH[31:3];
						bytes_left <= mem_size;
						bytes_written <= 32'd0;
						last_msg_end <= 32'd0;
					end
				end

				ST_WRITE: begin
					if(m_axis_s2mm_cmd_tready) begin
						if(bytes_left != 24'd0) begin
							if(bytes_left <= C_MAX_BYTES) begin
								m_axis_s2mm_cmd_tdata <= {8'b00111111, '0, mem_ptr, 9'd1, bytes_left[22:0]};
								m_axis_s2mm_cmd_tvalid <= 1'b1;

								bytes_left <= 32'd0;
							end else begin
								m_axis_s2mm_cmd_tdata <= {8'b00111111, '0, mem_ptr, 9'd1, C_MAX_BYTES[22:0]};
								m_axis_s2mm_cmd_tvalid <= 1'b1;

								mem_ptr <= mem_ptr + C_MAX_BYTES;
								bytes_left <= bytes_left - C_MAX_BYTES;
							end
						end else begin
							m_axis_s2mm_cmd_tvalid <= 1'b0;
						end
					end

					if(s_axis_s2mm_tvalid & m_axis_s2mm_tready) begin
						bytes_written <= bytes_written + C_AXIS_WIDTH[31:3];

						if(s_axis_s2mm_sts_tlast) begin
							last_msg_end <= bytes_written + C_AXIS_WIDTH[31:3];

							if(timeout_count >= timeout) begin
								irq[1] <= enable_irq[1];
							end
						end

						if(bytes_written == mem_size_q) begin
							state <= ST_WAIT_ENABLE;
							irq[0] <= enable_irq[0];
						end
					end
				end
			endcase
		end
	end

	always_comb begin
		m_axis_s2mm_tlast = (bytes_written == mem_size_q || bytes_written[$clog2(C_MAX_BYTES)-1:$clog2(C_AXIS_WIDTH/8)] == '1);
		s_axis_s2mm_sts_tready = 1'b1;

		if(state == ST_WRITE) begin
			m_axis_s2mm_tdata = s_axis_s2mm_tdata;
			m_axis_s2mm_tvalid = s_axis_s2mm_tvalid;
			s_axis_s2mm_tready = m_axis_s2mm_tready;
		end else begin
			m_axis_s2mm_tdata = '0;
			m_axis_s2mm_tvalid = 1'b0;
			s_axis_s2mm_tready = 1'b0;
		end
	end

	counter_big #(32) U0
	(
		.clk(clk),
		.rst(~rst_n | irq[1]),
		.enable(~&timeout_count),
		.count(timeout_count)
	);
endmodule
