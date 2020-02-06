/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_rx #(parameter C_NUM_SCRIPTS = 4, parameter C_AXI_WIDTH = 32, parameter C_MAX_SCRIPT_SIZE = 2048)
(
	input logic clk,
	input logic rst_n,

	// MEM

	input logic clk_mem,

	input logic mem_req,
	input logic [$clog2(4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:0] mem_addr,
	input logic mem_wenable,
	input logic [C_AXI_WIDTH-1:0] mem_wdata,
	output logic [C_AXI_WIDTH-1:0] mem_rdata,
	output logic mem_ack,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic s_axis_tuser,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic [32*C_NUM_SCRIPTS:0] m_axis_tuser,  // {C_NUM_SCRIPTS * {PARAM_B, PARAM_A, INSTR_B, INSTR_A}, FCS_INVALID}
	output logic m_axis_tlast,
	output logic m_axis_tvalid
);
	logic [C_NUM_SCRIPTS-1:0] script_ack;
	logic [C_AXI_WIDTH-1:0] script_data_a[0:C_NUM_SCRIPTS-1];
	logic [32*C_NUM_SCRIPTS-1:0] script_data_b;
	logic [15:0] count;
	logic script_end;

	logic [7:0] axis_tdata_q;
	logic axis_tuser_q;
	logic axis_tlast_q;
	logic axis_tvalid_q;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			count <= 16'd0;
			script_end <= 1'b0;

			m_axis_tdata <= 8'd0;
			m_axis_tuser <= '0;
			m_axis_tlast <= 1'b0;
			m_axis_tvalid <= 1'b0;

			axis_tdata_q <= 8'd0;
			axis_tuser_q <= 1'b0;
			axis_tlast_q <= 1'b0;
			axis_tvalid_q <= 1'b0;
		end else begin
			axis_tdata_q <= s_axis_tdata;
			axis_tuser_q <= s_axis_tuser;
			axis_tlast_q <= s_axis_tlast;
			axis_tvalid_q <= s_axis_tvalid;

			m_axis_tdata <= s_axis_tdata;
			m_axis_tuser <= (script_end ? {32'd0, axis_tuser_q} : {script_data_b, axis_tuser_q});
			m_axis_tlast <= axis_tlast_q;
			m_axis_tvalid <= axis_tvalid_q;

			if(s_axis_tvalid) begin
				if(s_axis_tlast) begin
					count <= 16'd0;
					script_end <= 1'b0;
				end else if(count != C_MAX_SCRIPT_SIZE - 1) begin
					count <= count + 16'd1;
				end else begin
					script_end <= 1'b1;
				end
			end
		end
	end

	// Memory for the scripts

	for(genvar i = 0; i < C_NUM_SCRIPTS; ++i) begin
		logic script_we, script_req;

		script_mem #(C_AXI_WIDTH, C_MAX_SCRIPT_SIZE) U0
		(
			.clk_a(clk_mem),
			.clk_b(clk),
			.rst_n(rst_n),

			.a(mem_addr[$clog2(4*C_MAX_SCRIPT_SIZE)-1:0]),
			.d(mem_wdata),
			.qspo(script_data_a[i]),
			.we(script_we),
			.req(script_req),
			.ack(script_ack[i]),

			.dpra(count),
			.qdpo(script_data_b[32*i+31:32*i])
		);

		always_comb begin
			if(C_NUM_SCRIPTS == 1) begin
				script_we = mem_wenable;
				script_req = mem_req;

			end else begin
				script_we = mem_wenable && (mem_addr[$clog2(4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:$clog2(4*C_MAX_SCRIPT_SIZE)] == i);
				script_req = mem_req && (mem_addr[$clog2(4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:$clog2(4*C_MAX_SCRIPT_SIZE)] == i);
			end
		end
	end

	always_comb begin
		if(C_NUM_SCRIPTS == 1) begin
			mem_rdata = script_data_a[0];
			mem_ack = script_ack[0];
		end else begin
			mem_rdata = script_data_a[mem_addr[$clog2(4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:$clog2(4*C_MAX_SCRIPT_SIZE)]];
			mem_ack = script_ack[mem_addr[$clog2(4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:$clog2(4*C_MAX_SCRIPT_SIZE)]];
		end
	end
endmodule
