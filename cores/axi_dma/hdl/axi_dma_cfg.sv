/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axi_dma_cfg
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_AXI_ADDR_WIDTH = 12,

	parameter C_FPGA_ADDR_WIDTH = 32,
	parameter C_HOST_ADDR_WIDTH = 64,

	parameter C_SG_FIFO_SIZE = 64
)
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [C_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [C_AXI_WIDTH-1:0] s_axi_wdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [C_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// Registers

	input logic busy,
	input logic [3:0] response,

	input logic irq,
	output logic irq_en,
	output logic irq_clr,

	output logic dma_trigger,
	output logic dma_direction,
	output logic [C_FPGA_ADDR_WIDTH-1:0] dma_fpga_addr,

	input logic [$clog2(C_SG_FIFO_SIZE+1)-1:0] sg_occupancy,

	output logic [C_HOST_ADDR_WIDTH+15:0] m_axis_sg_tdata,
	output logic m_axis_sg_tvalid,
	input logic m_axis_sg_tready
);
	// Handle AXI4-Lite requests

	logic read_req;
	logic read_ready;
	logic read_response;
	logic [C_AXI_WIDTH-1:0] read_value;

	logic write_req;
	logic write_ready;
	logic write_response;
	logic [C_AXI_ADDR_WIDTH-1:0] write_addr;

	axi4_lite_slave_rw #(C_AXI_ADDR_WIDTH, C_AXI_WIDTH) U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(read_req),

		.read_ready(read_ready),
		.read_response(read_response),
		.read_value(read_value),

		.write_req(write_req),
		.write_addr(write_addr),

		.write_ready(write_ready),
		.write_response(write_response),

		.s_axi_awaddr(s_axi_awaddr),
		.s_axi_awprot('0),
		.s_axi_awvalid(s_axi_awvalid),
		.s_axi_awready(s_axi_awready),

		.s_axi_wdata(s_axi_wdata),
		.s_axi_wstrb(s_axi_wstrb),
		.s_axi_wvalid(s_axi_wvalid),
		.s_axi_wready(s_axi_wready),

		.s_axi_bresp(s_axi_bresp),
		.s_axi_bvalid(s_axi_bvalid),
		.s_axi_bready(s_axi_bready),

		.s_axi_araddr(s_axi_araddr),
		.s_axi_arprot('0),
		.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),

		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rready(s_axi_rready)
	);

	// Read/write registers as requested

	logic [C_AXI_WIDTH-1:0] write_mask;

	logic [C_HOST_ADDR_WIDTH-1:0] sg_host_addr;
	logic [16:0] sg_length;
	logic sg_commit, sg_done;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			irq_en <= 1'b0;
			irq_clr <= 1'b0;

			dma_trigger <= 1'b0;
			dma_fpga_addr <= '0;

			sg_host_addr <= '0;
			sg_length <= 17'd0;
			sg_commit <= 1'b0;
			sg_done <= 1'b0;

			m_axis_sg_tdata <= '0;
			m_axis_sg_tvalid <= 1'b0;
		end else begin
			irq_clr <= 1'b0;
			dma_trigger <= 1'b0;
			sg_commit <= 1'b0;
			sg_done <= 1'b0;

			if(sg_length >= 17'd65536) begin
				sg_length <= 17'd65536;
			end

			if(sg_commit) begin
				m_axis_sg_tdata[C_HOST_ADDR_WIDTH+15:16] <= sg_host_addr;

				if(sg_length != 17'd0 && sg_occupancy < C_SG_FIFO_SIZE) begin
					m_axis_sg_tdata[15:0] <= sg_length - 17'd1;
					m_axis_sg_tvalid <= 1'b1;
				end else begin
					sg_done <= 1'b1;
				end
			end

			if(m_axis_sg_tvalid & m_axis_sg_tready) begin
				m_axis_sg_tvalid <= 1'b0;
				sg_done <= 1'b1;
			end

			if(write_req & ~busy) begin
				if(write_addr[C_AXI_ADDR_WIDTH-1:5] == '0) begin
					if(C_AXI_WIDTH == 32) begin
						case(write_addr[4:2])
							3'd0: begin
								dma_trigger <= 1'b1;
								dma_direction <= s_axi_wdata[0] & write_mask[0];
							end

							3'd1: begin
								irq_clr <= s_axi_wdata[0] & write_mask[0];
								irq_en <= (s_axi_wdata[16] & write_mask[16]) | (irq_en & ~write_mask[16]);
							end

							3'd3: begin
								dma_fpga_addr <= (s_axi_wdata[C_FPGA_ADDR_WIDTH-1:0] & write_mask[C_FPGA_ADDR_WIDTH-1:0]) | (dma_fpga_addr & ~write_mask[C_FPGA_ADDR_WIDTH-1:0]);
							end

							3'd4: begin
								sg_host_addr[31:0] <= (s_axi_wdata & write_mask) | (sg_host_addr[31:0] & ~write_mask);
							end

							3'd5: begin
								if(C_HOST_ADDR_WIDTH == 64) begin
									sg_host_addr[63:32] <= (s_axi_wdata & write_mask) | (sg_host_addr[63:32] & ~write_mask);
								end
							end

							3'd6: begin
								sg_length <= (s_axi_wdata[16:0] & write_mask[16:0]) | (sg_length & ~write_mask[16:0]);
							end

							3'd7: begin
								if(write_mask != '0) begin
									sg_commit <= 1'b1;
								end
							end
						endcase
					end else if(C_AXI_WIDTH == 64) begin
						case(write_addr[4:3])
							2'd0: begin
								dma_trigger <= write_mask[0];
								dma_direction <= s_axi_wdata[0] & write_mask[0];

								irq_clr <= s_axi_wdata[32] & write_mask[32];
								irq_en <= (s_axi_wdata[48] & write_mask[48]) | (irq_en & ~write_mask[48]);
							end

							2'd1: begin
								dma_fpga_addr <= (s_axi_wdata[C_FPGA_ADDR_WIDTH+31:32] & write_mask[C_FPGA_ADDR_WIDTH+31:32]) | (dma_fpga_addr & ~write_mask[C_FPGA_ADDR_WIDTH+31:32]);
							end

							2'd2: begin
								if(C_HOST_ADDR_WIDTH == 64) begin
									sg_host_addr <= (s_axi_wdata & write_mask) | (sg_host_addr & ~write_mask);
								end else begin
									sg_host_addr <= (s_axi_wdata[31:0] & write_mask[31:0]) | (sg_host_addr & ~write_mask[31:0]);
								end
							end

							2'd3: begin
								sg_length <= (s_axi_wdata[16:0] & write_mask[16:0]) | (sg_length & ~write_mask[16:0]);

								if(write_mask[63:32] != '0) begin
									sg_commit <= 1'b1;
								end
							end
						endcase
					end
				end
			end
		end
	end

	always_comb begin
		read_ready = 1'b0;
		read_response = 1'b0;
		read_value = '0;

		write_ready = 1'b0;
		write_response = 1'b0;

		for(int i = 0; i < C_AXI_WIDTH; ++i) begin
			write_mask[i] = s_axi_wstrb[i/8];
		end

		// Handle read requests

		if(read_req) begin
			if(s_axi_araddr <= 'd31) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				if(C_AXI_WIDTH == 32) begin
					case(s_axi_araddr[4:2])
						3'd0: read_value = {26'd0, response, busy, dma_direction};
						3'd1: read_value = {15'd0, irq_en, 15'd0, irq};
						3'd2: read_value = {'0, sg_occupancy, C_SG_FIFO_SIZE[15:0]};
						3'd3: read_value = {'0, dma_fpga_addr};
						3'd4: read_value = sg_host_addr[31:0];
						3'd5: read_value = (C_HOST_ADDR_WIDTH == 64) ? sg_host_addr[63:32] : 32'd0;
						3'd6: read_value = {15'd0, sg_length};
						3'd7: read_value = 32'd0;
					endcase
				end else if(C_AXI_WIDTH == 64) begin
					case(s_axi_araddr[4:3])
						2'd0: read_value = {15'd0, irq_en, 15'd0, irq, 26'd0, response, busy, dma_direction};
						2'd1: read_value = {'0, dma_fpga_addr, {(16-$clog2(C_SG_FIFO_SIZE+1)){1'b0}}, sg_occupancy, C_SG_FIFO_SIZE[15:0]};
						2'd2: read_value = {'0, sg_host_addr};
						2'd3: read_value = {47'd0, sg_length};
					endcase
				end
			end else begin
				// Invalid address, mark as error
				read_ready = 1'b1;
				read_response = 1'b0;
			end
		end

		// Handle write requests

		if(write_req) begin
			if((C_AXI_WIDTH == 64 && write_addr[C_AXI_ADDR_WIDTH-1:3] == 'd3 && write_mask[63:32] != '0) || (C_AXI_WIDTH == 32 && write_addr[C_AXI_ADDR_WIDTH-1:2] == 'd7 && write_mask != '0)) begin
				write_ready = sg_done;
			end else begin
				write_ready = 1'b1;
			end

			write_response = (write_addr <= 'd31);
		end
	end
endmodule
