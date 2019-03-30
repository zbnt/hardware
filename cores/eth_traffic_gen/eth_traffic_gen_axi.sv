/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_axi
#(
	parameter mem_addr_width = 6,
	parameter mem_size = 4,
	parameter reg_addr_width = 4,
	parameter num_regs = 2,
	parameter allow_write = {num_regs{1'b1}}
)
(
	// S_AXI

	input logic s_axi_clk,
	input logic s_axi_resetn,

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

	// MEM_A

	output logic [mem_addr_width-1:0] mem_a_addr,
	output logic [7:0] mem_a_wdata,
	output logic mem_a_we,
	input logic [7:0] mem_a_rdata,

	// Registers

	output logic [31:0] reg_val[0:num_regs-1],
	input logic [31:0] reg_in[0:num_regs-1]
);
	logic read_req, write_req;
	logic read_response, write_response;
	logic [addr_width-1:0] read_addr, write_addr;
	logic [31:0] read_value, write_value;
	logic [3:0] write_mask;

	logic [reg_addr_width-1:0] reg_write_idx;
	logic [31:0] reg_write_value;
	logic reg_write_enable;

	axi4_lite_slave_rw #(mem_addr_width) U0
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),

		.read_req(read_req),
		.read_addr(read_addr),

		.read_ready(read_ready),
		.read_response(read_response),
		.read_value(read_value),

		.write_req(write_req),
		.write_addr(write_addr),
		.write_value(write_value),
		.write_mask(write_mask),

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

	register_bank #(num_regs, reg_addr_width, allow_write) U1
	(
		.clk(s_axi_clk),
		.write_enable(reg_write_enable),
		.write_index(reg_write_idx),
		.write_value(reg_write_value),
		.reg_in(reg_in),
		.reg_val(reg_val)
	);

	// Handle AXI read/write operations

	enum logic [1:0] {ST_IDLE, ST_READ_MEM, ST_WRITE_MEM} state, state_next;
	logic [mem_addr_width-1:0] mem_a_addr_next;

	always_ff @(posedge s_axi_clk or negedge s_axi_resetn) begin
		if(~s_axi_resetn) begin
			state <= ST_IDLE;
			mem_a_addr <= '0;
			mem_a_we <= 1'b0;

			read_ready <= 1'b0;
			read_response <= 1'b0;
			read_value <= 32'd0;

			write_ready <= 1'b0;
			write_response <= 1'b0;
		end else begin
			state <= state_next;
			mem_a_addr <= mem_a_addr_next;
			mem_a_we <= mem_a_we_next;

			read_ready <= read_ready_next;
			read_response <= read_response_next;
			read_value <= read_value_next;

			write_ready <= write_ready_next;
			write_response <= write_response_next;
		end
	end

	always_comb begin
		state_next = state;
		mem_a_addr_next = mem_a_addr;
		mem_a_we_next = 1'b0;

		read_ready_next = 1'b0;
		read_response_next = 1'b0;
		read_value_next = read_value;

		write_ready_next = 1'b0;
		write_response_next = 1'b0;

		reg_write_enable = 1'b0;
		reg_write_idx = '0;
		reg_write_value = '0;

		case(state)
			ST_IDLE: begin
				if(s_axi_resetn) begin
					if(write_req) begin
						if(write_addr < mem_size) begin
							state_next = ST_WRITE_MEM;
							mem_a_addr_next = {write_addr[mem_addr_width-1:2], 2'd0};
						end else if(write_addr[mem_addr_width:6] == '1 && write_addr[5:2] < num_regs) begin
							logic [31:0] reg_write_mask;
							reg_write_mask = {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

							reg_write_enable = 1'b1;
							reg_write_idx = write_addr[5:2];
							reg_write_value = reg_vals[reg_write_idx] & ~reg_write_mask | write_value & reg_write_mask;
						end else begin
							write_ready_next = 1'b1;
							write_response_next = 1'b0;
						end
					end else if(read_req) begin
						if(read_addr < mem_size) begin
							state_next = ST_READ_MEM;
							mem_a_addr_next = {read_addr[mem_addr_width-1:2], 2'd0};
						end else if(read_addr[mem_addr_width:6] == '1 && read_addr[5:2] < num_regs) begin
							read_ready_next = 1'b1;
							read_response_next = 1'b1;
							read_value_next = reg_val[read_addr[5:2]];
						end else begin
							read_ready_next = 1'b1;
							read_response_next = 1'b0;
						end
					end
				end
			end

			ST_READ_MEM: begin
				read_value_next = {read_value[23:0], mem_a_rdata};

				if(mem_a_addr[1:0] == 2'b11 || mem_a_addr >= mem_size - 'd1) begin
					state_next = ST_IDLE;
					read_ready_next = 1'b1;
					read_response_next = 1'b1;
				end else begin
					mem_a_addr_next = mem_a_addr + 'd1;
				end
			end

			ST_WRITE_MEM: begin
				case(mem_a_addr[1:0])
					2'b00: begin
						if(write_mask[0]) begin
							mem_a_wdata_next = write_value[7:0];
							mem_a_we_next = 1'b1;
						end
					end

					2'b01: begin
						if(write_mask[1]) begin
							mem_a_wdata_next = write_value[15:8];
							mem_a_we_next = 1'b1;
						end
					end

					2'b10: begin
						if(write_mask[2]) begin
							mem_a_wdata_next = write_value[23:16];
							mem_a_we_next = 1'b1;
						end
					end

					2'b11: begin
						if(write_mask[3]) begin
							mem_a_wdata_next = write_value[31:24];
							mem_a_we_next = 1'b1;
						end
					end
				endcase

				if(mem_a_addr[1:0] == 2'b11 || mem_a_addr >= mem_size - 'd1) begin
					state_next = ST_IDLE;
					write_ready_next = 1'b1;
					write_response_next = 1'b1;
				end else begin
					mem_a_addr_next = mem_a_addr + 'd1;
				end
			end

			default: begin
				state_next = ST_IDLE;
			end
		endcase
	end
endmodule