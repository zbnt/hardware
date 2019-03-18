`timescale 1ns / 1ps

module axi4_lite_slave_write #(parameter num_regs = 2, parameter addr_width = 7)
(
	input logic clk,
	input logic rst_n,

	input logic [31:0] reg_vals[0:num_regs-1],
	output logic [addr_width-1:0] reg_write_idx,
	output logic [31:0] reg_write_value,
	output logic reg_write_enable,

	input logic [addr_width-1:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [31:0] s_axi_wdata,
	input logic [3:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready
);
	enum logic [1:0] {ST_W_WAIT_ADDR, ST_W_WAIT_DATA, ST_W_RESPONSE} w_state, w_state_next;
	logic [addr_width-1:0] w_addr, w_addr_next;
	logic [31:0] w_data_next, w_data_mask;
	logic [addr_width-3:0] w_idx_next;
	logic [1:0] w_resp_next;
	logic w_enable_next;

	always_ff @(posedge clk) begin
		w_state <= w_state_next;
		w_addr <= w_addr_next;
		s_axi_bresp <= w_resp_next;
		reg_write_idx <= w_idx_next;
		reg_write_value <= w_data_next;
		reg_write_enable <= w_enable_next;
	end

	always_comb begin
		w_state_next = w_state;

		w_addr_next = w_addr;
		w_data_next = reg_write_value;
		w_resp_next = s_axi_bresp;
		w_enable_next = 1'b0;
		w_idx_next = '0;

		s_axi_awready = 1'b0;
		s_axi_wready = 1'b0;
		s_axi_bvalid = 1'b0;

		w_data_mask = {{8{s_axi_wstrb[3]}}, {8{s_axi_wstrb[2]}}, {8{s_axi_wstrb[1]}}, {8{s_axi_wstrb[0]}}};

		if(~rst_n) begin
			w_state_next = ST_W_WAIT_ADDR;
			w_data_next = 32'd0;
			w_resp_next = 2'd0;
			w_addr_next = 7'd0;
		end else begin
			case(w_state)
				ST_W_WAIT_ADDR: begin
					s_axi_awready = 1'b1;

					if(s_axi_awvalid) begin
						w_state_next = ST_W_WAIT_DATA;
						w_addr_next = s_axi_awaddr;

						if(s_axi_awaddr[addr_width-1:2] < num_regs) begin
							w_resp_next = 2'b00;
						end else begin
							w_resp_next = 2'b10;
						end
					end
				end

				ST_W_WAIT_DATA: begin
					s_axi_wready = 1'b1;

					if(s_axi_wvalid) begin
						w_state_next = ST_W_RESPONSE;

						if(w_addr[addr_width-1:2] < num_regs) begin
							w_data_next = (reg_vals[w_addr[addr_width-1:2]] & ~w_data_mask) | (s_axi_wdata & w_data_mask);
							w_enable_next = 1'b1;
							w_idx_next = w_addr[addr_width-1:2];
						end else begin
							w_data_next = 32'd0;
						end
					end
				end

				// TODO: Merge with previous state?
				ST_W_RESPONSE: begin
					s_axi_bvalid = 1'b1;

					if(s_axi_bready) begin
						w_state_next = ST_W_WAIT_ADDR;
						w_data_next = 32'd0;
						w_resp_next = 2'd0;
						w_addr_next = 7'd0;
					end
				end
			endcase
		end
	end
endmodule
