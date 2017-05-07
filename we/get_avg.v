module get_avg(valid, clk, rst, data_in, out_data, out_valid);

input	valid;
input	clk;
input	rst;
input	[7:0]	data_in;
output	[7:0]	out_data;
output			out_valid;

parameter W= 960;
parameter H = 540;
reg	[9:0]	x_cnt;
reg	[9:0]	y_cnt;
reg	[17:0]		x_accum;
reg	[17:0]		y_accum;

wire	one_line;

reg	one_line_d;

wire	frame_div_valid;
assign	one_line = (x_cnt == (W-1)) & valid;
reg	one_frame;
wire			line_div_valid;
wire	[17:0]	div_out;

always @(posedge clk ) one_line_d <= one_line;


always @(posedge clk or posedge rst) begin
	if (rst)
		x_cnt <= 0;
	else if ( one_line  )
		x_cnt <= 0;
	else if (valid)
		x_cnt <= x_cnt + 1;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		y_cnt <= 0;
	else if ( one_frame )
		y_cnt <= 0;
	else if (one_line)
		y_cnt <= y_cnt + 1;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		one_frame <= 0;
	else 
		one_frame <= line_div_valid & (y_cnt == H);
end


always @(posedge clk or posedge rst) begin
	if (rst)
		x_accum <= 0;
	else if (one_line_d)
		x_accum <= 0;
	else if (valid)
		x_accum <= x_accum + data_in;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		y_accum <= 0;
	else if (out_valid)
		y_accum <= 0;
	else if (line_div_valid)
		y_accum <= y_accum + div_out[7:0];
end

div_control line_div_control(.clk	(clk), .rst(rst), .start(one_line_d), .out_valid(line_div_valid));
div_control frame_div_control(.clk	(clk), .rst(rst), .start(one_frame), .out_valid(frame_div_valid));

wire	[17:0]	numer;
wire	[9:0]		denom;

assign	numer = one_frame ? y_accum: 
						one_line_d ? x_accum : 0;
assign	denom = one_frame ? 10'h21c : 10'h3c0;


div8 div8 (
	.clock	(clk),
	.denom	(denom),
	.numer	(numer),
	.quotient	(div_out)
	);

reg	[7:0]	out_data;
reg		out_valid;

always @(posedge clk) out_valid <= frame_div_valid;


always @(posedge clk or posedge rst) begin
	if (rst)
		out_data <= 0;
	else if (frame_div_valid)
		out_data <= div_out;
end


endmodule 