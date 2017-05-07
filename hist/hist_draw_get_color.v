module hist_draw_get_color ( id_value,
														id_valid,
														
														x_cnt,
														y_cnt,
														color_in,
														color_value,
														
														clk,
														rst);
														
input	[8*8-1:0]	id_value;
input						id_valid;
input	[7:0]			x_cnt;
input	[7:0]			y_cnt;
input						clk;
input						rst;
input		[23:0]	color_in;
output	[23:0]	color_value;

reg		[8*8-1:0]	id_data_reg;
reg		[23:0]	color_reg;
reg		[7:0]	 id_now;

always @(posedge clk or posedge rst)
	if (rst)
		id_data_reg	<= 0;
	else if (id_valid)
		id_data_reg	<= id_value;
		
always @(posedge	clk or posedge	rst)
	if (rst) id_now <= 0;
	else begin
		case (x_cnt[7:5])
		0 : id_now <= id_data_reg [63:56];
		1 : id_now <= id_data_reg [55:48];
		2 : id_now <= id_data_reg [47:40];
		3 : id_now <= id_data_reg [39:32];
		4 : id_now <= id_data_reg [31:24];
		5 : id_now <= id_data_reg [23:16];
		6 : id_now <= id_data_reg [15:8];
		7 : id_now <= id_data_reg [7:0];
		endcase
		end

always @(posedge clk or posedge rst)
	if (rst) 
		color_reg	<= 0;
	else if (x_cnt[4:0] == 5'h1) begin
		if (	y_cnt <= id_now)
			color_reg <= color_in;
		else
			color_reg	<= 0;
	end

assign	color_value = color_reg;


endmodule 										