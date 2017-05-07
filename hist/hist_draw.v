module hist_draw (		input		wire	video_ready,
								output	wire	video_valid,
								output	wire	[23:0]	video_data,
								
								input		wire	[8*8-1:0] g_id_data,
								input		wire	[8*8-1:0] r_id_data,
								input		wire	[8*8-1:0] b_id_data,

								input		wire				id_valid,
								
								input		wire				clk,
								input		wire				rst,
								
								input		[35:0]		in_control_data,
								input						in_control_valid,
								
								output	[35:0]		out_control_data,
								output					out_control_valid
								);
						
parameter	WIDTH = 256;
parameter	HEIGHT = 256;


wire	[15:0]	width_value;
wire	[15:0]		height_value;
wire	[3:0]			interlace_value;
reg				rst_d;

assign	out_control_valid = in_control_valid | (rst_d & (!rst));
assign	width_value = WIDTH;
assign	height_value = HEIGHT;
assign	interlace_value = 0;

assign	out_control_data = {width_value,height_value,interlace_value};

//always @(posedge clk or posedge rst)
//		if (rst) begin
//			r_id_data_reg <= 0;
//			g_id_data_reg <= 0;
//			b_id_data_reg <= 0;
//			end
//		else if (id_valid) begin
//			r_id_data_reg <= r_id_data;
//			g_id_data_reg <= g_id_data;
//			b_id_data_reg <= b_id_data;
//		end
//			

reg	[7:0]		x_cnt;
reg	[7:0]		y_cnt;
wire			end_x;
wire			end_y;
wire	[23:0]		color_wire;
reg				video_valid_reg;


always @(posedge clk ) rst_d <= rst;


assign 	end_x = (x_cnt == (WIDTH - 1));
assign	end_y = (y_cnt == 0);

always @(posedge clk or posedge rst) 
	if (rst) begin	
		x_cnt <= 0;
		y_cnt <= HEIGHT-1;
	end
	else if (video_valid) begin
		if (end_x) begin
			x_cnt <= 0;
			if (end_y)
				y_cnt <= (HEIGHT-1);
			else 
				y_cnt <= y_cnt - 1;
		end
		else x_cnt <= x_cnt + 1;
	end

wire	[23:0]	color_value_r, color_value_g, color_value_b;
	
hist_draw_get_color r_hist_draw_get_color ( .id_value		(r_id_data),
														.id_valid										(id_valid),
														
														.x_cnt											(x_cnt),
														.y_cnt											(y_cnt),
														.color_in										(24'hff0000),
														.color_value								(color_value_r),
														
														.clk												(clk),
														.rst												(rst)
														);

hist_draw_get_color g_hist_draw_get_color ( .id_value		(g_id_data),
														.id_valid										(id_valid),
														
														.x_cnt											(x_cnt),
														.y_cnt											(y_cnt),
														.color_in										(24'h00ff00),
														.color_value								(color_value_g),
														
														.clk												(clk),
														.rst												(rst)
														);
														
hist_draw_get_color b_hist_draw_get_color ( .id_value		(b_id_data),
														.id_valid										(id_valid),
														
														.x_cnt											(x_cnt),
														.y_cnt											(y_cnt),
														.color_in										(24'h0000ff),
														.color_value								(color_value_b),
														
														.clk												(clk),
														.rst												(rst)
														);
														
											

//always @(posedge clk or posedge rst)
//	if (rst)
//		color_reg <= 0;
//	else if (video_ready) begin
//		case	(x_cnt[4:3]) 
//		0: 	color_reg <= 0;
//		1:	color_reg	<= color_value_r;
//		2:	color_reg <= color_value_g;
//		3:	color_reg <= color_value_b;
//		endcase
//	end
assign	color_wire = (x_cnt[4:3]==0) ? 0 :
											(x_cnt[4:3]==1) ? color_value_r :
											(x_cnt[4:3]==2) ? color_value_g :
											(x_cnt[4:3]==3) ? color_value_b : 0;
	
always @(posedge clk or posedge rst)
	if (rst)
		video_valid_reg <= 0;
	else 
		video_valid_reg <= video_ready;

assign	video_data = color_wire;
assign	video_valid = video_valid_reg;


endmodule 