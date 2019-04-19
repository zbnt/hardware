
module axi4_lite_slave_read #(parameter addr_width = 7)
(
	input logic clk,
	input logic rst_n,

	output logic read_req,

	input logic read_ready,
	input logic read_response,
	input logic [31:0] read_value,

	input logic [addr_width-1:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [31:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready
);
	enum logic {ST_R_WAIT_ADDR, ST_R_RESPONSE} state, state_next;

	logic arready_next;

	logic rvalid_next;
	logic [31:0] rdata_next;
	logic [1:0] rresp_next;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			state <= ST_R_WAIT_ADDR;

			s_axi_arready <= 1'b0;

			s_axi_rvalid <= 1'b0;
			s_axi_rdata <= 32'd0;
			s_axi_rresp <= 2'd0;
		end else begin
			state <= state_next;

			s_axi_arready <= arready_next;

			s_axi_rvalid <= rvalid_next;
			s_axi_rdata <= rdata_next;
			s_axi_rresp <= rresp_next;
		end
	end

	always_comb begin
		state_next = state;

		arready_next = s_axi_arready;

		rvalid_next = s_axi_rvalid;
		rdata_next = s_axi_rdata;
		rresp_next = s_axi_rresp;

		read_req = 1'b0;

		case(state)
			ST_R_WAIT_ADDR: begin
				arready_next = 1'b1;

				if(rst_n) begin
					if(s_axi_arvalid) begin
						state_next = ST_R_RESPONSE;
						arready_next = 1'b0;
						read_req = 1'b1;

						if(read_ready) begin
							rdata_next = read_value;
							rresp_next = {~read_response, 1'b0};
							rvalid_next = 1'b1;
						end
					end
				end
			end

			ST_R_RESPONSE: begin
				read_req = 1'b1;

				if(s_axi_rvalid & s_axi_rready) begin
					state_next = ST_R_WAIT_ADDR;
					arready_next = 1'b1;
					rvalid_next = 1'b0;
				end else if(read_ready) begin
					rdata_next = read_value;
					rresp_next = {~read_response, 1'b0};
					rvalid_next = 1'b1;
				end
			end
		endcase
	end
endmodule
