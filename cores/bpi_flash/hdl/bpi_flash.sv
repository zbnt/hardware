/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	bpi_flash: BPI Flash

	Allows accessing a BPI Flash memory using an AXI4 interface
*/

module bpi_flash
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_MEM_WIDTH = 16,
	parameter C_MEM_SIZE = 134217728,

	parameter C_ADDR_TO_CEL_TIME = 3,
	parameter C_OEL_TO_OEH_TIME = 6,
	parameter C_WEL_TO_DQ_TIME = 1,
	parameter C_DQ_TO_WEH_TIME = 6,
	parameter C_OEH_TO_DONE_TIME = 5
)
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [$clog2(C_MEM_SIZE)-1:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [C_AXI_WIDTH-1:0] s_axi_wdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [$clog2(C_MEM_SIZE)-1:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

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
	enum logic [1:0] {ST_WAIT_AXI, ST_READ_FLASH, ST_WRITE_FLASH, ST_DONE} state;

	logic read_req;
	logic read_ready;
	logic read_response;
	logic [C_AXI_WIDTH-1:0] read_value;
	logic [$clog2(C_MEM_SIZE)-1:0] read_addr;

	logic write_req;
	logic write_ready;
	logic write_response;
	logic [$clog2(C_MEM_SIZE)-1:0] write_addr;
	logic [(C_AXI_WIDTH/C_MEM_WIDTH)-1:0] write_strb;
	logic [(C_AXI_WIDTH/C_MEM_WIDTH)-1:0] write_strb_valid;

	logic req_valid, req_done, req_op;
	logic [C_MEM_WIDTH-1:0] req_rdata;
	logic [C_AXI_WIDTH-1:0] req_wdata;
	logic [(C_AXI_WIDTH/C_MEM_WIDTH)-1:0] req_strb;
	logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] req_addr;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_AXI;

			read_ready <= 1'b0;
			read_response <= 1'b0;
			read_value <= '0;
			read_addr <= '0;

			write_ready <= 1'b0;
			write_response <= 1'b0;

			req_valid <= 1'b0;
			req_op <= 1'b0;
			req_wdata <= '0;
			req_strb <= '0;
			req_addr <= '0;
		end else begin
			case(state)
				ST_WAIT_AXI: begin
					if(read_req) begin
						state <= ST_READ_FLASH;

						req_addr <= s_axi_araddr[$clog2(C_MEM_SIZE)-1:$clog2(C_MEM_WIDTH/8)];
						req_strb <= '1;
						req_op <= 1'b0;
						req_valid <= 1'b1;
					end else if(write_req) begin
						if(write_strb_valid == '1 && write_strb != '0) begin
							state <= ST_WRITE_FLASH;

							req_wdata <= s_axi_wdata;
							req_addr <= write_addr[$clog2(C_MEM_SIZE)-1:$clog2(C_MEM_WIDTH/8)];
							req_strb <= write_strb;
							req_op <= 1'b1;
							req_valid <= write_strb[0];
						end else begin
							state <= ST_DONE;

							write_ready <= 1'b1;
							write_response <= 1'b0;
						end
					end
				end

				ST_READ_FLASH: begin
					req_valid <= 1'b0;

					if(req_done) begin
						req_strb <= {1'b0, req_strb[(C_AXI_WIDTH/C_MEM_WIDTH)-1:1]};
						read_value <= {req_rdata, read_value[C_AXI_WIDTH-1:C_MEM_WIDTH]};

						if(req_strb == 'd1) begin
							state <= ST_DONE;

							read_ready <= 1'b1;
							read_response <= 1'b1;
						end else begin
							req_addr <= req_addr + 'd1;
							req_valid <= 1'b1;
						end
					end
				end

				ST_WRITE_FLASH: begin
					req_valid <= 1'b0;

					if(req_done | ~req_strb[0]) begin
						req_strb <= {1'b0, req_strb[(C_AXI_WIDTH/C_MEM_WIDTH)-1:1]};
						req_wdata <= {'0, req_wdata[C_AXI_WIDTH-1:C_MEM_WIDTH]};

						if(req_strb == 'd1) begin
							state <= ST_DONE;

							write_ready <= 1'b1;
							write_response <= 1'b1;
						end else begin
							req_addr <= req_addr + 'd1;
							req_valid <= req_strb[1];
						end
					end
				end

				ST_DONE: begin
					state <= ST_WAIT_AXI;

					read_ready <= 1'b0;
					read_response <= 1'b0;
					read_value <= '0;

					write_ready <= 1'b0;
					write_response <= 1'b0;
				end
			endcase
		end
	end

	for(genvar i = 0; i < C_AXI_WIDTH/C_MEM_WIDTH; ++i) begin
		always_comb begin
			write_strb[i] = s_axi_wstrb[i*(C_MEM_WIDTH/8)];
			write_strb_valid[i] = (s_axi_wstrb[(i+1)*(C_MEM_WIDTH/8)-1:i*(C_MEM_WIDTH/8)] == '0 || s_axi_wstrb[(i+1)*(C_MEM_WIDTH/8)-1:i*(C_MEM_WIDTH/8)] == '1);
		end
	end

	// AXI4-Lite

	axi4_lite_slave_rw #($clog2(C_MEM_SIZE), C_AXI_WIDTH) U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(read_req),

		.read_ready(read_ready),
		.read_response(read_response),
		.read_value(read_value),

		.write_req(write_req),
		.write_addr(write_addr),

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

	// Flash FSM

	bpi_flash_fsm
	#(
		C_MEM_WIDTH,
		C_MEM_SIZE,

		C_ADDR_TO_CEL_TIME,
		C_OEL_TO_OEH_TIME,
		C_WEL_TO_DQ_TIME,
		C_DQ_TO_WEH_TIME,
		C_OEH_TO_DONE_TIME
	)
	U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.req_valid(req_valid),
		.req_done(req_done),

		.req_addr(req_addr),
		.req_op(req_op),

		.req_wdata(req_wdata[C_MEM_WIDTH-1:0]),
		.req_rdata(req_rdata),

		// BPI

		.bpi_a(bpi_a),
		.bpi_dq_o(bpi_dq_o),
		.bpi_dq_t(bpi_dq_t),
		.bpi_dq_i(bpi_dq_i),

		.bpi_adv(bpi_adv),
		.bpi_ce_n(bpi_ce_n),
		.bpi_oe_n(bpi_oe_n),
		.bpi_we_n(bpi_we_n)
	);
endmodule
