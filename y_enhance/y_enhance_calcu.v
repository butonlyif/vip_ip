module y_enhance_calcu ( 						input	wire	[23:0]	video_in_data,
									input		wire					video_in_valid,
									input		wire					video_in_sop,
									input		wire					video_in_eop,
									output	wire					video_in_ready,
									
									output	wire	[23:0]	video_out_data,
									output	wire					video_out_valid,
									input		wire					video_out_ready,
									
									input	wire	[15:0]	rate,
									input	wire	[7:0]		min_value,								
									input		wire				diff2small,
									input		wire					clk,
									input		wire					rst);
									
reg	[15:0]		rate_reg;
reg	[7:0]			min_reg;
reg	[1:0]			video_in_valid_d;
reg	[7:0]			sub;
reg	[23:0]		mult;		
wire	[7:0]		y_value, cb_value, cr_value;
assign	video_in_ready = video_out_ready;
reg	[15:0]	cbcr_d, cbcr_d2;
reg			diff2small_reg;

always @(posedge clk or posedge rst)
	if (rst) begin
		rate_reg <= 0;
		min_reg <= 0;
		diff2small_reg <= 0;
	end
	else if (video_in_eop & video_in_valid) begin
		rate_reg <= rate;
		min_reg <= min_value;
		diff2small_reg <= diff2small;
	end

always @(posedge clk or posedge rst)
	if (rst) begin
		cbcr_d <= 0;
	end
	else if (video_in_valid) 
		cbcr_d <= video_in_data[15:0];

always @(posedge clk or posedge rst)
	if (rst) 
		cbcr_d2 <= 0;
	else if (video_in_valid_d[0])
		cbcr_d2 <= cbcr_d;

always @(posedge clk or posedge rst)
	if (rst) 
		video_in_valid_d <= 0;	
	else 
		video_in_valid_d <= {video_in_valid_d[0], video_in_valid};
		
always @(posedge clk or posedge rst)
	if (rst)
		sub <= 0;
	else if (video_in_valid) begin
	//	sub[23:16] <= video_in_data[23:16] - min_reg;
	//	sub[15:8]		<= video_in_data[15:8] - min_reg;
		sub[7:0]		<= video_in_data[23:16] - min_reg;
	end
	
always @(posedge clk or posedge rst)
	if (rst)
		mult <= 0;
	else if (video_in_valid_d[0]) begin
		//mult[24*3-1:24*2] <= sub[23:16] * rate_reg;
		//mult[24*2-1:24*1] <= sub[15:8] * rate_reg;
		mult[24*1-1:0] <= sub[7:0] * rate_reg;
	end

//assign	r_value = (mult[24*3-1:24*3-8]==0) ? mult[63:56] : 8'hff;
//assign	g_value = (mult[24*2-1:24*2-8]==0) ? mult[39:32] : 8'hff;
//assign	b_value = (mult[24*1-1:24*1-8]==0) ? mult[15:8] : 8'hff;

assign	video_out_valid = video_in_valid_d[1];
assign	video_out_data =  {mult[15:8], cbcr_d2};

endmodule 							
