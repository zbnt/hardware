/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_detector_axi
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [15:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [31:0] s_axi_wdata,
	input logic [3:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [15:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [31:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// MEM_A

	output logic mem_a_req,
	output logic mem_a_we,
	input logic mem_a_ack,

	output logic [10:0] mem_a_addr,
	output logic [29:0] mem_a_wdata,
	input logic [29:0] mem_a_rdata,

	// MEM_B

	output logic mem_b_req,
	output logic mem_b_we,
	input logic mem_b_ack,

	output logic [10:0] mem_b_addr,
	output logic [29:0] mem_b_wdata,
	input logic [29:0] mem_b_rdata,

	// Registers

	output logic srst,
	output logic [5:0] match_en,

	// Status

	input logic [63:0] current_time,
	input logic time_running,

	input logic [2:0] match_a,
	input logic [1:0] match_a_id,

	input logic [2:0] match_b,
	input logic [1:0] match_b_id
);
	// Handle AXI4-Lite requests

	logic read_req;
	logic read_ready;
	logic read_response;
	logic [31:0] read_value;

	logic write_req;
	logic write_ready;
	logic write_response;
	logic [15:0] write_addr;

	axi4_lite_slave_rw #(16) U0
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

	logic [31:0] write_mask;

	logic mem_a_done, mem_b_done;
	logic mem_a_rreq, mem_a_wreq, mem_b_rreq, mem_b_wreq;

	logic fifo_read, fifo_written, fifo_we, fifo_full, fifo_empty, fifo_pop, fifo_busy;
	logic [69:0] fifo_out, fifo_in;
	logic [10:0] fifo_occupancy;
	logic [63:0] fifo_time;
	logic [5:0] fifo_matches;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable <= 1'b0;
			srst <= srst & rst_n;
			match_en <= 6'd0;

			last_match_a_id <= 2'd0;
			last_match_b_id <= 2'd0;

			fifo_we <= 1'b0;
			fifo_in <= 70'd0;

			fifo_pop <= 1'b0;
			fifo_busy <= 1'b0;

			fifo_time <= 64'd0;
			fifo_matches <= 6'd0;
		end else begin
			// Write to config bits if requested via AXI
			if(write_req && write_addr[15:2] == 14'd0) begin
				enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
				match_en <= (s_axi_wdata[7:2] & write_mask[7:2]) | (match_en & ~write_mask[7:2]);
			end

			if(write_req && write_addr[15:2] == 14'd2 && ~fifo_busy) begin
				// Special FIFO_POP register
				fifo_pop <= 1'b1;
				fifo_busy <= 1'b1;
			end else begin
				fifo_pop <= 1'b0;
			end

			if(~write_req) begin
				fifo_pop <= 1'b0;
				fifo_busy <= 1'b0;
			end

			if(fifo_read) begin
				fifo_time <= fifo_out[63:0];
				fifo_matches <= fifo_out[69:64];
			end

			if(enable && time_running && ((last_match_a_id != match_a_id && (|match_a)) || (last_match_b_id != match_b_id && (|match_b)))) begin
				fifo_we <= 1'b1;
			end else begin
				fifo_we <= 1'b0;
			end

			fifo_in <= {match_b, match_a, current_time};

			last_match_a_id <= match_a_id;
			last_match_b_id <= match_b_id;
		end

		// SRST must be writable even after it has been set to 1
		if(rst_n & write_req && write_addr[15:2] == 14'd0) begin
			srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
		end
	end

	always_comb begin
		write_mask = {{8{s_axi_wstrb[3]}}, {8{s_axi_wstrb[2]}}, {8{s_axi_wstrb[1]}}, {8{s_axi_wstrb[0]}}};

		read_ready = 1'b0;
		read_response = 1'b0;
		read_value = 32'd0;

		write_ready = 1'b0;
		write_response = 1'b0;

		mem_a_rreq = 1'b0;
		mem_a_wreq = 1'b0;
		mem_b_rreq = 1'b0;
		mem_b_wreq = 1'b0;

		// Handle read requests

		if(read_req) begin
			if(s_axi_araddr[15:2] <= 14'd5) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				case(s_axi_araddr[4:2])
					3'd0: read_value = {24'd0, match_en, srst, enable};
					3'd1: read_value = {21'd0, fifo_occupancy};
					3'd2: read_value = 32'd0;
					3'd3: read_value = fifo_time[31:0];
					3'd4: read_value = fifo_time[63:32];
					3'd5: read_value = {26'd0, fifo_matches};
				endcase
			end else if(s_axi_araddr[15:13] == 3'd1 && s_axi_araddr[12:2] < 11'd1536) begin
				// MEM_A address
				read_ready = mem_a_done;
				read_response = 1'b1;
				mem_a_rreq = 1'b1;
				read_value = {2'd0, mem_a_rdata};
			end else if(s_axi_araddr[15:13] == 3'd2 && s_axi_araddr[12:2] < 11'd1536) begin
				// MEM_B address
				read_ready = mem_b_done;
				read_response = 1'b1;
				mem_b_rreq = 1'b1;
				read_value = {2'd0, mem_b_rdata};
			end else begin
				// Invalid address, mark as error
				read_ready = 1'b1;
				read_response = 1'b0;
			end
		end

		// Handle write requests

		if(write_req) begin
			if(write_addr[15:2] == 14'd0) begin
				// Register address
				write_ready = 1'b1;
				write_response = 1'b1;
			end else if(write_addr[15:2] == 14'd2) begin
				// Wait until the FIFO has been read, do nothing if the FIFO is empty
				if(~fifo_empty) begin
					write_ready = fifo_read;
					write_response = 1'b1;
				end else begin
					write_ready = 1'b1;
					write_response = 1'b1;
				end
			end else if(write_addr[15:13] == 3'd1 && write_addr[12:2] < 11'd1536) begin
				// MEM_A address
				write_ready = mem_a_done;
				write_response = 1'b1;
				mem_a_wreq = 1'b1;
			end else if(write_addr[15:13] == 3'd2 && write_addr[12:2] < 11'd1536) begin
				// MEM_B address
				write_ready = mem_b_done;
				write_response = 1'b1;
				mem_b_wreq = 1'b1;
			end else begin
				// Invalid address, mark as error
				write_ready = 1'b1;
				write_response = 1'b0;
			end
		end
	end

	log_fifo U1
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

	counter #(11) U2
	(
		.clk(clk),
		.rst(~rst_n | srst),

		.up(fifo_written),
		.down(fifo_read),

		.count(fifo_occupancy)
	);

	eth_frame_detector_axi_dram U3
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(mem_a_rreq),
		.read_addr(s_axi_araddr[12:2]),

		.write_req(mem_a_wreq),
		.write_mask(write_mask),
		.write_addr(write_addr[12:2]),
		.write_data(s_axi_wdata[29:0]),

		.done(mem_a_done),

		// MEM_A

		.mem_req(mem_a_req),
		.mem_we(mem_a_we),
		.mem_ack(mem_a_ack),

		.mem_addr(mem_a_addr),
		.mem_wdata(mem_a_wdata),
		.mem_rdata(mem_a_rdata)
	);

	eth_frame_detector_axi_dram U4
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(mem_b_rreq),
		.read_addr(s_axi_araddr[12:2]),

		.write_req(mem_b_wreq),
		.write_mask(write_mask),
		.write_addr(write_addr[12:2]),
		.write_data(s_axi_wdata[29:0]),

		.done(mem_b_done),

		// MEM_B

		.mem_req(mem_b_req),
		.mem_we(mem_b_we),
		.mem_ack(mem_b_ack),

		.mem_addr(mem_b_addr),
		.mem_wdata(mem_b_wdata),
		.mem_rdata(mem_b_rdata)
	);
endmodule