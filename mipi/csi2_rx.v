////////////////////////////////////////////////////////////
//   Function   : CSI2 receiver
//  Module Name: csi2_rx
/////////////////////////////////////////////////////////////

module csi2_rx(
    input                    rst_n,
	input                    sysclk,                //50Mhz j10 
    input                    rdclk,                 //100Mhz
   // input                    clk_24m,
    output       reg         cam_resetb,
    output       reg         cam_pwron,

//--------------mipi interface-------------------------------
	input                    lvds_hs_clk,
	input                    LP_dp,
	input                    LP_dn,
	input                    lvds_hs_dat0,     	//data1
	input                    lvds_hs_dat1,      //data2
	input                    lvds_hs_dat2,    	//data3
	input                    lvds_hs_dat3,      //data4
//--------------fifo-----------------------------------------
		input										 avl_ready,
    output                   avl_valid,
    output                   avl_sof,
    output   reg             avl_eof,
    output   reg [31:0]      avl_dat

//-------------image information------------------------------

       
);


//-----------------------parameter define---------------------------------------------
parameter            IDLE            = "IDLE",                     //IDLE
                     READ            = "READ",                     //READ FIFO
                     FINISH          = "FINISH";                   // FINISH


reg       [255:0]    curr_state;
reg       [255:0]    next_state;
reg                  state;

//-----------------------------------------------------------
    wire                     pll_lock;
    wire                     phasedone;
    wire  [2:0]              phasecounterselect;
    wire                     phasestep;
    wire                     phaseupdown;
//-----------------------------------------------------------
	reg                      reset;
	
//------------------------------------------------------------
     wire [7:0]              rx_out1; 
     wire [7:0]              rx_out2;
     wire [7:0]              rx_out3;
     wire [7:0]              rx_out4;
     wire                    lane1_flag;
     wire                    lane2_flag;
     wire                    lane3_flag;
     wire                    lane4_flag;
     
    
     wire                    align_lane_vld;
     wire                    lane1_valid;
     wire [7:0]              lane1_data_i;
     wire                    lane2_valid;
     wire [7:0]              lane2_data_i;
  
     wire [7:0]              lane1_data_o; 
     wire [7:0]              lane2_data_o; 


     wire [3:0]              lane_num;
     wire                    merging_valid;
     reg                     merge_valid_dly1;
     wire                    pkt_sof;
     reg                     pkt_sof_dly1;
     wire                    ecc_end;
     wire [5:0]              dat_type;
     wire [15:0]             WC;
     wire                    phy_clk;
     wire                    pixel_clk;
     reg                     DataType_RAW8;
     wire                    dattyp_shortpkt;
     wire                    snr_dat_8bit;
     reg  [1:0]              data_valid_d;
     reg  [31:0]             data_32bit_d;
     reg  [31:0]             data_32bit_dly2;
     reg  [31:0]             data_32bit_dly3;
     wire  [31:0]             merging_dat;
     wire                    wrreq;
    
     wire                    EccErr;
     reg  [2:0]              EccErr_d;

 
     wire                    dat_end;
     reg                     rst_i;
     wire                    lp_in_pls;
     reg                     lp_in;
     reg                     rx_vsync_pls; 
     reg                     rdreq;


     reg [2:0]               lp_sys;
     wire                    lp_f_pls;
     wire                    lp_b_pls;

  
     wire                    buf_lvdsclk;
     wire                    lp_in_p ; 

  
     wire [33:0]             rx_frame_dat;
     reg                     rdreq_dly1;
     reg                     rdreq_dly2;


     wire [33:0]             fifo_dout;
     wire                    fifo_empty;
	 wire                    fifo_full;
     wire  [15:0]             rximgvwidth;
	 wire  [15:0]             rximghwidth;
  
 //----------------------------------------------    
     reg   [31:0]             fram_dat;
     reg                      fram_sof;
     reg                      fram_eof;
     reg                      fram_valid; 
     


//-----------------------------------------------------------------------------
wire          cfg_rdy;

reg              err_msg;
reg  [15:0]      rst_cnt;

