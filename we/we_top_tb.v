`timescale 1 ps / 1 ps
module we_top_tb();

reg	clk, rst;

initial begin
clk <= 0;
rst <= 1;
#200
rst <= 0;
end

always #5 clk <= ~clk;

reg	toggle;

always @(posedge clk or posedge rst) 
	if (rst)
		toggle <= 0;
	else
		toggle <= ~toggle;


parameter W = 1920;
parameter H = 1080;

reg	[31:0]	cnt;

always @(posedge clk or posedge rst)
	if (rst)
		cnt <= 0;
	else if (toggle & (cnt == W * H))
		cnt <= 0;
	else if (toggle)
		cnt <= cnt + 1;

wire	sink_sop, sink_eop;
wire	[7:0]	sink_data;

assign	sink_sop = toggle & (cnt==0);
assign	sink_eop = 	toggle & (cnt == W * H);
assign	sink_data = sink_sop ? 0 : 8'h55;	
		
we_top we_top (	.clk(clk),
						.rst(rst), 
						.sink_data(sink_data), 
						.sink_eop(sink_eop), 
						.sink_sop(sink_sop), 
						.sink_valid(toggle),
						.source_ready(1'b1)
						);

endmodule 
