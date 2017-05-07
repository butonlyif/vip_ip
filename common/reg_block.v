module reg_block ( slave_addr, slave_wr, slave_rd, slave_wrdata, slave_rddata, clk, rst,small_th,total_th);
input	[3:0] slave_addr;
input			slave_rd;
input			slave_wr;
input	[31:0] slave_wrdata;
output 	[31:0] slave_rddata;
output	[9:0] small_th;
output	[31:0] total_th;
input		clk;
input		rst;
reg	[31:0]	small_threshold; //addr: 0 small threshold
reg	[31:0]	total_threshold; //addr: 1 total threshold

always @(posedge clk or posedge rst) 
	if (rst) 
		small_threshold <= 255;
	else if (slave_wr & (slave_addr == 0))
		small_threshold <= slave_wrdata;

always @(posedge clk or posedge rst) 
	if (rst) 
		total_threshold <= 255000;
	else if (slave_wr & (slave_addr == 1))
		total_threshold <= slave_wrdata;

reg	[31:0] slave_rddata;

always @(posedge clk or posedge rst) 
	if (rst) 
		slave_rddata <= 0;
	else if (slave_wr) begin	
		case (slave_addr)  
		0: slave_rddata <= small_threshold;
		1: slave_rddata <= total_threshold;
		endcase
	end

	assign	small_th = small_threshold[9:0];
	assign	total_th = total_threshold;
	
	
endmodule
