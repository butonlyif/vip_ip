module logo_tpg ( 	output	wire	[23:0]	video_out_data,
										output	wire					video_out_valid,
										input		wire				video_out_ready,
										
										output	wire	[35:0]	control_out_data,
										output	wire					control_out_valid,
										
										input		wire				clk,
										input		wire				rst);
										
parameter WIDTH = 160;

parameter HEIGHT = 36;

parameter RES = WIDTH*HEIGHT;

wire	[15:0]	width_value, height_value;
wire	[23:0]	q;
reg						video_out_ready_d;
assign	width_value = WIDTH;
assign	height_value = HEIGHT;
assign	control_out_data = {width_value, height_value, 4'h0};

reg		rst_d;

always @(posedge clk ) rst_d <= rst;

assign	 control_out_valid = (!rst) & rst_d;

reg	[12:0] address;

always @(posedge clk or posedge rst)
	if (rst)
		address <= 0;
	else if ( (address==(RES-1)) & video_out_ready ) 
		address <= 0;
	else if (video_out_ready)
		address <= address + 1;

always @(posedge clk or posedge rst)
	if (rst)
		video_out_ready_d <= 0;
	else 
		video_out_ready_d <= video_out_ready;

logo_rom logo_rom (
	.address			(address),
	.clock				(clk),
	.rden					(video_out_ready),
	.q						(q)
	);

assign video_out_data = q;
assign video_out_valid = video_out_ready_d;
	
endmodule