// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : top.v
// Author        : 
// Created On    : 2016-02-18 17:49
// Last Modified : 2016-02-23 08:34
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
module top(/*autoarg*/
);

reg                                     clk;
reg                                     rst;
/*autodef off*/
initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
end
initial begin
    rst = 1'b1;
    #52 rst = 1'b0;
end
/*autodef on*/

//{{{
/*autodef*/
// Define io wire here
// Define flip-flop registers here
reg  [7:0]                              sink_data;
reg                                     sink_valid;
// Define combination registers here
// Define wires here
wire [35:0]                             control_in_data;
wire                                    control_in_valid;
// Define inst wires here
wire [35:0]                             control_out_data;
wire                                    control_out_valid;
wire                                    sink_ready;
wire [7:0]                              source_data;
wire                                    source_valid;
// Unresolved define signals here
reg rst_d;
// End of automatic define
//}}}

always @(posedge clk ) rst_d <= rst;
assign  control_in_data = {16'd512, 16'd512, 4'h0};
assign  control_in_valid = rst_d & (!rst);


always @(posedge clk or posedge rst) begin
    if(rst) begin
        sink_data <= 0;
    end else if(sink_valid) begin
        sink_data <= sink_data + 1;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        sink_valid <= 0;
    end else begin
        sink_valid <= sink_ready;
    end
end

hist_enhance hist_enhance(/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .sink_data                  (sink_data[7:0]                 ),
    .sink_valid                 (sink_valid                     ),
    .sink_ready                 (sink_ready                     ),
    .source_data                (source_data[7:0]               ),
    .source_valid               (source_valid                   ),
    .source_ready               (1'b1                   ),
    .control_in_data            (control_in_data[35:0]          ),
    .control_in_valid           (control_in_valid               ),
    .control_out_data           (control_out_data[35:0]         ),
    .control_out_valid          (control_out_valid              )
);
defparam
hist_enhance.W=512,
hist_enhance.H=512,
hist_enhance.BITWIDTH=18;

endmodule
