/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_s2mm
#(
	parameter C_AXI_WIDTH = 64,
	parameter C_AXI_ADDR_WIDTH = 64,
	parameter C_AXI_MAX_BURST = 255,
	parameter C_FIFO_SIZE = 256,
	parameter C_FIFO_TYPE = "block"
)
(
	input logic clk,
	input logic rst_n,

	// S_AXIS_CTL

	input logic [C_AXI_ADDR_WIDTH+15:0] s_axis_ctl_tdata,
	input logic s_axis_ctl_tvalid,
	output logic s_axis_ctl_tready,

	// M_AXIS_ST

	output logic [7:0] m_axis_st_tdata,
	output logic m_axis_st_tvalid,
	input logic m_axis_st_tready,

	// M_AXI

	output logic [C_AXI_ADDR_WIDTH-1:0] m_axi_awaddr,
	output logic [7:0] m_axi_awlen,
	output logic [2:0] m_axi_awsize,
	output logic m_axi_awvalid,
	input logic m_axi_awready,

	output logic [C_AXI_WIDTH-1:0] m_axi_wdata,
	output logic [(C_AXI_WIDTH/8)-1:0] m_axi_wstrb,
	output logic m_axi_wlast,
	output logic m_axi_wvalid,
	input logic m_axi_wready,

	input logic [1:0] m_axi_bresp,
	input logic m_axi_bvalid,
	output logic m_axi_bready,

	// S_AXIS

	input logic [C_AXI_WIDTH-1:0] s_axis_tdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axis_tstrb,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready
);
	enum logic [1:0] {ST_IDLE, ST_EXECUTE_REQ, ST_WAIT_ST} state;

	logic busy, trigger;
	logic [1:0] response;
	logic [C_AXI_ADDR_WIDTH-1:0] start_addr;
	logic [15:0] bytes_to_write;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;

			s_axis_ctl_tready <= 1'b0;

			m_axis_st_tdata <= 8'd0;
			m_axis_st_tvalid <= 1'b0;
		end else begin

			case(state)
				ST_IDLE: begin
					s_axis_ctl_tready <= 1'b1;

					if(s_axis_ctl_tready & s_axis_ctl_tvalid) begin
						state <= ST_EXECUTE_REQ;

						trigger <= 1'b1;
						start_addr <= s_axis_ctl_tdata[C_AXI_ADDR_WIDTH+15:16];
						bytes_to_write <= s_axis_ctl_tdata[15:0];
					end
				end

				ST_EXECUTE_REQ: begin
					trigger <= 1'b0;

					if(~trigger & ~busy) begin
						state <= ST_WAIT_ST;

						m_axis_st_tdata <= {6'd0, response};
						m_axis_st_tvalid <= 1'b1;
					end
				end

				ST_WAIT_ST: begin
					if(m_axis_st_tvalid & m_axis_st_tready) begin
						state <= ST_IDLE;

						m_axis_st_tdata <= 8'd0;
						m_axis_st_tvalid <= 1'b0;

						s_axis_ctl_tready <= 1'b1;
					end
				end

				default: begin
					state <= ST_IDLE;
				end
			endcase
		end
	end

	axi_s2mm_io
	#(
		.C_AXI_WIDTH(C_AXI_WIDTH),
		.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
		.C_AXI_MAX_BURST(C_AXI_MAX_BURST),
		.C_FIFO_SIZE(C_FIFO_SIZE),
		.C_FIFO_TYPE(C_FIFO_TYPE)
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.busy(busy),
		.response(response),

		.trigger(trigger),
		.start_addr(start_addr),
		.bytes_to_write(bytes_to_write),

		// M_AXI

		.m_axi_awaddr(m_axi_awaddr),
		.m_axi_awlen(m_axi_awlen),
		.m_axi_awsize(m_axi_awsize),
		.m_axi_awvalid(m_axi_awvalid),
		.m_axi_awready(m_axi_awready),

		.m_axi_wdata(m_axi_wdata),
		.m_axi_wstrb(m_axi_wstrb),
		.m_axi_wlast(m_axi_wlast),
		.m_axi_wvalid(m_axi_wvalid),
		.m_axi_wready(m_axi_wready),

		.m_axi_bresp(m_axi_bresp),
		.m_axi_bvalid(m_axi_bvalid),
		.m_axi_bready(m_axi_bready),

		// S_AXIS

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tstrb(s_axis_tstrb),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tready(s_axis_tready)
	);
endmodule
