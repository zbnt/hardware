/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_mm_fifo_s2mm
#(
	parameter C_WIDTH = 64,
	parameter C_START_ADDR = 0,
	parameter C_END_ADDR = 134217727,
	parameter C_AVAIL_WIDTH = 16
)
(
	input logic clk,
	input logic rst_n,

	input logic enable,
	output logic busy,

	input logic [C_AVAIL_WIDTH-1:0] values_available,
	output logic [$clog2(C_END_ADDR+1)-1:0] mem_ptr,

	// M_AXI

	output logic [$clog2(C_END_ADDR+1)-1:0] m_axi_awaddr,
	output logic [7:0] m_axi_awlen,
	output logic m_axi_awvalid,
	input logic m_axi_awready,

	output logic [C_WIDTH-1:0] m_axi_wdata,
	output logic m_axi_wlast,
	output logic m_axi_wvalid,
	input logic m_axi_wready,

	input logic [1:0] m_axi_bresp,
	input logic m_axi_bvalid,
	output logic m_axi_bready,

	// S_AXIS

	input logic [C_WIDTH-1:0] s_axis_tdata,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready
);
	enum logic [2:0] {ST_IDLE, ST_ADDR_A, ST_WRITE_A, ST_RESP_A, ST_ADDR_B, ST_WRITE_B, ST_RESP_B} state, state_next;
	logic [$clog2(C_WIDTH)-1:0] values_written, values_to_write;
	logic [C_WIDTH-3:0] flags_valid, flags_last;

	// State

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;
		end else begin
			state <= state_next;
		end
	end

	always_comb begin
		state_next = state;
		busy = (state != ST_IDLE);

		case(state)
			ST_IDLE: begin
				if(enable) begin
					state_next = ST_ADDR_A;
				end
			end

			ST_ADDR_A: begin
				if(m_axi_awvalid & m_axi_awready) begin
					state_next = ST_WRITE_A;
				end
			end

			ST_WRITE_A: begin
				if(values_written == C_WIDTH - 2 && m_axi_wvalid && m_axi_wready) begin
					state_next = ST_RESP_A;
				end
			end

			ST_RESP_A: begin
				if(m_axi_bvalid & m_axi_bready) begin
					state_next = ST_ADDR_B;
				end
			end

			ST_ADDR_B: begin
				if(m_axi_awvalid & m_axi_awready) begin
					state_next = ST_WRITE_B;
				end
			end

			ST_WRITE_B: begin
				if(values_written == 'd2 && m_axi_wvalid && m_axi_wready) begin
					state_next = ST_RESP_B;
				end
			end

			ST_RESP_B: begin
				if(m_axi_bvalid & m_axi_bready) begin
					state_next = ST_IDLE;
				end
			end
		endcase
	end

	// Pointer

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			mem_ptr <= C_START_ADDR;
		end else begin
			if(state == ST_RESP_B && m_axi_bvalid && m_axi_bready) begin
				if(mem_ptr / (C_WIDTH*(C_WIDTH/8)) == C_END_ADDR / (C_WIDTH*(C_WIDTH/8))) begin
					mem_ptr <= C_START_ADDR;
				end else begin
					mem_ptr <= mem_ptr + C_WIDTH*(C_WIDTH/8);
				end
			end
		end
	end

	// Address channel

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			m_axi_awaddr <= '0;
			m_axi_awlen <= '0;
			m_axi_awvalid <= 1'b0;
		end else begin
			m_axi_awvalid <= (state_next == ST_ADDR_A || state_next == ST_ADDR_B);

			if(state_next == ST_ADDR_A) begin
				m_axi_awaddr <= mem_ptr | (2 * (C_WIDTH/8));
				m_axi_awlen <= C_WIDTH - 3;
			end

			if(state_next == ST_ADDR_B) begin
				m_axi_awaddr <= mem_ptr;
				m_axi_awlen <= 'd1;
			end
		end
	end

	// Write channel

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			flags_last <= '0;
			flags_valid <= '0;

			values_written <= '0;
			values_to_write <= '0;
		end else begin
			if(state == ST_WRITE_A && m_axi_wvalid && m_axi_wready) begin
				flags_valid <= {s_axis_tready, flags_valid[C_WIDTH-3:1]};
				flags_last <= {s_axis_tlast, flags_last[C_WIDTH-3:1]};
			end

			if(state == ST_ADDR_A || state == ST_ADDR_B) begin
				values_written <= 'd1;
			end

			if((state == ST_WRITE_A || state == ST_WRITE_B) && m_axi_wvalid && m_axi_wready) begin
				values_written <= values_written + 'd1;
			end

			if(state == ST_IDLE) begin
				if(values_available >= C_WIDTH - 2) begin
					values_to_write <= C_WIDTH - 2;
				end else begin
					values_to_write <= values_available;
				end
			end
		end
	end

	always_comb begin
		case(state)
			ST_WRITE_A: begin
				m_axi_wlast = (values_written == values_to_write);

				if(values_written > values_to_write) begin
					m_axi_wdata = 1'b0;
					m_axi_wvalid = 1'b1;
					s_axis_tready = 1'b0;
				end else begin
					m_axi_wdata = s_axis_tdata;
					m_axi_wvalid = s_axis_tvalid;
					s_axis_tready = m_axi_wready;
				end
			end

			ST_WRITE_B: begin
				if(values_written[0]) begin
					m_axi_wdata = {2'b0, flags_valid};
					m_axi_wlast = 1'b0;
				end else begin
					m_axi_wdata = {2'b0, flags_last};
					m_axi_wlast = 1'b1;
				end

				m_axi_wvalid = 1'b1;
				s_axis_tready = 1'b0;
			end

			default: begin
				m_axi_wdata = '0;
				m_axi_wvalid = 1'b0;
				m_axi_wlast = 1'b0;
				s_axis_tready = 1'b0;
			end
		endcase
	end

	// Response channel

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			m_axi_bready <= 1'b0;
		end else begin
			m_axi_bready <= (state_next == ST_RESP_A || state_next == ST_RESP_B);
		end
	end
endmodule
