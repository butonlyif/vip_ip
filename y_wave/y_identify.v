module y_identify (input	wire	[23:0] 	video_data,
								input	wire					video_valid,
								output	wire				video_ready,
								input	wire				video_eop,
								input	wire				video_sop,
								
								input		wire				clk,
								input		wire				rst,
								
								input		wire	[35:0]		control_in_data,
								input		wire						control_in_valid,
				
								output	wire			frame_sync,	
								output	wire	[7:0]		ram_addr,
								output	wire	[19:0]		ram_wrdata,
								input	wire	[19:0]		ram_rddata,
								output	wire			ram_rd,
								output	wire			ram_wr

								);
								
parameter	WIDTH = 1920;
parameter	HEIGHT = 1080;
assign		frame_sync = video_eop & video_valid;
reg	[15:0]		x_cnt;
reg	[15:0]		y_cnt;
reg	[15:0]		width_reg;
reg	[15:0]		height_reg;
wire			end_x;
wire			end_y;
wire	[8*8-1:0]	id_value0;
assign		video_ready = 1;
reg				id_clear;

reg	[31:0]	data_cnt;
reg	[7:0]	data_reg;
wire		data_store;
reg	[1:0]	data_store_d;
reg	[19:0]	incr_reg;	
always @(posedge clk or posedge rst)
	if (rst)
		data_cnt <= 0;
	else if (video_valid & video_eop)
		data_cnt <= 0;
	else if (video_valid)
		data_cnt <= data_cnt + 1;
assign	data_store = (data_cnt[1:0]==0) & video_valid;

always @(posedge clk or posedge	rst)
	if (rst)
		data_reg <= 0;
	else if ( data_store )
		data_reg <= video_data[23:16];

assign	ram_addr = data_store? video_data[23:16] : data_reg;
assign	ram_rd = data_store;

always @(posedge clk or posedge rst)
	if (rst)
		data_store_d <= 0;
	else 
		data_store_d <= {data_store_d[0],data_store};

always @(posedge clk or posedge rst)
	if (rst)
		incr_reg <= 0;
	else if (data_store_d[0]  )
		incr_reg <= ram_rddata + 1;

assign	ram_wrdata = incr_reg;
assign	ram_wr = data_store_d[1];

endmodule 
