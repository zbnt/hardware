
// Based on the information at https://github.com/Michaelangel007/crc32

module crc32b
(
	input logic clk,
	input logic rst,
	input logic enable,
	input logic [7:0] in_byte,
	output logic [31:0] crc
);
	logic [31:0] crc_next;

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			crc <= '1;
		end else begin
			crc <= crc_next;
		end
	end

	always_comb begin
		if(enable & ~rst) begin
			crc_next = crc ^ {24'd0, in_byte};

			for(int i = 0; i < 7; ++i) begin
				crc_next = (crc_next >> 1) ^ (crc_next[0] ? 32'hEDB88320 : 32'd0);
			end
		end else begin
			crc_next = crc;
		end
	end
endmodule
