/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_mm_fifo_mm2s
#(
	parameter C_WIDTH = 64,
	parameter C_START_ADDR = 0,
	parameter C_END_ADDR = 134217727
)
(
	input logic clk,
	input logic rst_n,

	input logic enable,
	output logic busy,

	output logic [$clog2(C_END_ADDR+1)-1:0] mem_ptr,

	// M_AXI

	output logic [$clog2(C_END_ADDR+1)-1:0] m_axi_araddr,
	output logic [7:0] m_axi_arlen,
	output logic m_axi_arvalid,
	input logic m_axi_arready,

	input logic [C_WIDTH-1:0] m_axi_rdata,
	input logic [1:0] m_axi_rresp,
	input logic m_axi_rlast,
	input logic m_axi_rvalid,
	output logic m_axi_rready,

	// M_AXIS

	output logic [C_WIDTH-1:0] m_axis_tdata,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [2:0] {ST_IDLE, ST_SET_ADDR, ST_READ_TVALID, ST_READ_TLAST, ST_READ_TDATA} state, state_next;
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
					state_next = ST_SET_ADDR;
				end
			end

			ST_SET_ADDR: begin
				if(m_axi_arvalid & m_axi_arready) begin
					state_next = ST_READ_TVALID;
				end
			end

			ST_READ_TVALID: begin
				if(m_axi_rvalid & m_axi_rready) begin
					state_next = ST_READ_TLAST;
				end
			end

			ST_READ_TLAST: begin
				if(m_axi_rvalid & m_axi_rready) begin
					state_next = ST_READ_TDATA;
				end
			end

			ST_READ_TDATA: begin
				if(m_axi_rvalid & m_axi_rready & m_axi_rlast) begin
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
			if(state == ST_READ_TDATA && state_next == ST_IDLE) begin
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
			m_axi_araddr <= '0;
			m_axi_arlen <= '0;
			m_axi_arvalid <= 1'b0;
		end else begin
			if(state_next == ST_SET_ADDR) begin
				m_axi_araddr <= mem_ptr;
				m_axi_arlen <= C_WIDTH - 1;
				m_axi_arvalid <= 1'b1;
			end else begin
				m_axi_araddr <= '0;
				m_axi_arlen <= '0;
				m_axi_arvalid <= 1'b0;
			end
		end
	end

	// Read channel

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			flags_last <= '0;
			flags_valid <= '0;
		end else begin
			if(state == ST_READ_TVALID) begin
				flags_valid <= m_axi_rdata;
			end

			if(state == ST_READ_TLAST) begin
				flags_last <= m_axi_rdata;
			end

			if(state == ST_READ_TDATA && m_axi_arvalid && m_axi_arready) begin
				flags_valid <= {1'b0, flags_valid[C_WIDTH-3:1]};
				flags_last <= {1'b0, flags_last[C_WIDTH-3:1]};
			end
		end
	end

	always_comb begin
		case(state)
			ST_READ_TVALID: begin
				m_axi_rready = 1'b1;

				m_axis_tdata = '0;
				m_axis_tlast = 1'b0;
				m_axis_tvalid = 1'b0;
			end

			ST_READ_TLAST: begin
				m_axi_rready = 1'b1;

				m_axis_tdata = '0;
				m_axis_tlast = 1'b0;
				m_axis_tvalid = 1'b0;
			end

			ST_READ_TDATA: begin
				m_axi_rready = m_axis_tready | ~flags_valid[0];

				m_axis_tdata = m_axi_rdata;
				m_axis_tlast = flags_last[0];
				m_axis_tvalid = flags_valid[0];
			end

			default: begin
				m_axi_rready = 1'b0;

				m_axis_tdata = '0;
				m_axis_tlast = 1'b0;
				m_axis_tvalid = 1'b0;
			end
		endcase
	end
endmodule
