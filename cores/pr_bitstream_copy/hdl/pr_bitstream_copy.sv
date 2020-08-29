/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module pr_bitstream_copy
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_AXI_ADDR_WIDTH = 32,

	parameter C_SOURCE_ADDR = 32'h01000000,
	parameter C_DESTINATION_ADDR = 32'h00000000
)
(
	input logic clk,
	input logic rst_n,

	input logic [C_AXI_ADDR_WIDTH-1:0] bytes_total,

	output logic ready,
	output logic error,

	// M_AXI_SRC

	output logic [C_AXI_ADDR_WIDTH-1:0] m_axi_src_araddr,
	output logic [7:0] m_axi_src_arlen,
	output logic [2:0] m_axi_src_arsize,
	output logic m_axi_src_arvalid,
	input logic m_axi_src_arready,

	input logic [C_AXI_WIDTH-1:0] m_axi_src_rdata,
	input logic [1:0] m_axi_src_rresp,
	input logic m_axi_src_rvalid,
	input logic m_axi_src_rlast,
	output logic m_axi_src_rready,

	// M_AXI_DST

	output logic [C_AXI_ADDR_WIDTH-1:0] m_axi_dst_awaddr,
	output logic [7:0] m_axi_dst_awlen,
	output logic [2:0] m_axi_dst_awsize,
	output logic m_axi_dst_awvalid,
	input logic m_axi_dst_awready,

	output logic [C_AXI_WIDTH-1:0] m_axi_dst_wdata,
	output logic [(C_AXI_WIDTH/8)-1:0] m_axi_dst_wstrb,
	output logic m_axi_dst_wlast,
	output logic m_axi_dst_wvalid,
	input logic m_axi_dst_wready,

	input logic [1:0] m_axi_dst_bresp,
	input logic m_axi_dst_bvalid,
	output logic m_axi_dst_bready
);
	enum logic [1:0] {ST_IDLE, ST_REQUEST, ST_WAIT, ST_DONE} state;

	logic [C_AXI_ADDR_WIDTH-1:0] curr_rd_addr, curr_wr_addr;
	logic [C_AXI_ADDR_WIDTH-1:0] bytes_left;
	logic [15:0] bytes_to_copy;

	logic mm2s_trigger, mm2s_busy;
	logic [1:0] mm2s_response;

	logic s2mm_trigger, s2mm_busy;
	logic [1:0] s2mm_response;

	logic [C_AXI_WIDTH-1:0] axis_tdata;
	logic [(C_AXI_WIDTH/8)-1:0] axis_tstrb;
	logic axis_tlast, axis_tvalid, axis_tready;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;

			ready <= 1'b0;
			error <= 1'b0;

			curr_rd_addr <= C_SOURCE_ADDR;
			curr_wr_addr <= C_DESTINATION_ADDR;
			bytes_left <= bytes_total;
			bytes_to_copy <= 16'd0;

			mm2s_trigger <= 1'b0;
			s2mm_trigger <= 1'b0;
		end else begin
			case(state)
				ST_IDLE: begin
					if(bytes_left == '0 || error == 1'b1) begin
						state <= ST_DONE;
					end else begin
						state <= ST_REQUEST;
					end
				end

				ST_REQUEST: begin
					state <= ST_WAIT;

					if(bytes_left >= 'h10000) begin
						bytes_to_copy <= 16'hFFFF;
					end else begin
						bytes_to_copy <= bytes_left[15:0] - 16'd1;
					end

					mm2s_trigger <= 1'b1;
					s2mm_trigger <= 1'b1;
				end

				ST_WAIT: begin
					if(mm2s_busy) begin
						mm2s_trigger <= 1'b0;
					end

					if(s2mm_busy) begin
						s2mm_trigger <= 1'b0;
					end

					if(mm2s_response >= 2'b10 || s2mm_response >= 2'b10) begin
						error <= 1'b1;
					end

					if(~mm2s_busy & ~mm2s_trigger & ~s2mm_busy & ~s2mm_trigger) begin
						state <= ST_IDLE;
						curr_rd_addr <= curr_rd_addr + (bytes_to_copy + 'd1);
						curr_wr_addr <= curr_wr_addr + (bytes_to_copy + 'd1);
						bytes_left <= bytes_left - (bytes_to_copy + 'd1);
					end
				end

				ST_DONE: begin
					ready <= 1'b1;
				end
			endcase
		end
	end

	axi_mm2s_io
	#(
		.C_AXI_WIDTH(C_AXI_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.C_AXI_MAX_BURST(255),
		.C_FIFO_SIZE(32),
		.C_FIFO_TYPE("distributed")
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.busy(mm2s_busy),
		.response(mm2s_response),

		.trigger(mm2s_trigger),
		.start_addr(curr_rd_addr),
		.bytes_to_read(bytes_to_copy),

		// M_AXI

		.m_axi_araddr(m_axi_src_araddr),
		.m_axi_arlen(m_axi_src_arlen),
		.m_axi_arsize(m_axi_src_arsize),
		.m_axi_arvalid(m_axi_src_arvalid),
		.m_axi_arready(m_axi_src_arready),

		.m_axi_rdata(m_axi_src_rdata),
		.m_axi_rresp(m_axi_src_rresp),
		.m_axi_rvalid(m_axi_src_rvalid),
		.m_axi_rlast(m_axi_src_rlast),
		.m_axi_rready(m_axi_src_rready),

		// M_AXIS

		.m_axis_tdata(axis_tdata),
		.m_axis_tstrb(axis_tstrb),
		.m_axis_tlast(axis_tlast),
		.m_axis_tvalid(axis_tvalid),
		.m_axis_tready(axis_tready)
	);

	axi_s2mm_io
	#(
		.C_AXI_WIDTH(C_AXI_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.C_AXI_MAX_BURST(255),
		.C_FIFO_SIZE(16),
		.C_FIFO_TYPE("none")
	)
	U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.busy(s2mm_busy),
		.response(s2mm_response),

		.trigger(s2mm_trigger),
		.start_addr(curr_wr_addr),
		.bytes_to_write(bytes_to_copy),

		// M_AXI

		.m_axi_awaddr(m_axi_dst_awaddr),
		.m_axi_awlen(m_axi_dst_awlen),
		.m_axi_awsize(m_axi_dst_awsize),
		.m_axi_awvalid(m_axi_dst_awvalid),
		.m_axi_awready(m_axi_dst_awready),

		.m_axi_wdata(m_axi_dst_wdata),
		.m_axi_wstrb(m_axi_dst_wstrb),
		.m_axi_wlast(m_axi_dst_wlast),
		.m_axi_wvalid(m_axi_dst_wvalid),
		.m_axi_wready(m_axi_dst_wready),

		.m_axi_bresp(m_axi_dst_bresp),
		.m_axi_bvalid(m_axi_dst_bvalid),
		.m_axi_bready(m_axi_dst_bready),

		// S_AXIS

		.s_axis_tdata(axis_tdata),
		.s_axis_tstrb(axis_tstrb),
		.s_axis_tlast(axis_tlast),
		.s_axis_tvalid(axis_tvalid),
		.s_axis_tready(axis_tready)
	);
endmodule
