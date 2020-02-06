/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_compare #(parameter C_NUM_SCRIPTS = 4)
(
	input logic clk,
	input logic rst_n,

	input logic [C_NUM_SCRIPTS-1:0] script_en,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic [32*C_NUM_SCRIPTS:0] s_axis_tuser,  // {C_NUM_SCRIPTS * {PARAM_B, PARAM_A, INSTR_B, INSTR_A}, FCS_INVALID}
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic [17*C_NUM_SCRIPTS:0] m_axis_tuser, // {C_NUM_SCRIPTS * {PARAM_B, INSTR_B, MATCHED}, FCS_INVALID}
	output logic m_axis_tlast,
	output logic m_axis_tvalid
);
	logic [7:0] s_axis_tdata_q;
	logic [32*C_NUM_SCRIPTS:0] s_axis_tuser_q;
	logic s_axis_tlast_q, s_axis_tvalid_q;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			s_axis_tdata_q <= 8'd0;
			s_axis_tuser_q[0] <= 1'b0;
			s_axis_tlast_q <= 1'b0;
			s_axis_tvalid_q <= 1'b0;

			m_axis_tdata <= 8'd0;
			m_axis_tuser[0] <= 1'b0;
			m_axis_tlast <= 1'b0;
			m_axis_tvalid <= 1'b0;
		end else begin
			s_axis_tdata_q <= s_axis_tdata;
			s_axis_tuser_q[0] <= s_axis_tuser[0];
			s_axis_tlast_q <= s_axis_tlast;
			s_axis_tvalid_q <= s_axis_tvalid;

			m_axis_tdata <= s_axis_tdata_q;
			m_axis_tuser[0] <= s_axis_tuser_q[0];
			m_axis_tlast <= s_axis_tlast_q;
			m_axis_tvalid <= s_axis_tvalid_q;
		end
	end

	for(genvar i = 0; i < C_NUM_SCRIPTS; ++i) begin
		logic [2:0] count;
		logic [64:0] data_sr, param_sr;

		// Stage 1: Push to shift-registers

		logic [7:0] opcode, param;

		always_comb begin
			opcode = s_axis_tuser[32*i+8:32*i+1];
			param = s_axis_tuser[32*i+24:32*i+17];
		end

		always_ff @(posedge clk) begin
			if(~rst_n | s_axis_tlast_q) begin
				count <= 3'd0;
				data_sr <= '0;
				param_sr <= '0;
				s_axis_tuser_q[32*i+32:32*i+1] <= 32'd0;
			end else if(s_axis_tvalid) begin
				s_axis_tuser_q[32*i+32:32*i+1] <= s_axis_tuser[32*i+32:32*i+1];

				if(opcode[0]) begin
					if(count == 3'd0) begin
						if(~opcode[2]) begin
							// Little-endian
							if(~opcode[3]) begin
								// Unsigned
								data_sr <= {1'b0, s_axis_tdata, 56'd0};
								param_sr <= {1'b0, param, 56'd0};
							end else begin
								// Signed
								data_sr <= {s_axis_tdata[7], s_axis_tdata, 56'd0};
								param_sr <= {param[7], param, 56'd0};
							end
						end else begin
							// Big-endian
							if(~opcode[3]) begin
								// Unsigned
								data_sr <= {57'd0, s_axis_tdata};
								param_sr <= {57'd0, param};
							end else begin
								// Signed
								data_sr <= {{57{s_axis_tdata[7]}}, s_axis_tdata};
								param_sr <= {{57{param[7]}}, param};
							end
						end
					end else begin
						if(~opcode[2]) begin
							// Little-endian
							if(~opcode[3]) begin
								// Unsigned
								data_sr <= {1'b0, s_axis_tdata, data_sr[63:8]};
								param_sr <= {1'b0, param, param_sr[63:8]};
							end else begin
								// Signed
								data_sr <= {s_axis_tdata[7], s_axis_tdata, data_sr[63:8]};
								param_sr <= {param[7], param, param_sr[63:8]};
							end
						end else begin
							// Big-endian
							data_sr <= {data_sr[56:0], s_axis_tdata};
							param_sr <= {param_sr[56:0], param};
						end
					end

					if(count != 3'd7) begin
						count <= count + 3'd1;
					end
				end

				if(opcode[1] | s_axis_tlast) begin
					count <= 3'd0;
				end
			end
		end

		// Stage 2: Comparisons

		logic [7:0] opcode_q, param_q;
		logic is_lt, is_eq;

		always_comb begin
			opcode_q = s_axis_tuser_q[32*i+8:32*i+1];
			param_q = s_axis_tuser_q[32*i+24:32*i+17];

			is_eq = (data_sr == param_sr);
			is_lt = ($signed(data_sr) < $signed(param_sr));
		end

		always_ff @(posedge clk) begin
			if(~rst_n | m_axis_tlast) begin
				m_axis_tuser[17*i+17:17*i+1] <= 17'd1;
			end else if(s_axis_tvalid_q) begin
				m_axis_tuser[17*i+17:17*i+2] <= {s_axis_tuser_q[32*i+32:32*i+25], s_axis_tuser_q[32*i+16:32*i+9]};

				if(~script_en[i]) begin
					m_axis_tuser[17*i+1] <= 1'b0;
				end

				if(opcode_q[1]) begin
					case(opcode_q[7:4])
						4'd0: begin
							// ==
							if(~is_eq) begin
								m_axis_tuser[17*i+1] <= 1'b0;
							end
						end

						4'd1: begin
							// >
							if(is_lt | is_eq) begin
								m_axis_tuser[17*i+1] <= 1'b0;
							end
						end

						4'd2: begin
							// <
							if(~is_lt) begin
								m_axis_tuser[17*i+1] <= 1'b0;
							end
						end

						4'd3: begin
							// >=
							if(is_lt) begin
								m_axis_tuser[17*i+1] <= 1'b0;
							end
						end

						4'd4: begin
							// <=
							if(~is_lt & ~is_eq) begin
								m_axis_tuser[17*i+1] <= 1'b0;
							end
						end

						4'd5: begin
							// &
							if((data_sr & param_sr) == '0) begin
								m_axis_tuser[17*i+1] <= 1'b0;
							end
						end

						4'd6: begin
							// &=
							if((data_sr & param_sr) != param_sr) begin
								m_axis_tuser[17*i+1] <= 1'b0;
							end
						end

						4'd15: begin
							m_axis_tuser[17*i+1] <= 1'b0;
						end
					endcase
				end
			end
		end
	end
endmodule
