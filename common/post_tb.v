// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : \work\mipi_project\mipi_project_edge\ip\common\post_tb.v
// Created On    : 2016-02-16 08:51
// Last Modified : 
// -------------------------------------------------------------------------------------------------
// Svn Info:
//   $Revision::                                                                                $:
//   $Author::                                                                                  $:
//   $Date::                                                                                    $:
//   $HeadURL::                                                                                 $:
// -------------------------------------------------------------------------------------------------
// Description:
//
//
// -FHDR--------------------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
module post_tb(/*autoarg*/);

parameter BITWIDTH = 24;

//{{{
/*autodef*/
// Define io wire here
// Define flip-flop registers here
reg [23:0]                                    sink_video_data;
reg                                     sink_video_valid;
// Define combination registers here
// Define wires here
wire [35:0]                             control_data;
wire                                    control_valid;
wire                                    source_ready;
// Define inst wires here
reg                                    clk;
reg                                    rst;
wire [2:0]                              flow_result;
wire                                    sink_video_ready;
wire                                    source_eop;
wire                                    source_sop;
wire                                    source_valid;
wire    [23:0]                          source_data;
// Unresolved define signals here
reg rst_d;
// End of automatic define
//}}}


initial begin
    clk <= 1'b0;
    rst <= 1'b1;
#200
    rst <= 1'b0;
end

always #5 clk <= ~clk;

assign  source_ready = 1'b1;

always @(posedge clk or posedge rst) 
    if (rst)
        sink_video_data <= 1'b0;
        else if (sink_video_ready)
            sink_video_data <= sink_video_data + 1;

 
always @(posedge clk or posedge rst)
    if (rst)
        sink_video_valid <= 1'b0;
    else
        sink_video_valid <= sink_video_ready;

always @(posedge clk ) rst_d <= rst;
assign control_data={16'd1920, 16'd1080, 4'h0};
assign control_valid = (!rst) & rst_d;



post post (/*autoinst*/
    .sink_video_data            (sink_video_data[BITWIDTH-1:0]  ),
    .sink_video_valid           (sink_video_valid               ),
    .sink_video_ready           (sink_video_ready               ),
    .source_data                (source_data[BITWIDTH-1:0]      ),
    .source_valid               (source_valid                   ),
    .source_sop                 (source_sop                     ),
    .source_eop                 (source_eop                     ),
    .flow_result                (flow_result[2:0]               ),
    .source_ready               (source_ready                   ),
    .control_valid              (control_valid                  ),
    .control_data               (control_data[35:0]             ),
    .clk                        (clk                            ),
    .rst                        (rst                            )
);
defparam
post.BITWIDTH = 24,
post.FIFO_DEPTH = 16,
post.ALMOST_FULL_DEPTH = 14,
post.DEPTH_WIDTH = 4,
post.PARALLEL_BITWIDTH = 0;


endmodule
