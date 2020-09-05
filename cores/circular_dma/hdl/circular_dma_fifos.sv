/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module circular_dma_fifos
#(
	parameter C_AXIS_WIDTH = 64,
	parameter C_MAX_BURST = 16,

	parameter C_FIFO_TYPE_0 = "block",
	parameter C_FIFO_TYPE_1 = "none",
	parameter C_FIFO_TYPE_2 = "none",
	parameter C_FIFO_TYPE_3 = "none",

	parameter C_FIFO_DEPTH_0 = 256,
	parameter C_FIFO_DEPTH_1 = 256,
	parameter C_FIFO_DEPTH_2 = 256,
	parameter C_FIFO_DEPTH_3 = 256
)
(
	input logic clk,
	input logic rst_n,

	input logic enable,
	input logic flush_req,

	output logic ready,
	output logic flush_active,
	output logic flush_ack,

	output logic [$clog2(C_MAX_BURST+1)-1:0] occupancy,

	// S_AXIS

	input logic [C_AXIS_WIDTH-1:0] s_axis_tdata,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready,

	// M_AXIS

	output logic [C_AXIS_WIDTH-1:0] m_axis_tdata,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	localparam int C_FIFO_TYPES[0:3]  = '{C_FIFO_TYPE_0,  C_FIFO_TYPE_1,  C_FIFO_TYPE_2,  C_FIFO_TYPE_3};
	localparam int C_FIFO_DEPTHS[0:3] = '{C_FIFO_DEPTH_0, C_FIFO_DEPTH_1, C_FIFO_DEPTH_2, C_FIFO_DEPTH_3};

	logic [C_AXIS_WIDTH-1:0] axis_f2f_tdata[0:4];
	logic [4:0] axis_f2f_tlast, axis_f2f_tvalid, axis_f2f_tready;

	logic shutdown_input, shutdown_input_ack;
	logic shutdown_output, shutdown_output_ack;

	logic occupancy_capped;

	// Enable/shutdown FSM

	enum logic [1:0] {ST_IDLE, ST_ACTIVE, ST_WAIT_FLUSH, ST_WAIT_SHUTDOWN} state;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;
			flush_ack <= 1'b0;
			flush_active <= 1'b0;
		end else begin
			case(state)
				ST_IDLE: begin
					if(enable) begin
						state <= ST_ACTIVE;
					end
				end

				ST_ACTIVE: begin
					if(~enable) begin
						state <= ST_WAIT_SHUTDOWN;
					end else if(flush_req) begin
						state <= ST_WAIT_FLUSH;
					end
				end

				ST_WAIT_FLUSH: begin
					if(~enable) begin
						state <= ST_WAIT_SHUTDOWN;
						flush_ack <= 1'b0;
						flush_active <= 1'b0;
					end else if(shutdown_input_ack) begin
						if(~occupancy_capped) begin
							flush_active <= 1'b1;
						end

						if(shutdown_input_ack && occupancy == '0) begin
							flush_ack <= 1'b1;
						end
					end
				end

				ST_WAIT_SHUTDOWN: begin
					if(shutdown_input_ack && shutdown_output_ack && occupancy == '0) begin
						state <= ST_IDLE;
					end
				end
			endcase
		end
	end

	always_comb begin
		shutdown_input  = (state != ST_ACTIVE);
		shutdown_output = (state != ST_ACTIVE && state != ST_WAIT_FLUSH);

		ready = (state == ST_ACTIVE || state == ST_WAIT_FLUSH);
	end

	// Input shutdown

	axis_shutdown
	#(
		.C_AXIS_TDATA_WIDTH(C_AXIS_WIDTH),
		.C_TREADY_IN_SHUTDOWN(1)
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.shutdown_req(shutdown_input),
		.shutdown_ack(shutdown_input_ack),

		// S_AXIS

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tready(s_axis_tready),

		// M_AXIS

		.m_axis_tdata(axis_f2f_tdata[0]),
		.m_axis_tlast(axis_f2f_tlast[0]),
		.m_axis_tvalid(axis_f2f_tvalid[0]),
		.m_axis_tready(axis_f2f_tready[0])
	);

	// FIFO chain

	for(genvar i = 0; i < 4; ++i) begin
		if(C_FIFO_TYPES[i] != "none") begin
			axis_fifo
			#(
				.C_DEPTH(C_FIFO_DEPTHS[i]),
				.C_MEM_TYPE(C_FIFO_TYPES[i]),
				.C_CDC_STAGES(0),

				.C_DATA_WIDTH(C_AXIS_WIDTH),
				.C_HAS_LAST(1)
			)
			U1
			(
				.s_clk(clk),
				.s_rst_n(rst_n),

				.s_axis_tdata(axis_f2f_tdata[i]),
				.s_axis_tlast(axis_f2f_tlast[i]),
				.s_axis_tvalid(axis_f2f_tvalid[i]),
				.s_axis_tready(axis_f2f_tready[i]),

				.m_clk(clk),

				.m_axis_tdata(axis_f2f_tdata[i + 1]),
				.m_axis_tlast(axis_f2f_tlast[i + 1]),
				.m_axis_tvalid(axis_f2f_tvalid[i + 1]),
				.m_axis_tready(axis_f2f_tready[i + 1])
			);
		end else begin
			always_comb begin
				axis_f2f_tdata[i + 1] = axis_f2f_tdata[i];
				axis_f2f_tlast[i + 1] = axis_f2f_tlast[i];
				axis_f2f_tvalid[i + 1] = axis_f2f_tvalid[i];
				axis_f2f_tready[i] = axis_f2f_tready[i + 1];
			end
		end
	end

	// Output shutdown

	axis_shutdown
	#(
		.C_AXIS_TDATA_WIDTH(C_AXIS_WIDTH),
		.C_TREADY_IN_SHUTDOWN(1)
	)
	U2
	(
		.clk(clk),
		.rst_n(rst_n),

		.shutdown_req(shutdown_output),
		.shutdown_ack(shutdown_output_ack),

		// S_AXIS

		.s_axis_tdata(axis_f2f_tdata[4]),
		.s_axis_tlast(axis_f2f_tlast[4]),
		.s_axis_tvalid(axis_f2f_tvalid[4]),
		.s_axis_tready(axis_f2f_tready[4]),

		// M_AXIS

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);

	// Occupancy count

	localparam C_FIFO_DEPTH_TOTAL = C_FIFO_DEPTH_0 + 4
	                              + (C_FIFO_TYPE_1 != "none") * (C_FIFO_DEPTH_1 + 4)
	                              + (C_FIFO_TYPE_2 != "none") * (C_FIFO_DEPTH_2 + 4)
	                              + (C_FIFO_TYPE_3 != "none") * (C_FIFO_DEPTH_3 + 4);

	logic [$clog2(C_FIFO_DEPTH_TOTAL+1)-1:0] total_occupancy;

	always_comb begin
		occupancy = occupancy_capped ? C_MAX_BURST : total_occupancy[$bits(occupancy)-1:0];
	end

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			total_occupancy <= '0;
			occupancy_capped <= 1'b0;
		end else begin
			if((axis_f2f_tvalid[0] & axis_f2f_tready[0]) ^ (axis_f2f_tvalid[4] & axis_f2f_tready[4])) begin
				if(axis_f2f_tvalid[0] & axis_f2f_tready[0]) begin
					total_occupancy <= total_occupancy + 'd1;

					if(total_occupancy == C_MAX_BURST) begin
						occupancy_capped <= 1'b1;
					end
				end else begin
					total_occupancy <= total_occupancy - 'd1;

					if(total_occupancy == C_MAX_BURST) begin
						occupancy_capped <= 1'b0;
					end
				end
			end
		end
	end
endmodule
