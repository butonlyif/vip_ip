module dat_end_check	(
 input	            lp_in,
 input	            reset,
 input	            clk,
 input              dat_end_en,
 input    [31:0]	din,
 input    [15:0]    wc,
 output             dat_end

);
    reg	[4:0] 	dat_end_d;
	reg			dat_end_t;
 
    reg [15:0]	word_cnt;
 


always @(posedge clk or posedge reset)
 if(reset)
	word_cnt	<=	16'b0;
 else if(dat_end_en && ~dat_end_d[2])
	word_cnt	<=	word_cnt + 16'h4;

always @(posedge clk or posedge reset)
if(reset)
	dat_end_t	<=	1'b0;
else if(dat_end_en && word_cnt >= wc-16'd11)
	dat_end_t	<=	1'b1;


always @(posedge clk or posedge reset) 
if(reset)
	dat_end_d	<=	4'b0;
else if(dat_end_en)
	dat_end_d[4:0]	<=	{dat_end_d[3:1],dat_end_t & ~dat_end_d[0], dat_end_t};
			
assign	dat_end	= dat_end_d[0];


endmodule
