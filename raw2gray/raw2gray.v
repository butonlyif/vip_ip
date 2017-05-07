// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : c:\projects\working\raw2gray\raw2gray.v
// Author        : Dylan
// Created On    : 2016-02-23 17:35
// Last Modified : 2016-02-24 08:35
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

module raw2gray(/*autoarg*/
    //Inputs
    clk, rst, sink_data, sink_valid, source_ready, 
    control_in_data, control_in_valid, 

    //Outputs
    sink_ready, source_data, source_valid, 
    control_out_data, control_out_valid
);

parameter BITWIDTH = 8;
parameter W = 1920;
parameter H = 1080;
input                                   clk;
input                                   rst;
input      [BITWIDTH-1:0]               sink_data;
input                                   sink_valid;
output                                  sink_ready;
output     [BITWIDTH-1:0]               source_data;
output                                  source_valid;
input                                   source_ready;
input      [35:0]                       control_in_data;
input                                   control_in_valid;
output      [35:0]                      control_out_data;
output                                  control_out_valid;

parameter LATENCY = 2;
//{{{
/*autodef*/
// Define io wire here
wire                                    clk;
wire                                    rst;
wire [BITWIDTH-1:0]                     sink_data;
wire                                    sink_valid;
wire                                    sink_ready;
wire [BITWIDTH-1:0]                     source_data;
wire                                    source_valid;
wire                                    source_ready;
wire [35:0]                             control_in_data;
wire                                    control_in_valid;
wire [35:0]                             control_out_data;
wire                                    control_out_valid;
// Define flip-flop registers here
reg  [BITWIDTH:0]                     add00;
reg  [BITWIDTH:0]                     add01;
reg  [BITWIDTH+1:0]                     add11;
reg  [BITWIDTH-1:0]                     d01;
reg  [BITWIDTH-1:0]                     d11;
wire  [15:0]                             height;
reg                                     rst_d;
reg  [LATENCY-1:0]                     valid_dly;
wire  [15:0]                             width;
// Define combination registers here
// Define wires here
wire [BITWIDTH-1:0]                     d00;
wire                                    initial_control_valid;
// Define inst wires here
wire                                    first_pixel;
wire                                    frame_sync;
wire                                    line_sync;
wire [15:0]                             x;
wire [15:0]                             y;
// Unresolved define signals here
wire [BITWIDTH-1:0]                     d10;
wire                                     forth;
wire    [15:0]          out_width;
wire    [15:0]          out_height;
// End of automatic define
//}}}
//

/*always @(posedge clk or posedge rst) begin
    if(rst) begin
        width <= W;
        height <= H;
    end else begin
        width <= control_in_data[35:20];
        height <= control_in_data[19:4];
    end
end*/

assign  width = W;
assign  height = H;
assign  out_width = {1'b0,width[15:1]};
assign  out_height = {1'b0,height[15:1]};

always @(posedge clk) begin
    rst_d <= rst;
end
assign  initial_control_valid = (!rst) & rst_d;

assign  control_out_valid = control_in_valid | initial_control_valid;
assign  control_out_data = {out_width, out_height, 4'h0};

assign  d00 = sink_data;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        d01 <= 0;
        d11 <= 0;
    end else begin
        d01 <= d00;
        d11 <= d10;
    end
end

assign forth = x[0] & y[0] & sink_valid;


always @(posedge clk or posedge rst) begin
    if(rst) begin
        add00 <= 0;
        add01 <= 0;
        add11 <= 0;
    end else begin
        add00 <= d00 + d01;
        add01 <= d10 + d11;
        add11 <= add00 + add01;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
       valid_dly <= 0;
    end else begin
        valid_dly <= {valid_dly[LATENCY-2:0],forth};
    end
end

assign  source_data = add11[BITWIDTH+1:2];
assign  source_valid = valid_dly[LATENCY-1];
assign  sink_ready = source_ready;

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

altshift_taps	ALTSHIFT_TAPS_component (
				.aclr (rst),
				.clken (sink_valid),
				.clock (clk),
				.shiftin (d00),
				.shiftout (),
				.taps (d10)
				);
	defparam
		ALTSHIFT_TAPS_component.intended_device_family = "MAX 10",
		ALTSHIFT_TAPS_component.lpm_hint = "RAM_BLOCK_TYPE=AUTO",
		ALTSHIFT_TAPS_component.lpm_type = "altshift_taps",
		ALTSHIFT_TAPS_component.number_of_taps = 1,
		ALTSHIFT_TAPS_component.tap_distance = W,
		ALTSHIFT_TAPS_component.width = BITWIDTH;

endmodule
