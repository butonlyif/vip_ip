`timescale 1 ps / 1 ps
module raw2rgb_tb();

reg	clk;
reg	rst;

initial begin
	clk <= 0;
	rst <= 0;
#100 
	rst <= 1;
end

always #5 clk <= ~clk;

reg	[15:0]	ix_cnt;
reg	[15:0]	iy_cnt;


reg	[3:0]	toggle;
wire			valid;
always @(posedge clk) begin
	if (!rst)
		toggle <= 0;
	else 
		toggle <= toggle + 1;
end


assign	valid = (toggle > 3'h3);


always @(posedge clk) begin
	if (!rst) begin
		ix_cnt <= 0;
		iy_cnt <= 0;
	end
	else if ((iy_cnt == 1079) & (ix_cnt==1919) & valid)
		iy_cnt <= 0;
	else if ((ix_cnt == 1919) & valid) begin
		ix_cnt <= 0;
		iy_cnt <= iy_cnt + 1;
		end
	else if (valid)
		ix_cnt <= ix_cnt + 1;
end



RAW2RGB	RAW2RGB		(	.iCLK(clk),
								.iRST_n(rst),
								//Read Port 1
								.iData (ix_cnt),
								.iDval	(valid),

							//	iMIRROR,
								.iX_Cont	(ix_cnt[0]),
								.iY_Cont (iy_cnt[0])
							);
							
endmodule 