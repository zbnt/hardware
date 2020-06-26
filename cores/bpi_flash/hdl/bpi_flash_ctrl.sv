/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module bpi_flash_ctrl
#(
	parameter C_MEM_WIDTH = 16,
	parameter C_MEM_SIZE = 134217728,

	parameter C_ADDR_TO_CEL_TIME = 3,
	parameter C_OEL_TO_DQ_TIME = 6,
	parameter C_WEL_TO_DQ_TIME = 1,
	parameter C_DQ_TO_WEH_TIME = 6,
	parameter C_IO_TO_IO_TIME = 5
)
(
	input logic clk,
	input logic rst_n,

	input logic mode,

	// M_AXIS_RD

	output logic [C_MEM_WIDTH-1:0] m_axis_rd_tdata,
	output logic m_axis_rd_tvalid,

	// S_AXIS_RD

	input logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] s_axis_rd_tdata,
	input logic s_axis_rd_tvalid,
	output logic s_axis_rd_tready,

	// S_AXIS_WR

	input logic [C_MEM_WIDTH-1:0] s_axis_wr_tdata,
	input logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] s_axis_wr_tdest,
	input logic s_axis_wr_tvalid,
	output logic s_axis_wr_tready,

	// BPI

	output logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] bpi_a,
	output logic [C_MEM_WIDTH-1:0] bpi_dq_o,
	output logic [C_MEM_WIDTH-1:0] bpi_dq_t,
	input logic [C_MEM_WIDTH-1:0] bpi_dq_i,

	output logic bpi_adv,
	output logic bpi_ce_n,
	output logic bpi_oe_n,
	output logic bpi_we_n
);
	enum logic [1:0] {ST_IDLE, ST_READ_MEM, ST_WRITE_MEM, ST_DONE} state;

	localparam C_READ_TIME = C_ADDR_TO_CEL_TIME + C_OEL_TO_DQ_TIME;
	localparam C_WRITE_TIME = C_ADDR_TO_CEL_TIME + C_WEL_TO_DQ_TIME + C_DQ_TO_WEH_TIME;

	logic [$clog2(C_READ_TIME | C_WRITE_TIME | C_IO_TO_IO_TIME)-1:0] count;
	logic rd_en;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;
			count <= '0;
			rd_en <= 1'b0;

			bpi_a <= '0;
			bpi_dq_o <= '0;
			bpi_dq_t <= '1;

			bpi_ce_n <= 1'b1;
			bpi_oe_n <= 1'b1;
			bpi_we_n <= 1'b1;
			bpi_adv <= 1'b1;

			m_axis_rd_tdata <= '0;
			m_axis_rd_tvalid <= 1'b0;

			s_axis_rd_tready <= 1'b0;
			s_axis_wr_tready <= 1'b0;
		end else begin
			case(state)
				ST_IDLE: begin
					count <= '0;
					rd_en <= 1'b0;

					bpi_a <= '0;
					bpi_dq_o <= '0;
					bpi_dq_t <= '1;
					bpi_ce_n <= 1'b1;
					bpi_oe_n <= 1'b1;
					bpi_we_n <= 1'b1;
					bpi_adv <= 1'b1;

					s_axis_rd_tready <= ~mode;
					s_axis_wr_tready <= mode;

					if(s_axis_rd_tready & s_axis_rd_tvalid) begin
						state <= ST_READ_MEM;
						bpi_a <= s_axis_rd_tdata;

						s_axis_wr_tready <= 1'b0;
					end

					if(s_axis_wr_tready & s_axis_wr_tvalid) begin
						state <= ST_WRITE_MEM;
						bpi_a <= s_axis_wr_tdest;
						bpi_dq_o <= s_axis_wr_tdata;

						s_axis_rd_tready <= 1'b0;
						s_axis_wr_tready <= 1'b0;
					end
				end

				ST_READ_MEM: begin
					count <= count + 'd1;

					if(~s_axis_rd_tvalid) begin
						s_axis_rd_tready <= 1'b0;
					end

					if(count == C_ADDR_TO_CEL_TIME - 1) begin
						bpi_ce_n <= 1'b0;
						bpi_oe_n <= 1'b0;
						bpi_we_n <= 1'b1;
						bpi_adv <= 1'b0;
					end

					if(count == C_ADDR_TO_CEL_TIME + C_OEL_TO_DQ_TIME - 1) begin
						rd_en <= 1'b1;
					end

					if(rd_en) begin
						count <= '0;

						m_axis_rd_tdata <= bpi_dq_i;
						m_axis_rd_tvalid <= 1'b1;

						if(~s_axis_rd_tvalid) begin
							if(C_IO_TO_IO_TIME <= 3) begin
								state <= ST_IDLE;
								s_axis_rd_tready <= ~mode;
								s_axis_wr_tready <= mode;
							end else begin
								state <= ST_DONE;
							end

							bpi_ce_n <= 1'b1;
							bpi_oe_n <= 1'b1;
							bpi_we_n <= 1'b1;
							bpi_adv <= 1'b1;

							rd_en <= 1'b0;

							m_axis_rd_tdata <= '0;
							m_axis_rd_tvalid <= 1'b0;
						end
					end
				end

				ST_WRITE_MEM: begin
					count <= count + 'd1;

					if(count == C_ADDR_TO_CEL_TIME - 1) begin
						bpi_ce_n <= 1'b0;
						bpi_oe_n <= 1'b1;
						bpi_we_n <= 1'b0;
						bpi_adv <= 1'b0;
					end

					if(count == C_ADDR_TO_CEL_TIME + C_WEL_TO_DQ_TIME - 1) begin
						bpi_dq_t <= '0;
					end

					if(count == C_ADDR_TO_CEL_TIME + C_WEL_TO_DQ_TIME + C_DQ_TO_WEH_TIME - 1) begin
						if(C_IO_TO_IO_TIME <= 3) begin
							state <= ST_IDLE;
							s_axis_rd_tready <= ~mode;
							s_axis_wr_tready <= mode;
						end else begin
							state <= ST_DONE;
							count <= '0;
						end

						bpi_dq_t <= '1;

						bpi_ce_n <= 1'b1;
						bpi_oe_n <= 1'b1;
						bpi_we_n <= 1'b1;
						bpi_adv <= 1'b1;
					end
				end

				ST_DONE: begin
					count <= count + 'd1;

					if(count == C_IO_TO_IO_TIME - 3) begin
						state <= ST_IDLE;
						s_axis_rd_tready <= ~mode;
						s_axis_wr_tready <= mode;
					end
				end
			endcase
		end
	end
endmodule
