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
	logic [31:0] bytes_left_req, bytes_left_ack, bytes_queued, mem_size_q, timeout_count;
	logic queue_done;

	logic [31:0] s_fifo_tdata, m_fifo_tdata;
	logic s_fifo_tvalid, m_fifo_tvalid;
	logic s_fifo_tready, m_fifo_tready;

	localparam C_BURST_BYTES = C_MAX_BURST * (C_AXIS_WIDTH / 8);

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_ENABLE;
			irq <= 2'b0;
			mem_ptr <= '0;
			bytes_left_req <= 32'd0;
			bytes_left_ack <= 32'd0;
			bytes_queued <= 32'd0;
			bytes_written <= 32'd0;
			last_msg_end <= 32'd0;
			status_flags <= 4'd0;
			queue_done <= 1'b0;

			s_fifo_tdata <= 32'd0;
			s_fifo_tvalid <= 1'b0;
			m_fifo_tready <= 1'b0;
		end else begin
			irq <= irq & ~clear_irq & enable_irq;
			s_fifo_tvalid <= 1'b0;
			m_fifo_tready <= 1'b0;

			case(state)
				ST_WAIT_ENABLE: begin
					if(enable && irq == 2'd0 && mem_size != 'd0) begin
						state <= ST_WRITE;
						mem_ptr <= mem_base;
						mem_size_q <= mem_size - C_AXIS_WIDTH[31:3];
						bytes_left_req <= mem_size;
						bytes_left_ack <= mem_size;
						bytes_queued <= 32'd0;
						bytes_written <= 32'd0;
						last_msg_end <= 32'd0;
						s_fifo_tdata <= 32'd0;
						queue_done <= 1'b0;
					end
				end

				ST_WRITE: begin
					if(m_axis_s2mm_cmd_tvalid & m_axis_s2mm_cmd_tready) begin
						mem_ptr <= mem_ptr + C_BURST_BYTES;
						bytes_left_req <= bytes_left_req - C_BURST_BYTES;
					end

					if(s_axis_s2mm_tvalid & m_axis_s2mm_tready) begin
						bytes_queued <= bytes_queued + C_AXIS_WIDTH[31:3];
						s_fifo_tvalid <= m_axis_s2mm_tlast & ~queue_done;

						if(s_axis_s2mm_tlast) begin
							s_fifo_tdata <= bytes_queued + C_AXIS_WIDTH[31:3];
						end

						if(bytes_queued == mem_size_q) begin
							queue_done <= 1'b1;
						end
					end

					if(s_axis_s2mm_sts_tvalid) begin
						if(bytes_left_ack != 32'd0) begin
							bytes_written <= bytes_written + C_BURST_BYTES;
							bytes_left_ack <= bytes_left_ack - C_BURST_BYTES;
						end

						m_fifo_tready <= 1'b1;
						status_flags <= {s_axis_s2mm_sts_tdata[6:4], s_axis_s2mm_sts_tdata[7]};
					end

					if(m_fifo_tready & m_fifo_tvalid) begin
						last_msg_end <= m_fifo_tdata;

						if(bytes_left_ack == 32'd0) begin
							state <= ST_WAIT_ENABLE;
							irq[0] <= enable_irq[0];
						end

						if(timeout_count >= timeout) begin
							irq[1] <= enable_irq[1];
						end
					end
				end
			endcase
		end
	end

	always_comb begin
		m_axis_s2mm_tlast = (bytes_queued == mem_size_q || bytes_queued[$clog2(C_BURST_BYTES)-1:$clog2(C_AXIS_WIDTH/8)] == '1);
		s_axis_s2mm_sts_tready = 1'b1;

		m_axis_s2mm_cmd_tdata = {8'b00111111, '0, mem_ptr, 9'd1, C_BURST_BYTES[22:0]};
		m_axis_s2mm_cmd_tvalid = (state == ST_WRITE && bytes_left_req != 32'd0);

		if(state == ST_WRITE && ~queue_done) begin
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
		.rst(~rst_n || irq[1] || state != ST_WRITE),
		.enable(~&timeout_count),
		.count(timeout_count)
	);

	xpm_fifo_axis
	#(
		.CLOCKING_MODE("common_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(256),
		.FIFO_MEMORY_TYPE("block"),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(10),
		.PROG_FULL_THRESH(10),
		.RD_DATA_COUNT_WIDTH(1),
		.TDATA_WIDTH(32),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH(1),
		.USE_ADV_FEATURES("1000"),
		.WR_DATA_COUNT_WIDTH(1)
	)
	U1
	(
		.m_aclk(clk),
		.s_aclk(clk),
		.s_aresetn(rst_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.s_axis_tdata(s_fifo_tdata),
		.s_axis_tlast(1'b0),
		.s_axis_tuser(1'b0),
		.s_axis_tvalid(s_fifo_tvalid),
		.s_axis_tready(s_fifo_tready),

		.m_axis_tdata(m_fifo_tdata),
		.m_axis_tlast(),
		.m_axis_tuser(),
		.m_axis_tvalid(m_fifo_tvalid),
		.m_axis_tready(m_fifo_tready),

		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tstrb(1'b1),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);
endmodule
