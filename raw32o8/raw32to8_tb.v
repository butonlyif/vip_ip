// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module raw32to8_tb();

reg	sink_clk, source_clk;
reg	sink_rst, source_rst;

initial begin
	sink_clk <= 0;
	source_clk <= 0;
	sink_rst <= 1;
	source_rst <= 1;
#200
	sink_rst <= 0;
	source_rst <= 0;
end

always #5 source_clk <= ~source_clk;
always #20 sink_clk <= ~sink_clk;
reg	[31:0] cnt;
wire	sink_sop;
wire	sink_eop;
always @(posedge sink_clk) begin
	if (sink_rst)
		cnt <= 0;
	else if (cnt == 1000)
		cnt <= 0;
	else 
		cnt <= cnt + 1;
end

assign	 sink_sop = (cnt==0);
assign	sink_eop = (cnt==1000);

raw32to8 raw32to8(	.sink_sop				(sink_sop), 
										.sink_eop				(sink_eop), 
										.sink_valid			(~sink_rst), 
										.sink_ready			(), 
										.sink_data			(cnt), 
										.sink_clk				(sink_clk), 
										.sink_rst				(sink_rst),
										.source_sop			(),
									 .source_eop			(), 
									 .source_valid		(), 
									 .source_ready		(1'b1), 
									 .source_data			(), 
									 .source_clk			(source_clk), 
									 .source_rst			(source_rst)
									 );
endmodule 