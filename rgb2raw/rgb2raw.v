module rgb2raw( sink_data, sink_valid, sink_sop, sink_eop, sink_ready,
								source_data, source_valid, source_sop, source_eop, source_ready,
								clk, rst);
parameter WIDTH = 1920;
parameter HEIGHT = 1080;
input	[23:0]	sink_data;
input					sink_sop;
input					sink_eop;
input					sink_valid;
output				sink_ready;

output	[7:0]	source_data;
output				source_sop;
output				source_eop;
output				source_valid;
input					source_ready;

input					clk;
input					rst;
reg			source_sop;
reg			source_eop;
reg			source_valid;
reg			vid_in;
reg		[15:0]	x_cnt;
reg		[15:0]	y_cnt;
assign	sink_ready = source_ready;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		source_sop <= 0;
		source_eop <= 0;
		source_valid <= 0;
	end
	else begin
		source_sop <= sink_sop;
		source_eop <= sink_eop;
		source_valid <= sink_valid;
		end
end


always @(posedge clk or posedge rst) begin
	if (rst) 
		vid_in <= 0;
	else if (sink_valid & sink_sop & (sink_data==0))
		vid_in <= 1'b1;
	else if (sink_valid & sink_eop)
		vid_in <= 1'b0;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		x_cnt <= 0;
	else if (vid_in & (x_cnt==1919))
		x_cnt <= 0;
	else if (vid_in)
		x_cnt <= x_cnt + 1;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		y_cnt <= 0;
	else if (sink_eop & sink_valid)
		y_cnt <= 0;
	else if (vid_in & (x_cnt==1919))
		y_cnt <= y_cnt + 1;
end

wire	[1:0]	sel;
assign	sel = {x_cnt[0], y_cnt[0]};
reg		[7:0]		raw_out;
always @(posedge clk or posedge rst) begin
	if (rst )
		raw_out <= 0;
	else begin
		case	(sel) 
			0: raw_out <= sink_data[7:0];
			1: raw_out <= sink_data[15:8];
			2: raw_out <= sink_data[15:8];
			3: raw_out <= sink_data[23:16];
		endcase
	end
end

assign	source_data= raw_out;

endmodule 