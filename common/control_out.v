module control_out (	source_data,
										source_valid,
										source_sop,
										source_eop,
										source_ready,
										
										clk,
										rst,
										//control_start,
										width,
										height,
										interlace,
										control_valid
										);
parameter WIDTH_VALUE = 24;
output	[WIDTH_VALUE-1:0]	source_data;
output				source_valid, source_eop, source_sop;
input					source_ready;
//input					control_start;
input					clk, rst;
input		[15:0]	width;
input		[15:0]	height;
input		[3:0]		interlace;
input						control_valid;
reg	[3:0] cnt;
wire	[WIDTH_VALUE-1:0]	data0, data1, data2, data3, data4, data5, data6, data7, data8, data9;
wire	[3:0] packet_num;	


reg	[15:0]	width_reg, height_reg;
reg	[3:0]		interlace_reg;
reg					control_en;

reg					source_ready_d;

always @(posedge clk)
	if (rst)
		source_ready_d <= 0;
	else if (control_en)
	source_ready_d <= source_ready & (!source_eop);





always @(posedge clk or posedge rst)
	if (rst)
		cnt <= 0;
	else if ( source_valid & control_en ) begin
		if (cnt==packet_num)
			cnt <= 0;
		else
		cnt <= cnt + 1;
end

always @(posedge clk or posedge rst)
	if (rst) begin	
		control_en <= 0;
		width_reg <= 0;
		height_reg <= 0;
		interlace_reg <= 0;
	end else if (control_valid) begin
		control_en <= 1'b1;
		width_reg <= width;
		height_reg <= height;
		interlace_reg <= interlace;
		end
		
generate begin	
case (WIDTH_VALUE)
24: begin
assign	data0 = 24'h00000f;
assign	data1 = {4'h0, width_reg[7:4], 4'h0, width_reg[11:8], 4'h0, width_reg[15:12]};
assign	data2 = {4'h0, height_reg[11:8], 4'h0, height_reg[15:12], 4'h0, width_reg[3:0]};
assign	data3 = {4'h0, interlace_reg[3:0], 4'h0, height_reg[3:0], 4'h0, height_reg[7:4]};
assign 	packet_num = 3;
assign	source_eop = (cnt==3) & source_valid;
end
32 : begin
assign	data0 = 32'h00000f;
assign	data1 = {4'h0, width_reg[3:0], 4'h0, width_reg[7:4], 4'h0, width_reg[11:8], 4'h0, width_reg[15:12]};
assign	data2 = {4'h0, height_reg[3:0], 4'h0, height_reg[7:4], 4'h0, height_reg[11:8], 4'h0, width_reg[15:12]};
assign	data3 = {28'h0, interlace_reg[3:0]};
assign	packet_num = 3;
assign	source_eop = (cnt==3) & source_valid;
end
8: begin
assign  data0 = 8'h0f;
assign  data1 = {4'h0, width_reg[15:12]};
assign  data2 = {4'h0, width_reg[11:8]};
assign  data3 = {4'h0, width_reg[7:4]};
assign  data4 = {4'h0, width_reg[3:0]};
assign  data5 = {4'h0, height_reg[15:12]};
assign  data6 = {4'h0, height_reg[11:8]};
assign  data7 = {4'h0, height_reg[7:4]};
assign  data8 = {4'h0, height_reg[3:0]};
assign  data9 = {4'h0, interlace_reg[3:0]};
assign  packet_num=9;
assign	source_eop = (cnt==9) & source_valid;
end
endcase
end
endgenerate
		
assign	source_data = (cnt == 0) ? 	data0 :
											(cnt == 1) ? data1 :
											(cnt == 2) ? data2 :
											(cnt == 3) ? data3 : 
											(cnt == 4) ? data4 :
											(cnt == 5) ? data5 :
											(cnt == 6) ? data6 :
											(cnt == 7) ? data7 :
											(cnt == 8) ? data8 :
											(cnt == 9) ? data9 : 0;
											
assign	source_valid = source_ready_d;
assign	source_sop = (cnt==0) & source_valid;

endmodule 

