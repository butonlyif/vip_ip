module y_enhance ( input	wire	[23:0]	video_in_data,
									input		wire					video_in_valid,
									output	wire					video_in_ready,
									
									output	wire	[23:0]	video_out_data,
									output	wire					video_out_valid,
									input		wire					video_out_ready,
									
									input		wire	[35:0]	control_in_data,
									input		wire					control_in_valid,
									
									output	wire	[35:0]	control_out_data,
									output	wire					control_out_valid,
									
									input		wire					clk,
									input		wire					rst);

reg		[15:0]	width_reg, height_reg;
reg	[15:0]		x_cnt;
reg	[15:0]		y_cnt;
wire					end_frame
wire					end_x, end_y;
reg	[7:0]		max_reg, min_reg;
reg	[7:0]		diff_reg;
reg					end_frame_d;
reg	[7:0]		min_reg_d;
reg	[7:0]		diff_value, min_value;
always @(posedge clk or posedge rst)
	if (rst) begin	
		width_reg <= 0;
		height_reg <= 0;
	end 
	else if (control_in_valid) begin
		width_reg <= control_in_data[35:20];
		height_reg <= control_in_data[19:4];
		end


always @(posedge clk or posedge rst) 
	if (rst) begin	
		x_cnt <= 0;
		y_cnt <= 0;
	end
	else if (video_valid) begin
		if (end_x) begin
			x_cnt <= 0;
			if (end_y)
				y_cnt <= 0;
			else 
				y_cnt <= y_cnt + 1;
		end
		else x_cnt <= x_cnt + 1;
	end
	
assign 	end_x = (x_cnt == (width_reg - 1));
assign	end_y = (y_cnt == (height_reg -1));
assign	end_frame = end_x & end_y & video_in_valid;

always @(posedge clk or posedge rst) 
	if (rst) begin
		max_reg <= 0;
		min_reg <= 8'hff;
	end
	else if (end_frame) begin
		max_reg <= 0;
		min_reg <= 8'hff;
	end
	else if (video_in_valid) begin
		if (video_in_data[23:16] > max_reg)	max_reg <= video_in_data[23:16];
		if (video_in_data[23:16] < min_reg) min_reg <= video_in_data[23:16];
		end
		
always @(posedge clk or posedge rst)
	if (rst) 
		diff_reg <= 0;
	else if (end_frame)
		diff_reg <= max_reg - min_reg;

always @(posedge clk or posedge rst)
	if (rst) begin
		end_frame_d <= 0
		min_reg_d <= 0;
	end
	else begin
		end_frame_d <= end_frame;
		min_reg_d <= min_reg;
	end
	
