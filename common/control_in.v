module control_in (	sink_data,
										sink_valid,
										sink_ready,
                                        sink_eop,
										
										clk,
										rst,
										
										width,
										height,
										interlace,
										out_valid
										);
parameter BITWIDTH = 32;
input	[BITWIDTH-1:0]	sink_data;
input									sink_valid;
input                               sink_eop;
output								sink_ready;

input								clk;
input								rst;
output		[15:0]	width;
output		[15:0]	height;
output		[3:0]		interlace;
output					out_valid;

assign sink_ready = 1'b1;
reg	out_valid_reg;
reg	[3:0]		cnt;

always @(posedge clk or posedge rst)
	if (rst)
		cnt <= 0;
	else if (( sink_eop )& sink_valid)
		cnt <= 0;
	else if (sink_valid)
		cnt <= cnt + 1;
		
reg	[15:0]	width_reg;
reg	[15:0]	height_reg;
reg	[3:0]				interlace_reg;

generate begin
case (BITWIDTH) 
32: begin
always @(posedge clk or posedge rst)
	if (rst)
		width_reg <= 0;
	else if ( (cnt==0) & sink_valid) begin
		width_reg[3:0] <= sink_data [27:24];
		width_reg[7:4] <= sink_data [19:16];
		width_reg[11:8] <= sink_data [11:8];
		width_reg[15:12]	<= sink_data [3:0];
	end
	
always @(posedge clk or posedge rst)
	if (rst)
		height_reg <= 0;
	else if ( (cnt==1) & sink_valid) begin
		height_reg[3:0] <= sink_data [27:24];
		height_reg[7:4] <= sink_data [19:16];
		height_reg[11:8] <= sink_data [11:8];
		height_reg[15:12]	<= sink_data [3:0];
	end	
	
always @(posedge clk or posedge rst)
	if (rst)
		interlace_reg <= 0;
	else if ( (cnt==2) & sink_valid) begin
		interlace_reg[3:0]	<= sink_data [3:0];
	end	


always @(posedge clk or posedge rst)
	if (rst)
		out_valid_reg <= 0;
	else
		out_valid_reg <= ((cnt==2) & sink_valid);
end
24: begin
always @(posedge clk or posedge rst)
	if (rst) begin
		width_reg <= 0;
		height_reg <= 0;
		interlace_reg <= 0;
		end
	else if (sink_valid) begin
	case (cnt) 
	0: begin
	width_reg[7:4] <= sink_data [19:16];
		width_reg[11:8] <= sink_data [11:8];
		width_reg[15:12]	<= sink_data [3:0];
	end
	1: begin
		height_reg[11:8] <= sink_data [19:16];
		height_reg[15:12] <= sink_data [11:8];
		width_reg[3:0]	<= sink_data [3:0];
	end
	2: begin
	interlace_reg[3:0] <= sink_data [19:16];
		height_reg[3:0] <= sink_data [11:8];
		height_reg[7:4]	<= sink_data [3:0];
	end
	endcase
	end
	
always @(posedge clk or posedge rst)
	if (rst)
		out_valid_reg <= 0;
	else
		out_valid_reg <= ((cnt==2) & sink_valid);
end
8: begin

always @(posedge clk or posedge rst) begin
    if(rst) begin
        	width_reg <= 0;
		height_reg <= 0;
		interlace_reg <= 0;
    end else if(sink_valid) begin
        case (cnt)
            0:  width_reg[15:12] <= sink_data[3:0];
            1:  width_reg[11:8] <= sink_data[3:0];
            2:  width_reg[7:4] <= sink_data[3:0];
            3:  width_reg[3:0] <= sink_data[3:0];
            4:  height_reg[15:12] <= sink_data[3:0];
            5:  height_reg[11:8] <= sink_data[3:0];
            6:  height_reg[7:4] <= sink_data[3:0];
            7:  height_reg[3:0] <= sink_data[3:0];
            8:  interlace_reg[3:0] <= sink_data[3:0];
        endcase
    end
end

always @(posedge clk or posedge rst)
	if (rst)
		out_valid_reg <= 0;
	else
		out_valid_reg <= ((cnt==8) & sink_valid);
end
endcase
end
endgenerate

	
assign	width = width_reg;
assign	height = height_reg;
assign	interlace = interlace_reg;
assign	out_valid = out_valid_reg;

endmodule 
