module div_control (clk, rst, start, out_valid);

input	clk, rst, start;
output	out_valid;

reg	line_div_en;
reg	[3:0]	line_div_cnt;
reg	line_div_en_d;

always @(posedge clk or posedge rst) begin
	if (rst)	
		line_div_en <= 0;
	else if ( start)
		line_div_en <= 1'b1;
	else if ( line_div_cnt == 7)
		line_div_en <= 1'b0;
end
always @(posedge clk) line_div_en_d <= line_div_en;

always @(posedge clk or posedge rst) begin
	if (rst)
		line_div_cnt <= 0;
	else if (line_div_en)
		line_div_cnt <= line_div_cnt + 1;
	else
		line_div_cnt <= 0;
end

assign	out_valid = line_div_en_d & (!line_div_en);

endmodule 