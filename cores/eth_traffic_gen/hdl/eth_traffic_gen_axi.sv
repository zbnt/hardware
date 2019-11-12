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

	input logic [12:0] s_axi_awaddr,
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

	input logic [12:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [axi_width-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// MEM_FRAME

	output logic [10-$clog2(axi_width/8):0] mem_frame_addr,
	output logic [axi_width-1:0] mem_frame_wdata,
	output logic [(axi_width/8)-1:0] mem_frame_we,
	input logic [axi_width-1:0] mem_frame_rdata,

	// MEM_PATTERN

	output logic [7-$clog2(axi_width/8):0] mem_pattern_addr,
	output logic [axi_width-1:0] mem_pattern_wdata,
	output logic [(axi_width/8)-1:0] mem_pattern_we,
	input logic [axi_width-1:0] mem_pattern_rdata,

	// Registers

	output logic tx_enable,

	input logic [1:0] tx_state,
	input logic [10:0] tx_ptr,

	output logic [15:0] frame_size,
	output logic [31:0] frame_delay,

	output logic use_burst,
	output logic [15:0] burst_on_time,
	output logic [15:0] burst_off_time,

	output logic lfsr_seed_req,
	output logic [7:0] lfsr_seed_val
);
	// Handle AXI4-Lite requests

	logic read_req;
	logic read_ready;
	logic read_response;
	logic [axi_width-1:0] read_value;

	logic write_req;
	logic write_ready;
	logic write_response;
	logic [12:0] write_addr;

	axi4_lite_slave_rw #(13, axi_width) U0
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
	logic mem_frame_wdone, mem_frame_rdone, mem_frame_wbusy, mem_frame_rbusy;
	logic mem_pattern_wdone, mem_pattern_rdone, mem_pattern_wbusy, mem_pattern_rbusy;
	logic srst;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			tx_enable <= 1'b0;
			srst <= srst & rst_n;
			use_burst <= 1'b0;

			frame_size <= 16'd60;
			frame_delay <= 32'd12;

			burst_on_time <= 16'd0;
			burst_off_time <= 16'd0;

			lfsr_seed_req <= 1'b0;
			lfsr_seed_val <= 8'd0;

			mem_frame_rdone <= 1'b0;
			mem_frame_wdone <= 1'b0;
			mem_frame_rbusy <= 1'b0;
			mem_frame_wbusy <= 1'b0;
			mem_frame_addr <= '0;
			mem_frame_wdata <= '0;
			mem_frame_we <= '0;

			mem_pattern_rdone <= 1'b0;
			mem_pattern_wdone <= 1'b0;
			mem_pattern_rbusy <= 1'b0;
			mem_pattern_wbusy <= 1'b0;
			mem_pattern_addr <= '0;
			mem_pattern_wdata <= '0;
			mem_pattern_we <= '0;
		end else begin
			mem_frame_rdone <= mem_frame_rbusy;
			mem_frame_wdone <= mem_frame_wbusy;
			mem_frame_rbusy <= 1'b0;
			mem_frame_wbusy <= 1'b0;
			mem_frame_we <= '0;

			mem_pattern_rdone <= mem_pattern_rbusy;
			mem_pattern_wdone <= mem_pattern_wbusy;
			mem_pattern_rbusy <= 1'b0;
			mem_pattern_wbusy <= 1'b0;
			mem_pattern_we <= '0;

			lfsr_seed_req <= 1'b0;

			if(read_req && s_axi_araddr[12:11] == 2'b01) begin
				mem_frame_addr <= s_axi_araddr[10:$clog2(axi_width/8)];
				mem_frame_rbusy <= 1'b1;
			end else if(write_req && write_addr[12:11] == 2'b01) begin
				mem_frame_addr <= write_addr[10:$clog2(axi_width/8)];
				mem_frame_wdata <= s_axi_wdata;
				mem_frame_we <= s_axi_wstrb;
				mem_frame_wbusy <= 1'b1;
			end

			if(read_req && s_axi_araddr[12:8] == 5'b10000) begin
				mem_pattern_addr <= s_axi_araddr[7:$clog2(axi_width/8)];
				mem_pattern_rbusy <= 1'b1;
			end else if(write_req && write_addr[12:8] == 5'b10000) begin
				mem_pattern_addr <= write_addr[7:$clog2(axi_width/8)];
				mem_pattern_wdata <= s_axi_wdata;
				mem_pattern_we <= s_axi_wstrb;
				mem_pattern_wbusy <= 1'b1;
			end

			if(write_req && write_addr[12:5] == 8'd0) begin
				if(axi_width == 32) begin
					case(write_addr[4:2])
						3'd0: begin
							tx_enable <= (s_axi_wdata[0] & write_mask[0]) | (tx_enable & ~write_mask[0]);
							srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
							use_burst <= (s_axi_wdata[2] & write_mask[2]) | (use_burst & ~write_mask[2]);
							lfsr_seed_req <= (s_axi_wdata[3] & write_mask[3]) | (lfsr_seed_req & ~write_mask[3]);
						end

						3'd2: begin
							frame_size <= (s_axi_wdata[15:0] & write_mask[15:0]) | (frame_size & ~write_mask[15:0]);
						end

						3'd3: begin
							frame_delay <= (s_axi_wdata & write_mask) | (frame_delay & ~write_mask);
						end

						3'd4: begin
							burst_on_time <= (s_axi_wdata[15:0] & write_mask[15:0]) | (burst_on_time & ~write_mask[15:0]);
							burst_off_time <= (s_axi_wdata[31:16] & write_mask[31:16]) | (burst_off_time & ~write_mask[31:16]);
						end

						3'd5: begin
							lfsr_seed_val[7:0] <= (s_axi_wdata & write_mask) | (lfsr_seed_val[7:0] & ~write_mask);
						end
					endcase
				end else if(axi_width == 64) begin
					case(write_addr[4:3])
						2'd0: begin
							tx_enable <= (s_axi_wdata[0] & write_mask[0]) | (tx_enable & ~write_mask[0]);
							srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
							use_burst <= (s_axi_wdata[2] & write_mask[2]) | (use_burst & ~write_mask[2]);
							lfsr_seed_req <= (s_axi_wdata[3] & write_mask[3]) | (lfsr_seed_req & ~write_mask[3]);
						end

						2'd1: begin
							frame_size <= (s_axi_wdata[15:0] & write_mask[15:0]) | (frame_size & ~write_mask[15:0]);
							frame_delay <= (s_axi_wdata[63:32] & write_mask[63:32]) | (frame_delay & ~write_mask[63:32]);
						end

						2'd2: begin
							burst_on_time <= (s_axi_wdata[15:0] & write_mask[15:0]) | (burst_on_time & ~write_mask[15:0]);
							burst_off_time <= (s_axi_wdata[31:16] & write_mask[31:16]) | (burst_off_time & ~write_mask[31:16]);
							lfsr_seed_val <= (s_axi_wdata[39:32] & write_mask[39:32]) | (lfsr_seed_val & ~write_mask[39:32]);
						end
					endcase
				end else if(axi_width == 128) begin
					case(write_addr[4])
						1'd0: begin
							tx_enable <= (s_axi_wdata[0] & write_mask[0]) | (tx_enable & ~write_mask[0]);
							srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
							use_burst <= (s_axi_wdata[2] & write_mask[2]) | (use_burst & ~write_mask[2]);
							lfsr_seed_req <= (s_axi_wdata[3] & write_mask[3]) | (lfsr_seed_req & ~write_mask[3]);

							frame_size <= (s_axi_wdata[79:64] & write_mask[79:64]) | (frame_size & ~write_mask[79:64]);
							frame_delay <= (s_axi_wdata[127:96] & write_mask[127:96]) | (frame_delay & ~write_mask[127:96]);
						end

						1'd1: begin
							burst_on_time <= (s_axi_wdata[15:0] & write_mask[15:0]) | (burst_on_time & ~write_mask[15:0]);
							burst_off_time <= (s_axi_wdata[31:16] & write_mask[31:16]) | (burst_off_time & ~write_mask[31:16]);
							lfsr_seed_val <= (s_axi_wdata[39:32] & write_mask[39:32]) | (lfsr_seed_val & ~write_mask[39:32]);
						end
					endcase
				end
			end
		end

		// SRST must be writable even after it has been set to 1
		if(rst_n & write_req && write_addr[12:$clog2(axi_width/8)] == '0) begin
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
			if(s_axi_araddr[12:5] == 8'd0) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				if(axi_width == 32) begin
					case(s_axi_araddr[4:2])
						3'd0: read_value = {29'd0, use_burst, srst, tx_enable};
						3'd1: read_value = {19'd0, tx_ptr, tx_state};
						3'd2: read_value = {16'd0, frame_size};
						3'd3: read_value = frame_delay;
						3'd4: read_value = {burst_off_time, burst_on_time};
						3'd5: read_value = {24'd0, lfsr_seed_val};
					endcase
				end else if(axi_width == 64) begin
					case(s_axi_araddr[4:3])
						2'd0: read_value = {19'd0, tx_ptr, tx_state, 29'd0, use_burst, srst, tx_enable};
						2'd1: read_value = {frame_delay, 16'd0, frame_size};
						2'd2: read_value = {24'd0, lfsr_seed_val, burst_off_time, burst_on_time};
					endcase
				end else if(axi_width == 128) begin
					case(s_axi_araddr[4])
						2'd0: begin
							read_value[63:0] = {19'd0, tx_ptr, tx_state, 29'd0, use_burst, srst, tx_enable};
							read_value[127:64] = {frame_delay, 16'd0, frame_size};
						end

						2'd1: begin
							read_value = {56'd0, lfsr_seed_val, burst_off_time, burst_on_time};
						end
					endcase
				end
			end else if(s_axi_araddr[12:11] == 2'b01) begin
				// DRAM address, frame
				read_ready = mem_frame_rdone;
				read_response = 1'b1;
				read_value = mem_frame_rdata;
			end else if(s_axi_araddr[12:8] == 5'b10000) begin
				// DRAM address, pattern
				read_ready = mem_pattern_rdone;
				read_response = 1'b1;
				read_value = mem_pattern_rdata;
			end else begin
				// Invalid address, mark as error
				read_ready = 1'b1;
				read_response = 1'b0;
			end
		end

		// Handle write requests

		if(write_req) begin
			if(write_addr[12:5] == 8'd0) begin
				// Register address
				write_ready = 1'b1;
				write_response = 1'b1;
			end else if(write_addr[12:11] == 2'b01) begin
				// DRAM address
				write_ready = mem_frame_wdone;
				write_response = 1'b1;
			end else if(write_addr[12:8] == 5'b10000) begin
				// DRAM address, pattern
				write_ready = mem_pattern_wdone;
				write_response = 1'b1;
			end else begin
				// Invalid address, mark as error
				write_ready = 1'b1;
				write_response = 1'b0;
			end
		end
	end
endmodule
