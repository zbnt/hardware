`timescale 1ns / 1ps

module axi4_lite_slave_read #(parameter num_regs = 2, parameter addr_width = 7)
(
	input logic clk,
	input logic rst_n,

	input logic [31:0] reg_vals[0:num_regs-1],

	input logic [addr_width-1:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [31:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready
);
	enum logic {ST_R_WAIT_ADDR, ST_R_RESPONSE} r_state, r_state_next;
	logic [31:0] r_data_next;
	logic [1:0] r_resp_next;

	always_ff @(posedge clk) begin
		r_state <= r_state_next;
		s_axi_rresp <= r_resp_next;
		s_axi_rdata <= r_data_next;
	end

	always_comb begin
		r_state_next = r_state;

		r_data_next = s_axi_rdata;
		r_resp_next = s_axi_rresp;

		s_axi_arready = 1'b0;
		s_axi_rvalid = 1'b0;

		if(~rst_n) begin
			r_state_next = ST_R_WAIT_ADDR;
			r_data_next = 32'd0;
			r_resp_next = 2'd0;
		end else begin
			case(r_state)
				ST_R_WAIT_ADDR: begin
					s_axi_arready = 1'b1;

					if(s_axi_arvalid) begin
						r_state_next = ST_R_RESPONSE;

						if(s_axi_araddr[addr_width-1:2] < num_regs) begin
							r_data_next = reg_vals[s_axi_araddr[addr_width-1:2]];
							r_resp_next = 2'b00;
						end else begin
							r_data_next = 32'd0;
							r_resp_next = 2'b10;
						end
					end
				end

				ST_R_RESPONSE: begin
					s_axi_rvalid = 1'b1;

					if(s_axi_rready) begin
						r_state_next = ST_R_WAIT_ADDR;
						r_data_next = 32'd0;
						r_resp_next = 2'd0;
					end
				end
			endcase
		end
	end
endmodule
