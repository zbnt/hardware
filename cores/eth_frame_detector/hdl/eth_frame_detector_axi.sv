/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_detector_axi
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_ADDR_WIDTH = 16,

	parameter C_AXIS_LOG_ENABLE = 1,

	parameter C_ENABLE_COMPARE = 1,
	parameter C_ENABLE_EDIT = 1,
	parameter C_ENABLE_CHECKSUM = 1,
	parameter C_NUM_SCRIPTS = 4,
	parameter C_MAX_SCRIPT_SIZE = 2048,
	parameter C_LOOP_FIFO_A_SIZE = 2048,
	parameter C_LOOP_FIFO_B_SIZE = 128,
	parameter C_EXTRACT_FIFO_SIZE = 2048
)
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [C_ADDR_WIDTH-1:0] s_axi_awaddr,
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

	input logic [C_ADDR_WIDTH-1:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// MEM_A

	output logic mem_a_req,
	output logic [C_ADDR_WIDTH-3:0] mem_a_addr,
	output logic mem_a_wenable,
	output logic [C_AXI_WIDTH-1:0] mem_a_wdata,
	input logic [C_AXI_WIDTH-1:0] mem_a_rdata,
	input logic mem_a_ack,

	// MEM_B

	output logic mem_b_req,
	output logic [C_ADDR_WIDTH-3:0] mem_b_addr,
	output logic mem_b_wenable,
	output logic [C_AXI_WIDTH-1:0] mem_b_wdata,
	input logic [C_AXI_WIDTH-1:0] mem_b_rdata,
	input logic mem_b_ack,

	// Registers

	output logic enable,
	output logic srst,
	output logic log_en,
	output logic [2*C_NUM_SCRIPTS-1:0] script_en,
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
	logic [C_ADDR_WIDTH-1:0] write_addr;

	axi4_lite_slave_rw #(C_ADDR_WIDTH, C_AXI_WIDTH) U0
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

	logic mem_a_done, mem_b_done;
	logic mem_a_rreq, mem_a_wreq;
	logic mem_b_rreq, mem_b_wreq;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable <= 1'b0;
			srst <= srst & rst_n;
			log_id <= 16'd0;
			script_en <= '0;
		end else begin
			if(write_req) begin
				if(write_addr[C_ADDR_WIDTH-1:3] == 13'd0) begin
					if(C_AXI_WIDTH == 32) begin
						case(write_addr[2])
							1'd0: begin
								enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
								log_en <= (s_axi_wdata[2] & write_mask[2]) | (log_en & ~write_mask[2]);
								log_id <= (s_axi_wdata[31:16] & write_mask[31:16]) | (log_id & ~write_mask[31:16]);
							end

							1'd1: begin
								script_en <= (s_axi_wdata[2*C_NUM_SCRIPTS-1:0] & write_mask[2*C_NUM_SCRIPTS-1:0]) | (script_en & ~write_mask[2*C_NUM_SCRIPTS-1:0]);
							end
						endcase
					end else if(C_AXI_WIDTH == 64) begin
						enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
						log_en <= (s_axi_wdata[2] & write_mask[2]) | (log_en & ~write_mask[2]);
						log_id <= (s_axi_wdata[31:16] & write_mask[31:16]) | (log_id & ~write_mask[31:16]);
						script_en <= (s_axi_wdata[2*C_NUM_SCRIPTS+31:32] & write_mask[2*C_NUM_SCRIPTS+31:32]) | (script_en & ~write_mask[2*C_NUM_SCRIPTS+31:32]);
					end
				end
			end
		end

		// SRST must be writable even after it has been set to 1
		if(rst_n & write_req && write_addr[C_ADDR_WIDTH-1:$clog2(C_AXI_WIDTH/8)] == '0) begin
			srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
		end
	end

	always_comb begin
		read_ready = 1'b0;
		read_response = 1'b1;
		read_value = '0;

		write_ready = 1'b0;
		write_response = 1'b1;

		mem_a_rreq = 1'b0; mem_a_wreq = 1'b0;
		mem_b_rreq = 1'b0; mem_b_wreq = 1'b0;

		for(int i = 0; i < C_AXI_WIDTH; ++i) begin
			write_mask[i] = s_axi_wstrb[i/8];
		end

		// Handle read requests

		if(read_req) begin
			read_ready = 1'b1;

			case(s_axi_araddr[C_ADDR_WIDTH-1:C_ADDR_WIDTH-2])
				2'd0: begin
					if(s_axi_araddr <= 'd47) begin
						// Register address

						if(C_AXI_WIDTH == 32) begin
							case(s_axi_araddr[5:2])
								4'h0: read_value = {log_id, 13'd0, log_en, srst, enable};
								4'h1: read_value = (C_NUM_SCRIPTS == 16) ? script_en : {{(32-2*C_NUM_SCRIPTS){1'b0}}, script_en};
								4'h2: read_value = {29'd0, C_ENABLE_CHECKSUM[0], C_ENABLE_EDIT[0], C_ENABLE_COMPARE[0]};
								4'h3: read_value = C_NUM_SCRIPTS;
								4'h4: read_value = C_MAX_SCRIPT_SIZE;
								4'h5: read_value = {'d1, {(C_ADDR_WIDTH-2){1'b0}}};
								4'h6: read_value = C_LOOP_FIFO_A_SIZE + C_LOOP_FIFO_B_SIZE;
								4'h7: read_value = C_EXTRACT_FIFO_SIZE;
								4'h8: read_value = overflow_count_a[31:0];
								4'h9: read_value = overflow_count_a[63:32];
								4'hA: read_value = overflow_count_b[31:0];
								4'hB: read_value = overflow_count_b[63:32];
							endcase
						end else if(C_AXI_WIDTH == 64) begin
							case(s_axi_araddr[5:3])
								3'h0: read_value = {(C_NUM_SCRIPTS == 16) ? script_en : {{(32-2*C_NUM_SCRIPTS){1'b0}}, script_en}, log_id, 13'd0, log_en, srst, enable};
								3'h1: read_value = {C_NUM_SCRIPTS, 29'd0, C_ENABLE_CHECKSUM[0], C_ENABLE_EDIT[0], C_ENABLE_COMPARE[0]};
								3'h2: read_value = {'d1, {(C_ADDR_WIDTH-2){1'b0}}, C_MAX_SCRIPT_SIZE};
								3'h3: read_value = {C_EXTRACT_FIFO_SIZE, C_LOOP_FIFO_A_SIZE + C_LOOP_FIFO_B_SIZE};
								3'h4: read_value = overflow_count_a;
								3'h5: read_value = overflow_count_b;
							endcase
						end
					end
				end

				2'd1: begin
					// MEM_A address
					read_ready = mem_a_done;
					read_value = mem_a_rdata;
					mem_a_rreq = 1'b1;
				end

				2'd2: begin
					// MEM_B address
					read_ready = mem_b_done;
					read_value = mem_b_rdata;
					mem_b_rreq = 1'b1;
				end
			endcase
		end

		// Handle write requests

		if(write_req) begin
			write_ready = 1'b1;

			case(write_addr[C_ADDR_WIDTH-1:C_ADDR_WIDTH-2])
				2'd0: begin
					if(write_addr <= 'd47) begin
						// Register address
						write_ready = 1'b1;
					end
				end

				2'd1: begin
					// MEM_A address
					write_ready = mem_a_done;
					mem_a_wreq = 1'b1;
				end

				2'd2: begin
					// MEM_B address
					write_ready = mem_b_done;
					mem_b_wreq = 1'b1;
				end
			endcase
		end
	end

	eth_frame_detector_axi_dram #(C_AXI_WIDTH, C_ADDR_WIDTH - 2) U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(mem_a_rreq),
		.read_addr(s_axi_araddr[C_ADDR_WIDTH-3:0]),

		.write_req(mem_a_wreq),
		.write_mask(write_mask),
		.write_addr(write_addr[C_ADDR_WIDTH-3:0]),
		.write_data(s_axi_wdata),

		.done(mem_a_done),

		// MEM_A

		.mem_req(mem_a_req),
		.mem_addr(mem_a_addr),
		.mem_we(mem_a_wenable),
		.mem_wdata(mem_a_wdata),
		.mem_rdata(mem_a_rdata),
		.mem_ack(mem_a_ack)
	);

	eth_frame_detector_axi_dram #(C_AXI_WIDTH, C_ADDR_WIDTH - 2) U2
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(mem_b_rreq),
		.read_addr(s_axi_araddr[C_ADDR_WIDTH-3:0]),

		.write_req(mem_b_wreq),
		.write_mask(write_mask),
		.write_addr(write_addr[C_ADDR_WIDTH-3:0]),
		.write_data(s_axi_wdata),

		.done(mem_b_done),

		// MEM_B

		.mem_req(mem_b_req),
		.mem_addr(mem_b_addr),
		.mem_we(mem_b_wenable),
		.mem_wdata(mem_b_wdata),
		.mem_rdata(mem_b_rdata),
		.mem_ack(mem_b_ack)
	);
endmodule
