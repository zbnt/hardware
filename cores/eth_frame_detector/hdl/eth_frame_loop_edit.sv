/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_edit #(parameter C_NUM_SCRIPTS = 4)
(
	input logic clk,
	input logic rst_n,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic [17*C_NUM_SCRIPTS:0] s_axis_tuser,  // {C_NUM_SCRIPTS * {PARAM_B, INSTR_B, MATCHED}, FCS_INVALID}
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic [9:0] m_axis_tuser, // {ORIG_BYTE, DROP_FRAME, FCS_INVALID}
	output logic m_axis_tlast,
	output logic m_axis_tvalid
);
	// Stage 1: Select instruction

	logic [7:0] s_axis_tdata_q;
	logic s_axis_tuser_q, s_axis_tlast_q, s_axis_tvalid_q;

	logic [14:0] instr_bits[0:C_NUM_SCRIPTS-1];
	logic [2:0] instr_size[0:C_NUM_SCRIPTS-1];
	logic [C_NUM_SCRIPTS-1:0] instr_valid;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			s_axis_tdata_q <= 8'd0;
			s_axis_tuser_q <= 1'b0;
			s_axis_tlast_q <= 1'b0;
			s_axis_tvalid_q <= 1'b0;
		end else begin
			s_axis_tdata_q <= s_axis_tdata;
			s_axis_tuser_q <= s_axis_tuser[0];
			s_axis_tlast_q <= s_axis_tlast;
			s_axis_tvalid_q <= s_axis_tvalid;
		end
	end

	for(genvar i = 0; i < C_NUM_SCRIPTS; ++i) begin
		always_ff @(posedge clk) begin
			if(~rst_n | ~s_axis_tvalid) begin
				instr_valid[i] <= 1'b0;
				instr_size[i] <= 3'd0;
				instr_bits[i] <= 15'd0;
			end else begin
				instr_bits[i] <= s_axis_tuser[17*i+17:17*i+3];

				if(instr_size[i] == 3'd0) begin
					if(s_axis_tuser[17*i+1] && s_axis_tuser[17*i+7:17*i+3] != 'd0) begin
						instr_valid[i] <= 1'b1;

						case(s_axis_tuser[17*i+9:17*i+8])
							2'd0: instr_size[i] <= 3'd0;
							2'd1: instr_size[i] <= 3'd1;
							2'd2: instr_size[i] <= 3'd3;
							2'd3: instr_size[i] <= 3'd7;
						endcase
					end else begin
						instr_valid[i] <= 1'b0;
					end
				end else begin
					instr_size[i] <= instr_size[i] - 3'd1;
				end
			end
		end
	end

	logic [7:0] axis_s1_tdata;
	logic [15:0] axis_s1_tuser;
	logic axis_s1_tlast, axis_s1_tvalid;

	logic in_instr;
	logic [$clog2(C_NUM_SCRIPTS)-1:0] in_instr_idx;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			axis_s1_tdata <= 8'd0;
			axis_s1_tuser <= 16'd0;
			axis_s1_tlast <= 1'b0;
			axis_s1_tvalid <= 1'b0;

			in_instr <= 1'b0;
			in_instr_idx <= 'd0;
		end else begin
			axis_s1_tdata <= s_axis_tdata_q;
			axis_s1_tuser[0] <= s_axis_tuser_q;
			axis_s1_tlast <= s_axis_tlast_q;
			axis_s1_tvalid <= s_axis_tvalid_q;

			if(~in_instr | ~instr_valid[in_instr_idx]) begin
				axis_s1_tuser[15:1] <= 15'd0;

				for(int i = C_NUM_SCRIPTS - 1; i >= 0; --i) begin
					if(instr_valid[i]) begin
						in_instr <= 1'b1;
						in_instr_idx <= i;
						axis_s1_tuser[15:1] <= instr_bits[i];
					end
				end
			end else begin
				axis_s1_tuser[15:1] <= instr_bits[in_instr_idx];
			end
		end
	end

	// Stage 2: Input shift-registers

	logic [7:0] axis_s2_tdata[0:7];
	logic [15:0] axis_s2_tuser[0:7];
	logic [7:0] axis_s2_tlast, axis_s2_tvalid;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			for(int i = 0; i < 8; ++i) begin
				axis_s2_tdata[i] <= 8'd0;
				axis_s2_tuser[i] <= 16'd0;
				axis_s2_tlast[i] <= 1'b0;
				axis_s2_tvalid[i] <= 1'b0;
			end
		end else begin
			axis_s2_tlast[0] <= axis_s1_tlast;
			axis_s2_tvalid[0] <= axis_s1_tvalid;

			if(axis_s1_tvalid) begin
				axis_s2_tdata[0] <= axis_s1_tdata;
				axis_s2_tuser[0] <= axis_s1_tuser;
			end else begin
				axis_s2_tdata[0] <= 8'd0;
				axis_s2_tuser[0] <= 16'd0;
			end

			for(int i = 1; i < 8; ++i) begin
				axis_s2_tdata[i] <= axis_s2_tdata[i-1];
				axis_s2_tuser[i] <= axis_s2_tuser[i-1];
				axis_s2_tlast[i] <= axis_s2_tlast[i-1];
				axis_s2_tvalid[i] <= axis_s2_tvalid[i-1];
			end
		end
	end

	// Stage 3: Prepare operands

	logic [7:0] axis_s3_tdata;
	logic [7:0] axis_s3_tuser;
	logic axis_s3_tlast, axis_s3_tvalid;

	logic [63:0] op_data, op_param;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			op_data <= 64'd0;
			op_param <= 64'd0;

			axis_s3_tdata <= 8'd0;
			axis_s3_tuser <= 8'd0;
			axis_s3_tlast <= 1'b0;
			axis_s3_tvalid <= 1'b0;
		end else begin
			axis_s3_tdata <= axis_s2_tdata[7];
			axis_s3_tuser <= axis_s2_tuser[7][7:0];
			axis_s3_tlast <= axis_s2_tlast[7];
			axis_s3_tvalid <= axis_s2_tvalid[7];

			case(axis_s2_tuser[7][7:6])
				2'd0: begin
					// 1 byte
					op_data[7:0] <= axis_s2_tdata[7];
					op_param[7:0] <= axis_s2_tuser[7][15:8];

					if(~axis_s2_tuser[7][5]) begin
						// Unsigned
						op_data[63:8] <= 56'd0;
						op_param[63:8] <= 56'd0;
					end else begin
						// Signed
						op_data[63:8] <= {56{axis_s2_tdata[7][7]}};
						op_param[63:8] <= {56{axis_s2_tuser[7][15]}};
					end
				end

				2'd1: begin
					// 2 bytes
					if(~axis_s2_tuser[7][4]) begin
						// Little-endian
						op_data[7:0] <= axis_s2_tdata[7];
						op_data[15:8] <= axis_s2_tdata[6];
						op_param[7:0] <= axis_s2_tuser[7][15:8];
						op_param[15:8] <= axis_s2_tuser[6][15:8];

						if(~axis_s2_tuser[7][5]) begin
							// Unsigned
							op_data[63:16] <= 48'd0;
							op_param[63:16] <= 48'd0;
						end else begin
							// Signed
							op_data[63:16] <= {48{axis_s2_tdata[6][7]}};
							op_param[63:16] <= {48{axis_s2_tuser[6][15]}};
						end
					end else begin
						// Big-endian
						op_data[7:0] <= axis_s2_tdata[6];
						op_data[15:8] <= axis_s2_tdata[7];
						op_param[7:0] <= axis_s2_tuser[6][15:8];
						op_param[15:8] <= axis_s2_tuser[7][15:8];

						if(~axis_s2_tuser[7][5]) begin
							// Unsigned
							op_data[63:16] <= 48'd0;
							op_param[63:16] <= 48'd0;
						end else begin
							// Signed
							op_data[63:16] <= {48{axis_s2_tdata[7][7]}};
							op_param[63:16] <= {48{axis_s2_tuser[7][15]}};
						end
					end
				end

				2'd2: begin
					// 4 bytes
					if(~axis_s2_tuser[7][4]) begin
						// Little-endian
						op_data[7:0] <= axis_s2_tdata[7];
						op_data[15:8] <= axis_s2_tdata[6];
						op_data[23:16] <= axis_s2_tdata[5];
						op_data[31:24] <= axis_s2_tdata[4];
						op_param[7:0] <= axis_s2_tuser[7][15:8];
						op_param[15:8] <= axis_s2_tuser[6][15:8];
						op_param[23:16] <= axis_s2_tuser[5][15:8];
						op_param[31:24] <= axis_s2_tuser[4][15:8];

						if(~axis_s2_tuser[7][5]) begin
							// Unsigned
							op_data[63:32] <= 32'd0;
							op_param[63:32] <= 32'd0;
						end else begin
							// Signed
							op_data[63:32] <= {32{axis_s2_tdata[4][7]}};
							op_param[63:32] <= {32{axis_s2_tuser[4][15]}};
						end
					end else begin
						// Big-endian
						op_data[7:0] <= axis_s2_tdata[4];
						op_data[15:8] <= axis_s2_tdata[5];
						op_data[23:16] <= axis_s2_tdata[6];
						op_data[31:24] <= axis_s2_tdata[7];
						op_param[7:0] <= axis_s2_tuser[4][15:8];
						op_param[15:8] <= axis_s2_tuser[5][15:8];
						op_param[23:16] <= axis_s2_tuser[6][15:8];
						op_param[31:24] <= axis_s2_tuser[7][15:8];

						if(~axis_s2_tuser[7][5]) begin
							// Unsigned
							op_data[63:32] <= 32'd0;
							op_param[63:32] <= 32'd0;
						end else begin
							// Signed
							op_data[63:32] <= {32{axis_s2_tdata[7][7]}};
							op_param[63:32] <= {32{axis_s2_tuser[7][15]}};
						end
					end
				end

				2'd3: begin
					// 8 bytes
					if(~axis_s2_tuser[7][4]) begin
						// Little-endian
						op_data[7:0] <= axis_s2_tdata[7];
						op_data[15:8] <= axis_s2_tdata[6];
						op_data[23:16] <= axis_s2_tdata[5];
						op_data[31:24] <= axis_s2_tdata[4];
						op_data[39:32] <= axis_s2_tdata[3];
						op_data[47:40] <= axis_s2_tdata[2];
						op_data[55:48] <= axis_s2_tdata[1];
						op_data[63:56] <= axis_s2_tdata[0];
						op_param[7:0] <= axis_s2_tuser[7][15:8];
						op_param[15:8] <= axis_s2_tuser[6][15:8];
						op_param[23:16] <= axis_s2_tuser[5][15:8];
						op_param[31:24] <= axis_s2_tuser[4][15:8];
						op_param[39:32] <= axis_s2_tuser[3][15:8];
						op_param[47:40] <= axis_s2_tuser[2][15:8];
						op_param[55:48] <= axis_s2_tuser[1][15:8];
						op_param[63:56] <= axis_s2_tuser[0][15:8];
					end else begin
						// Big-endian
						op_data[7:0] <= axis_s2_tdata[0];
						op_data[15:8] <= axis_s2_tdata[1];
						op_data[23:16] <= axis_s2_tdata[2];
						op_data[31:24] <= axis_s2_tdata[3];
						op_data[39:32] <= axis_s2_tdata[4];
						op_data[47:40] <= axis_s2_tdata[5];
						op_data[55:48] <= axis_s2_tdata[6];
						op_data[63:56] <= axis_s2_tdata[7];
						op_param[7:0] <= axis_s2_tuser[0][15:8];
						op_param[15:8] <= axis_s2_tuser[1][15:8];
						op_param[23:16] <= axis_s2_tuser[2][15:8];
						op_param[31:24] <= axis_s2_tuser[3][15:8];
						op_param[39:32] <= axis_s2_tuser[4][15:8];
						op_param[47:40] <= axis_s2_tuser[5][15:8];
						op_param[55:48] <= axis_s2_tuser[6][15:8];
						op_param[63:56] <= axis_s2_tuser[7][15:8];
					end
				end
			endcase
		end
	end

	// Stage 4: Execute instruction

	logic [7:0] axis_s4_tdata;
	logic [1:0] axis_s4_tuser;
	logic axis_s4_tlast, axis_s4_tvalid;

	logic [7:0] op_res;
	logic op_res_valid;

	logic drop_frame, corrupt_frame;
	logic axis_s3_tlast_q;

	always_ff @(posedge clk) begin
		if(~rst_n | axis_s3_tlast_q) begin
			axis_s3_tlast_q <= 1'b0;
			corrupt_frame <= 1'b0;
			drop_frame <= 1'b0;
		end else if(axis_s3_tvalid) begin
			axis_s3_tlast_q <= axis_s3_tlast;

			if(axis_s3_tuser[3:1] == 3'd0) begin
				corrupt_frame <= corrupt_frame | axis_s3_tuser[0] | axis_s3_tuser[4];
				drop_frame <= drop_frame | axis_s3_tuser[5];
			end else begin
				corrupt_frame <= corrupt_frame | axis_s3_tuser[0];
			end
		end
	end

	alu U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.opcode({axis_s3_tuser[7:1], 1'b0}),
		.a(op_data),
		.b(op_param),

		.res(op_res),
		.res_valid(op_res_valid)
	);

	reg_slice #(10, 7) U1
	(
		.clk(clk),
		.rst(~rst_n),
		.data_in({axis_s3_tvalid, axis_s3_tlast, axis_s3_tdata}),
		.data_out({axis_s4_tvalid, axis_s4_tlast, axis_s4_tdata})
	);

	reg_slice #(2, 6) U2
	(
		.clk(clk),
		.rst(~rst_n),
		.data_in({drop_frame, corrupt_frame}),
		.data_out(axis_s4_tuser)
	);

	// Stage 5: Output

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			m_axis_tdata <= 8'd0;
			m_axis_tuser <= 10'd0;
			m_axis_tlast <= 1'b0;
			m_axis_tvalid <= 1'b0;
		end else begin
			if(op_res_valid) begin
				m_axis_tdata <= op_res;
			end else begin
				m_axis_tdata <= axis_s4_tdata;
			end

			m_axis_tuser <= {axis_s4_tdata, axis_s4_tuser};
			m_axis_tlast <= axis_s4_tlast;
			m_axis_tvalid <= axis_s4_tvalid;
		end
	end
endmodule
