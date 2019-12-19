/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_detector_axi #(parameter C_AXI_WIDTH = 32, parameter C_AXIS_LOG_ENABLE = 1)
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [15:0] s_axi_awaddr,
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

	input logic [15:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// MEM_A

	output logic mem_a_req,
	output logic mem_a_we,
	input logic mem_a_ack,

	output logic [10:0] mem_a_addr,
	output logic [C_AXI_WIDTH-1:0] mem_a_wdata,
	input logic [C_AXI_WIDTH-1:0] mem_a_rdata,

	// MEM_B

	output logic mem_b_req,
	output logic mem_b_we,
	input logic mem_b_ack,

	output logic [10:0] mem_b_addr,
	output logic [C_AXI_WIDTH-1:0] mem_b_wdata,
	input logic [C_AXI_WIDTH-1:0] mem_b_rdata,

	// MEM_C

	output logic mem_c_req,
	output logic mem_c_we,
	input logic mem_c_ack,

	output logic [10:0] mem_c_addr,
	output logic [C_AXI_WIDTH-1:0] mem_c_wdata,
	input logic [C_AXI_WIDTH-1:0] mem_c_rdata,

	// MEM_D

	output logic mem_d_req,
	output logic mem_d_we,
	input logic mem_d_ack,

	output logic [10:0] mem_d_addr,
	output logic [C_AXI_WIDTH-1:0] mem_d_wdata,
	input logic [C_AXI_WIDTH-1:0] mem_d_rdata,

	// Registers

	output logic enable,
	output logic srst,
	output logic mode,
	output logic [7:0] match_en,
	output logic [15:0] log_id,

	input logic [63:0] overflow_count_a,
	input logic [63:0] overflow_count_b
);
	// Handle AXI4-Lite requests

	logic read_req;
	logic read_ready;
	logic read_response;
	logic [C_AXI_WIDTH-1:0] read_value;

	logic write_req;
	logic write_ready;
	logic write_response;
	logic [15:0] write_addr;

	axi4_lite_slave_rw #(16, C_AXI_WIDTH) U0
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

	logic [C_AXI_WIDTH-1:0] write_mask;

	logic mem_a_done, mem_b_done, mem_c_done, mem_d_done;
	logic mem_a_rreq, mem_a_wreq;
	logic mem_b_rreq, mem_b_wreq;
	logic mem_c_rreq, mem_c_wreq;
	logic mem_d_rreq, mem_d_wreq;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable <= 1'b0;
			srst <= srst & rst_n;
			mode <= 1'b0;
			log_id <= 16'd0;
			match_en <= 8'd0;
		end else begin
			if(write_req) begin
				if(write_addr[15:3] == 13'd0) begin
					if(C_AXI_WIDTH == 32) begin
						case(write_addr[2])
							1'd0: begin
								enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
								mode <= (s_axi_wdata[2] & write_mask[2]) | (mode & ~write_mask[2]);
								log_id <= (s_axi_wdata[31:16] & write_mask[31:16]) | (log_id & ~write_mask[31:16]);
							end

							1'd1: begin
								match_en[3:0] <= (s_axi_wdata[3:0] & write_mask[3:0]) | (match_en[3:0] & ~write_mask[3:0]);
								match_en[7:4] <= (s_axi_wdata[19:16] & write_mask[19:16]) | (match_en[7:4] & ~write_mask[19:16]);
							end
						endcase
					end else if(C_AXI_WIDTH == 64) begin
						enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
						mode <= (s_axi_wdata[2] & write_mask[2]) | (mode & ~write_mask[2]);
						log_id <= (s_axi_wdata[31:16] & write_mask[31:16]) | (log_id & ~write_mask[31:16]);
						match_en[3:0] <= (s_axi_wdata[35:32] & write_mask[35:32]) | (match_en[3:0] & ~write_mask[35:32]);
						match_en[7:4] <= (s_axi_wdata[51:48] & write_mask[51:48]) | (match_en[7:4] & ~write_mask[51:48]);
					end
				end
			end
		end

		// SRST must be writable even after it has been set to 1
		if(rst_n & write_req && write_addr[15:$clog2(C_AXI_WIDTH/8)] == '0) begin
			srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
		end
	end

	always_comb begin
		read_ready = 1'b0;
		read_response = 1'b0;
		read_value = '0;

		write_ready = 1'b0;
		write_response = 1'b0;

		mem_a_rreq = 1'b0; mem_a_wreq = 1'b0;
		mem_b_rreq = 1'b0; mem_b_wreq = 1'b0;
		mem_c_rreq = 1'b0; mem_c_wreq = 1'b0;
		mem_d_rreq = 1'b0; mem_d_wreq = 1'b0;

		for(int i = 0; i < C_AXI_WIDTH; ++i) begin
			write_mask[i] = s_axi_wstrb[i/8];
		end

		// Handle read requests

		if(read_req) begin
			if(s_axi_araddr <= 16'd23) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				if(C_AXI_WIDTH == 32) begin
					case(s_axi_araddr[4:2])
						3'd0: read_value = {log_id, 13'd0, mode, srst, enable};
						3'd1: read_value = {12'd0, match_en[7:4], 12'd0, match_en[3:0]};
						3'd2: read_value = overflow_count_a[31:0];
						3'd3: read_value = overflow_count_a[63:32];
						3'd4: read_value = overflow_count_b[31:0];
						3'd5: read_value = overflow_count_b[63:32];
					endcase
				end else if(C_AXI_WIDTH == 64) begin
					case(s_axi_araddr[4:3])
						2'd0: read_value = {12'd0, match_en[7:4], 12'd0, match_en[3:0], log_id, 13'd0, mode, srst, enable};
						2'd1: read_value = overflow_count_a;
						2'd2: read_value = overflow_count_b;
					endcase
				end
			end else if(s_axi_araddr[15:13] == 3'd1) begin
				// MEM_A address
				read_ready = mem_a_done;
				read_response = 1'b1;
				read_value = mem_a_rdata;
				mem_a_rreq = 1'b1;
			end else if(s_axi_araddr[15:13] == 3'd2) begin
				// MEM_B address
				read_ready = mem_b_done;
				read_response = 1'b1;
				read_value = mem_b_rdata;
				mem_b_rreq = 1'b1;
			end else if(s_axi_araddr[15:13] == 3'd3) begin
				// MEM_C address
				read_ready = mem_b_done;
				read_response = 1'b1;
				read_value = mem_c_rdata;
				mem_c_rreq = 1'b1;
			end else if(s_axi_araddr[15:13] == 3'd4) begin
				// MEM_D address
				read_ready = mem_d_done;
				read_response = 1'b1;
				read_value = mem_d_rdata;
				mem_d_rreq = 1'b1;
			end else begin
				// Invalid address, mark as error
				read_ready = 1'b1;
				read_response = 1'b0;
			end
		end

		// Handle write requests

		if(write_req) begin
			if(write_addr <= 16'd23) begin
				// Register address
				write_ready = 1'b1;
				write_response = 1'b1;
			end else if(write_addr[15:13] == 3'd1) begin
				// MEM_A address
				write_ready = mem_a_done;
				write_response = 1'b1;
				mem_a_wreq = 1'b1;
			end else if(write_addr[15:13] == 3'd2) begin
				// MEM_B address
				write_ready = mem_b_done;
				write_response = 1'b1;
				mem_b_wreq = 1'b1;
			end else if(write_addr[15:13] == 3'd3) begin
				// MEM_C address
				write_ready = mem_c_done;
				write_response = 1'b1;
				mem_c_wreq = 1'b1;
			end else if(write_addr[15:13] == 3'd4) begin
				// MEM_D address
				write_ready = mem_d_done;
				write_response = 1'b1;
				mem_d_wreq = 1'b1;
			end else begin
				// Invalid address, mark as error
				write_ready = 1'b1;
				write_response = 1'b0;
			end
		end
	end

	eth_frame_detector_axi_dram #(C_AXI_WIDTH) U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(mem_a_rreq),
		.read_addr(s_axi_araddr),

		.write_req(mem_a_wreq),
		.write_mask(write_mask),
		.write_addr(write_addr),
		.write_data(s_axi_wdata),

		.done(mem_a_done),

		// MEM_A

		.mem_req(mem_a_req),
		.mem_we(mem_a_we),
		.mem_ack(mem_a_ack),

		.mem_addr(mem_a_addr),
		.mem_wdata(mem_a_wdata),
		.mem_rdata(mem_a_rdata)
	);

	eth_frame_detector_axi_dram #(C_AXI_WIDTH) U2
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(mem_b_rreq),
		.read_addr(s_axi_araddr),

		.write_req(mem_b_wreq),
		.write_mask(write_mask),
		.write_addr(write_addr),
		.write_data(s_axi_wdata),

		.done(mem_b_done),

		// MEM_B

		.mem_req(mem_b_req),
		.mem_we(mem_b_we),
		.mem_ack(mem_b_ack),

		.mem_addr(mem_b_addr),
		.mem_wdata(mem_b_wdata),
		.mem_rdata(mem_b_rdata)
	);

	eth_frame_detector_axi_dram #(C_AXI_WIDTH) U3
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(mem_c_rreq),
		.read_addr(s_axi_araddr),

		.write_req(mem_c_wreq),
		.write_mask(write_mask),
		.write_addr(write_addr),
		.write_data(s_axi_wdata),

		.done(mem_c_done),

		// MEM_C

		.mem_req(mem_c_req),
		.mem_we(mem_c_we),
		.mem_ack(mem_c_ack),

		.mem_addr(mem_c_addr),
		.mem_wdata(mem_c_wdata),
		.mem_rdata(mem_c_rdata)
	);

	eth_frame_detector_axi_dram #(C_AXI_WIDTH) U4
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(mem_d_rreq),
		.read_addr(s_axi_araddr),

		.write_req(mem_d_wreq),
		.write_mask(write_mask),
		.write_addr(write_addr),
		.write_data(s_axi_wdata),

		.done(mem_d_done),

		// MEM_D

		.mem_req(mem_d_req),
		.mem_we(mem_d_we),
		.mem_ack(mem_d_ack),

		.mem_addr(mem_d_addr),
		.mem_wdata(mem_d_wdata),
		.mem_rdata(mem_d_rdata)
	);
endmodule
