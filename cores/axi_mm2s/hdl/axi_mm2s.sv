/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_mm2s
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

	output logic [C_AXI_ADDR_WIDTH-1:0] m_axi_araddr,
	output logic [7:0] m_axi_arlen,
	output logic [2:0] m_axi_arsize,
	output logic m_axi_arvalid,
	input logic m_axi_arready,

	input logic [C_AXI_WIDTH-1:0] m_axi_rdata,
	input logic [1:0] m_axi_rresp,
	input logic m_axi_rvalid,
	input logic m_axi_rlast,
	output logic m_axi_rready,

	// M_AXIS

	output logic [C_AXI_WIDTH-1:0] m_axis_tdata,
	output logic [(C_AXI_WIDTH/8)-1:0] m_axis_tstrb,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [1:0] {ST_IDLE, ST_EXECUTE_REQ, ST_WAIT_ST} state;

	logic busy, trigger;
	logic [1:0] response;
	logic [C_AXI_ADDR_WIDTH-1:0] start_addr;
	logic [15:0] bytes_to_read;

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
						bytes_to_read <= s_axis_ctl_tdata[15:0];
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

	axi_mm2s_io
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
		.bytes_to_read(bytes_to_read),

		// M_AXI

		.m_axi_araddr(m_axi_araddr),
		.m_axi_arlen(m_axi_arlen),
		.m_axi_arsize(m_axi_arsize),
		.m_axi_arvalid(m_axi_arvalid),
		.m_axi_arready(m_axi_arready),

		.m_axi_rdata(m_axi_rdata),
		.m_axi_rresp(m_axi_rresp),
		.m_axi_rvalid(m_axi_rvalid),
		.m_axi_rlast(m_axi_rlast),
		.m_axi_rready(m_axi_rready),

		// M_AXIS

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tstrb(m_axis_tstrb),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);
endmodule
