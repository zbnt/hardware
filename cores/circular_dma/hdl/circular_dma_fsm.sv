/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module circular_dma_fsm
#(
	parameter C_ADDR_WIDTH = 32,
	parameter C_AXIS_WIDTH = 64,
	parameter C_MAX_BURST = 16,
	parameter C_AXIS_OCCUP_WIDTH = 16
)
(
	input logic clk,
	input logic rst_n,

	input logic fifo_flush_req,
	input logic fifo_flush_ack,
	input logic [C_AXIS_OCCUP_WIDTH-1:0] fifo_occupancy,

	input logic enable,
	input logic [2:0] clear_irq,
	input logic [2:0] enable_irq,
	output logic [2:0] irq,
	output logic [2:0] status_flags,

	input logic [C_ADDR_WIDTH-1:0] mem_base,
	input logic [31:0] mem_size,
	output logic [31:0] bytes_written,
	output logic [31:0] last_msg_end,
	input logic [31:0] timeout,

	// M_AXI

	output logic [C_ADDR_WIDTH-1:0] m_axi_awaddr,
	output logic [7:0] m_axi_awlen,
	output logic m_axi_awvalid,
	input logic m_axi_awready,

	output logic [C_AXIS_WIDTH-1:0] m_axi_wdata,
	output logic m_axi_wlast,
	output logic m_axi_wvalid,
	input logic m_axi_wready,

	input logic [1:0] m_axi_bresp,
	input logic m_axi_bvalid,
	output logic m_axi_bready,

	// S_AXIS_S2MM

	input logic [C_AXIS_WIDTH-1:0] s_axis_s2mm_tdata,
	input logic s_axis_s2mm_tlast,
	input logic s_axis_s2mm_tvalid,
	output logic s_axis_s2mm_tready
);
	enum logic [1:0] {ST_WAIT_ENABLE, ST_WRITE_ADDR, ST_DATA_BURST, ST_WAIT_RESP} state;
	logic [31:0] mem_size_q, timeout_count, last_msg_end_b;
	logic [7:0] burst_count;
	logic counter_rst;

	localparam C_BURST_BYTES = C_MAX_BURST * (C_AXIS_WIDTH / 8);

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_ENABLE;
			irq <= 3'd0;
			mem_size_q <= '0;
			bytes_written <= 32'd0;
			last_msg_end_b <= 32'd0;
			last_msg_end <= 32'd0;
			status_flags <= 3'd0;
			burst_count <= 8'd0;
			counter_rst <= 1'b0;

			m_axi_awaddr <= '0;
			m_axi_awlen <= '0;
			m_axi_awvalid <= 1'b0;
			m_axi_bready <= 1'b0;
		end else begin
			irq <= irq & ~clear_irq & enable_irq;
			counter_rst <= 1'b0;

			case(state)
				ST_WAIT_ENABLE: begin
					if(enable && irq == 3'd0 && mem_size >= C_BURST_BYTES && (~fifo_flush_req | ~fifo_flush_ack)) begin
						state <= ST_WRITE_ADDR;
						mem_size_q <= mem_size - C_BURST_BYTES;
						bytes_written <= 32'd0;
						last_msg_end <= 32'd0;
						status_flags <= 3'd1;
						burst_count <= 8'd0;
						counter_rst <= 1'b1;

						m_axi_awaddr <= mem_base;
					end
				end

				ST_WRITE_ADDR: begin
					if(~m_axi_awvalid) begin
						if(fifo_occupancy >= C_MAX_BURST) begin
							m_axi_awlen <= C_MAX_BURST[7:0] - 8'd1;
							m_axi_awvalid <= 1'b1;
						end else if(fifo_flush_req) begin
							if(fifo_occupancy != 'd0) begin
								m_axi_awlen <= fifo_occupancy[7:0] - 8'd1;
								m_axi_awvalid <= 1'b1;
							end else if(fifo_flush_ack) begin
								state <= ST_WAIT_ENABLE;
								irq[0] <= enable_irq[0];
								status_flags[0] <= 1'b0;
							end
						end
					end else if(m_axi_awready) begin
						state <= ST_DATA_BURST;
						m_axi_awaddr <= m_axi_awaddr + C_BURST_BYTES;
						m_axi_awvalid <= 1'b0;
					end
				end

				ST_DATA_BURST: begin
					if(m_axi_wvalid & m_axi_wready) begin
						burst_count <= burst_count + 8'd1;

						if(s_axis_s2mm_tlast) begin
							last_msg_end_b <= bytes_written + {{(24-$clog2(C_AXIS_WIDTH/8)){1'b0}}, burst_count + 8'd1, {($clog2(C_AXIS_WIDTH/8)){1'b0}}};
						end

						if(m_axi_wlast) begin
							state <= ST_WAIT_RESP;
							burst_count <= 8'd0;
							m_axi_bready <= 1'b1;
						end
					end
				end

				ST_WAIT_RESP: begin
					if(m_axi_bvalid) begin
						m_axi_bready <= 1'b0;

						if(~m_axi_bresp[1]) begin
							last_msg_end <= last_msg_end_b;
							bytes_written <= bytes_written + {{(24-$clog2(C_AXIS_WIDTH/8)){1'b0}}, m_axi_awlen + 8'd1, {($clog2(C_AXIS_WIDTH/8)){1'b0}}};

							if(bytes_written == mem_size_q || (fifo_flush_req & fifo_flush_ack)) begin
								state <= ST_WAIT_ENABLE;
								irq[0] <= enable_irq[0];
								status_flags[0] <= 1'b0;
							end else begin
								state <= ST_WRITE_ADDR;

								if(timeout_count >= timeout) begin
									irq[1] <= enable_irq[1];
								end
							end
						end else begin
							state <= ST_WAIT_ENABLE;
							irq[2] <= enable_irq[2];
							status_flags <= {m_axi_bresp[0], ~m_axi_bresp[0], 1'b0};
						end
					end
				end
			endcase
		end
	end

	always_comb begin
		if(state == ST_DATA_BURST) begin
			m_axi_wdata = s_axis_s2mm_tdata;
			m_axi_wvalid = s_axis_s2mm_tvalid;
			m_axi_wlast = (m_axi_awlen == burst_count);
			s_axis_s2mm_tready = m_axi_wready;
		end else begin
			m_axi_wdata = '0;
			m_axi_wvalid = 1'b0;
			m_axi_wlast = 1'b0;
			s_axis_s2mm_tready = 1'b0;
		end
	end

	counter_big #(32) U0
	(
		.clk(clk),
		.rst(~rst_n | irq[1] | counter_rst),
		.enable(~&timeout_count),
		.count(timeout_count)
	);
endmodule
