module reg_block ( slave_addr, slave_wr, slave_rd, slave_wrdata, slave_rddata, clk, rst,bypass,diff_threshold);
input	[3:0] slave_addr;
input			slave_rd;
input			slave_wr;
input	[31:0] slave_wrdata;
output 	[31:0] slave_rddata;
output	 bypass;
output	[7:0]	diff_threshold;
input		clk;
input		rst;
reg	bypass_reg;
reg	[7:0]	diff_threshold_reg;
parameter DIFF_TH = 10;

always @(posedge clk or posedge rst) 
	if (rst) 
		bypass_reg <= 0;
	else if (slave_wr & (slave_addr == 0))
		bypass_reg <= slave_wrdata[0];

always @(posedge clk or posedge rst)
	if (rst)
		diff_threshold_reg <= DIFF_TH;
	else if (slave_wr & (slave_addr==1))
		diff_threshold_reg <= slave_wrdata[7:0];

reg	[31:0] slave_rddata;

always @(posedge clk or posedge rst) 
	if (rst) 
		slave_rddata <= 0;
	else if (slave_rd) begin	
		case (slave_addr)  
		0: slave_rddata <= {31'h0,bypass_reg};
		1: slave_rddata <= {24'h0, diff_threshold_reg};
		endcase
	end

assign	bypass = bypass_reg;
assign 	diff_threshold = diff_threshold_reg;
	
	
endmodule
