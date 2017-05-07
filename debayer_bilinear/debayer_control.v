module  debayer_control (slave_addr, slave_write, slave_writedata, slave_read, slave_readdata, //sink_data, sink_sop, sink_valid, sink_ready, sink_eop,
						source_data, source_sop, source_valid, source_ready, source_eop,
						clk, rst, width, height, go);

//input	[7:0]	sink_data;
//input			sink_eop, sink_sop;
//input			sink_valid;
//output		sink_ready;
parameter	WID=1920;
parameter HEI = 1080;
parameter INT = 3;

input	[2:0]	slave_addr;
input				slave_write;
input				slave_read;
input	[31:0]	slave_writedata;
output	[31:0]	slave_readdata;
output				go;

output	[23:0]	source_data;
output				source_eop, source_sop;
output				source_valid;
input					source_ready;
output	[15:0]	width;
output	[15:0]	height;
input	clk, rst;

reg	[15:0]	width;
reg	[15:0]	height;
reg	[3:0]		interlacing;
reg					status;
reg					go;
reg	[31:0]	slave_read_reg;
//control register mapping
//00: go bit
//01: status bit
//02: width
//03: height
//04: interlacing

always @(posedge clk  or posedge rst) begin
	if (rst )
		go <= 0;
	else if (slave_write & (slave_addr == 0))
		go <= slave_writedata[0];
end

always @(posedge clk) status <= go;

always @(posedge clk  or posedge rst) begin
	if (rst )
		width <= WID;
	else if (slave_write & (slave_addr == 2))
		width <= slave_writedata[15:0];
end

always @(posedge clk  or posedge rst) begin
	if (rst )
		height <= HEI;
	else if (slave_write & (slave_addr == 3))
		height <= slave_writedata[15:0];
end

always @(posedge clk  or posedge rst) begin
	if (rst )
		interlacing <= 0;
	else if (slave_write & (slave_addr == 4))
		interlacing <= slave_writedata[3:0];
end

always @(posedge clk or posedge rst) begin
	if (rst) 
		slave_read_reg <= 0;
	else if (slave_read) begin
		case (slave_addr) 
			0: slave_read_reg <= go;
			1: slave_read_reg <= status;
			2: slave_read_reg <= width;
			3: slave_read_reg <= height;
			4: slave_read_reg <= interlacing;
			endcase
		end
end

assign	slave_readdata = slave_read_reg;


	

reg				control_out_valid;
reg		[1:0]	control_out_cnt;
reg				initial_reg;

always @(posedge clk or posedge rst) begin
	if (rst)
		initial_reg <= 1'b0;
	else if (slave_write & slave_writedata[0] & (slave_addr == 0))
		initial_reg <= 1'b1;
	else if (source_eop & source_valid)
		initial_reg <= 1'b0;
end 
always @(posedge clk or posedge rst) begin
	if (rst)
		control_out_valid <= 0;
	else if ( initial_reg)
		control_out_valid <= 1'b1;
	else if ( control_out_valid & source_eop)
		control_out_valid <= 1'b0;
		end

always @(posedge clk or posedge rst) begin
	if (rst)
		control_out_cnt <= 0;
	else if(control_out_valid)
		control_out_cnt <= control_out_cnt + 1;
end

assign	source_sop = control_out_valid & (control_out_cnt == 2'b00);
assign	source_eop = control_out_valid & (control_out_cnt == 2'b11);

wire	[23:0]	control_out;

assign	control_out = (control_out_cnt == 2'b00) ? 24'h00000f :
								(control_out_cnt ==2'b01) ? {4'b0000, width[7:4], 4'b0000, width[11:8], 4'b0000, width[15:12]} :
								(control_out_cnt == 2'b10) ? {4'b0000, height[11:8], 4'b0000, height[15:12], 4'b0000, width[3:0]} :
								{4'b0000, interlacing[3:0], 4'b0000, height[3:0], 4'b0000, height[7:4]} ;
								
assign	source_valid = control_out_valid;
assign	source_data = control_out;
								
endmodule 		
	
	
	
	
	
	