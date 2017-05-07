module hist_accum	(	input	wire		[7:0]	video_data,
										input	wire				video_valid,
										input	wire				id_clear,
										
										output	wire		[8*8-1:0]	id_value,
										
										input	wire			clk,
										input	wire			rst);

reg	[20:0] 	id0_reg, id1_reg, id2_reg, id3_reg,id4_reg, id5_reg,id6_reg, id7_reg;
always @(posedge clk  or posedge rst)
	if (rst) begin
		id0_reg <= 0;
		id1_reg <= 0;
		id2_reg <= 0;
		id3_reg <= 0;
		id4_reg <= 0;
		id5_reg <= 0;
		id6_reg <= 0;
		id7_reg <= 0;
	end
	else if (id_clear) begin
		id0_reg <= 0;
		id1_reg <= 0;
		id2_reg <= 0;
		id3_reg <= 0;
		id4_reg <= 0;
		id5_reg <= 0;
		id6_reg <= 0;
		id7_reg <= 0;
	end
	else if (video_valid) begin
		case (video_data[7:5]) 
		0:		id0_reg <= id0_reg + 1;
		1:		id1_reg <= id1_reg + 1;
		2:		id2_reg <= id2_reg + 1;
		3:		id3_reg <= id3_reg + 1;
		4:		id4_reg <= id4_reg + 1;
		5:		id5_reg <= id5_reg + 1;
		6:		id6_reg <= id6_reg + 1;
		7:		id7_reg <= id7_reg + 1;
		endcase
	end

assign	id_value = {id7_reg[20:13], id6_reg[20:13], id5_reg[20:13], id4_reg[20:13], id3_reg[20:13], id2_reg[20:13], id1_reg[20:13], id0_reg[20:13]};

endmodule