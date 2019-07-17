
module axi4_lite_slave_read #(parameter addr_width = 7, parameter data_width = 32)
(
	input logic clk,
	input logic rst_n,

	output logic read_req,

	input logic read_ready,
	input logic read_response,
	input logic [data_width-1:0] read_value,

	input logic [addr_width-1:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [data_width-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready
);
	enum logic [1:0] {ST_R_WAIT_ADDR, ST_R_WAIT_DONE, ST_R_RESPONSE} state, state_next;

	logic arready_next;

	logic rvalid_next;
	logic [1:0] rresp_next;
	logic [data_width-1:0] rdata_next;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_R_WAIT_ADDR;

			s_axi_arready <= 1'b0;

			s_axi_rvalid <= 1'b0;
			s_axi_rdata <= '0;
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
						arready_next = 1'b0;
						read_req = 1'b1;

						if(read_ready) begin
							state_next = ST_R_RESPONSE;
							rdata_next = read_value;
							rresp_next = {~read_response, 1'b0};
							rvalid_next = 1'b1;
						end else begin
							state_next = ST_R_WAIT_DONE;
						end
					end
				end
			end

			ST_R_WAIT_DONE: begin
				read_req = 1'b1;

				if(read_ready) begin
					state_next = ST_R_RESPONSE;
					rdata_next = read_value;
					rresp_next = {~read_response, 1'b0};
					rvalid_next = 1'b1;
				end
			end

			ST_R_RESPONSE: begin
				if(s_axi_rready) begin
					state_next = ST_R_WAIT_ADDR;
					arready_next = 1'b1;
					rvalid_next = 1'b0;
				end
			end

			default: begin
				state_next = ST_R_WAIT_ADDR;
			end
		endcase
	end
endmodule
