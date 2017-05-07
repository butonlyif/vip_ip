module frame_dat (
	input                  reset,
    input                  pixel_clk,
	input                  ecc_end,
    input   [5:0]          dat_type,
    input                  dat_vld,
	input                  rx_vsync_pls,
    input      [31:0]      dat_32bit_i,
	output reg [15:0]      RxImgHWidth,
	output reg [15:0]      RxImgVWidth,
	output reg [33:0]      rx_frame_dat,
	output reg             wrreq,
	input                  snr_dat_8bit
   
	);
//----------------------------------------------------------------------------	
reg                        RxHREF;
reg                        fifo_empty;
wire                       fifo_read_empty;
wire                       fifo_almost_full;
reg	                       fifo_rdreq;
wire        [31:0]         fifo_dout;
reg         [31:0]         din;

reg			               dat_vld_d;
reg			               rx_vsync_dly1;
wire				       RxVSYNC_fall;
wire				       RxVSYNC_rise;
reg	[15:0]	               row_cnt;
reg	[15:0]	               col_cnt;
reg [15:0]                 hpixel_cnt;


reg                        RxHREF_d;
reg [2:0]                  state_add;
reg [4:0]                  counter;
reg [3:0]                  counter_add;
wire                       RxHREF_fall;
reg                        row_plus;
reg                        frame_sof;
reg                        frame_eof;
reg   [3:0]                frame_cnt;
reg   [31:0]               din_dly1;




always @(posedge pixel_clk or posedge reset)
begin
    if(reset)
    begin
        din <= 32'b0;
        din_dly1 <=32'b0;
    end
    else
    begin

      din <= dat_32bit_i;
      din_dly1 <=din;
  end

end


always @(posedge pixel_clk or posedge reset)
     if(reset)	
         frame_sof <= 1'b0;
     else if(ecc_end)
	 begin     
	     if(dat_type==5'h0)
	       frame_sof <=1'b1;
     end
     else if(RxHREF)
       frame_sof <= 1'b0;
    

always @(posedge pixel_clk or posedge reset)
     if(reset)	
         frame_eof <= 1'b0;
     else if(ecc_end)
	 begin     
	     if(dat_type==5'h1)
	       frame_eof <=1'b1;
         else
	       frame_eof<=1'b0;
     end
     else 
         frame_eof <= 1'b0;
 
always@(posedge pixel_clk or posedge reset)
    if(reset)
        frame_cnt <=4'b0;
    else if(frame_cnt==4'b0100)
        frame_cnt <=frame_cnt;
    else if(frame_eof)
        frame_cnt <= frame_cnt +4'b0001;



always @(posedge pixel_clk )
begin
	dat_vld_d  <= dat_vld;
	rx_vsync_dly1 <=	rx_vsync_pls;
end
	
		
						
assign 	RxVSYNC_fall	=	~rx_vsync_pls & rx_vsync_dly1;
assign	RxVSYNC_rise	=	~rx_vsync_dly1 & rx_vsync_pls;
	

always@(posedge pixel_clk or posedge reset)
    if(reset)
	   row_plus <=1'b0;
    else if(ecc_end & ~(dat_type=='h0 || dat_type=='h1))
	   row_plus <=1'b1;
    else 
	   row_plus <=1'b0;

always @(posedge pixel_clk or posedge reset)
	if(reset)
        row_cnt <= 'h0;
    else if(RxVSYNC_rise)
        row_cnt	<=	'b0;
	else begin
		if(row_plus) 
			row_cnt	<=	row_cnt +16'b1;
		else
			row_cnt	<=	row_cnt;
		end
		
always @(posedge pixel_clk or posedge reset)
    if(reset) begin
	    RxImgVWidth	<=	'b0;
		RxImgHWidth	<=	'b0;
		end
	else if(RxVSYNC_rise ) begin
		RxImgVWidth	<=	row_cnt;
		RxImgHWidth	<=	col_cnt;
		end
			

always @(posedge pixel_clk or posedge RxVSYNC_fall)
	if(RxVSYNC_fall)
		col_cnt	<='b0;
	else if(row_cnt == 'b1) begin
		if(RxHREF)
			col_cnt	<= col_cnt	+ 16'h4;
		else
			col_cnt	<=	col_cnt;
		end



always @(posedge pixel_clk or posedge reset)
 if(reset)
     hpixel_cnt <=16'b0;
 else if(ecc_end)
     hpixel_cnt <=16'b0;
 else if(dat_vld_d)
     hpixel_cnt <=hpixel_cnt +16'd4;


	
always @(posedge pixel_clk or posedge reset) 
	if(reset) begin
		RxHREF		<=	1'b0;
         wrreq <= 1'b0;
		end
	 else if(frame_cnt ==4'b0 && frame_cnt==4'b0001 )
     begin
         RxHREF		<=	1'b0;
         wrreq <= 1'b0;
     end
     else
     begin	
		RxHREF	<=dat_vld_d;
        wrreq <= RxHREF;
     end		



assign RxHREF_fall=!RxHREF & RxHREF_d;

always@(posedge pixel_clk )
    RxHREF_d<=RxHREF;
	 
											
									      			              	 			            			                	
always @(posedge pixel_clk or posedge reset) 
if(reset) 
begin
	rx_frame_dat		<=	34'b0;
end
else 
begin
    if(frame_cnt ==4'b0 && frame_cnt==4'b0001 )
        rx_frame_dat <= 34'b0;
	else if(RxHREF && frame_sof)
		rx_frame_dat	<=	{2'b01,din_dly1};
    else if(RxHREF && row_cnt== RxImgVWidth && hpixel_cnt ==RxImgHWidth )
        rx_frame_dat <= {2'b11,din_dly1};
    else
        rx_frame_dat <= {2'b00,din_dly1}; 
 end

endmodule
	

