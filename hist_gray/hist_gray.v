// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) BITWIDTH-116 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : hist_blk.v
// Author        : 
// Created On    : BITWIDTH-116-02-18 BITWIDTH-1:46
// Last Modified : 2016-02-24 11:21
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

module hist_gray(/*autoarg*/
    //Inputs
    clk, rst, asi_in0_data, asi_in0_valid, 
    aso_out0_ready, asi_in1_data, asi_in1_valid, 
    avs_s0_writedata, avs_s0_write, avs_s0_address, 

    //Outputs
    asi_in0_ready, aso_out0_data, aso_out0_valid, 
    aso_out1_data, aso_out1_valid
);
parameter BITWIDTH=19;
parameter W=1920/2;
parameter H=1080/2;
parameter TOTOLNUM=W*H;
input                                   clk;
input                                   rst;
input   [7:0]   asi_in0_data;
input           asi_in0_valid;
output           asi_in0_ready;

output  [23:0]   aso_out0_data;
output          aso_out0_valid;
input           aso_out0_ready;

input   [35:0]  asi_in1_data;
input           asi_in1_valid;
output  [35:0]  aso_out1_data;
output          aso_out1_valid;

input   [31:0]  avs_s0_writedata;
input           avs_s0_write;
input   [1:0]   avs_s0_address;
//{{{
/*autodef*/
// Define io wire here
wire                                    clk;
wire                                    rst;
wire [7:0]                              asi_in0_data;
wire                                    asi_in0_valid;
wire                                    asi_in0_ready;
wire [7:0]                              out_data;
wire                                    aso_out0_valid;
wire                                    aso_out0_ready;
wire [35:0]                             asi_in1_data;
wire                                    asi_in1_valid;
wire [35:0]                             aso_out1_data;
wire                                    aso_out1_valid;
// Define flip-flop registers here
reg  [15:0]                             height;
reg  [15:0]                             width;
reg                                     bypass;
reg                                     bypass_s0;
// Define combination registers here
// Define wires here
// Define inst wires here
wire                                    clean;
wire                                    data_load;
wire [7:0]                              data_load_addr;
wire [BITWIDTH-1:0]                     load_data;
wire                                    first_pixel;
wire                                    line_sync;
wire                                    sink_eop;
wire                                    update;
wire [7:0]                              update_addr;
wire [7:0]                              update_data;
wire [15:0]                             x;
wire [15:0]                             y;
wire                                    source_valid;
// Unresolved define signals here
// End of automatic define
//}}}
//
//


always @(posedge clk or posedge rst) begin
    if(rst) begin
        bypass_s0 <=0;
    end else if(avs_s0_write) begin
        bypass_s0 <=  avs_s0_writedata[0];
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        bypass <= 0;
    end else if(sink_eop) begin
        bypass <= bypass_s0;
    end
end
assign aso_out0_data = bypass? {asi_in0_data,asi_in0_data,asi_in0_data} : {out_data,out_data,out_data};
assign aso_out0_valid = bypass ? asi_in0_valid : source_valid;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        width <= W;
        height <= H;
    end else if(asi_in1_valid) begin
        width <= asi_in1_data[35:20];
        height <= asi_in1_data[19:4];
    end
end

assign  aso_out1_data = asi_in1_data;
assign  aso_out1_valid = asi_in1_valid;
assign  asi_in0_ready = !asi_in0_valid & aso_out0_ready;

frame_cnt frame_ctn(/*autoinst*/
    .en                         (asi_in0_valid                             ),
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
p_collect p_collect (/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .video_data                 (asi_in0_data[7:0]                ),
    .video_valid                (asi_in0_valid                    ),
    .video_eop                  (sink_eop                      ),
    .data_load                  (data_load                      ),
    .data_load_addr             (data_load_addr[7:0]            ),
    .data_out                   (load_data[BITWIDTH-1:0]                 ),
    .clean                      (clean                          )
);
defparam
p_collect.BITWIDTH=BITWIDTH;
pro_cdf pro_cdf (/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .video_eop                  (sink_eop                      ),
    .load_addr                  (data_load_addr[7:0]                 ),
    .load                       (data_load                           ),
    .load_data                  (load_data[BITWIDTH-1:0]                ),
    .update_addr                (update_addr[7:0]               ),
    .update                     (update                         ),
    .clean                      (clean                          ),
    .update_data                (update_data[7:0]               )
);
defparam
pro_cdf.BITWIDTH=BITWIDTH,
pro_cdf.TOTOLNUM=TOTOLNUM;
hist_regenerate hist_regenerate (/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .update_data                (update_data[7:0]               ),
    .update_address             (update_addr[7:0]            ),
    .update                     (update                         ),
    .sink_eop                   (sink_eop                       ),
    .sink_data                  (asi_in0_data[7:0]                 ),
    .sink_valid                 (asi_in0_valid                     ),
    .source_valid               (source_valid                   ),
    .source_data                (out_data[7:0]               )
);

endmodule
