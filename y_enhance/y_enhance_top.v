module y_enhance_top ( 	input	wire	[23:0]	video_y_in_data,
			input	wire		video_y_in_valid,
			input	wire		video_y_in_sop,
			input	wire		video_y_in_eop,
			output	wire		video_y_in_ready,
			
		//	input	wire	[23:0]	video_in_data,
		//	input	wire		video_in_valid,
		//	input	wire		video_in_sop,
		//	input	wire		video_in_eop,
		//	output	wire		video_in_ready,

			input	wire	[35:0]	control_in_data,
			input	wire		control_in_valid,

			output	wire	[35:0]	control_out_data,
			output	wire		control_out_valid,

			input	wire	[3:0]	slave_addr,
			input	wire		slave_rd,
			input	wire		slave_wr,
			input	wire	[31:0]	slave_wrdata,
			output	wire	[31:0]	slave_rddata,

			output	wire	[23:0]	video_out_data,
			output	wire		video_out_valid,
			input	wire		video_out_ready,

//			output	wire		diff2small,
			input	wire		clk,
			input	wire		rst);

wire	bypass;
wire	[15:0]	rate;
wire	[7:0]	min_value;
wire	[7:0]	diff_threshold;
//wire		diff2small;
assign		control_out_data = control_in_data;
assign		control_out_valid = control_in_valid;
reg_block U_REG_BLOCK_0(
    .slave_addr                     ( slave_addr                    ),
    .slave_wr                       ( slave_wr                      ),
    .slave_rd                       ( slave_rd                      ),
    .slave_wrdata                   ( slave_wrdata                  ),
    .slave_rddata                   ( slave_rddata                  ),
    .clk                            ( clk                           ),
    .rst                            ( rst                           ),
    .bypass                         ( bypass                        ),
    .diff_threshold			(diff_threshold			)
);

y_enhance_calcu U_Y_ENHANCE_CALCU_0(
    .video_in_data                  ( video_y_in_data                 ),
    .video_in_valid                 ( video_y_in_valid                ),
    .video_in_sop                   ( video_y_in_sop                  ),
    .video_in_eop                   ( video_y_in_eop                  ),
    .video_in_ready                 ( video_y_in_ready                ),
    .video_out_data                 ( video_out_data                ),
    .video_out_valid                ( video_out_valid               ),
    .video_out_ready                ( video_out_ready               ),
    .rate                           ( rate                          ),
    .diff2small				(diff2small			),
    .min_value                      ( min_value                     ),
    .clk                            ( clk                           ),
    .rst                            ( rst                           )
);



y_enhance_rate U_Y_ENHANCE_RATE_0(
    .video_in_data                  ( video_y_in_data                 ),
    .video_in_valid                 ( video_y_in_valid                ),
    .video_in_sop                   ( video_y_in_sop                  ),
    .video_in_eop                   ( video_y_in_eop                  ),
  //  .video_in_ready                 ( video_y_in_ready                ),
    .rate                           ( rate                          ),
    .min_out_value                  ( min_value                 ),
    .bypass                         ( bypass                        ),
    .diff_threshold			(diff_threshold			),
    .diff2small				(diff2small			),
    .clk                            ( clk                           ),
    .rst                            ( rst                           )
);

endmodule 
