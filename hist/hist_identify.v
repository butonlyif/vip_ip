module hist_identify (input	wire	[23:0] 	video_data,
								input	wire					video_valid,
								output	wire				video_ready,
								input		wire				clk,
								input		wire				rst,
								
								input		wire	[35:0]		control_in_data,
								input		wire						control_in_valid,
				
								
								output	wire	[8*8-1:0]		r_id_data,
								output	wire	[8*8-1:0]		g_id_data,
								output	wire	[8*8-1:0]		b_id_data,
								output	wire						id_valid

								);
								
parameter	WIDTH = 1920;
parameter	HEIGHT = 1080;
reg	[15:0]		x_cnt;
reg	[15:0]		y_cnt;
reg	[15:0]		width_reg;
reg	[15:0]		height_reg;
wire			end_x;
wire			end_y;
wire	[8*8-1:0]	id_value0;
assign		video_ready = 1;
assign 	end_x = (x_cnt == (width_reg - 1));
assign	end_y = (y_cnt == (height_reg -1));
reg				id_clear;

always @(posedge clk or posedge rst)
	if (rst) begin
		width_reg <= WIDTH;
		height_reg <= HEIGHT;
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
	
always @(posedge clk or posedge rst)
	if (rst)
		id_clear <= 0;
	else if (id_clear)
		id_clear <= 0;
	else if (end_x & end_y & video_valid)
		id_clear <= 1'b1;
		
hist_accum hist_accum0_b	(		.video_data		(video_data[7:0]),
														.video_valid	(video_valid),
														.id_clear			(id_clear),
										
														.id_value			(b_id_data),
										
														.clk					(clk),
														.rst					(rst)
														);
														
hist_accum hist_accum0_g	(		.video_data		(video_data[15:8]),
														.video_valid	(video_valid),
														.id_clear			(id_clear),
										
														.id_value			(g_id_data),
										
														.clk					(clk),
														.rst					(rst)
														);

hist_accum hist_accum0_r	(		.video_data		(video_data[23:16]),
														.video_valid	(video_valid),
														.id_clear			(id_clear),
										
														.id_value			(r_id_data),
										
														.clk					(clk),
														.rst					(rst)
														);


assign	id_valid = id_clear;


endmodule 