/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_latency_measurer_axi #(parameter C_AXI_WIDTH = 32, parameter C_AXIS_LOG_ENABLE = 1)
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [11:0] s_axi_awaddr,
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

	input logic [11:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// Registers

	output logic enable,
	output logic srst,
	output logic log_enable,
	output logic use_broadcast,
	output logic [15:0] log_id,

	output logic [47:0] mac_addr_a,
	output logic [47:0] mac_addr_b,
	output logic [31:0] ip_addr_a,
	output logic [31:0] ip_addr_b,

	output logic [15:0] padding,
	output logic [31:0] delay,
	output logic [31:0] timeout,
	input logic [63:0] overflow_count,

	input logic [63:0] current_time,

	input logic [63:0] ping_count,
	input logic [31:0] ping_time,
	input logic [31:0] pong_time,
	input logic [63:0] pings_lost,
	input logic [63:0] pongs_lost
);
	// Handle AXI4-Lite requests

	logic read_req;
	logic read_ready;
	logic read_response;
	logic [C_AXI_WIDTH-1:0] read_value;

	logic write_req;
	logic write_ready;
	logic write_response;
	logic [11:0] write_addr;

	axi4_lite_slave_rw #(12, C_AXI_WIDTH) U0
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

	logic hold;
	logic [63:0] ping_count_reg, ping_time_reg, pong_time_reg, pings_lost_reg, pongs_lost_reg;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable <= 1'b0;
			srst <= srst & rst_n;
			hold <= 1'b0;
			log_enable <= 1'b0;
			log_id <= 15'd0;
			mac_addr_a <= 48'd0;
			mac_addr_b <= 48'd0;
			ip_addr_a <= 32'd0;
			ip_addr_b <= 32'd0;
			padding <= 16'd0;
			delay <= 32'd12500000;
			timeout <= 32'd125000000;

			ping_count_reg <= 64'd0;
			ping_time_reg <= 32'd0;
			pong_time_reg <= 32'd0;
			pings_lost_reg <= 64'd0;
			pongs_lost_reg <= 64'd0;
		end else begin
			// Update the stored values if hold is set to 0
			if(~hold) begin
				ping_count_reg <= ping_count;
				ping_time_reg <= ping_time;
				pong_time_reg <= pong_time;
				pings_lost_reg <= pings_lost_reg;
				pongs_lost_reg <= pongs_lost_reg;
			end

			if(write_req) begin
				if(write_addr[11:5] == 8'd0) begin
					if(C_AXI_WIDTH == 32) begin
						case(write_addr[5:2])
							4'd0: begin
								enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
								hold <= (s_axi_wdata[2] & write_mask[2]) | (hold & ~write_mask[2]);
								log_enable <= (s_axi_wdata[3] & write_mask[3]) | (log_enable & ~write_mask[3]);
								use_broadcast <= (s_axi_wdata[4] & write_mask[4]) | (use_broadcast & ~write_mask[4]);
								log_id <= (s_axi_wdata[31:16] & write_mask[31:16]) | (log_id & ~write_mask[31:16]);
							end

							4'd1: begin
								mac_addr_a[31:0] <= (s_axi_wdata & write_mask) | (mac_addr_a[31:0] & ~write_mask);
							end

							4'd2: begin
								mac_addr_a[47:32] <= (s_axi_wdata[15:0] & write_mask[15:0]) | (mac_addr_a[47:32] & ~write_mask[15:0]);
								mac_addr_b[15:0] <= (s_axi_wdata[31:16] & write_mask[31:16]) | (mac_addr_b[15:0] & ~write_mask[31:16]);
							end

							4'd3: begin
								mac_addr_b[47:16] <= (s_axi_wdata & write_mask) | (mac_addr_b[47:16] & ~write_mask);
							end

							4'd4: begin
								ip_addr_a <= (s_axi_wdata & write_mask) | (ip_addr_a & ~write_mask);
							end

							4'd5: begin
								ip_addr_b <= (s_axi_wdata & write_mask) | (ip_addr_b & ~write_mask);
							end

							4'd6: begin
								padding <= (s_axi_wdata[15:0] & write_mask[15:0]) | (padding & ~write_mask[15:0]);
							end

							4'd7: begin
								delay <= (s_axi_wdata & write_mask) | (delay & ~write_mask);
							end

							4'd8: begin
								timeout <= (s_axi_wdata & write_mask) | (timeout & ~write_mask);
							end
						endcase
					end else if(C_AXI_WIDTH == 64) begin
						case(write_addr[5:3])
							3'd0: begin
								enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
								hold <= (s_axi_wdata[2] & write_mask[2]) | (hold & ~write_mask[2]);
								log_enable <= (s_axi_wdata[3] & write_mask[3]) | (log_enable & ~write_mask[3]);
								use_broadcast <= (s_axi_wdata[4] & write_mask[4]) | (use_broadcast & ~write_mask[4]);
								log_id <= (s_axi_wdata[31:16] & write_mask[31:16]) | (log_id & ~write_mask[31:16]);
								mac_addr_a[31:0] <= (s_axi_wdata[63:32] & write_mask[63:32]) | (mac_addr_a[31:0] & ~write_mask[63:32]);
							end

							3'd1: begin
								mac_addr_a[47:32] <= (s_axi_wdata[15:0] & write_mask[15:0]) | (mac_addr_a[47:32] & ~write_mask[15:0]);
								mac_addr_b <= (s_axi_wdata[63:16] & write_mask[63:16]) | (mac_addr_b & ~write_mask[63:16]);
							end

							3'd2: begin
								ip_addr_a <= (s_axi_wdata[31:0] & write_mask[31:0]) | (ip_addr_a & ~write_mask[31:0]);
								ip_addr_b <= (s_axi_wdata[63:32] & write_mask[63:32]) | (ip_addr_b & ~write_mask[63:32]);
							end

							3'd3: begin
								padding <= (s_axi_wdata[15:0] & write_mask[15:0]) | (padding & ~write_mask[15:0]);
								delay <= (s_axi_wdata[63:32] & write_mask[63:32]) | (delay & ~write_mask[63:32]);
							end

							3'd4: begin
								timeout <= (s_axi_wdata[31:0] & write_mask[31:0]) | (timeout & ~write_mask[31:0]);
							end
						endcase
					end
				end
			end
		end

		// SRST must be writable even after it has been set to 1
		if(rst_n & write_req && write_addr[11:$clog2(C_AXI_WIDTH/8)] == '0) begin
			srst <= (s_axi_wdata[1] & write_mask[1]) | (srst & ~write_mask[1]);
		end
	end

	always_comb begin
		read_ready = 1'b0;
		read_response = 1'b1;
		read_value = '0;

		write_ready = 1'b0;
		write_response = 1'b1;

		for(int i = 0; i < C_AXI_WIDTH; ++i) begin
			write_mask[i] = s_axi_wstrb[i/8];
		end

		// Handle read requests

		if(read_req) begin
			read_ready = 1'b1;

			if(s_axi_araddr <= 12'd79) begin
				// Register address

				if(C_AXI_WIDTH == 32) begin
					case(s_axi_araddr[6:2])
						5'h00: read_value = {log_id, 11'd0, use_broadcast, log_enable & C_AXIS_LOG_ENABLE[0], hold, srst, enable};
						5'h01: read_value = mac_addr_a[31:0];
						5'h02: read_value = {mac_addr_b[15:0], mac_addr_a[47:32]};
						5'h03: read_value = mac_addr_b[47:16];
						5'h04: read_value = ip_addr_a;
						5'h05: read_value = ip_addr_b;
						5'h06: read_value = {16'd0, padding};
						5'h07: read_value = delay;
						5'h08: read_value = timeout;
						5'h09: read_value = 32'd0;
						5'h0A: read_value = overflow_count[31:0];
						5'h0B: read_value = overflow_count[63:32];
						5'h0C: read_value = ping_count_reg[31:0];
						5'h0D: read_value = ping_count_reg[63:32];
						5'h0E: read_value = ping_time_reg;
						5'h0F: read_value = pong_time_reg;
						5'h10: read_value = pings_lost_reg[31:0];
						5'h11: read_value = pings_lost_reg[63:32];
						5'h12: read_value = pongs_lost_reg[31:0];
						5'h13: read_value = pongs_lost_reg[63:32];
					endcase
				end else if(C_AXI_WIDTH == 64) begin
					case(s_axi_araddr[6:3])
						4'h00: read_value = {mac_addr_a[31:0], log_id, 11'd0, use_broadcast, log_enable & C_AXIS_LOG_ENABLE[0], hold, srst, enable};
						4'h01: read_value = {mac_addr_b, mac_addr_a[47:32]};
						4'h02: read_value = {ip_addr_b, ip_addr_a};
						4'h03: read_value = {delay, 16'd0, padding};
						4'h04: read_value = {32'd0, timeout};
						4'h05: read_value = overflow_count;
						4'h06: read_value = ping_count_reg;
						4'h07: read_value = {pong_time_reg, ping_time_reg};
						4'h08: read_value = pings_lost_reg;
						4'h09: read_value = pongs_lost_reg;
					endcase
				end
			end
		end

		// Handle write requests

		if(write_req) begin
			write_ready = 1'b1;
		end
	end
endmodule
