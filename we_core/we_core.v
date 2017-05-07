// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : we_core.v
// Author        : Dylan
// Created On    : 2016-02-14 16:58
// Last Modified : 2016-02-14 20:15
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

module we_core(/*autoarg*/
    //Inputs
    clk, rst, sink_video_data, sink_video_valid, 
    source_video_ready, 

    //Outputs
    sink_video_ready, source_video_data, 
    source_video_valid, control_out_data, 
    control_out_valid
);

input                                   clk;
input                                   rst;

input   [7:0]  sink_video_data;
input           sink_video_valid;
output           sink_video_ready;

output  [7:0]  source_video_data;
output          source_video_valid;
input           source_video_ready;

output  [35:0]  control_out_data;
output          control_out_valid;
parameter   W=16'd1920;
parameter   H=16'd1080;

//{{{
/*autodef*/
// Define io wire here
wire                                    clk;
wire                                    rst;
wire [23:0]                             sink_video_data;
wire                                    sink_video_valid;
wire                                    sink_video_ready;
wire [23:0]                             source_video_data;
wire                                    source_video_valid;
wire                                    source_video_ready;
wire [35:0]                             control_out_data;
wire                                    control_out_valid;
// Define flip-flop registers here
reg  [17:0]                             bk_reg;
reg  [7:0]                              result_reg;
reg  [17:0]                             rk_reg;
reg  [2:0]                              valid_d;
// Define combination registers here
// Define wires here
wire [17:0]                             datab;
wire [15:0]                             height;
wire [15:0]                             width;
// Define inst wires here
wire [17:0]                             bk;
wire                                    first_pixel;
wire                                    frame_sync;
wire                                    line_sync;
wire [25:0]                             result;
wire [17:0]                             rk;
wire [15:0]                             x;
wire [15:0]                             y;
// Unresolved define signals here
// End of automatic define
//}}}
wire [1:0] cube;
reg rst_d;
wire sat;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        bk_reg <= 18'h100;
        rk_reg <= 18'h100;
    end else if (frame_sync) begin
        bk_reg <= bk;
        rk_reg <= rk;
    end
end

assign  cube = {y[0],x[0]};

assign  datab = (cube==0) ? bk_reg :
                (cube==1) ? 18'h100 :
                (cube==2) ? 18'h100 : rk_reg;
assign  sat = (|result[25:16]);

always @(posedge clk or posedge rst ) 
    if (rst)
        result_reg <= 8'h0;
    else
        result_reg <= sat? 8'hff : result[15:8];

always @(posedge clk or posedge rst)
    if (rst)
        valid_d <= 3'h0;
    else 
        valid_d <= {valid_d[1:0], sink_video_valid};

assign  width = W;
assign  height = H;

frame_cnt frame_cnt (/*autoinst*/
    .en                         (sink_video_valid               ),
    .line_sync                  (line_sync                      ),
    .frame_sync                 (frame_sync                     ),
    .first_pixel                (first_pixel                    ),
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .width                      (width[15:0]                    ),
    .height                     (height[15:0]                   ),
    .x                          (x[15:0]                        ),
    .y                          (y[15:0]                        )
);

get_result get_result (/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .data_in_valid              (sink_video_valid                  ),
    .data_in                    (sink_video_data[7:0]                   ),
    .x                          (x[0]                              ),
    .y                          (y[0]                              ),
    .rk                         (rk[17:0]                       ),
    .bk                         (bk[17:0]                       )
);

mult8x18 mult8x18(/*autoinst*/
    .clock                      (clk                          ),
    .dataa                      (sink_video_data[7:0]                     ),
    .datab                      (datab[17:0]                    ),
    .result                     (result[25:0]                   )
);



assign sink_video_ready = source_video_ready;
assign source_video_data = result_reg;
assign source_video_data = valid_d[2];

always @(posedge clk ) rst_d <= rst;
assign  control_out_valid = (!rst) & rst_d;
assign control_out_data = {width, height, 4'h0};

endmodule
