// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : inc_tpg.v
// Author        : 
// Created On    : 2016-02-13 00:03
// Last Modified : 2016-02-13 00:19
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






module inc_tpg(/*autoarg*/
    //Inputs
    clk, rst, source_ready, 

    //Outputs
    source_valid, video_data, control_data, 
    control_valid
);



input	clk; //clock
input	rst; //reset
input	source_ready;
output	source_valid;
output	[23:0]	video_data;
output	[35:0]	control_data;
output		control_valid;
/*autodef*/
// Define io wire here

wire                                    clk;
wire                                    rst;
wire                                    source_ready;
wire                                    source_valid;
wire [23:0]                             video_data;
wire [35:0]                             control_data;
wire                                    control_valid;
// Define flip-flop registers here
reg                                     source_ready_d;
// Define combination registers here
// Define wires here
wire [15:0]                             height_value;
wire [15:0]                             width_value;
wire [11:0]                             x_value;
wire [11:0]                             y_value;
// Define inst wires here
wire                                    frame_sync;
wire                                    line_sync;
wire [15:0]                             x;
wire [15:0]                             y;
// Unresolved define signals here
unresolved first_pixel;
unresolved rst_d;
// End of automatic define
parameter WIDTH = 1920;
parameter HEIGHT = 1080;


always @(posedge clk) rst_d <= rst;

assign	control_valid = (!rst) & rst_d;
assign	width_value = WIDTH;
assign	height_value = HEIGHT;
assign	control_data = {width_value, height_value, 4'h0};
assign	x_value = x[11:0];
assign	y_value = y[11:0];


always @(posedge clk or posedge rst) begin
    if (rst) begin
	    source_ready_d <= 0;
    end
    else begin
	    source_ready_d <= source_ready;
    end
end

assign	source_valid = source_ready_d;
assign	video_data = {y,x};

frame_cnt frame_cnt (/*autoinst*/
        //Inputs
        .clk         (clk          ),
        .rst         (rst          ),
        .en          (source_valid           ),
        .width       (width_value[15:0]  ),
        .height      (height_value[15:0] ),
        //Outputs
        .x           (x[15:0]      ),
        .line_sync   (line_sync    ),
        .y           (y[15:0]      ),
        .frame_sync  (frame_sync   ),
        .first_pixel (first_pixel  ));


endmodule 
