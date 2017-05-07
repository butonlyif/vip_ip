// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module raw32to8(	sink_sop, sink_eop, sink_valid, sink_ready, sink_data, sink_clk, sink_rst,
									source_sop, source_eop, source_valid, source_ready, source_data, source_clk, source_rst);

input	sink_sop, sink_eop, sink_valid;
input	[31:0]	sink_data;
input	sink_clk, sink_rst;
output	sink_ready;

output source_sop, source_eop, source_valid;
input			source_ready;
output [7:0]		source_data;
input			source_clk, source_rst;
assign	sink_ready = 1'b1;
//reg	[31:0]	sink_data_d1, sink_data_d2;
//reg					sink_eop_d1, sink_sop_d1, sink_eop_d2, sink_sop_d2;

reg		[31:0]	sink_cnt/* synthesis noprune */;
reg		[31:0]	source_cnt/* synthesis noprune */;

always @(posedge sink_clk or posedge sink_rst) begin
	if (sink_rst ) 
		sink_cnt <= 0;
	else if (sink_valid & sink_eop)
		sink_cnt <= 0;
	else if (sink_valid)
		sink_cnt <= sink_cnt + 1;
end

always @(posedge source_clk or posedge source_rst) begin
	if (source_rst ) 
		source_cnt <= 0;
	else if (source_valid & source_eop)
		source_cnt <= 0;
	else if (source_valid)
		source_cnt <= source_cnt + 1;
end


wire				fifo_read;
wire	[31:0]	raw_data;
wire				raw_eop, raw_sop;
wire				rdempty, wrfull;
reg		[1:0]	cnt4;
reg					fifo_d1;
reg					raw_valid_reg;
reg					skip_sop;
raw_fifo raw_fifo (
	.aclr			(sink_rst),
	.data			({sink_eop, sink_sop, sink_data}),
	.rdclk		(source_clk),
	.rdreq		(fifo_read),
	.wrclk		(sink_clk),
	.wrreq		(sink_valid),
	.q				({raw_eop, raw_sop, raw_data}),
	.rdempty	(rdempty),
	.wrfull		(wrfull)
	);

 assign fifo_read = (~rdempty ) & source_ready & (cnt4 == 0);
 
 reg		fifo_read_d1;
 
 always @(posedge source_clk) begin
 	if (source_rst) 
 		cnt4 <= 0;
 	else 
 		cnt4 <= cnt4 + 1;
 end
 
always @(posedge source_clk) fifo_read_d1 <= fifo_read;

always @(posedge source_clk) begin
	if (source_rst)
		raw_valid_reg <= 0;
	else if ( fifo_read & (cnt4==0))
		raw_valid_reg <= 1;
	else if ( ~fifo_read & (cnt4==0))
		raw_valid_reg <= 0;
end

always @(posedge source_clk) begin
	if (source_rst) 
		skip_sop <= 0;
	else if ( raw_sop & (cnt4==1))
		skip_sop <= 1'b1;
	else if (cnt4==00)
		skip_sop <= 0;
end


assign	source_valid = raw_valid_reg & (~skip_sop);
assign	source_sop = raw_sop & (cnt4==1) & source_valid;
assign	source_eop = raw_eop & (cnt4==0)	& source_valid;
assign	source_data = (cnt4==1) ? raw_data[7:0] : 
											(cnt4==2) ? raw_data[15:8] :
											(cnt4==3) ? raw_data[23:16] :
											(cnt4==0) ? raw_data[31:24]: 0;
											
endmodule 
		
 	

 	