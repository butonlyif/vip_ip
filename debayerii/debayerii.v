// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : debayerii.v
// Author        : Dylan
// Created On    : 2016-02-14 17:43
// Last Modified : 2016-02-14 19:45
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

module debayerii(/*autoarg*/
    //Inputs
    clk, rst, sink_data, sink_valid, source_ready, 
    control_in_data, control_in_valid, 

    //Outputs
    sink_ready, source_data, source_valid, 
    control_out_data, control_out_valid
);

input                                   clk;
input                                   rst;

input      [7:0]                    sink_data;
input                               sink_valid;
output                              sink_ready;

output      [23:0]                  source_data;
output                              source_valid;
input                               source_ready;

input       [35:0]                  control_in_data;
input                               control_in_valid;
output      [35:0]                  control_out_data;
output                              control_out_valid;

parameter W = 1920;
parameter H = 1080;
parameter DEPTH = 8;

//{{{
/*autodef*/
// Define io wire here
wire                                    clk;
wire                                    rst;
wire [7:0]                              sink_data;
wire                                    sink_valid;
wire                                    sink_ready;
wire [23:0]                             source_data;
wire                                    source_valid;
wire                                    source_ready;
wire [35:0]                             control_in_data;
wire                                    control_in_valid;
wire [35:0]                             control_out_data;
wire                                    control_out_valid;
// Define flip-flop registers here
reg  [15:0]                             height;
reg  [15:0]                             width;
// Define combination registers here
// Define wires here
// Define inst wires here
wire                                    first_pixel;
wire                                    frame_sync;
wire                                    line_sync;
wire [15:0]                             x;
wire [15:0]                             y;
// Unresolved define signals here
// End of automatic define
//}}}

always @(posedge clk or posedge rst) begin
    if(rst) begin
        width <= W;
        height <= H;
    end else if(control_in_valid) begin
        width <= control_in_data[35:20];
        height <= control_in_data[19:4];
    end 
end

assign  control_out_valid = control_in_valid;
assign  control_out_data = control_in_data;
//assign  width = W;
//assign  height = H;

frame_cnt frame_cnt (/*autoinst*/
    .en                         (sink_valid                             ),
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

RAW2RGB RAW2RGB (/*autoinst*/
    .iCLK                       (clk                           ),
    .iRST_n                     (~rst                         ),
    .iData                      (sink_data[DEPTH-1:0]               ),
    .iDval                      (sink_valid                          ),
    .oRed                       (source_data[23:16]                ),
    .oGreen                     (source_data[15:8]              ),
    .oBlue                      (source_data[DEPTH-1:0]               ),
    .oDval                      (source_valid                          ),
    .iMIRROR                    (1'b0                        ),
    .iX_Cont                    (x                        ),
    .iY_Cont                    (y                        )
);

assign  sink_ready = source_ready;

endmodule
