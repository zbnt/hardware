/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module mdio #(parameter C_AXI_WIDTH = 32)
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [10:0] s_axi_awaddr,
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

	input logic [10:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// MDIO

	input logic mdio_i,
	output logic mdio_o,
	output logic mdio_t,

	output logic mdc
);
	enum logic [1:0] {ST_IDLE, ST_READ, ST_WRITE, ST_DONE} state;
	logic mdio_en;

	logic [9:0] s_axi_awaddr_q;
	logic s_axi_awvalid_q;

	logic [C_AXI_WIDTH-1:0] s_axi_wdata_q;
	logic [(C_AXI_WIDTH/8)-1:0] strb;

	logic trigger, operation, done;
	logic [9:0] addr;
	logic [15:0] data_in, data_out;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;

			s_axi_awready <= 1'b0;
			s_axi_awaddr_q <= 10'd0;
			s_axi_awvalid_q <= 1'b0;
			s_axi_wdata_q <= '0;
			s_axi_wready <= 1'b0;
			s_axi_bvalid <= 1'b0;

			s_axi_arready <= 1'b0;
			s_axi_rdata <= '0;
			s_axi_rvalid <= 1'b0;

			strb <= '0;

			trigger <= 1'b0;
			operation <= 1'b0;
			addr <= 10'd0;
			data_in <= 16'd0;
		end else begin
			case(state)
				ST_IDLE: begin
					s_axi_awready <= 1'b1;
					s_axi_arready <= 1'b1;

					if(s_axi_awready & s_axi_awvalid) begin
						s_axi_awaddr_q <= s_axi_awaddr[10:1];
						s_axi_awvalid_q <= 1'b1;
						s_axi_awready <= 1'b0;
						s_axi_arready <= 1'b0;

						if(~s_axi_arready | ~s_axi_arvalid) begin
							state <= ST_WRITE;
							s_axi_wready <= 1'b1;
						end
					end

					if(s_axi_arready & s_axi_arvalid) begin
						state <= ST_READ;

						s_axi_awready <= 1'b0;
						s_axi_arready <= 1'b0;
						strb <= '1;

						trigger <= 1'b1;
						operation <= 1'b0;
						addr <= s_axi_araddr[10:1];
					end
				end

				ST_READ: begin
					if(done & mdio_en) begin
						if(strb <= 'd3) begin
							state <= ST_DONE;
							trigger <= 1'b0;
							s_axi_rvalid <= 1'b1;
						end

						addr <= addr + 10'd1;
						strb <= {2'd0, strb[(C_AXI_WIDTH/8)-1:2]};
						s_axi_rdata <= {data_out, s_axi_rdata[C_AXI_WIDTH-1:16]};
					end
				end

				ST_WRITE: begin
					if(s_axi_wready & s_axi_wvalid) begin
						s_axi_wdata_q <= s_axi_wdata;

						addr <= s_axi_awaddr_q;
						strb <= s_axi_wstrb;

						s_axi_wready <= 1'b0;
					end

					if(~s_axi_wready) begin
						if(~trigger) begin
							s_axi_wdata_q <= {16'd0, s_axi_wdata_q[C_AXI_WIDTH-1:16]};

							trigger <= strb[1] | strb[0];
							operation <= strb[1] & strb[0];
							data_in <= s_axi_wdata_q[15:0];

							if(strb[1:0] == '0) begin
								addr <= addr + 10'd1;
								strb <= {2'd0, strb[(C_AXI_WIDTH/8)-1:2]};
							end

							if(strb == '0) begin
								state <= ST_DONE;
								s_axi_bvalid <= 1'b1;
								s_axi_awvalid_q <= 1'b0;
							end
						end

						if(done & mdio_en) begin
							if(~operation) begin
								operation <= 1'b1;

								if(~strb[1]) begin
									data_in[15:8] <= data_out[15:8];
								end

								if(~strb[0]) begin
									data_in[7:0] <= data_out[7:0];
								end
							end else begin
								trigger <= 1'b0;
								addr <= addr + 10'd1;
								strb <= {2'd0, strb[(C_AXI_WIDTH/8)-1:2]};
							end
						end
					end
				end

				ST_DONE: begin
					if((s_axi_rready & s_axi_rvalid) | (s_axi_bready & s_axi_bvalid)) begin
						s_axi_rvalid <= 1'b0;
						s_axi_bvalid <= 1'b0;

						s_axi_awvalid_q <= 1'b0;

						if(s_axi_awvalid_q) begin
							state <= ST_WRITE;
							s_axi_wready <= 1'b1;
						end else begin
							state <= ST_IDLE;
						end
					end
				end
			endcase
		end
	end

	always_comb begin
		s_axi_bresp = 1'b0;
		s_axi_rresp = 1'b0;
	end

	mdio_fsm U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.enable(mdio_en),

		.trigger(trigger),
		.operation(operation),
		.addr(addr),
		.data_in(data_in),

		.done(done),
		.data_out(data_out),

		// MDIO

		.mdio_i(mdio_i),
		.mdio_o(mdio_o),
		.mdio_t(mdio_t)
	);

	mdio_clk U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.mdio_en(mdio_en),
		.mdc(mdc)
	);
endmodule
