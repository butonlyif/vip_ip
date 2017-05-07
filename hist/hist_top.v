module hist_top(	input		wire	[23:0]		video_in_data,
									input		wire						video_in_valid,
									output		wire						video_in_ready,
									
									output	wire	[23:0]		video_out_data,
									output	wire						video_out_valid,
									input		wire						video_out_ready,
									
									input		wire	[35:0]		in_control_data,
									input		wire						in_control_valid,
									
									output	wire	[35:0]		out_control_data,
									output	wire						out_control_valid,
									
									input		wire						clk,
									input		wire						rst);
									

wire		[8*8-1:0] 	r_id_data, g_id_data, b_id_data;
wire								id_valid;




								
hist_identify hist_identify (.video_data		(video_in_data),
														.video_valid		(video_in_valid),
														.video_ready		(video_in_ready),
														.clk						(clk),
														.rst						(rst),
													.control_in_data		(in_control_data),
													.control_in_valid		(in_control_valid),
													.r_id_data					(r_id_data),
													.g_id_data					(g_id_data),
													.b_id_data					(b_id_data),
													.id_valid					(id_valid)

								);
								
hist_draw hist_draw (		.video_ready	(video_out_ready),
								.video_valid					(video_out_valid),
								.video_data						(video_out_data),
								
								.g_id_data						(g_id_data),
								.r_id_data						(r_id_data),
								.b_id_data						(b_id_data),
                
								.id_valid							(id_valid),
								
								.clk									(clk),
								.rst									(rst),
								
								.in_control_data			(in_control_data),
								.in_control_valid			(in_control_valid),
								
								.out_control_data			(out_control_data),
								.out_control_valid		(out_control_valid)
								);
								
endmodule 