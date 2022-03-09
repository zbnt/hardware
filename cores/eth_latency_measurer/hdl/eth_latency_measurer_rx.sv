/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_latency_measurer_rx #(parameter C_MODE = 0)
(
	input logic clk,
	input logic rst,
	input logic clk_rx,

	// Config

	input logic [47:0] mac_addr_src,
	input logic [31:0] ip_addr_src,

	input logic [47:0] mac_addr_dst,
	input logic [31:0] ip_addr_dst,

	input logic [15:0] frame_id,
	input logic [15:0] log_id,
	output logic [15:0] ping_id,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic [2:0] s_axis_tuser,
	input logic s_axis_tlast,
	input logic s_axis_tvalid
);
	// clk_rx clock domain

	logic rst_rx;
	logic is_valid, is_valid_next;
	logic [15:0] count, count_next;
	logic [15:0] id_buffer, id_buffer_next;
	logic [319:0] rx_buffer, rx_buffer_next;

	logic [31:0] ip_addr_src_cdc, ip_addr_dst_cdc;
	logic [47:0] mac_addr_src_cdc, mac_addr_dst_cdc;
	logic [15:0] frame_id_cdc, log_id_cdc, ping_id_cdc, ping_id_cdc_next;

	always_ff @(posedge clk_rx) begin
		if(rst_rx) begin
			count <= 16'd0;
			is_valid <= 1'b1;
			id_buffer <= '0;
			rx_buffer <= '0;
			ping_id_cdc <= '1;
		end else begin
			count <= count_next;
			is_valid <= is_valid_next;
			id_buffer <= id_buffer_next;
			rx_buffer <= rx_buffer_next;
			ping_id_cdc <= ping_id_cdc_next;
		end
	end

	always_comb begin
		count_next = count;
		is_valid_next = is_valid;
		id_buffer_next = id_buffer;
		rx_buffer_next = rx_buffer;
		ping_id_cdc_next = ping_id_cdc;

		if(s_axis_tvalid) begin
			count_next = count + 16'd1;
			rx_buffer_next = {rx_buffer[311:0], 8'd0};

			if(~s_axis_tuser[2] && count <= 16'd39 && count != 16'd24 && count != 16'd25 && count != 16'd36 && count != 16'd37) begin
				if(rx_buffer[319:312] != s_axis_tdata) begin
					is_valid_next = 1'b0;
				end
			end

			if(count == 16'd40) begin
				id_buffer_next[15:8] = s_axis_tdata;
			end

			if(count == 16'd41) begin
				id_buffer_next[7:0] = s_axis_tdata;
			end

			if(s_axis_tlast & is_valid) begin
				ping_id_cdc_next = id_buffer;
			end
		end else begin
			count_next = 16'd0;
			is_valid_next = 1'b1;
			rx_buffer_next = {mac_addr_dst_cdc, mac_addr_src_cdc, 48'h08004500001C, frame_id_cdc, 48'h400040010000, ip_addr_src_cdc, ip_addr_dst_cdc, C_MODE ? 8'h00 : 8'h08, 24'd0, log_id_cdc};
		end
	end

	// CDC

	bus_cdc #(16, 2) U0
	(
		.clk_src(clk_rx),
		.clk_dst(clk),
		.data_in(ping_id_cdc),
		.data_out(ping_id)
	);

	bus_cdc #(192, 2) U1
	(
		.clk_src(clk),
		.clk_dst(clk_rx),
		.data_in({mac_addr_src, mac_addr_dst, ip_addr_src, ip_addr_dst, frame_id, log_id}),
		.data_out({mac_addr_src_cdc, mac_addr_dst_cdc, ip_addr_src_cdc, ip_addr_dst_cdc, frame_id_cdc, log_id_cdc})
	);

	sync_ffs #(1, 2) U2
	(
		.clk_src(clk),
		.clk_dst(clk_rx),
		.data_in(rst),
		.data_out(rst_rx)
	);
endmodule
