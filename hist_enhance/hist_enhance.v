// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : hist_enhance.v
// Author        : 
// Created On    : 2016-02-18 21:36
// Last Modified : 2016-02-23 08:26
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

module hist_enhance(/*autoarg*/
    //Inputs
    clk, rst, sink_data, sink_valid, source_ready, 
    control_in_data, control_in_valid, 

    //Outputs
    sink_ready, source_data, source_valid, 
    control_out_data, control_out_valid
);

input                                   clk;
input                                   rst;

input   [7:0]    sink_data;
input             sink_valid;
output            sink_ready;

output  [7:0]  source_data;
output          source_valid;
input           source_ready;


input   [35:0]  control_in_data;
input           control_in_valid;

output  [35:0]  control_out_data;
output          control_out_valid;
parameter BITWIDTH = 20;
//{{{
/*autodef*/
// Define io wire here
wire                                    clk;
wire                                    rst;
wire [7:0]                             sink_data;
wire                                    sink_valid;
wire                                    sink_ready;
wire [7:0]                             source_data;
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
wire                                    line_sync;
wire [7:0]                              sink_data_b;
wire [7:0]                              sink_data_g;
wire [7:0]                              sink_data_r;
wire                                    sink_eop;
wire                                    sink_valid_b;
wire                                    sink_valid_g;
wire                                    sink_valid_r;
wire [7:0]                              source_data_b;
wire [7:0]                              source_data_g;
wire [7:0]                              source_data_r;
wire                                    source_valid_b;
wire                                    source_valid_g;
wire                                    source_valid_r;
wire [15:0]                             x;
wire [15:0]                             y;
// Unresolved define signals here
wire    [1:0] cube;
reg             rst_d;
// End of automatic define
//}}}
//
//
parameter W=1920;
parameter H=1080;
parameter TOTOLNUM=W*H;
assign  sink_ready = source_ready;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        width <= W; 
        height <= H;   
    end else if(control_in_valid) begin
        width <= control_in_data[35:20];
        height <= control_in_data[19:4];
    end
end

always @(posedge clk) begin
    rst_d <= rst;
end
assign  control_out_data = {width,height,4'h0};
assign  control_out_valid = ((!rst)&rst_d) | control_in_valid;
assign  cube = {y[0],x[0]};


/*always @(cube) begin
    case (cube)
        0: begin
            sink_valid_b <= sink_valid;
            sink_data_b <= sink_data;
           end
        1: begin
            sink_valid_g <= sink_valid;
            sink_data_g <= sink_data;
        end
        2: begin
            sink_valid_g <= sink_valid;
            sink_data_g <= sink_data;
        end
        3: begin
            sink_valid_r <= sink_valid;
            sink_data_r <= sink_data;
        end
    endcase
end*/
assign  sink_data_b = (cube==0) ? sink_data : 0;
assign  sink_data_g = ((cube==1)  | (cube==2)) ? sink_data :0;
assign  sink_data_r = (cube==3) ? sink_data : 0;
assign  sink_valid_b = (cube==0) ? sink_valid : 0;
assign  sink_valid_g = ((cube==1)  | (cube==2)) ? sink_valid :0;
assign  sink_valid_r = (cube==3) ? sink_valid : 0;

frame_cnt frame_cnt(/*autoinst*/
    .en                         (sink_valid                             ),
    .line_sync                  (line_sync                      ),
    .frame_sync                 (sink_eop                     ),
    .first_pixel                (first_pixel                    ),
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .width                      (width[15:0]                    ),
    .height                     (height[15:0]                   ),
    .x                          (x[15:0]                        ),
    .y                          (y[15:0]                        )
);

hist_blk r(/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .sink_data                  (sink_data_r[7:0]                 ),
    .sink_valid                 (sink_valid_r                     ),
    .sink_eop                   (sink_eop                       ),
    .source_data                (source_data_r[7:0]               ),
    .source_valid               (source_valid_r                   )
);
defparam
r.BITWIDTH=BITWIDTH-1,
r.TOTOLNUM=TOTOLNUM/4;

hist_blk g(/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .sink_data                  (sink_data_g[7:0]                 ),
    .sink_valid                 (sink_valid_g                     ),
    .sink_eop                   (sink_eop                       ),
    .source_data                (source_data_g[7:0]               ),
    .source_valid               (source_valid_g                   )
);
defparam
g.BITWIDTH=BITWIDTH,
g.TOTOLNUM=TOTOLNUM/2;

hist_blk b(/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .sink_data                  (sink_data_b[7:0]                 ),
    .sink_valid                 (sink_valid_b                     ),
    .sink_eop                   (sink_eop                       ),
    .source_data                (source_data_b[7:0]               ),
    .source_valid               (source_valid_b                   )
);
defparam
b.BITWIDTH=BITWIDTH-1,
b.TOTOLNUM=TOTOLNUM/4;

assign  source_valid = source_valid_r | source_valid_b | source_valid_g;
assign  source_data = source_valid_r ? source_data_r : 
                        source_valid_g ? source_data_g :
                        source_valid_b ? source_data_b : 0;
endmodule
