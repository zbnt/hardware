/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module simple_timer_axi #(parameter data_width = 32)
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [11:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [data_width-1:0] s_axi_wdata,
	input logic [(data_width/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [11:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [data_width-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// Registers

	output logic enable,
	output logic srst,

	input logic running,

	output logic [63:0] max_count,
	input logic [63:0] current_count
);
	// Handle AXI4-Lite requests

	logic read_req;
	logic read_ready;
	logic read_response;
	logic [data_width-1:0] read_value;

	logic write_req;
	logic write_ready;
	logic write_response;
	logic [11:0] write_addr;

	axi4_lite_slave_rw #(12, data_width) U0
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

	logic [data_width-1:0] write_mask;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable <= 1'b0;
			srst <= srst & rst_n;
			max_count <= 64'd0;
		end else if(write_req && write_addr[11:4] == 8'd0) begin
			if(data_width == 32) begin
				case(write_addr[3:2])
					2'd0: begin
						enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
					end

					2'd2: begin
						max_count[31:0] <= (s_axi_wdata & write_mask) | (max_count[31:0] & ~write_mask);
					end

					2'd3: begin
						max_count[63:32] <= (s_axi_wdata & write_mask) | (max_count[63:32] & ~write_mask);
					end
				endcase
			end else if(data_width == 64) begin
				case(write_addr[3])
					1'd0: begin
						enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
					end

					1'd1: begin
						max_count <= (s_axi_wdata & write_mask) | (max_count & ~write_mask);
					end
				endcase
			end else if(data_width == 128) begin
				enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
				max_count <= (s_axi_wdata[127:64] & write_mask[127:64]) | (max_count & ~write_mask[127:64]);
			end
		end

		// SRST must be writable even after it has been set to 1
		if(rst_n & write_req && write_addr[11:$clog2(data_width/8)] == '0) begin
			srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
		end
	end

	always_comb begin
		read_ready = 1'b0;
		read_response = 1'b0;
		read_value = 32'd0;

		write_ready = 1'b0;
		write_response = 1'b0;

		for(int i = 0; i < data_width; ++i) begin
			write_mask[i] = s_axi_wstrb[i/8];
		end

		// Handle read requests

		if(read_req) begin
			read_ready = 1'b1;

			if(s_axi_araddr >= 12'd0 && s_axi_araddr <= 12'd23) begin
				read_response = 1'b1;

				if(data_width == 32) begin
					case(s_axi_araddr[4:2])
						3'd0: read_value = {30'd0, srst, enable};
						3'd1: read_value = {31'd0, running};
						3'd2: read_value = max_count[31:0];
						3'd3: read_value = max_count[63:32];
						3'd4: read_value = current_count[31:0];
						3'd5: read_value = current_count[63:32];
					endcase
				end else if(data_width == 64) begin
					case(s_axi_araddr[4:3])
						2'd0: read_value = {31'd0, running, 30'd0, srst, enable};
						2'd1: read_value = max_count;
						2'd2: read_value = current_count;
					endcase
				end else if(data_width == 128) begin
					case(s_axi_araddr[4])
						1'd0: read_value = {max_count, 31'd0, running, 30'd0, srst, enable};
						1'd1: read_value = {64'd0, current_count};
					endcase
				end
			end else begin
				read_response = 1'b0;
			end
		end

		// Handle write requests

		if(write_req) begin
			write_ready = 1'b1;
			write_response = write_addr >= 12'd0 && write_addr <= 12'd23;
		end
	end
endmodule
