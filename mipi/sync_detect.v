//////////////////////////////////////////////
//Detect  sync code 
module sync_detect(
input              reset,
input              clk,
input              lp_in,
input       [7:0]  din,
output  reg        lane_valid,
output  reg [7:0]  lane_dat,
output  reg        lane_flag

);

parameter delay_0d = 8'b0000_0001,
          delay_1d = 8'b0000_0010,
          delay_2d = 8'b0000_0100,
          delay_3d = 8'b0000_1000,
          delay_4d = 8'b0001_0000,
          delay_5d = 8'b0010_0000,
          delay_6d = 8'b0100_0000,
          delay_7d = 8'b1000_0000;

parameter s0 = "IDLE",
          s1 = "SYNC",
          s2 = "END";
//-------------------------------------------------------
reg  [15:0]     din_expand; 
reg  [31:0]      state;
reg  [31:0]      next_state;
wire [7:0]      delay;
wire            sync_dect_find;
reg  [7:0]      channel_dly1;

reg             valid_pre;
reg             lp_in_dly1;


always@ (posedge clk or posedge reset)
  if(reset)
      din_expand <= 16'h0;
  else
      din_expand <= {din_expand[7:0],din};

always @ (posedge clk or posedge reset)
begin
    if(reset)
      state <= s0;
    else
      state <= next_state; 
end

always @ (*)
begin
    case (state)
      s0:
          if(lp_in)
             next_state <= s0;
          else
             next_state <= s1;
      s1:  
	  if(lp_in)
	     next_state <= s0; 	  
	  else if(!sync_dect_find)    
             next_state <= s1;
          else
             next_state <= s2;
      s2:
          if(lp_in)
             next_state <= s0;
          else
             next_state <= s2;
      default:
	     next_state<= s0;
     endcase
end	

always @(posedge clk or posedge reset)
 if(reset)
      channel_dly1 <= 8'h00;
 else if(sync_dect_find)
      channel_dly1 <= delay;

assign delay = (din_expand[7:0]   == 'h1d) ? delay_0d :
               (din_expand[8:1]   == 'h1d) ? delay_1d :
               (din_expand[9:2]   == 'h1d) ? delay_2d :
               (din_expand[10:3]  == 'h1d) ? delay_3d :
               (din_expand[11:4]  == 'h1d) ? delay_4d :
               (din_expand[12:5]  == 'h1d) ? delay_5d :
               (din_expand[13:6]  == 'h1d) ? delay_6d :
               (din_expand[14:7]  == 'h1d) ? delay_7d : 8'h00;

assign sync_dect_find = |delay && (state == s1);

always @(posedge clk or posedge reset)
   if(reset)
       lane_flag = 1'b0;
   else if(state == s0)
       lane_flag = 1'b0;
   else if(sync_dect_find)
       lane_flag = 1'b1;

wire [7:0] dout_p = (channel_dly1 == delay_0d) ? din_expand[7:0] :
                    (channel_dly1 == delay_1d) ? din_expand[8:1] :
                    (channel_dly1 == delay_2d) ? din_expand[9:2] :
                    (channel_dly1 == delay_3d) ? din_expand[10:3] :
                    (channel_dly1 == delay_4d) ? din_expand[11:4] :
                    (channel_dly1 == delay_5d) ? din_expand[12:5] :
                    (channel_dly1 == delay_6d) ? din_expand[13:6] :
                    (channel_dly1 == delay_7d) ? din_expand[14:7] : 8'h00;


always @(posedge clk or posedge reset)
begin
   if(reset)
     valid_pre <= 1'b0;
   else if(sync_dect_find)
     valid_pre <= 1'b1;	
   else if(lp_in)
     valid_pre <= 1'b0;
end

always @(posedge clk or posedge reset)
   if(reset)
     begin	   
       lane_dat  <= 8'h0;	  
       lane_valid <= valid_pre; 
     end  
   else
     begin	   
       lane_dat <= {dout_p[0],dout_p[1],dout_p[2],dout_p[3],dout_p[4],dout_p[5],dout_p[6],dout_p[7]};
       lane_valid <= valid_pre;
     end  

endmodule

