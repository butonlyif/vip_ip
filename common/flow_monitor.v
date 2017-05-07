module flow_monitor (	input	wire	clk,
			input	wire	rst,
			
			input	wire	empty,
			input	wire	full,
			input	wire	valid,
			input	wire	ready,

			input	wire	sop,
			input	wire	eop,

			input	wire	[15:0]	width,
			input	wire	[15:0]	height,

			output	wire	[2:0]	flow_result);

reg	not_match, underflow, overflow;
reg	[15:0]	cnt_x, cnt_y;
assign	flow_result = {not_match, underflow, overflow};

always @(posedge clk or posedge rst)
	if (rst)
		not_match <= 0;
	else if (eop& valid & not_match)
		not_match <= 0;
		else if (eop & valid) begin
			if ( (cnt_x == width-1) & (cnt_y == height-1))
				not_match <= 0;
			else
				not_match <= 1'b1;
			end



always @(posedge clk or posedge rst)
	if (rst)
		underflow <= 0;
	else if (eop)
		underflow <= 0;
	else if (ready & empty)
		underflow <= 1'b1;

always @(posedge clk or posedge rst)
	if (rst)
		overflow <= 0;
	else if (eop)
		overflow <= 0;
	else if (!ready & full)
		overflow <= 1'b1;

always @(posedge clk or posedge rst)
	if (rst) begin
		cnt_x <= 0;
		cnt_y <= 0;
	end
       	else if (eop & valid) begin
		cnt_x <= 0;
		cnt_y <= 0;
	end	
	else if (valid) begin	
		if (cnt_x == width-1) begin	
			cnt_y <= cnt_y +1;
			cnt_x <= 0;
			end
		else 
			cnt_x <= cnt_x + 1;
	end

endmodule 
