module lane_merging(
input                    reset            ,
input                    clk              ,
input [3:0]              lane_num         ,
input                    align_lane_vld   ,
input [7:0]              lane1_data_o     ,
input [7:0]              lane2_data_o     ,  
output                   pkt_sof          ,
output reg  [31:0]       merging_dat      ,
output reg               merging_valid
);

reg  [3:0]   shift_bit;
reg  [4:0]   dat_valid_dly1;
wire         merging_start;
reg          merging_valid_dly1;
always @ (posedge clk or posedge reset)
	if(reset)
		shift_bit <= 4'h0;
	else if(~align_lane_vld)
		shift_bit <= 4'b0001; 
        else if(align_lane_vld)
		shift_bit <= {shift_bit[2:0],shift_bit[3]};

always @ (posedge clk or posedge reset)
	if(reset)
          dat_valid_dly1 <= 5'h0;
        else 
	  dat_valid_dly1 <={dat_valid_dly1[3:0], align_lane_vld};

assign merging_start = (lane_num == 'h2) ? dat_valid_dly1[1] && ~dat_valid_dly1[2] :
                       (lane_num == 'h1) ? dat_valid_dly1[3] && ~dat_valid_dly1[4] : 1'b0;

always @ (posedge clk or posedge reset)
	if(reset)
        merging_valid_dly1 <= 1'b0;
    else
        merging_valid_dly1 <= merging_valid;


assign pkt_sof = (merging_valid & ~merging_valid_dly1) && merging_start;
always@(posedge clk or posedge reset)
begin
  if(reset)
    merging_dat <= 'h0;	  
  else if(align_lane_vld)
    begin
       case (lane_num)
	   'h1:
          merging_dat <= {lane1_data_o,merging_dat[31:8]};
	   'h2:
          merging_dat <= {lane2_data_o,lane1_data_o,merging_dat[31:16]};     
       default:
          merging_dat <='h0; 
       endcase
    end
  else
	merging_dat <='h0;  
end

always@(posedge clk or posedge reset)
begin
  if(reset)
    merging_valid <= 'h0;	  
  else if(align_lane_vld)
    begin
       case (lane_num)
	   'h1:
          merging_valid <= shift_bit[3];
	   'h2:
          merging_valid <= shift_bit[3] || shift_bit[1];         
       default:
          merging_valid <='h0; 
       endcase
    end
  else
	merging_valid <=1'b0;  
end
endmodule
