module y_wave_top (	input 	wire	[23:0]	video_in_data,
			input	wire		video_in_valid,
			output	wire		video_in_ready,
			input	wire		video_in_sop,
			input	wire		video_in_eop,
			
			output	wire	[23:0]	video_out_data,
			output	wire		video_out_valid,
			input	wire		video_out_ready,

			input	wire	[35:0]	control_in_data,
			input	wire		control_in_valid,
			output	wire	[35:0]	control_out_data,
			output	wire		control_out_valid,

			input	wire		clk,
			input	wire		rst);

wire	[7:0]	i_ram_addr;
wire	[7:0] d_ram_addr;
wire	[19:0] i_ram_wrdata, i_ram_rddata;
wire	[7:0]	d_ram_rddata;
			
			
y_identify U_Y_IDENTIFY_0(
    .video_data                     ( video_in_data                    ),
    .video_valid                    ( video_in_valid                   ),
    .video_ready                    ( video_in_ready                   ),
    .video_eop                      ( video_in_eop                     ),
    .video_sop                      ( video_in_sop                     ),
    .clk                            ( clk                           ),
    .rst                            ( rst                           ),
    .control_in_data                ( control_in_data               ),
    .control_in_valid               ( control_in_valid              ),
    .frame_sync                     ( i_frame_sync                    ),
    .ram_addr                       ( i_ram_addr                      ),
    .ram_wrdata                     ( i_ram_wrdata                    ),
    .ram_rddata                     ( i_ram_rddata                    ),
    .ram_rd                         ( i_ram_rd                        ),
    .ram_wr                         ( i_ram_wr                        )
);

ram_control U_RAM_CONTROL_0(
    .i_ram_wr                       ( i_ram_wr                      ),
    .i_ram_rd                       ( i_ram_rd                      ),
    .i_ram_addr                     ( i_ram_addr                    ),
    .i_ram_wrdata                   ( i_ram_wrdata                  ),
    .i_ram_rddata                   ( i_ram_rddata                  ),
    .d_ram_rd                       ( d_ram_rd                      ),
    .d_ram_addr                     ( d_ram_addr                    ),
    .d_ram_rddata                   ( d_ram_rddata                  ),
    .i_frame_sync                   ( i_frame_sync                  ),
    .d_frame_sync                   ( d_frame_sync                  ),
    .clk                            ( clk                           ),
    .rst                            ( rst                           )
);

y_draw U_Y_DRAW_0(
    .video_ready                    ( video_out_ready                   ),
    .video_valid                    ( video_out_valid                   ),
    .video_data                     ( video_out_data                    ),
    .ram_rddata                     ( d_ram_rddata                    ),
    .ram_addr                       ( d_ram_addr                      ),
    .ram_rd                         ( d_ram_rd                        ),
    .clk                            ( clk                           ),
    .rst                            ( rst                           ),
    .frame_sync                     ( d_frame_sync                    ),
    .in_control_data                ( control_in_data               ),
    .in_control_valid               ( control_in_valid              ),
    .out_control_data               ( control_out_data              ),
    .out_control_valid              ( control_out_valid             )
);

endmodule 
