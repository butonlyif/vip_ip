module get_result (clk, rst, data_in_valid, data_in, x, y, bk,  rk);

input	clk, rst;
input	data_in_valid;
input	[7:0]	data_in;
input	x, y;

output [17:0]	bk,  rk;

wire	b_valid, g0_valid, g1_valid, r_valid;

assign	b_valid = (!x) & (!y) & data_in_valid ;
assign	g0_valid = x & (!y) & data_in_valid;
assign	g1_valid = y & (!x)& data_in_valid;
assign	r_valid = x & y& data_in_valid;

wire	[7:0]	b_data_out, g0_data_out, g1_data_out, r_data_out;
wire	b_out_valid, g0_out_valid, g1_out_valid, r_out_valid;

get_avg	get_avg_blue(.valid(b_valid), .clk(clk), .rst(rst), .data_in(data_in), .out_data(b_data_out), .out_valid(b_out_valid));
get_avg	get_avg_green0(.valid(g0_valid), .clk(clk), .rst(rst), .data_in(data_in), .out_data(g0_data_out), .out_valid(g0_out_valid));
get_avg	get_avg_green1(.valid(g1_valid), .clk(clk), .rst(rst), .data_in(data_in), .out_data(g1_data_out), .out_valid(g1_out_valid));
get_avg	get_avg_red(.valid(r_valid), .clk(clk), .rst(rst), .data_in(data_in), .out_data(r_data_out), .out_valid(r_out_valid));

reg	[9:0]	accum;

reg	b_div_in, g0_div_in, g1_div_in, r_div_in;
wire	b_div_out;
reg	g0_div_out, g1_div_out, r_div_out;
always @(posedge clk) begin
	b_div_in <= r_out_valid;
	g0_div_in <= b_div_in;
	g1_div_in <= g0_div_in;
	r_div_in <= g1_div_in;
	g0_div_out <= b_div_out;
	g1_div_out <= g0_div_out;
	r_div_out <= g1_div_out;
end

	
always @(posedge clk or posedge rst) 
	if (rst)
		accum <= 0;
	else if (r_div_in)
		accum <= 0;
	else if ( g1_out_valid)
		accum <= g0_data_out + g1_data_out;


		
wire	[17:0]	div_numer;
wire	[7:0]		div_denom;
wire	[17:0]	div_out;		


assign	div_numer = {1'h0,accum, 7'h0};

div_control div_control (.clk(clk), .rst(rst), .start(b_div_in), .out_valid(b_div_out));

assign	div_denom = b_div_in ? b_data_out :
							r_div_in ? r_data_out : 0;
	
div8 div8 (
	.clock	(clk),
	.denom	({2'h0,div_denom}),
	.numer	(div_numer),
	.quotient	(div_out)
	);	

reg	[17:0]	bk, g0k, g1k, rk;

always @(posedge clk or posedge rst) 
		if (rst)
			bk <= 0;
		else if ( b_div_out )
			bk <= div_out;
			
//always @(posedge clk or posedge rst) 
//		if (rst)
//			g0k <= 0;
//		else if ( g0_div_out )
//			g0k <= div_out;
			
//always @(posedge clk or posedge rst) 
//		if (rst)
//			g1k <= 0;
//		else if ( g1_div_out )
//			g1k <= div_out;
			
always @(posedge clk or posedge rst) 
		if (rst)
			rk <= 0;
		else if ( r_div_out )
			rk <= div_out;
			
endmodule 