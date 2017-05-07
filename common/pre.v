module pre(	sink_data, 
					sink_valid,
					sink_sop, 
					sink_eop,
					sink_ready,
					
					
					source_video_data,
					source_video_valid,
					source_video_ready,
					video_fifo_empty,
					flow_result,
					control_data,
					control_valid,
					clk, 
					rst);
parameter BITWDITH= 32;
parameter FIFO_DEPTH = 16;
parameter ALMOST_FULL_DEPTH = 15;
parameter DEPTH_WIDTH = 4;
			
input	[BITWDITH-1:0]	sink_data;
input	sink_eop, sink_sop, sink_valid;
output	sink_ready;

output	[BITWDITH-1:0] source_video_data;
output						source_video_valid;
input							source_video_ready;
output						video_fifo_empty;
output [2:0]					flow_result;

output			control_valid;
output	[35:0]	control_data;



input		clk,rst;

wire	[BITWDITH-1:0]	sink_video_data, sink_control_data;
wire	sink_video_valid, sink_video_ready, sink_control_valid, sink_control_ready;
wire	[15:0] width, height;
wire	[3:0] interlace;
assign		control_data = {width, height, interlace};
reg		sink_video_sop;
wire		sink_vdieo_eop;
always	@(posedge clk or posedge rst)
	if (rst)
		sink_video_sop <= 0;
	else 
		sink_video_sop <= sink_valid & sink_sop & (sink_data[3:0]==4'h0);

reg	control_packet_en;
reg	data_packet_en;

always @(posedge clk or posedge rst)
	if (rst)
		control_packet_en <= 0;
	else if (sink_valid & sink_sop & (sink_data[3:0]==4'hf))
		control_packet_en <= 1;
	else if (sink_valid & sink_eop)
		control_packet_en <= 0;

assign sink_video_eop = data_packet_en & sink_eop;

always @(posedge clk or posedge rst)
	if (rst)
		data_packet_en <= 0;
	else if (sink_valid & sink_sop & (sink_data[3:0]==4'h0))
		data_packet_en <= 1;
	else if (sink_valid & sink_eop)
		data_packet_en <= 0;

assign	sink_video_data = data_packet_en ? sink_data : 0;
assign	sink_video_valid = data_packet_en ? sink_valid : 0;
assign	sink_ready = data_packet_en ? sink_video_ready : 1'b1;

assign	sink_control_data = control_packet_en ? sink_data : 0;
assign	sink_control_valid = control_packet_en ? sink_valid :0;
		
		
video_in video_in(	.sink_data	(sink_video_data),
							.sink_valid		(sink_video_valid),
							.sink_ready		(sink_video_ready),
							.sink_sop			(sink_video_sop),
							.sink_eop			(sink_eop),
							
							.source_data	(source_video_data),
							.source_valid	(source_video_valid),
							.source_ready	(source_video_ready),
							.fifo_empty	(video_fifo_empty),
							.width		(width),
							.height		(height),
							.flow_result	(flow_result),
							
							.clk				(clk), 
							.rst				(rst)
							);
defparam
video_in.FIFO_DEPTH = FIFO_DEPTH,
video_in.BITWIDTH = BITWDITH,
video_in.ALMOST_FULL_DEPTH = ALMOST_FULL_DEPTH,
video_in.DEPTH_WIDTH = DEPTH_WIDTH;
					
control_in control_in (	.sink_data	(sink_control_data),
										.sink_valid	(sink_control_valid),
										.sink_ready	(sink_control_ready),
										.sink_eop   (sink_eop),
										.clk			(clk),
										.rst			(rst),
										
										.width		(width),
										.height		(height),
										.interlace	(interlace),
										.out_valid	(control_valid)
										);		
defparam
control_in.BITWIDTH = BITWDITH;
										
endmodule 
