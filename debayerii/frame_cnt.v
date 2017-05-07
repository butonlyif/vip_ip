module frame_cnt (/*autoarg*/
    //Inputs
    en, clk, rst, width, height, 

    //Outputs
    line_sync, frame_sync, first_pixel, x, y);


input	en;
output	line_sync;
output	frame_sync;
output	first_pixel;
input	clk; //clock
input	rst; //reset
input	[15:0]	width;
input	[15:0]	height;
output	[15:0]	x;
output	[15:0]	y;

reg	[15:0]	x_cnt;
reg	[15:0]	y_cnt;

assign line_sync = (x_cnt==(width-1)) & en;
assign	frame_sync = line_sync & (y_cnt==(height-1));
assign	first_pixcel = (x_cnt==0) & (y_cnt==0) & en;

always @(posedge clk or posedge rst) begin
    if (rst) begin
	    x_cnt <= 0;
	    y_cnt <= 0;
    end
    else if (frame_sync) begin
	    x_cnt <= 0;
	    y_cnt <= 0;
    end
    else if (line_sync) begin
	    x_cnt <= 0;
	    y_cnt <= y_cnt + 1;
	  end
    else if (en) begin
	    x_cnt <= x_cnt + 1;
    end
end

assign	x=x_cnt;
assign y=y_cnt;

endmodule
