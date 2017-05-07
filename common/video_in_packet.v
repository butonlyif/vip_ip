module video_in_packet(	sink_data,
							sink_valid,
							sink_sop,
							sink_eop,
							sink_ready,
							
							source_data,
							source_valid,
							source_ready,
							source_sop, 
							source_eop,
							fifo_empty,

							width,
							height,
							flow_result,
							
							clk, 
							rst);
parameter BITWIDTH = 32;
parameter FIFO_DEPTH = 16;
parameter ALMOST_FULL_DEPTH = 15;
parameter DEPTH_WIDTH = 4;
input	[BITWIDTH-1:0]		sink_data;
input					sink_valid;
output				sink_ready;
input					sink_sop;
input					sink_eop;

output	[BITWIDTH-1:0]	source_data;
output				source_valid;
input					source_ready;
output				source_sop;
output				source_eop;

input					rst, clk;
output				fifo_empty;

input	[15:0]	width, height;
output	[2:0]	flow_result;
wire	[BITWIDTH+1:0]	data;
wire				rdreq, wrreq;
wire				almost_full, empty,full;
wire	[BITWIDTH+1:0]	q;
reg				source_valid_reg;
assign	sink_ready = !almost_full;
assign	source_data = q[BITWIDTH-1:0];
assign	source_sop = q[BITWIDTH+1] & source_valid; 
assign	source_eop = q[BITWIDTH] & source_valid;

assign	data = {sink_sop, sink_eop, sink_data};
assign	rdreq = source_ready & (!empty);
assign	wrreq = sink_valid;

always @(posedge clk or posedge rst)
	if (rst)
		source_valid_reg <= 0;
	else 
		source_valid_reg <= rdreq;

assign	source_valid = source_valid_reg;

assign	fifo_empty = empty;		
scfifo	scfifo_component (
				.aclr(rst),
				.clock (clk),
				.data (data),
				.rdreq (rdreq),
				.wrreq (wrreq),
				.almost_full (almost_full),
				.empty (empty),
				.full (full),
				.q (q)
);
	defparam
		scfifo_component.add_ram_output_register = "OFF",
		scfifo_component.almost_full_value = ALMOST_FULL_DEPTH,
		scfifo_component.intended_device_family = "MAX 10",
		scfifo_component.lpm_numwords = FIFO_DEPTH,
		scfifo_component.lpm_showahead = "OFF",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = BITWIDTH+2,
		scfifo_component.lpm_widthu = DEPTH_WIDTH,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";
flow_monitor U_FLOW_MONITOR_0(
    .clk                            ( clk                           ),
    .rst                            ( rst                           ),
    .empty                          ( empty                         ),
    .full                           ( full                          ),
    .valid                          ( sink_valid                         ),
    .ready                          ( source_ready                         ),
    .sop                            ( sink_sop                           ),
    .eop                            ( sink_eop                           ),
    .width                          ( width                         ),
    .height                         ( height                        ),
    .flow_result                    ( flow_result                   )
);

		
endmodule 
