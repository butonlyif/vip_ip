module y_draw (		input		wire	video_ready,
								output	wire	video_valid,
								output	wire	[23:0]	video_data,
								
								input	wire[7:0]	ram_rddata,
								output	wire[7:0]	ram_addr,
								output	wire		ram_rd,

								input		wire				clk,
								input		wire				rst,
								output			frame_sync,
								
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
reg			video_ready_d;
assign	frame_sync = end_x & end_y & video_valid;
always @(posedge clk ) rst_d <= rst;
always @(posedge clk or posedge rst)
	if (rst)
		video_ready_d <= 0;
	else
		video_ready_d <= video_ready;

assign 	end_x = (x_cnt == (WIDTH - 1));
assign	end_y = (y_cnt == 0);

always @(posedge clk or posedge rst) 
	if (rst) begin	
		x_cnt <= 0;
		y_cnt <= HEIGHT-1;
	end
	else if (video_ready) begin
		if (end_x) begin
			x_cnt <= 0;
			if (end_y)
				y_cnt <= (HEIGHT-1);
			else 
				y_cnt <= y_cnt - 1;
		end
		else x_cnt <= x_cnt + 1;
	end

	assign	ram_addr = x_cnt;
	assign	ram_rd = video_ready;
	
	assign	video_valid = video_ready_d;
	assign	video_data = (ram_rddata == y_cnt) ? 24'hffffff : 24'h0;


endmodule 
