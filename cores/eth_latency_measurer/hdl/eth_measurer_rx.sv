/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_measurer_rx #(parameter src_mac, parameter identifier)
(
	input logic clk,
	input logic rst,

	input logic clk_rx,

	output logic [63:0] ping_id,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic s_axis_tkeep,
	input logic s_axis_tlast,
	input logic s_axis_tvalid
);
	logic rst_rx;
	logic [15:0] count, count_next;
	logic [207:0] rx_buffer, rx_buffer_next;

	logic [63:0] ping_id_cdc, ping_id_cdc_next;

	// clk_rx clock domain: reads data from the TEMAC and writes to FIFO

	always_ff @(posedge clk_rx) begin
		if(rst_rx) begin
			count <= 16'd0;
			rx_buffer <= '0;
			ping_id_cdc <= '1;
		end else begin
			count <= count_next;
			rx_buffer <= rx_buffer_next;
			ping_id_cdc <= ping_id_cdc_next;
		end
	end

	always_comb begin
		count_next = count;
		rx_buffer_next = rx_buffer;
		ping_id_cdc_next = ping_id_cdc;

		if(~rst_rx & s_axis_tvalid) begin
			count_next = count + 16'd1;

			if(count <= 16'd25) begin
				rx_buffer_next = {rx_buffer[199:0], s_axis_tdata};
			end

			if(s_axis_tlast) begin
				count_next = 16'd0;

				if(rx_buffer[207:160] == 48'hFF_FF_FF_FF_FF_FF && rx_buffer[159:112] == src_mac && rx_buffer[95:64] == identifier) begin
					ping_id_cdc_next = rx_buffer[63:0];
				end
			end
		end
	end

	// cross clock domains using synchronizer flip-flops

	bus_cdc #(64, 2) U0
	(
		.clk_src(clk_rx),
		.clk_dst(clk),
		.data_in(ping_id_cdc),
		.data_out(ping_id)
	);

	sync_ffs #(1, 2) U1
	(
		.clk_src(clk),
		.clk_dst(clk_rx),
		.data_in(rst),
		.data_out(rst_rx)
	);
endmodule
