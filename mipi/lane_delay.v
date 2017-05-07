//Delay 2 pattern
module lane_delay(
input                      reset       ,
input                      clk_i       ,
input                      lane1_valid ,
input      [7:0]           lane1_data_i,
input                      lane2_valid ,
input      [7:0]           lane2_data_i,


output reg                 align_lane_vld,
output reg [7:0]           lane1_data_o,
output reg [7:0]           lane2_data_o

);

 
reg [7:0] l1_dat_o;
reg [7:0] l2_dat_o;
reg [7:0] l3_dat_o;
reg [7:0] l4_dat_o;    
 
reg       lane1_valid_dly1;
reg       lane2_valid_dly1;
reg       lane3_valid_dly1;
reg       lane4_valid_dly1;

always@(posedge clk_i or posedge reset)
    if(reset)
    begin
         lane1_valid_dly1 <=1'b0;
         lane2_valid_dly1 <=1'b0;

    end
    else
    begin
        lane1_valid_dly1 <= lane1_valid;
        lane2_valid_dly1 <= lane2_valid;

    end

always@(posedge clk_i or posedge reset)
    if(reset)
    begin
        l1_dat_o <= 8'b0;
        l2_dat_o <= 8'b0;

    end
    else
    begin
        l1_dat_o <= lane1_data_i;
        l2_dat_o <= lane2_data_i;
 
    end


always@(posedge clk_i or posedge reset)
    if(reset)
      begin	

        lane2_data_o <=8'h0;
        lane1_data_o <=8'h0;
	    align_lane_vld <=1'b0;
      end
    else
      begin 	    
   
        lane2_data_o <=l2_dat_o;
        lane1_data_o <=l1_dat_o;
        align_lane_vld <=lane1_valid_dly1;
      end      
endmodule
