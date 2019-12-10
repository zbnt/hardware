/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_stats_collector_axi #(parameter C_AXI_WIDTH = 32, parameter C_AXIS_LOG_ENABLE = 1, parameter C_AXIS_LOG_ID = 0)
(
	input logic clk,
	input logic rst_n,

	input logic [63:0] current_time,

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

	output logic [31:0] sample_period,
	input logic [63:0] overflow_count,

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
	logic [63:0] time_reg, tx_bytes_reg, tx_good_reg, tx_bad_reg, rx_bytes_reg, rx_good_reg, rx_bad_reg;

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable <= 1'b0;
			srst <= srst & rst_n;
			hold <= 1'b0;
			sample_period <= 32'd0;

			time_reg <= 64'd0;
			tx_bytes_reg <= 64'd0;
			tx_good_reg <= 64'd0;
			tx_bad_reg <= 64'd0;
			rx_bytes_reg <= 64'd0;
			rx_good_reg <= 64'd0;
			rx_bad_reg <= 64'd0;
		end else begin
			// Update the stored values if hold is set to 0
			if(~hold) begin
				time_reg <= current_time;
				tx_bytes_reg <= tx_bytes;
				tx_good_reg <= tx_good;
				tx_bad_reg <= tx_bad;
				rx_bytes_reg <= rx_bytes;
				rx_good_reg <= rx_good;
				rx_bad_reg <= rx_bad;
			end

			if(write_req) begin
				if(write_addr[11:4] == 8'd0) begin
					if(C_AXI_WIDTH == 32) begin
						case(write_addr[3:2])
							2'd0: begin
								enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
								hold <= (s_axi_wdata[2] & write_mask[2]) | (hold & ~write_mask[2]);
							end

							2'd1: begin
								sample_period <= (s_axi_wdata & write_mask) | (sample_period & ~write_mask);
							end
						endcase
					end else if(C_AXI_WIDTH == 64) begin
						case(write_addr[3])
							1'd0: begin
								enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
								hold <= (s_axi_wdata[2] & write_mask[2]) | (hold & ~write_mask[2]);
								sample_period <= (s_axi_wdata[63:32] & write_mask[63:32]) | (sample_period & ~write_mask[63:32]);
							end
						endcase
					end else if(C_AXI_WIDTH == 128) begin
						enable <= (s_axi_wdata[0] & write_mask[0]) | (enable & ~write_mask[0]);
						hold <= (s_axi_wdata[2] & write_mask[2]) | (hold & ~write_mask[2]);
						sample_period <= (s_axi_wdata[63:32] & write_mask[63:32]) | (sample_period & ~write_mask[63:32]);
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
		read_response = 1'b0;
		read_value = '0;

		write_ready = 1'b0;
		write_response = 1'b0;

		for(int i = 0; i < C_AXI_WIDTH; ++i) begin
			write_mask[i] = s_axi_wstrb[i/8];
		end

		// Handle read requests

		if(read_req) begin
			if(s_axi_araddr <= 12'd71) begin
				// Register address
				read_ready = 1'b1;
				read_response = 1'b1;

				if(C_AXI_WIDTH == 32) begin
					case(s_axi_araddr[6:2])
						5'd00: read_value = {16'd0, C_AXIS_LOG_ID[7:0], 4'b0, C_AXIS_LOG_ENABLE[0], hold, srst, enable};
						5'd01: read_value = sample_period;
						5'd02: read_value = overflow_count[31:0];
						5'd03: read_value = overflow_count[63:32];
						5'd04: read_value = time_reg[31:0];
						5'd05: read_value = time_reg[63:32];
						5'd06: read_value = tx_bytes_reg[31:0];
						5'd07: read_value = tx_bytes_reg[63:32];
						5'd08: read_value = tx_good_reg[31:0];
						5'd09: read_value = tx_good_reg[63:32];
						5'd10: read_value = tx_bad_reg[31:0];
						5'd11: read_value = tx_bad_reg[63:32];
						5'd12: read_value = rx_bytes_reg[31:0];
						5'd13: read_value = rx_bytes_reg[63:32];
						5'd14: read_value = rx_good_reg[31:0];
						5'd15: read_value = rx_good_reg[63:32];
						5'd16: read_value = rx_bad_reg[31:0];
						5'd17: read_value = rx_bad_reg[63:32];
					endcase
				end else if(C_AXI_WIDTH == 64) begin
					case(s_axi_araddr[6:3])
						4'd0: read_value = {sample_period, 16'd0, C_AXIS_LOG_ID[7:0], 4'b0, C_AXIS_LOG_ENABLE[0], hold, srst, enable};
						4'd1: read_value = overflow_count;
						4'd2: read_value = time_reg;
						4'd3: read_value = tx_bytes_reg;
						4'd4: read_value = tx_good_reg;
						4'd5: read_value = tx_bad_reg;
						4'd6: read_value = rx_bytes_reg;
						4'd7: read_value = rx_good_reg;
						4'd8: read_value = rx_bad_reg;
					endcase
				end else if(C_AXI_WIDTH == 128) begin
					case(s_axi_araddr[6:4])
						3'd0: read_value = {overflow_count, sample_period, 16'd0, C_AXIS_LOG_ID[7:0], 4'b0, C_AXIS_LOG_ENABLE[0], hold, srst, enable};
						3'd1: read_value = {tx_bytes_reg, time_reg};
						3'd2: read_value = {tx_bad_reg, tx_good_reg};
						3'd3: read_value = {rx_good_reg, rx_bytes_reg};
						3'd4: read_value = {64'd0, rx_bad_reg};
					endcase
				end
			end else begin
				// Invalid address, mark as error
				read_ready = 1'b1;
				read_response = 1'b0;
			end
		end

		// Handle write requests

		if(write_req) begin
			write_ready = 1'b1;
			write_response = (write_addr <= 12'd71);
		end
	end
endmodule
