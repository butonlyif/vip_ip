module y_enhance_rate ( input	wire	[23:0]	video_in_data,
									input		wire					video_in_valid,
									input		wire					video_in_sop,
									input		wire					video_in_eop,
									output	wire					video_in_ready,
									
									output	wire	[15:0]	rate,
									output	wire	[7:0]		min_out_value,								
									
									input		wire					bypass,
									input		wire	[7:0]				diff_threshold,
									output		wire					diff2small,
									input		wire					clk,
									input		wire					rst);

wire					dont_calcu;
reg		[15:0]	width_reg, height_reg;
reg	[15:0]		x_cnt;
reg	[15:0]		y_cnt;
//wire					end_frame
//wire					end_x, end_y;
reg	[7:0]		max_reg, min_reg;
reg	[7:0]		diff_reg;
reg					video_in_eop_d, video_in_eop_d_2;
reg	[7:0]		min_reg_d;
reg	[7:0]		min_out_reg;
reg	[15:0]	div_q_reg;
reg	[7:0]		diff_value, min_value;
wire	[15:0]	div_q;
assign	video_in_ready = 1'b1;
reg	[7:0]	div_valid_reg; 
//always @(posedge clk or posedge rst)


//	if (rst) begin	
//		width_reg <= 0;
//		height_reg <= 0;
//	end 
//	else if (control_in_valid) begin
//		width_reg <= control_in_data[35:20];
//		height_reg <= control_in_data[19:4];
//		end


//always @(posedge clk or posedge rst) 
//	if (rst) begin	
//		x_cnt <= 0;
//		y_cnt <= 0;
//	end
//	else if (video_valid) begin
//		if (end_x) begin
//			x_cnt <= 0;
//			if (end_y)
//				y_cnt <= 0;
//			else 
//				y_cnt <= y_cnt + 1;
//		end
//		else x_cnt <= x_cnt + 1;
//	end
//	
//assign 	end_x = (x_cnt == (width_reg - 1));
//assign	end_y = (y_cnt == (height_reg -1));
//assign	end_frame = end_x & end_y & video_in_valid;

always @(posedge clk or posedge rst) 
	if (rst) begin
		max_reg <= 0;
		min_reg <= 8'hff;
	end
	else if (video_in_eop_d) begin
		max_reg <= 0;
		min_reg <= 8'hff;
	end
	else if (video_in_valid) begin
		if (video_in_data[23:16] > max_reg)	max_reg <= video_in_data[23:16];
		if (video_in_data[23:16] < min_reg) min_reg <= video_in_data[23:16];
		end
		
always @(posedge clk or posedge rst)
	if (rst) begin
		diff_reg <= 0;
		min_reg_d <= 0;
		end
	else if (video_in_eop) begin
		diff_reg <= max_reg - min_reg;
		min_reg_d <= min_reg;
	end
assign dont_calcu	= bypass | (diff_reg==0);
assign	diff2small = (diff_reg <= diff_threshold);

always @(posedge clk or posedge rst)
	if (rst) begin
		video_in_eop_d <= 0;
		video_in_eop_d_2 <= 0;
		
	end
	else begin
		video_in_eop_d <= video_in_eop;
		video_in_eop_d_2 <= video_in_eop_d;
		
	end
	
	
div16 div16 (
	.clock		(clk),
	.denom		(diff_reg),
	.numer		(16'hff00),
	.quotient	(div_q)
	);	

always @(posedge clk or posedge rst)
	if (rst)
		div_valid_reg <= 0;
	else 
		div_valid_reg <= {div_valid_reg[7:0],video_in_eop_d_2};

		
always @(posedge clk or posedge rst)
	if (rst) begin	
		div_q_reg <= 0;
		min_out_reg <= 0;
	end 
	else if (dont_calcu) begin	
		div_q_reg <= 16'h100;
		min_out_reg <= 0;
	end
	else if (div_valid_reg[7]) begin
		div_q_reg <= div_q;
		min_out_reg <= min_reg_d;
	end

assign	rate = div_q_reg;
assign	min_out_value = min_out_reg;


endmodule 
