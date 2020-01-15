/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module circular_dma_axi #(parameter C_AXI_WIDTH = 32, parameter C_ADDR_WIDTH = 32, parameter C_AXIS_WIDTH = 64, parameter C_MAX_BURST = 16)
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [11:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [C_AXI_WIDTH-1:0] s_axi_wdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [11:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// Registers

	output logic enable,
	output logic srst,
	output logic flush_fifo,
	input logic [2:0] status_flags,
	input logic fifo_empty,

	input logic [2:0] irq,
	output logic [2:0] clear_irq,
	output logic [2:0] enable_irq,

	output logic [C_ADDR_WIDTH-1:0] mem_base,
	output logic [31:0] mem_size,
	input logic [31:0] bytes_written,
	input logic [31:0] last_msg_end,
	output logic [31:0] timeout
);
	// Handle AXI4-Lite requests

	logic read_req;
	logic read_ready;
	logic read_response;
	logic [C_AXI_WIDTH-1:0] read_value;

	logic write_req;
	logic write_ready;
	logic write_response;
	logic [11:0] write_addr;

	axi4_lite_slave_rw #(12, C_AXI_WIDTH) U0
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
		.s_axi_awprot(s_axi_awprot),
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
		.s_axi_arprot(s_axi_arprot),
		.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),

		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rready(s_axi_rready)
	);

	// Read/write registers as requested

	localparam C_BURST_BYTES = C_MAX_BURST * (C_AXIS_WIDTH / 8);

	logic [C_AXI_WIDTH-1:0] write_mask;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable <= 1'b0;
			srst <= srst & rst_n;
			flush_fifo <= 1'b0;
			clear_irq <= 3'b0;
			enable_irq <= 3'b0;
			timeout <= 32'd125000000;

			mem_base <= '0;
			mem_size <= 32'd0;
		end else begin
			clear_irq <= 3'b0;

			if(fifo_empty) begin
				flush_fifo <= 1'b0;
			end

			if(write_req) begin
				if(write_addr[11:5] == 7'd0) begin
					if(C_AXI_WIDTH == 32) begin
						case(write_addr[4:2])
							3'd0: begin
								enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
								flush_fifo <= (s_axi_wdata[2] & write_mask[2]) | (flush_fifo & ~write_mask[2]);
							end

							3'd1: begin
								clear_irq <= s_axi_wdata[2:0] & write_mask[2:0];
								enable_irq <= (s_axi_wdata[18:16] & write_mask[18:16]) | (enable_irq & ~write_mask[18:16]);
							end

							3'd2: begin
								mem_base[31:0] <= (s_axi_wdata & write_mask) | (mem_base[31:0] & ~write_mask);
								mem_base[$clog2(C_AXIS_WIDTH/8)-1:0] <= 'd0;
							end

							3'd3: begin
								if(C_ADDR_WIDTH == 64) begin
									mem_base[63:32] <= (s_axi_wdata & write_mask) | (mem_base[63:32] & ~write_mask);
								end
							end

							3'd4: begin
								mem_size <= (s_axi_wdata & write_mask) | (mem_size & ~write_mask);
								mem_size[$clog2(C_BURST_BYTES)-1:0] <= 'd0;
							end

							3'd7: begin
								timeout <= (s_axi_wdata & write_mask) | (timeout & ~write_mask);
							end
						endcase
					end else if(C_AXI_WIDTH == 64) begin
						case(write_addr[4:3])
							2'd0: begin
								enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
								flush_fifo <= (s_axi_wdata[2] & write_mask[2]) | (flush_fifo & ~write_mask[2]);
								clear_irq <= s_axi_wdata[34:32] & write_mask[34:32];
								enable_irq <= (s_axi_wdata[50:48] & write_mask[50:48]) | (enable_irq & ~write_mask[50:48]);
							end

							2'd1: begin
								mem_base <= (s_axi_wdata[C_ADDR_WIDTH-1:0] & write_mask[C_ADDR_WIDTH-1:0]) | (mem_base & ~write_mask[C_ADDR_WIDTH-1:0]);
								mem_base[$clog2(C_AXIS_WIDTH/8)-1:0] <= 'd0;
							end

							2'd2: begin
								mem_size <= (s_axi_wdata[31:0] & write_mask[31:0]) | (mem_size & ~write_mask[31:0]);
								mem_size[$clog2(C_BURST_BYTES)-1:0] <= 'd0;
							end

							3'd3: begin
								timeout <= (s_axi_wdata[63:32] & write_mask[63:32]) | (timeout & ~write_mask[63:32]);
							end
						endcase
					end
				end
			end
		end

		// SRST must be writable even after it has been set to 1
		if(rst_n & write_req && write_addr[11:$clog2(C_AXI_WIDTH/8)] == '0) begin
			srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
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
			if(s_axi_araddr <= 12'd31) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				if(C_AXI_WIDTH == 32) begin
					case(s_axi_araddr[4:2])
						3'd0: read_value = {12'd0, fifo_empty, status_flags, 13'd0, flush_fifo, srst, enable};
						3'd1: read_value = {13'd0, enable_irq, 13'd0, irq};
						3'd2: read_value = mem_base[31:0];
						3'd3: read_value = (C_ADDR_WIDTH == 64) ? mem_base[63:32] : 32'd0;
						3'd4: read_value = mem_size;
						3'd5: read_value = bytes_written;
						3'd6: read_value = last_msg_end;
						3'd7: read_value = timeout;
					endcase
				end else if(C_AXI_WIDTH == 64) begin
					case(s_axi_araddr[4:3])
						2'd0: read_value = {13'd0, enable_irq, 13'd0, irq, 12'd0, fifo_empty, status_flags, 13'd0, flush_fifo, srst, enable};
						2'd1: read_value = (C_ADDR_WIDTH == 64) ? mem_base : {32'd0, mem_base};
						2'd2: read_value = {bytes_written, mem_size};
						2'd3: read_value = {timeout, last_msg_end};
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
			write_ready = 1'b1;
			write_response = (write_addr <= 12'd31);
		end
	end
endmodule
