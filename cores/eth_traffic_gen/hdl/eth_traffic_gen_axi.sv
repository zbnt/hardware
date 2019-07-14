/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_axi
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

	// MEM

	output logic [10:0] mem_addr,
	output logic [7:0] mem_wdata,
	output logic mem_we,
	input logic [7:0] mem_rdata,

	// FIFOs

	input logic fifo_trigger,
	output logic fifo_ready,

	// Registers

	output logic tx_enable,

	input logic tx_busy,
	input logic [1:0] tx_state,
	input logic [10:0] tx_ptr,

	output logic [11:0] headers_size,
	output logic [15:0] payload_size,
	output logic [31:0] frame_delay,

	output logic use_burst,
	output logic [15:0] burst_on_time,
	output logic [15:0] burst_off_time
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

	logic fifo_rst;
	logic frame_delay_src;
	logic payload_size_src;

	logic frame_delay_we, frame_delay_wbusy;
	logic payload_size_we, payload_size_wbusy;

	logic [10:0] frame_delay_avail;
	logic [10:0] payload_size_avail;

	logic [31:0] write_mask;

	logic mem_read_req, mem_write_req;
	logic mem_read_ready, mem_write_ready;
	logic mem_read_response, mem_write_response;
	logic [31:0] mem_read_value;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			tx_enable <= 1'b0;
			fifo_rst <= 1'b0;
			frame_delay_src <= 1'b0;
			payload_size_src <= 1'b0;
			use_burst <= 1'b0;
			headers_size <= 12'd14;
			burst_on_time <= 16'd0;
			burst_off_time <= 16'd0;
		end else if(write_req) begin
			// TG_CFG and TG_HSIZE work like regular registers.
			// TG_PSIZE and TG_FDELAY writes are handled in a different way in order to support writing to FIFOs, see eth_traffic_gen_fifo.
			// DRAM access also works in a special way, see eth_traffic_gen_axi_dram.

			if(write_addr[11:5] == 7'd0) begin
				case(write_addr[4:2])
					3'd0: begin
						tx_enable <= (s_axi_wdata[0] & write_mask[0]) | (tx_enable & ~write_mask[0]);
						fifo_rst <= (s_axi_wdata[1] & write_mask[1]) | (fifo_rst & ~write_mask[1]);
						frame_delay_src <= (s_axi_wdata[2] & write_mask[2]) | (frame_delay_src & ~write_mask[2]);
						payload_size_src <= (s_axi_wdata[3] & write_mask[3]) | (payload_size_src & ~write_mask[3]);
						use_burst <= (s_axi_wdata[4] & write_mask[4]) | (use_burst & ~write_mask[4]);
					end

					3'd2: begin
						headers_size <= (s_axi_wdata[11:0] & write_mask[11:0]) | (headers_size & ~write_mask[11:0]);
					end

					3'd3: begin
						if(~frame_delay_wbusy) begin
							frame_delay_we <= 1'b1;
							frame_delay_wbusy <= 1'b1;
						end else begin
							frame_delay_we <= 1'b0;
						end
					end

					3'd4: begin
						if(~payload_size_wbusy) begin
							payload_size_we <= 1'b1;
							payload_size_wbusy <= 1'b1;
						end else begin
							payload_size_we <= 1'b0;
						end
					end

					3'd6: begin
						burst_on_time <= (s_axi_wdata[15:0] & write_mask[15:0]) | (burst_on_time & ~write_mask[15:0]);
						burst_off_time <= (s_axi_wdata[31:16] & write_mask[31:16]) | (burst_off_time & ~write_mask[31:16]);
					end
				endcase
			end
		end else begin
			frame_delay_we <= 1'b0;
			payload_size_we <= 1'b0;
			frame_delay_wbusy <= 1'b0;
			payload_size_wbusy <= 1'b0;
		end
	end

	always_comb begin
		write_mask = {{8{s_axi_wstrb[3]}}, {8{s_axi_wstrb[2]}}, {8{s_axi_wstrb[1]}}, {8{s_axi_wstrb[0]}}};

		read_ready = 1'b0;
		read_response = 1'b0;
		read_value = 32'd0;

		write_ready = 1'b0;
		write_response = 1'b0;

		mem_read_req = 1'b0;
		mem_write_req = 1'b0;

		// Handle read requests

		if(read_req) begin
			if(s_axi_araddr >= 12'd0 && s_axi_araddr <= 12'd27) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				case(s_axi_araddr[4:2])
					3'd0: read_value = {27'd0, use_burst, payload_size_src, frame_delay_src, fifo_rst, tx_enable};
					3'd1: read_value = {17'd0, fifo_ready, tx_ptr, tx_state, tx_busy};
					3'd2: read_value = {20'd0, headers_size};
					3'd3: read_value = frame_delay;
					3'd4: read_value = {16'd0, payload_size};
					3'd5: read_value = {5'd0, frame_delay_avail, 5'd0, payload_size_avail};
					3'd6: read_value = {burst_off_time, burst_on_time};
				endcase
			end else if(s_axi_araddr >= 12'h800) begin
				// DRAM address, handled by eth_traffic_gen_axi_dram
				read_ready = mem_read_ready;
				read_response = mem_read_response;
				read_value = mem_read_value;
				mem_read_req = 1'b1;
			end else begin
				// Invalid address, mark as error
				read_ready = 1'b1;
				read_response = 1'b0;
			end
		end

		// Handle write requests

		if(write_req) begin
			if(write_addr <= 12'd27) begin
				// Register address
				write_ready = 1'b1;
				write_response = (write_addr[4:2] != 3'd1 && write_addr[4:2] != 3'd5);
			end else if(write_addr >= 12'h800) begin
				// DRAM address, handled by eth_traffic_gen_axi_dram
				write_ready = mem_write_ready;
				write_response = mem_write_response;
				mem_write_req = 1'b1;
			end else begin
				// Invalid address, mark as error
				write_ready = 1'b1;
				write_response = 1'b0;
			end
		end
	end

	// Handle FIFOs

	eth_traffic_gen_fifo U1
	(
		.clk(clk),
		.rst(~rst_n),
		.fifo_rst(fifo_rst),
		.trigger(fifo_trigger),

		.ready(fifo_ready),

		.frame_delay_src(frame_delay_src),
		.frame_delay_wen(frame_delay_we),
		.frame_delay_req(s_axi_wdata & write_mask),
		.frame_delay_avail(frame_delay_avail),

		.payload_size_src(payload_size_src),
		.payload_size_wen(payload_size_we),
		.payload_size_req(s_axi_wdata[15:0] & write_mask[15:0]),
		.payload_size_avail(payload_size_avail),

		.frame_delay(frame_delay),
		.payload_size(payload_size)
	);

	// Handle DRAM read/write requests

	eth_traffic_gen_axi_dram U2
	(
		.clk(clk),
		.rst(~rst_n),

		.mem_addr(mem_addr),
		.mem_wdata(mem_wdata),
		.mem_we(mem_we),
		.mem_rdata(mem_rdata),

		.read_req(mem_read_req),
		.read_addr(s_axi_araddr),

		.read_ready(mem_read_ready),
		.read_response(mem_read_response),
		.read_value(mem_read_value),

		.write_req(mem_write_req),
		.write_addr(write_addr),
		.write_value(s_axi_wdata),
		.write_mask(s_axi_wstrb),

		.write_ready(mem_write_ready),
		.write_response(mem_write_response)
	);
endmodule
