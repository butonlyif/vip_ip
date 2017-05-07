module video_out(	sink_data,
							sink_valid,
							sink_ready,
							
							source_data,
							source_valid,
							source_ready,
							source_sop,
							source_eop,
							width,
							height,
							flow_result,
							clk, 
							rst);
parameter BITWDITH = 25;
parameter FIFO_DEPTH = 16;
parameter ALMOST_FULL_DEPTH = 14;
parameter DEPTH_WIDTH = 4;
							
input	[BITWDITH-2:0]	sink_data;
input				sink_valid;
output			sink_ready;

output	[BITWDITH-2:0]	source_data;
output				source_eop, source_sop, source_valid;
input					source_ready;

input					clk, rst;
input		[15:0]	width;
input		[15:0]	height;
output		[2:0]	flow_result;
reg		[15:0]	cnt_x;
reg		[15:0]	cnt_y;
reg					rst_d;
wire					initial_wr;
wire					wrreq;
wire					rdreq;
wire		[BITWDITH-1:0]	data;
wire		[BITWDITH-1:0]	q;
wire					almost_full;
wire					full;
wire					empty;
wire		[BITWDITH-1:0]	sop_signal;
wire					eop_in;
reg					sop_rd;
reg					source_valid_reg;				
wire			almost_empty;	
wire		[BITWDITH-2:0] zero;
assign		zero = 0;
//always @(posedge clk) rst_d <= rst;
//assign	initial_wr = rst_d & (!rst);
reg [BITWDITH-1:0] q_reg; 
wire        load;
reg         sop_reg;
always @(posedge clk or posedge rst)
	if (rst) begin
		cnt_x <= 0;
		cnt_y <= 0;
	end 
	else if (sink_valid) begin	
		if (cnt_x == width-1) begin	
			if (cnt_y == height-1)
				cnt_y <= 0;
			else
				cnt_y <= cnt_y +1;
			cnt_x <= 0;
			end
		else 
			cnt_x <= cnt_x + 1;
	end
	
assign	eop_in = sink_valid & (cnt_x == width-1)	& (cnt_y == height-1);

always @(posedge clk or posedge rst)
	if (rst)
		sop_rd <= 1'b1;
	else if (load & sop_rd)
		sop_rd <= 1'b0;
    else if (source_eop )
        sop_rd <= 1'b1;

always @(posedge clk or posedge rst)
    if (rst)
        sop_reg <= 0;
    else if (sop_reg)
        sop_reg <= 0;
    else if (load & sop_rd)
        sop_reg <= 1'b1;
		
assign wrreq =  sink_valid;
assign data = {eop_in, sink_data};
		

assign	load = source_ready & (!empty);//why almost_empty?
assign	sink_ready = (!rst) & (!almost_full) ;
assign  rdreq = load & (!sop_rd) & (!source_eop);
always @(posedge clk or posedge rst)
	if (rst)
		source_valid_reg <= 0;
	else 
		source_valid_reg <= load & (!source_eop);
always @(posedge clk or posedge rst)
    if (rst)
        q_reg <= 0;
    else if (rdreq)
        q_reg <= q;
     
assign source_sop = sop_reg;
assign source_eop = q_reg[BITWDITH-1] & source_valid_reg & (!source_sop);
assign source_data = sop_reg ? zero : q_reg[BITWDITH-2:0];
assign source_valid = source_valid_reg;

scfifo	scfifo_component (
				.aclr (rst),
				.clock (clk),
				.data (data),
				.rdreq (rdreq),
				.wrreq (wrreq),
				.almost_full (almost_full),
				.almost_empty (almost_empty),
				.empty (empty),
				.full (full),
				.q (q)
);
	defparam
		scfifo_component.add_ram_output_register = "OFF",
		scfifo_component.almost_empty_value = 2,
		scfifo_component.almost_full_value = ALMOST_FULL_DEPTH,
		scfifo_component.intended_device_family = "MAX 10",
		scfifo_component.lpm_numwords = FIFO_DEPTH,
		scfifo_component.lpm_showahead = "ON",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = BITWDITH,
		scfifo_component.lpm_widthu = DEPTH_WIDTH,
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";

/*flow_monitor U_FLOW_MONITOR_0(
    .clk                            ( clk                           ),
    .rst                            ( rst                           ),
    .empty                          ( empty                         ),
    .full                           ( full                          ),
    .valid                          ( sink_valid                         ),
    .ready                          ( source_ready                         ),
    .sop                            ( 0                           ),
    .eop                            ( source_eop                          ),
    .width                          ( 0                         ),
    .height                         ( 0                        ),
    .flow_result                    ( flow_result                   )
);*/

		
endmodule 
