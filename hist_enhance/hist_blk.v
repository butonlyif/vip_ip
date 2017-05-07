// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) BITWIDTH-116 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : hist_blk.v
// Author        : 
// Created On    : BITWIDTH-116-02-18 BITWIDTH-1:46
// Last Modified : 2016-02-23 20:43
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
    clk, rst, sink_data, sink_valid, source_ready, 
    control_in_data, control_in_valid, 

    //Outputs
    sink_ready, source_data, source_valid, 
    control_out_valid, control_out_data
);
parameter BITWIDTH=21;
parameter W = 1920/2;
parameter H = 1080/2;
parameter TOTOLNUM=W*H;
input                                   clk;
input                                   rst;
input   [7:0]   sink_data;
input           sink_valid;
output           sink_ready;

output  [7:0]   source_data;
output          source_valid;
input           source_ready;

input   [35:0]  control_in_data;
input           control_in_valid;
output          control_out_valid;
output  [35:0]  control_out_data;
//{{{
/*autodef*/
// Define io wire here
wire                                    clk;
wire                                    rst;
wire [7:0]                              sink_data;
wire                                    sink_valid;
wire                                    sink_eop;
wire [7:0]                              source_data;
wire                                    source_valid;
// Define flip-flop registers here
// Define combination registers here
// Define wires here
// Define inst wires here
wire                                    clean;
wire                                    data_load;
wire [7:0]                              data_load_addr;
wire [BITWIDTH-1:0]                             load_data;
wire                                    update;
wire [7:0]                              update_addr;
wire [7:0]                              update_address;
wire [7:0]                              update_data;
// Unresolved define signals here
// End of automatic define
//}}}
//

frame_cnt frame_cnt (/*autoinst*/);
p_collect p_collect (/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .video_data                 (sink_data[7:0]                ),
    .video_valid                (sink_valid                    ),
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
    .sink_data                  (sink_data[7:0]                 ),
    .sink_valid                 (sink_valid                     ),
    .source_valid               (source_valid                   ),
    .source_data                (source_data[7:0]               )
);

endmodule
