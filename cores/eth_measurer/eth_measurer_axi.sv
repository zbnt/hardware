/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_measurer_axi
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [11:0] s_axi_awaddr,
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

	input logic [11:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [31:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// Registers

	output logic enable,
	output logic srst,
	output logic [15:0] padding,
	output logic [31:0] delay,
	output logic [31:0] timeout,

	input logic [63:0] current_time,

	input logic ping_pong_done,
	input logic [31:0] ping_time,
	input logic [31:0] pong_time,
	input logic [63:0] ping_pongs_good,
	input logic [63:0] pings_lost,
	input logic [63:0] pongs_lost
);
	// Handle AXI4-Lite requests

	logic read_req;
	logic read_ready;
	logic read_response;
	logic [31:0] read_value;

	logic write_req;
	logic write_ready;
	logic write_response;
	logic [11:0] write_addr;

	axi4_lite_slave_rw #(12) U0
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

	logic [31:0] write_mask;

	logic fifo_read, fifo_written, fifo_full, fifo_empty, fifo_pop, fifo_busy;
	logic [15:0] fifo_occupancy;
	logic [319:0] fifo_out;
	logic [63:0] fifo_time, fifo_ping_time, fifo_pong_time, fifo_ping_pongs_good, fifo_pings_lost, fifo_pongs_lost;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable <= 1'b0;
			srst <= srst & rst_n;
			padding <= 16'd38;

			fifo_pop <= 1'b0;
			fifo_busy <= 1'b0;

			fifo_time <= 64'd0;
			fifo_ping_time <= 32'd0;
			fifo_pong_time <= 32'd0;
			fifo_ping_pongs_good <= 64'd0;
			fifo_pings_lost <= 64'd0;
			fifo_pongs_lost <= 64'd0;
		end else begin
			// Write to config bits if requested via AXI
			if(write_req && write_addr[11:4] == 8'd0) begin
				case(write_addr[3:2])
					2'd0: begin
						enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
					end

					2'd1: begin
						padding <= (s_axi_wdata[15:0] & write_mask[15:0]) | (padding & ~write_mask[15:0]);
					end

					2'd2: begin
						delay <= (s_axi_wdata & write_mask) | (delay & ~write_mask);
					end

					2'd3: begin
						timeout <= (s_axi_wdata & write_mask) | (timeout & ~write_mask);
					end
				endcase
			end

			if(write_req && write_addr[11:2] == 10'd5 && ~fifo_busy) begin
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
				fifo_time <= fifo_out[319:256];
				fifo_ping_time <= fifo_out[255:224];
				fifo_pong_time <= fifo_out[223:192];
				fifo_ping_pongs_good <= fifo_out[191:128];
				fifo_pings_lost <= fifo_out[127:64];
				fifo_pongs_lost <= fifo_out[63:0];
			end
		end

		// SRST must be writable even after it has been set to 1
		if(rst_n & write_req && write_addr[11:2] == 10'd0) begin
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

		// Handle read requests

		if(read_req) begin
			if(s_axi_araddr >= 12'd0 && s_axi_araddr <= 12'd63) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				case(s_axi_araddr[5:2])
					4'h0: read_value = {30'd0, srst, enable};
					4'h1: read_value = padding;
					4'h2: read_value = delay;
					4'h3: read_value = timeout;
					4'h4: read_value = {16'd0, fifo_occupancy};
					4'h5: read_value = 32'd0;
					4'h6: read_value = fifo_time[31:0];
					4'h7: read_value = fifo_time[63:32];
					4'h8: read_value = fifo_ping_time;
					4'h9: read_value = fifo_pong_time;
					4'hA: read_value = fifo_ping_pongs_good[31:0];
					4'hB: read_value = fifo_ping_pongs_good[63:32];
					4'hC: read_value = fifo_pings_lost[31:0];
					4'hD: read_value = fifo_pings_lost[63:32];
					4'hE: read_value = fifo_pongs_lost[31:0];
					4'hF: read_value = fifo_pongs_lost[63:32];
				endcase
			end else begin
				// Invalid address, mark as error
				read_ready = 1'b1;
				read_response = 1'b0;
			end
		end

		// Handle write requests

		if(write_req) begin
			if(write_addr[11:2] <= 10'd3) begin
				// Register address
				write_ready = 1'b1;
				write_response = 1'b1;
			end else if(write_addr[11:2] == 10'd5) begin
				// Avoid trouble, make the CPU wait until the FIFO has been read
				// Do nothing if the FIFO is empty
				if(~fifo_empty) begin
					write_ready = fifo_read;
					write_response = 1'b1;
				end else begin
					write_ready = 1'b1;
					write_response = 1'b1;
				end
			end else begin
				// Invalid address, mark as error
				write_ready = 1'b1;
				write_response = 1'b0;
			end
		end
	end

	latency_fifo U1
	(
		.clk(clk),
		.rst(~rst_n | srst),

		.wr_ack(fifo_written),
		.valid(fifo_read),

		.full(fifo_full),
		.din({current_time, ping_time, pong_time, ping_pongs_good, pings_lost, pongs_lost}),
		.wr_en(ping_pong_done & ~fifo_full),

		.empty(fifo_empty),
		.dout(fifo_out),
		.rd_en((fifo_pop | fifo_full) & ~fifo_empty)
	);

	counter #(16) U2
	(
		.clk(clk),
		.rst(~rst_n | srst),

		.up(fifo_written),
		.down(fifo_read),

		.count(fifo_occupancy)
	);
endmodule
