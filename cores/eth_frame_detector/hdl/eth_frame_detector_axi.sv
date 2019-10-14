/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_detector_axi #(parameter C_AXI_WIDTH = 32, parameter C_LOG_FIFO_SIZE = 4096)
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

	output logic srst,
	output logic [7:0] match_en,

	// Status

	input logic [63:0] current_time,
	input logic time_running,

	input logic [3:0] match_a,
	input logic [1:0] match_a_id,
	input logic [4:0] match_a_ext_num,
	input logic [127:0] match_a_ext_data,

	input logic [3:0] match_b,
	input logic [1:0] match_b_id,
	input logic [4:0] match_b_ext_num,
	input logic [127:0] match_b_ext_data
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

	logic enable;
	logic [1:0] last_match_a_id, last_match_b_id;

	logic [C_AXI_WIDTH-1:0] write_mask;

	logic mem_a_done, mem_b_done, mem_c_done, mem_d_done;
	logic mem_a_rreq, mem_a_wreq;
	logic mem_b_rreq, mem_b_wreq;
	logic mem_c_rreq, mem_c_wreq;
	logic mem_d_rreq, mem_d_wreq;

	logic fifo_read, fifo_written, fifo_we, fifo_full, fifo_empty, fifo_pop, fifo_busy;
	logic [$clog2(C_LOG_FIFO_SIZE+1)-1:0] fifo_occupancy;
	logic [201:0] fifo_out, fifo_in;
	logic [63:0] fifo_time;
	logic [3:0] fifo_matches;
	logic [4:0] fifo_ext_num;
	logic [127:0] fifo_ext_data;
	logic fifo_match_dir;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable <= 1'b0;
			srst <= srst & rst_n;
			match_en <= 8'd0;

			last_match_a_id <= 2'd0;
			last_match_b_id <= 2'd0;

			fifo_we <= 1'b0;
			fifo_in <= 202'd0;

			fifo_pop <= 1'b0;
			fifo_busy <= 1'b0;

			fifo_time <= 64'd0;
			fifo_matches <= 4'd0;
			fifo_ext_num <= 5'd0;
			fifo_ext_data <= 128'd0;
			fifo_match_dir <= 1'b0;
		end else begin
			if(write_req) begin
				// Write to config bits if requested via AXI
				if(write_addr[15:$clog2(C_AXI_WIDTH/8)] == '0) begin
					enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
					match_en <= (s_axi_wdata[9:2] & write_mask[9:2]) | (match_en & ~write_mask[9:2]);
				end

				// Special FIFO_POP register
				if(C_AXI_WIDTH == 32) begin
					if(~fifo_busy && write_addr[11:2] == 10'd2) begin
						fifo_pop <= 1'b1;
						fifo_busy <= 1'b1;
					end else begin
						fifo_pop <= 1'b0;
					end
				end else if(C_AXI_WIDTH == 64) begin
					if(~fifo_busy && write_addr[11:3] == 9'd1 && |s_axi_wstrb[3:0]) begin
						fifo_pop <= 1'b1;
						fifo_busy <= 1'b1;
					end else begin
						fifo_pop <= 1'b0;
					end
				end else if(C_AXI_WIDTH == 128) begin
					if(~fifo_busy && write_addr[11:4] == 8'd0 && |s_axi_wstrb[11:8]) begin
						fifo_pop <= 1'b1;
						fifo_busy <= 1'b1;
					end else begin
						fifo_pop <= 1'b0;
					end
				end
			end else begin
				fifo_pop <= 1'b0;
				fifo_busy <= 1'b0;
			end

			if(fifo_read) begin
				fifo_time <= fifo_out[63:0];
				fifo_matches <= fifo_out[67:64];
				fifo_ext_num <= fifo_out[72:68];
				fifo_ext_data <= fifo_out[200:73];
				fifo_match_dir <= fifo_out[201];
			end

			if(last_match_a_id != match_a_id && |match_a) begin
				fifo_we <= enable && time_running;
				fifo_in <= {1'b0, match_a_ext_data, match_a_ext_num, match_a, current_time};
				last_match_a_id <= match_a_id;
			end else if(last_match_b_id != match_b_id && |match_b) begin
				fifo_we <= enable && time_running;
				fifo_in <= {1'b1, match_b_ext_data, match_b_ext_num, match_b, current_time};
				last_match_b_id <= match_b_id;
			end else begin
				fifo_we <= 1'b0;
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
			if(s_axi_araddr <= 16'd43) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				if(C_AXI_WIDTH == 32) begin
					case(s_axi_araddr[5:2])
						4'h0: read_value = {22'd0, match_en, srst, enable};
						4'h1: read_value = {{(32-$clog2(C_LOG_FIFO_SIZE+1)){1'd0}}, fifo_occupancy};
						4'h2: read_value = 32'd0;
						4'h3: read_value = 32'd0;
						4'h4: read_value = fifo_time[31:0];
						4'h5: read_value = fifo_time[63:32];
						4'h6: read_value = {11'd0, fifo_ext_num, 4'd0, fifo_matches, 7'd0, fifo_match_dir};
						4'h7: read_value = fifo_ext_data[31:0];
						4'h8: read_value = fifo_ext_data[63:32];
						4'h9: read_value = fifo_ext_data[95:64];
						4'hA: read_value = fifo_ext_data[127:96];
					endcase
				end else if(C_AXI_WIDTH == 64) begin
					case(s_axi_araddr[5:3])
						3'd0: read_value = {{(32-$clog2(C_LOG_FIFO_SIZE+1)){1'd0}}, fifo_occupancy, 22'd0, match_en, srst, enable};
						3'd1: read_value = 64'd0;
						3'd2: read_value = fifo_time;
						3'd3: read_value = {fifo_ext_data[31:0], 11'd0, fifo_ext_num, 4'd0, fifo_matches, 7'd0, fifo_match_dir};
						3'd4: read_value = fifo_ext_data[95:32];
						3'd5: read_value = {32'd0, fifo_ext_data[127:96]};
					endcase
				end else if(C_AXI_WIDTH == 128) begin
					case(s_axi_araddr[5:4])
						2'd0: read_value = {{(96-$clog2(C_LOG_FIFO_SIZE+1)){1'd0}}, fifo_occupancy, 22'd0, match_en, srst, enable};
						2'd1: read_value = {fifo_ext_data[31:0], 11'd0, fifo_ext_num, 4'd0, fifo_matches, 7'd0, fifo_match_dir, fifo_time};
						2'd2: read_value = {32'd0, fifo_ext_data[127:32]};
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
			if(write_addr <= 16'd43) begin
				// Register address
				write_ready = 1'b1;
				write_response = 1'b1;

				if(C_AXI_WIDTH == 32) begin
					if(~fifo_busy && write_addr[11:2] == 10'd2) begin
						write_ready = fifo_read;
					end
				end else if(C_AXI_WIDTH == 64) begin
					if(~fifo_busy && write_addr[11:3] == 9'd1 && |s_axi_wstrb[3:0]) begin
						write_ready = fifo_read;
					end
				end else if(C_AXI_WIDTH == 128) begin
					if(~fifo_busy && write_addr[11:4] == 8'd0 && |s_axi_wstrb[11:8]) begin
						write_ready = fifo_read;
					end
				end
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

	log_fifo #(C_LOG_FIFO_SIZE) U1
	(
		.clk(clk),
		.rst(~rst_n | srst),

		.wr_ack(fifo_written),
		.valid(fifo_read),

		.full(fifo_full),
		.din(fifo_in),
		.wr_en(fifo_we & ~fifo_full),

		.empty(fifo_empty),
		.dout(fifo_out),
		.rd_en((fifo_pop | fifo_full) & ~fifo_empty)
	);

	counter #($clog2(C_LOG_FIFO_SIZE+1)) U2
	(
		.clk(clk),
		.rst(~rst_n | srst),

		.up(fifo_written),
		.down(fifo_read),

		.count(fifo_occupancy)
	);

	eth_frame_detector_axi_dram #(C_AXI_WIDTH) U3
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

	eth_frame_detector_axi_dram #(C_AXI_WIDTH) U4
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

	eth_frame_detector_axi_dram #(C_AXI_WIDTH) U5
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

	eth_frame_detector_axi_dram #(C_AXI_WIDTH) U6
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
