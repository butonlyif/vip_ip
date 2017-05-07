module we_top (	clk, rst, sink_data, sink_eop, sink_sop, sink_ready,sink_valid,
							source_data, source_eop, source_sop, source_ready, source_valid);

input	clk, rst;
input	[7:0]	sink_data;
input			sink_sop, sink_eop;
input			sink_valid;
output		sink_ready;

output	[7:0]	source_data;
output			source_sop, source_eop;
output	source_valid;
input			source_ready;
parameter W=1920;
parameter H=1080;
reg	[15:0]	x_cnt, y_cnt;
wire	[1:0]	cube;
wire	video_valid;
assign	video_valid = sink_valid & (!sink_sop);
assign	cube = {y_cnt[0],x_cnt[0]};
wire	one_line;

assign	one_line = (x_cnt == (W-1)) & video_valid;


always @(posedge clk or posedge rst) begin
	if (rst)
		x_cnt <= 0;
	else if ( one_line  )
		x_cnt <= 0;
	else if (video_valid)
		x_cnt <= x_cnt + 1;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		y_cnt <= 0;
	else if ( sink_eop & video_valid )
		y_cnt <= 0;
	else if (one_line)
		y_cnt <= y_cnt + 1;
end

wire	[17:0]	bk,  rk;
get_result get_result (.clk(clk), .rst(rst), .data_in_valid(video_valid), .data_in(sink_data), .x(x_cnt[0]), .y(y_cnt[0]), 
							.bk(bk), .rk(rk));
							
reg	[17:0]	bk_reg, rk_reg;

always @(posedge clk or posedge rst)
	if (rst) begin
		bk_reg <= 18'h100;
		//g0k_reg <= 18'h100;
		//g1k_reg <= 18'h100;
		rk_reg <= 18'h100;
	end 
	else if (source_eop) begin
		bk_reg <= bk;
		//g0k_reg <= g0k;
		//g1k_reg <= g1k;
		rk_reg <= rk;
	end
	
wire	[17:0]	mult_b;
assign	mult_b = (cube==0) ?	bk_reg :
						(cube==1) ? 18'h100 :
						(cube==2) ? 18'h100 :
						(cube==3) ? rk_reg :0;
wire	[25:0]	mult_result;						
mult8x18 mult8x18 (
	.clock	(clk),
	.dataa	(sink_data),
	.datab	(mult_b),
	.result	(mult_result)
	);		

reg	valid_d, sop_d, eop_d, valid_d2, sop_d2, eop_d2, source_valid, source_sop, source_eop;
reg	[7:0]	source_data;
wire	sat;

assign	sat = |mult_result[25:16];
//assign	source_data = mult_result[15:8];
assign	sink_ready = source_ready;

always @(posedge clk or posedge rst)
	if (rst) begin
		source_data <= 0;
	end else
		source_data <= sat ? 8'hff : mult_result[15:8];





always @(posedge clk or posedge rst) 
	if (rst) begin
		valid_d <= 0;
		sop_d <= 0;
		eop_d <= 0;
				valid_d2 <= 0;
		sop_d2 <= 0;
		eop_d2 <= 0;
		source_valid <= 0;
		source_sop <= 0;
		source_eop <= 0;
		end
	else begin
		valid_d <= sink_valid;
		sop_d <= sink_sop;
		eop_d <= sink_eop;
		valid_d2 <= valid_d;
		sop_d2 <= sop_d;
		eop_d2 <= eop_d;
		source_valid <= valid_d2;
		source_sop <= sop_d2;
		source_eop <= eop_d2;
		end
		
endmodule 