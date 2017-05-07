module w_detect ( input	wire [23:0]	video_in_data,
									input	wire				video_in_valid,
									input	wire				video_in_eop,
									
									//input	wire				logo_in_eop,
									
									input	wire	[15:0]	cnt_x,
									input	wire	[15:0]	cnt_y,
									
									output	wire		det_draw,
									//output	wire	[15:0]	start_y,
									
									
									input	wire					clk,
									input	wire					rst);
									
parameter	SIZE = 10;
parameter INIT_X = 10;
parameter INIT_Y = 100;

wire	w_get;

assign	w_get = (video_in_data==24'hffffff) & video_in_valid;

reg	[15:0]	w_x_cnt;
reg	[4:0]	w_y_cnt;

always @(posedge clk or posedge rst)
	if (rst)
		w_x_cnt <= 0;
	else if (!w_get & video_in_valid)
		w_x_cnt <= 0;
	else if (w_get)
		w_x_cnt <= w_x_cnt + 1;

always @(posedge clk or posedge rst)
	if (rst)
		w_y_cnt <= 0;
	else if (video_in_eop)
		w_y_cnt <= 0;
	else if (w_get & (w_x_cnt==SIZE-1))
		w_y_cnt <= w_y_cnt + 1;


reg	[15:0]	x_reg, y_reg, x_load, y_load;

always @(posedge clk or posedge rst)
	if (rst) begin
		x_reg <= INIT_X;
		y_reg <= INIT_Y;
	end else 	if (w_get & (w_x_cnt==SIZE-1) & (w_y_cnt == SIZE-1)) begin
		x_reg <= cnt_x;
		y_reg <= cnt_y;
	end
	
always @(posedge clk or posedge rst)
	if (rst) begin
		x_load <= INIT_X;
		y_load <= INIT_X;
	end else if (video_in_eop) begin
		x_load <= x_reg;
		y_load <= y_reg;
	end

reg	det_valid;

always @(posedge clk or posedge rst)
	if (rst)
		det_valid <= 0;
	else if ((cnt_y >= y_load-SIZE) & (cnt_y <= y_load)) begin
		if (cnt_x==x_load-SIZE)
			det_valid <= 1'b1;
		else if (cnt_x==(x_load))
			det_valid <= 1'b0;
	end
	
assign	start_x = x_load;
assign	start_y = y_load;
assign	det_draw = det_valid;

endmodule 