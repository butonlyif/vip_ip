module  debayer( 	sink_data, sink_eop, sink_sop, sink_valid, sink_ready,
						source_data, source_sop, source_valid, source_ready, source_eop,
						slave_addr, slave_write, slave_writedata, slave_read, slave_readdata,
						clk, rst);
parameter	WID=1920;  
parameter HEI = 1080;
input	[7:0]	sink_data;
input			sink_eop, sink_sop;
input			sink_valid;
input	[2:0]	slave_addr;
input				slave_write;
input				slave_read;
input	[31:0]	slave_writedata;
output	[31:0]	slave_readdata;

output		sink_ready;

output	[23:0]	source_data;
output				source_eop, source_sop;
output				source_valid;
input					source_ready;

input	clk, rst;
wire		[23:0]	source_control_data;
wire					source_control_eop;
wire					source_control_sop;
wire					source_control_valid;
wire					source_control_ready;

wire		[15:0]	width, height;
wire					go;
assign	sink_ready = go & source_ready;

debayer_control  debayer_control ( 
//						.sink_data			(sink_data), 
//						.sink_sop			(sink_sop), 
//						.sink_valid			(sink_valid), 
//					//	.sink_ready			(sink_ready), 
//						.sink_eop			(sink_eop),
						.slave_addr			(slave_addr),
						.slave_write		(slave_write),
						.slave_writedata	(slave_writedata),
						.slave_read			(slave_read),
						.slave_readdata	(slave_readdata),
						.source_data		(source_control_data), 
						.source_sop			(source_control_sop), 
						.source_valid		(source_control_valid), 
						.source_ready		(source_control_ready), 
						.source_eop			(source_control_eop),
						.clk					(clk), 
						.rst					(rst), 
						.width				(width), 
						.height				(height),
						.go						(go)
						);
reg	[15:0]	x_cont;
reg	[15:0]	y_cont;
//reg				vid_in_reg;
wire	[23:0]	rgb_data;
//reg				vid_in_reg_d;
reg	[15:0]	rgb_out_x;
reg	[15:0]	rgb_out_y;
wire				video_data_valid;
wire 				one_line;
wire	[23:0]	source_video_data;
wire				source_video_eop;
wire				source_video_sop;
wire				source_video_valid;
wire			rgb_valid;
wire				vid_in;
reg vid_in_reg;
reg	vid_in_d;
reg	sink_eop_d;

always @(posedge clk or posedge rst) begin
	if (rst)
		vid_in_reg <= 0;
	else if (vid_in  )
		vid_in_reg <= 1'b1;
	else if (sink_eop & sink_valid)
		vid_in_reg <= 1'b0;
end
////always @(posedge clk or posedge rst) 
////	vid_in_reg_d <= vid_in_reg;
//
always @(posedge clk or posedge rst) begin
	if (rst)
		sink_eop_d <= 0;
	else
		sink_eop_d <= sink_eop & vid_in_reg & sink_valid;
end


always @(posedge clk) vid_in_d <= vid_in;
assign	vid_in = sink_sop & sink_valid & (sink_data[7:0]==8'h00);
//
//		
assign video_data_valid = sink_valid & vid_in_reg;
assign one_line = video_data_valid & (x_cont == (WID-1));
always @(posedge clk or posedge rst) begin	
	if (rst)
		x_cont <= 0;
	else if (one_line | sink_eop )
		x_cont <= 0;
	else if (video_data_valid)
		x_cont <= x_cont + 1;
end

always @(posedge clk or posedge rst) begin	
	if (rst)
		y_cont <= 0;
	else if (sink_eop)
		y_cont <= 0;
	else if (one_line)
		y_cont <= y_cont + 1;
end
		
RAW2RGB	RAW2RGB		(	.iCLK				(clk),
								.iRST_n			(!rst),
								//Read Port 1
								.iData			(sink_data),
								.iDval			(video_data_valid),
								.oRed				(rgb_data[23:16]),
								.oGreen			(rgb_data[15:8]),
								.oBlue			(rgb_data[7:0]),
								.oDval			(rgb_valid),
							//	iMIRROR,
								.iX_Cont				(x_cont[0]),
								.iY_Cont				(y_cont[0])
							);	

//always @(posedge clk or posedge rst) begin
//	if (rst) begin
//		rgb_out_x <= 0;
//		rgb_out_y <= 0;
//		end
//		else if (source_eop & rgb_valid)begin
//			rgb_out_x <= 0;
//			rgb_out_y <= 0;
//		end
//	else if (rgb_valid & (x_cont == (width-1)) ) begin
//		rgb_out_x <= 0;
//		rgb_out_y <= rgb_out_y + 1;
//	end
//	else if (rgb_valid) begin
//		rgb_out_x <= rgb_out_x + 1;
//		end
//	end	
//	
assign	source_video_sop = vid_in_d;	
assign	source_video_eop = sink_eop_d;
assign	source_video_valid = source_video_sop | rgb_valid;		
assign	source_video_data = source_video_sop? 24'h0 : rgb_data;

assign	source_sop = source_control_valid?  source_control_sop : source_video_sop;
assign	source_eop = source_control_valid?	source_control_eop :source_video_eop;
assign	source_valid = source_control_valid | source_video_valid;
assign	source_data = source_control_valid? source_control_data : source_video_data;

	
	
endmodule 
	