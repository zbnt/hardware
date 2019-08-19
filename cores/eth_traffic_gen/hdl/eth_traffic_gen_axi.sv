/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_axi #(parameter axi_width = 32)
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [11:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [axi_width-1:0] s_axi_wdata,
	input logic [(axi_width/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [11:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [axi_width-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// MEM

	output logic [10:0] mem_addr,
	output logic [axi_width-1:0] mem_wdata,
	output logic [(axi_width/8)-1:0] mem_we,
	input logic [axi_width-1:0] mem_rdata,

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
	logic [axi_width-1:0] read_value;

	logic write_req;
	logic write_ready;
	logic write_response;
	logic [11:0] write_addr;

	axi4_lite_slave_rw #(12, axi_width) U0
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

	logic [axi_width-1:0] write_mask;
	logic mem_wdone, mem_rdone;
	logic mem_wbusy, mem_rbusy;
	logic srst;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			tx_enable <= 1'b0;
			srst <= srst & rst_n;
			use_burst <= 1'b0;

			headers_size <= 12'd14;
			frame_delay <= 32'd12;
			payload_size <= 16'd46;

			burst_on_time <= 16'd0;
			burst_off_time <= 16'd0;

			mem_rdone <= 1'b0;
			mem_wdone <= 1'b0;
			mem_rbusy <= 1'b0;
			mem_wbusy <= 1'b0;
			mem_addr <= 11'd0;
			mem_wdata <= '0;
			mem_we <= '0;
		end else begin
			mem_rdone <= mem_rbusy;
			mem_wdone <= mem_wbusy;
			mem_rbusy <= 1'b0;
			mem_wbusy <= 1'b0;
			mem_we <= '0;

			if(read_req && s_axi_araddr >= 12'h800) begin
				mem_addr <= s_axi_araddr[10:0];
				mem_rbusy <= 1'b1;
			end else if(write_req && write_addr >= 12'h800) begin
				mem_addr <= write_addr[10:0];
				mem_wdata <= s_axi_wdata;
				mem_we <= s_axi_wstrb;
				mem_wbusy <= 1'b1;
			end

			if(write_req && write_addr[11:5] == 7'd0) begin
				if(axi_width == 32) begin
					case(write_addr[4:2])
						3'd0: begin
							tx_enable <= (s_axi_wdata[0] & write_mask[0]) | (tx_enable & ~write_mask[0]);
							srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
							use_burst <= (s_axi_wdata[2] & write_mask[2]) | (use_burst & ~write_mask[2]);
						end

						3'd2: begin
							headers_size <= (s_axi_wdata[11:0] & write_mask[11:0]) | (headers_size & ~write_mask[11:0]);
						end

						3'd3: begin
							frame_delay <= (s_axi_wdata & write_mask) | (frame_delay & ~write_mask);
						end

						3'd4: begin
							payload_size <= (s_axi_wdata[15:0] & write_mask[15:0]) | (payload_size & ~write_mask[15:0]);
						end

						3'd5: begin
							burst_on_time <= (s_axi_wdata[15:0] & write_mask[15:0]) | (burst_on_time & ~write_mask[15:0]);
							burst_off_time <= (s_axi_wdata[31:16] & write_mask[31:16]) | (burst_off_time & ~write_mask[31:16]);
						end
					endcase
				end else if(axi_width == 64) begin
					case(write_addr[4:3])
						2'd0: begin
							tx_enable <= (s_axi_wdata[0] & write_mask[0]) | (tx_enable & ~write_mask[0]);
							srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
							use_burst <= (s_axi_wdata[2] & write_mask[2]) | (use_burst & ~write_mask[2]);
						end

						2'd1: begin
							headers_size <= (s_axi_wdata[11:0] & write_mask[11:0]) | (headers_size & ~write_mask[11:0]);
							frame_delay <= (s_axi_wdata[63:32] & write_mask[63:32]) | (frame_delay & ~write_mask[63:32]);
						end

						2'd2: begin
							payload_size <= (s_axi_wdata[15:0] & write_mask[15:0]) | (payload_size & ~write_mask[15:0]);
							burst_on_time <= (s_axi_wdata[47:32] & write_mask[47:32]) | (burst_on_time & ~write_mask[47:32]);
							burst_off_time <= (s_axi_wdata[63:48] & write_mask[63:48]) | (burst_off_time & ~write_mask[63:48]);
						end
					endcase
				end else if(axi_width == 128) begin
					case(write_addr[4])
						1'd0: begin
							tx_enable <= (s_axi_wdata[0] & write_mask[0]) | (tx_enable & ~write_mask[0]);
							srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
							use_burst <= (s_axi_wdata[2] & write_mask[2]) | (use_burst & ~write_mask[2]);

							headers_size <= (s_axi_wdata[75:64] & write_mask[75:64]) | (headers_size & ~write_mask[75:64]);
							frame_delay <= (s_axi_wdata[127:96] & write_mask[127:96]) | (frame_delay & ~write_mask[127:96]);
						end

						1'd1: begin
							payload_size <= (s_axi_wdata[15:0] & write_mask[15:0]) | (payload_size & ~write_mask[15:0]);
							burst_on_time <= (s_axi_wdata[47:32] & write_mask[47:32]) | (burst_on_time & ~write_mask[47:32]);
							burst_off_time <= (s_axi_wdata[63:48] & write_mask[63:48]) | (burst_off_time & ~write_mask[63:48]);
						end
					endcase
				end
			end
		end

		// SRST must be writable even after it has been set to 1
		if(rst_n & write_req && write_addr[11:$clog2(axi_width/8)] == '0) begin
			srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
		end
	end

	always_comb begin
		read_ready = 1'b0;
		read_response = 1'b0;
		read_value = '0;

		write_ready = 1'b0;
		write_response = 1'b0;

		for(int i = 0; i < axi_width; ++i) begin
			write_mask[i] = s_axi_wstrb[i/8];
		end

		// Handle read requests

		if(read_req) begin
			if(s_axi_araddr <= 12'd27) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				if(axi_width == 32) begin
					case(s_axi_araddr[4:2])
						3'd0: read_value = {29'd0, use_burst, srst, tx_enable};
						3'd1: read_value = {18'd0, tx_ptr, tx_state, tx_busy};
						3'd2: read_value = {20'd0, headers_size};
						3'd3: read_value = frame_delay;
						3'd4: read_value = {16'd0, payload_size};
						3'd5: read_value = {burst_off_time, burst_on_time};
					endcase
				end else if(axi_width == 64) begin
					case(s_axi_araddr[4:3])
						2'd0: read_value = {18'd0, tx_ptr, tx_state, tx_busy, 29'd0, use_burst, srst, tx_enable};
						2'd1: read_value = {frame_delay, 20'd0, headers_size};
						2'd2: read_value = {burst_off_time, burst_on_time, 16'd0, payload_size};
					endcase
				end else if(axi_width == 128) begin
					case(s_axi_araddr[4])
						2'd0: begin
							read_value[63:0] = {18'd0, tx_ptr, tx_state, tx_busy, 29'd0, use_burst, srst, tx_enable};
							read_value[127:64] = {frame_delay, 20'd0, headers_size};
						end

						2'd1: begin
							read_value[63:0] = {burst_off_time, burst_on_time, 16'd0, payload_size};
							read_value[127:64] = 64'd0;
						end
					endcase
				end
			end else if(s_axi_araddr >= 12'h800) begin
				// DRAM address
				read_ready = mem_rdone;
				read_response = 1'b1;
				read_value = mem_rdata;
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
				write_response = 1'b1;
			end else if(write_addr >= 12'h800) begin
				// DRAM address
				write_ready = mem_wdone;
				write_response = 1'b1;
			end else begin
				// Invalid address, mark as error
				write_ready = 1'b1;
				write_response = 1'b0;
			end
		end
	end
endmodule
