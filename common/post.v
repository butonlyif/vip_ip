module post (	sink_video_data,
						sink_video_valid,
						sink_video_ready,
						
						control_data,
						control_valid,
						
						source_data,
						source_valid,
						source_sop,
						source_eop,
						source_ready,

						flow_result,
						
					
						
						clk,
						rst);
parameter BITWIDTH = 32;
parameter FIFO_DEPTH = 16;
parameter ALMOST_FULL_DEPTH = 14;
parameter DEPTH_WIDTH = 4;
parameter PARALLEL_BITWIDTH = 0;
input	[BITWIDTH-1:0] sink_video_data;
input						sink_video_valid;
output					sink_video_ready;

output	[BITWIDTH-1:0] source_data;
output						source_valid;
output						source_sop;
output						source_eop;
output	[2:0]	flow_result;
input							source_ready;


input					control_valid;
input	[35:0]	control_data;
input			clk, rst;


wire	[2:0]	post_flow_result;
wire	[15:0]	video_width;
wire		[BITWIDTH-1:0] source_control_data, source_video_data;
wire		source_control_eop, source_control_sop, source_control_valid, source_control_ready;
wire		source_video_eop, source_video_ready, source_video_valid, source_video_sop;
wire	[15:0]	width;

wire	[15:0]	height;
wire	[3:0]		interlace;


reg		vid_en;
assign	flow_result = {1'b0, post_flow_result[1:0]};
assign	width = control_data[35:20];
assign	height = control_data[19:4];
assign	interlace = control_data[3:0];

generate begin
if (PARALLEL_BITWIDTH==0)
assign	video_width = width;
else begin
wire	[PARALLEL_BITWIDTH-1:0] ZERO;
assign	ZERO = 0;
assign	video_width = {ZERO, width[15:PARALLEL_BITWIDTH]};
end
end
endgenerate

always @(posedge clk or posedge rst)
	if (rst)
		vid_en <= 0;
	else if ( source_control_eop & source_control_valid)
		vid_en <= 1'b1;
	else if (source_video_eop & source_video_valid)
		vid_en <= 1'b0;

assign	source_data = vid_en ? source_video_data : source_control_data;
assign	source_valid = vid_en ? source_video_valid : source_control_valid;
assign	source_sop = vid_en ? source_video_sop : source_control_sop;
assign	source_eop = vid_en ? source_video_eop : source_control_eop;

assign	source_control_ready = vid_en ? 1'b0: source_ready;
assign	source_video_ready = vid_en ? source_ready : 1'b0;

		

control_out control_out (	.source_data				(source_control_data),
										.source_valid		(source_control_valid),
										.source_sop			(source_control_sop),
										.source_eop			(source_control_eop),
										.source_ready		(source_control_ready),
										
										.clk					(clk),
										.rst					(rst),
										
										.width				(width),
										.height				(height),
										.interlace			(interlace),
										.control_valid	(control_valid)
										);
defparam
control_out.WIDTH_VALUE= BITWIDTH;
										
video_out video_out(	.sink_data			(sink_video_data),
							.sink_valid			(sink_video_valid),
							.sink_ready			(sink_video_ready),
							
							.source_data		(source_video_data),
							.source_valid		(source_video_valid),
							.source_ready		(source_video_ready),
							.source_sop			(source_video_sop),
							.source_eop			(source_video_eop),
							.flow_result			(post_flow_result),
							.width				(video_width),
							.height				(height),
							
							.clk					(clk), 
							.rst					(rst)
							);
defparam
video_out.BITWDITH = BITWIDTH + 1,
video_out.FIFO_DEPTH = FIFO_DEPTH,
video_out.ALMOST_FULL_DEPTH = ALMOST_FULL_DEPTH,
video_out.DEPTH_WIDTH=DEPTH_WIDTH;
							
endmodule 
