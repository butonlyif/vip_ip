`timescale 1 ps / 1 ps
module get_avg_tb();

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


get_avg get_avg(.valid(toggle), .clk(clk), .rst(rst), .data_in(8'h55));

endmodule 