//assign  cam_pwron =1'b0;
always @ (posedge sysclk or posedge rst_i)
begin
    if(rst_i)
        rst_cnt <= 16'b0;
    else if(rst_cnt ==16'hfffe)
        rst_cnt <=rst_cnt;
    else
       rst_cnt <=rst_cnt +16'b1;
end
always @ (posedge sysclk or posedge rst_i)
begin
    if(rst_i)
    begin
        cam_pwron <= 1'b1;

    end
    else if(rst_cnt>=16'h00ff)
          cam_pwron <= 1'b0;
 end

always @ (posedge sysclk or posedge rst_i)
begin
    if(rst_i)
    begin
        cam_resetb  <=1'b0;
    end
    else if(rst_cnt>=16'h01ff)
           cam_resetb  <=1'b1;
 end


external_pll U_EXTERNAL_PLL_0(
    .areset                         ( ~rst_n                        ),
    .inclk0                         ( lvds_hs_clk                   ),
    .phasecounterselect             ( phasecounterselect            ),
    .phasestep                      ( phasestep                     ),
    .phaseupdown                    ( phaseupdown                   ),
    .scanclk                        ( sysclk                        ),
    .c0                             ( phy_clk                       ),
    .c1                             ( pixel_clk                     ),
    .locked                         ( pll_lock                      ),
    .phasedone                      ( phasedone                     )
);

always @ (posedge sysclk)
begin
    rst_i <=~rst_n;
end

always @ (posedge sysclk )
begin
    reset <=~rst_n | (~pll_lock);
end

phase_shift U_PHASE_SHIFT_0(
    .rst_i                          ( rst_i                         ),
    .clk                            ( sysclk                        ),
    .phasedone                      ( phasedone                     ),
    .pll_lock                       ( pll_lock                      ),
    .phasecounterselect             ( phasecounterselect            ),
    .phasestep                      ( phasestep                     ),
    .phaseupdown                    ( phaseupdown                   ),
    .cfg_start                      ( 1'b0                          ),
    .err_msg                        ( 1'b0                          ),
    .cfg_rdy                        (                               )
);

//------------------------------------------------------------------------------------

assign lp_in_p = LP_dp && LP_dn;
always @ (posedge sysclk or posedge rst_i)
	if(rst_i)
            lp_sys <=3'b000; 
        else
	    lp_sys <= {lp_sys[1:0],lp_in_p};

assign lp_b_pls = lp_sys[2] && ~lp_sys[1];


always @ (posedge sysclk or posedge rst_i)
	if(rst_i)
            EccErr_d <=3'h0; 
        else
	    EccErr_d <= {EccErr_d[1:0],EccErr};

wire EccErr_pls =  EccErr_d[1] && ~EccErr_d[2];


         

//--------------------------------------------------------------------------


//channel 1
lvds_rx U_LVDS_RX_0(
    .rx_inclock                     ( phy_clk                       ),
    .rx_in                          ( lvds_hs_dat0                  ),
    .rx_out                         ( rx_out1                       )
);

//channel 2
lvds_rx U_LVDS_RX_1(
    .rx_inclock                     ( phy_clk                       ),
    .rx_in                          ( lvds_hs_dat1                  ),
    .rx_out                         ( rx_out2                       )
);

//channel 3 
lvds_rx U_LVDS_RX_2(
    .rx_inclock                     ( phy_clk                       ),
    .rx_in                          ( lvds_hs_dat2                  ),
    .rx_out                         ( rx_out3                       )
);

//channel 4
lvds_rx U_LVDS_RX_3(
    .rx_inclock                     ( phy_clk                       ),
    .rx_in                          ( lvds_hs_dat3                  ),
    .rx_out                         ( rx_out4                       )
);


always @ (posedge pixel_clk or posedge reset)
	if(reset)
        lp_in <=1'b0; 
    else
        lp_in <= lp_in_p;

assign lp_in_pls= lp_in_p && ~lp_in;


sync_detect U_SYNC_DETECT_0(
    .reset                          ( reset                         ),
    .clk                            ( pixel_clk                     ),
    .lp_in                          ( lp_in                         ),
    .din                            ( rx_out1                       ),
    .lane_valid                     ( lane1_valid                   ),
    .lane_dat                       ( lane1_data_i                  ),
    .lane_flag                      ( lane1_flag                    )
    
);


sync_detect U_SYNC_DETECT_1(
    .reset                          ( reset                         ),
    .clk                            ( pixel_clk                     ),
    .lp_in                          ( lp_in                         ),
    .din                            ( rx_out2                       ),
    .lane_valid                     ( lane2_valid                   ),
    .lane_dat                       ( lane2_data_i                  ),
    .lane_flag                      ( lane2_flag                    )
    
);



assign lane_num = ({lane1_flag,lane2_flag,1'b0, 1'b0} == 'b1000) ? 4'h1 :
                  ({lane1_flag,lane2_flag,1'b0, 1'b0} == 'b1100) ? 4'h2 : 4'h0;



lane_delay U_LANE_DELAY_0(
    .reset                          ( reset                         ),
    .clk_i                          ( pixel_clk                     ),
    .lane1_valid                    ( lane1_valid                   ),
    .lane1_data_i                   ( lane1_data_i                  ),
    .lane2_valid                    ( lane2_valid                   ),
    .lane2_data_i                   ( lane2_data_i                  ),


    .align_lane_vld                 ( align_lane_vld                ),
    .lane1_data_o                   ( lane1_data_o                  ),
    .lane2_data_o                   ( lane2_data_o                  ),

);



lane_merging U_LANE_MERGING_0(
    .reset                          ( reset                         ),
    .clk                            ( pixel_clk                     ),
    .lane_num                       ( lane_num                      ),
    .align_lane_vld                 ( align_lane_vld                ),
    .lane1_data_o                   ( lane1_data_o                  ),
    .lane2_data_o                   ( lane2_data_o                  ),
    .pkt_sof                        ( pkt_sof                       ),
    .merging_dat                    ( merging_dat                   ),
    .merging_valid                  ( merging_valid                 )
);


always@(posedge pixel_clk or posedge reset)
    if(reset)
        merge_valid_dly1 <= 1'b0;
    else
        merge_valid_dly1 <= merging_valid;


ecc_check U_ECC_CHECK_0(
    .reset                          ( reset                         ),
    .clk                            ( pixel_clk                     ),
    .lp_in                          ( lp_in_pls                     ),
    .mipi_dat                       ( merging_dat                   ),
    .pkt_sof                        ( pkt_sof                       ),
    .ecc_end                        ( ecc_end                       ),
    .dat_type                       ( dat_type                      ),
    .WC                             ( WC                            ),
    .EccErr                         ( EccErr                        )
);


assign dattyp_shortpkt=(dat_type == 'h01 | dat_type == 'h00);


always @(posedge pixel_clk or posedge reset)
begin
   if(reset)
   begin
    
       DataType_RAW8  <= 'b0;
   end
   else if(ecc_end)
   begin
	   DataType_RAW8    <=  dattyp_shortpkt ? DataType_RAW8  : (dat_type== 'h2a);
    
    end
end

assign	snr_dat_8bit = DataType_RAW8;		



always@(posedge pixel_clk or posedge reset)
    if(reset)
     begin 
        data_32bit_dly3 <= 32'h0; 
        data_32bit_dly2 <= 32'h0;
        data_32bit_d <= 32'h0;
        pkt_sof_dly1  <= 1'b0; 
      end	
    else
      begin 
        data_32bit_dly3<= data_32bit_dly2 ; 
        data_32bit_dly2<= data_32bit_d ;      
  	    data_32bit_d <= merging_dat;
        pkt_sof_dly1  <= pkt_sof; 
      end	

   
wire  dat_end_en = (merge_valid_dly1 && ~pkt_sof_dly1) && ~(dat_type=='h0 || dat_type== 'h1); 


dat_end_check U_DAT_END_CHECK_0(
    .lp_in                          ( lp_in_pls                     ),
    .reset                          ( pkt_sof                       ),
    .clk                            ( pixel_clk                     ),
    .dat_end_en                     ( dat_end_en                    ),
    .din                            ( data_32bit_d                  ),
    .wc                             ( WC                            ),
    .dat_end                        ( dat_end                       )

);




	
always @(posedge pixel_clk or posedge reset)
     if(reset)	
         rx_vsync_pls <= 1'b1;

     else if(ecc_end)
	 begin     
	     if(dat_type=='h0)
	       rx_vsync_pls <=1'b0;
           else if(dat_type=='h1)
	       rx_vsync_pls <=1'b1;
         end
     else
	     rx_vsync_pls <= rx_vsync_pls;


always @(posedge pixel_clk or posedge reset)
     if(reset)	
          data_valid_d[0] <= 1'b0;
     else if(dattyp_shortpkt)
     begin
         data_valid_d[0] <= 1'b0;
     end
     else
        data_valid_d[0] <=  ~dat_end && (merge_valid_dly1 && ~pkt_sof_dly1); 

always @(posedge pixel_clk or posedge reset)
     if(reset)	
         data_valid_d[1] <=1'b0;
     else
         data_valid_d[1] <= data_valid_d[0];
     

frame_dat U_FRAME_DAT_0(
    .reset                          ( reset                         ),
    .pixel_clk                      ( pixel_clk                     ),
    .ecc_end                        ( ecc_end                       ),
    .dat_type                       ( dat_type                      ),
    .dat_vld                        (  data_valid_d[1]              ),
    .rx_vsync_pls                   ( rx_vsync_pls                  ),
    .dat_32bit_i                    ( data_32bit_dly3               ),
    .RxImgHWidth                    ( rximghwidth                   ),
    .RxImgVWidth                    ( rximgvwidth                   ),
    .rx_frame_dat                   ( rx_frame_dat                  ),
    .wrreq                          ( wrreq                         ),
    .snr_dat_8bit                   ( snr_dat_8bit                  )
);




///----------------------------modify below rdclk to pixel clock for fifo test-------------- 
wire rdreq_rd;

fifo34 U_FIFO34_0(
    .aclr                           ( ~rst_n || ~pll_lock           ),                     
    .data                           ( rx_frame_dat                  ),
    .rdclk                          ( rdclk                         ),
    .rdreq                          ( rdreq_rd                      ),
    .wrclk                          ( pixel_clk                     ),
    .wrreq                          ( wrreq                         ),
    .q                              ( fifo_dout                     ),
    .rdempty                        ( fifo_empty                    ),
    .wrfull                         (                               )
);


///////////////////////////////////////////////////////////////////////////////////////
always@(posedge rdclk or posedge reset)
begin
    if(reset)
        rdreq <=1'b0;
    else if(~fifo_empty && (curr_state == IDLE) && (rdreq==1'b0))
        rdreq <= 1'b1;
    else if(~fifo_empty && (curr_state ==READ))
        rdreq <= 1'b1;
    else
        rdreq <=1'b0;
end

assign rdreq_rd =rdreq && (~fifo_empty);



 

always@(posedge rdclk or posedge reset)
begin
    if(reset)
    begin
        rdreq_dly1 <=1'b0;
        fram_valid <=1'b0;
//        avl_valid <= 1'b0;
    end
    else
    begin
        rdreq_dly1 <= rdreq_rd;
        rdreq_dly2 <= rdreq_dly1;
        fram_valid <=rdreq_dly2;
     
    end
end

assign   avl_valid  = avl_sof | fram_valid;



always@(posedge rdclk or posedge reset)
begin
    if(reset)
    begin
        fram_sof <=1'b0;
        fram_eof <=1'b0;
    end
    else if(fifo_dout[33:32]==2'b01 && rdreq_dly1)
     begin
        fram_sof <=1'b1;
        fram_eof <=1'b0;
     end
     else if(fifo_dout[33:32]==2'b11 &&rdreq_dly1)
     begin
       fram_sof <=1'b0;
       fram_eof <=1'b1;
     end
     else
     begin
       fram_sof <= 1'b0;
       fram_eof <= 1'b0;
     end
end
always@(posedge rdclk or posedge reset)
begin
    if(reset)
    begin
    
        avl_eof <=1'b0;
   end
    else
    begin
     
        avl_eof <=fram_eof;
    end
end


assign avl_sof =fram_sof;
//assign avl_eof =fram_eof;


always@(posedge rdclk or posedge reset)
begin
    if(reset)
    begin
        fram_dat <= 32'b0;
    end
    else
        fram_dat <= fifo_dout[31:0];
        
end
always@(posedge rdclk or posedge reset)
begin
    if(reset)
        avl_dat <=32'b0;
    else if(fifo_dout[33:32]==2'b01)
        avl_dat <= 32'b0;
    else

        avl_dat <= fram_dat;
end




//-------------------------------------------------------------------------------------
always@(posedge rdclk or posedge reset)
begin
    if(reset)
    begin
        curr_state <= IDLE;
    end
    else
    begin
        curr_state <=next_state;
    end
end
//state machine next state machine

always@(*)
begin
    next_state = IDLE;
    case (curr_state) 
        IDLE:
        begin
            if(~fifo_empty &&(rdreq ==1'b0))
                next_state = READ;
            else
                next_state =IDLE;                
        end
        READ:
        begin
            if(fifo_dout[33:32]==2'b11)
                next_state = FINISH;
            else
                next_state = READ;
        end
        FINISH:
        begin
            next_state = IDLE;                                       
	    end   
        default:
        begin 
            next_state =IDLE;
        end
    endcase
end


endmodule
