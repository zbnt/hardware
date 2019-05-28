/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_stats_collector_axi #(parameter use_fifo = 1)
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

	input logic [63:0] current_time,

	input logic [63:0] tx_bytes,
	input logic [63:0] tx_good,
	input logic [63:0] tx_bad,
	input logic [63:0] rx_bytes,
	input logic [63:0] rx_good,
	input logic [63:0] rx_bad
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

	logic hold, stats_changed;
	logic [31:0] write_mask;
	logic [63:0] time_reg, tx_bytes_reg, tx_good_reg, tx_bad_reg, rx_bytes_reg, rx_good_reg, rx_bad_reg;

	logic fifo_read, fifo_written, fifo_full, fifo_empty, fifo_pop, fifo_busy;
	logic [15:0] fifo_occupancy;
	logic [447:0] fifo_out;
	logic [63:0] fifo_time, fifo_tx_bytes, fifo_tx_good, fifo_tx_bad, fifo_rx_bytes, fifo_rx_good, fifo_rx_bad;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable <= 1'b0;
			srst <= srst & rst_n;
			hold <= 1'b0;

			time_reg <= 64'd0;
			tx_bytes_reg <= 64'd0;
			tx_good_reg <= 64'd0;
			tx_bad_reg <= 64'd0;
			rx_bytes_reg <= 64'd0;
			rx_good_reg <= 64'd0;
			rx_bad_reg <= 64'd0;

			fifo_pop <= 1'b0;
			fifo_busy <= 1'b0;

			fifo_time <= 64'd0;
			fifo_tx_bytes <= 64'd0;
			fifo_tx_good <= 64'd0;
			fifo_tx_bad <= 64'd0;
			fifo_rx_bytes <= 64'd0;
			fifo_rx_good <= 64'd0;
			fifo_rx_bad <= 64'd0;
		end else begin
			// Write to config bits if requested via AXI
			if(write_req && write_addr[11:2] == 10'd0) begin
				enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
				hold <= (s_axi_wdata[2] & write_mask[2]) | (hold & ~write_mask[2]);
			end

			// Update the stored values if they changed and either hold is set to 0 or FIFO is enabled
			if(stats_changed & (use_fifo | ~hold)) begin
				time_reg <= current_time;
				tx_bytes_reg <= tx_bytes;
				tx_good_reg <= tx_good;
				tx_bad_reg <= tx_bad;
				rx_bytes_reg <= rx_bytes;
				rx_good_reg <= rx_good;
				rx_bad_reg <= rx_bad;
			end

			if(write_req && write_addr[11:2] == 10'd2 && ~fifo_busy) begin
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
				fifo_time <= fifo_out[447:384];
				fifo_tx_bytes <= fifo_out[383:320];
				fifo_tx_good <= fifo_out[319:256];
				fifo_tx_bad <= fifo_out[255:192];
				fifo_rx_bytes <= fifo_out[191:128];
				fifo_rx_good <= fifo_out[127:64];
				fifo_rx_bad <= fifo_out[63:0];
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

		stats_changed = (tx_bytes != tx_bytes_reg || tx_good != tx_good_reg || tx_bad != tx_bad_reg || rx_bytes != rx_bytes_reg || rx_good != rx_good_reg || rx_bad != rx_bad_reg);

		// Handle read requests

		if(read_req) begin
			if(s_axi_araddr >= 12'd0 && s_axi_araddr <= 12'd71) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				case(s_axi_araddr[6:2])
					5'd00: read_value = {29'd0, hold, srst, enable};
					5'd01: read_value = {16'd0, fifo_occupancy};
					5'd02: read_value = 32'd0;
					5'd03: read_value = 32'd0;
					5'd04: read_value = use_fifo ? fifo_time[31:0]      : time_reg[31:0];
					5'd05: read_value = use_fifo ? fifo_time[63:32]     : time_reg[63:32];
					5'd06: read_value = use_fifo ? fifo_tx_bytes[31:0]  : tx_bytes_reg[31:0];
					5'd07: read_value = use_fifo ? fifo_tx_bytes[63:32] : tx_bytes_reg[63:32];
					5'd08: read_value = use_fifo ? fifo_tx_good[31:0]   : tx_good_reg[31:0];
					5'd09: read_value = use_fifo ? fifo_tx_good[63:32]  : tx_good_reg[63:32];
					5'd10: read_value = use_fifo ? fifo_tx_bad[31:0]    : tx_bad_reg[31:0];
					5'd11: read_value = use_fifo ? fifo_tx_bad[63:32]   : tx_bad_reg[63:32];
					5'd12: read_value = use_fifo ? fifo_rx_bytes[31:0]  : rx_bytes_reg[31:0];
					5'd13: read_value = use_fifo ? fifo_rx_bytes[63:32] : rx_bytes_reg[63:32];
					5'd14: read_value = use_fifo ? fifo_rx_good[31:0]   : rx_good_reg[31:0];
					5'd15: read_value = use_fifo ? fifo_rx_good[63:32]  : rx_good_reg[63:32];
					5'd16: read_value = use_fifo ? fifo_rx_bad[31:0]    : rx_bad_reg[31:0];
					5'd17: read_value = use_fifo ? fifo_rx_bad[63:32]   : rx_bad_reg[63:32];
				endcase
			end else begin
				// Invalid address, mark as error
				read_ready = 1'b1;
				read_response = 1'b0;
			end
		end

		// Handle write requests

		if(write_req) begin
			if(write_addr[11:2] == 10'd0) begin
				// Register address
				write_ready = 1'b1;
				write_response = 1'b1;
			end else if(write_addr[11:2] == 10'd2) begin
				// Avoid trouble, make the CPU wait until the FIFO has been read
				// Mark as error if the FIFO is empty
				// Mark as success if FIFO is disabled.
				write_ready = ~use_fifo | fifo_empty | fifo_read;
				write_response = ~use_fifo | ~fifo_empty | fifo_read;
			end else begin
				// Invalid address, mark as error
				write_ready = 1'b1;
				write_response = 1'b0;
			end
		end
	end

	if(use_fifo) begin
		stats_fifo U1
		(
			.clk(clk),
			.rst(~rst_n | srst),

			.wr_ack(fifo_written),
			.valid(fifo_read),

			.full(fifo_full),
			.din({current_time, tx_bytes, tx_good, tx_bad, rx_bytes, rx_good, rx_bad}),
			.wr_en(stats_changed & ~fifo_full),

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
	end else begin
		always_comb begin
			fifo_read = 1'b0;
			fifo_written = 1'b0;
			fifo_full = 1'b0;
			fifo_empty = 1'b0;
			fifo_occupancy = 16'd0;
			fifo_out = 448'd0;
		end
	end
endmodule
