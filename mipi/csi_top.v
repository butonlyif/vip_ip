module csi_top(
input                    rst_n,
input                    sysclk,
input                    rdclk,
input                    lvds_hs_clk,
input                    LP_dp,
input                    LP_dn,
input                    lvds_hs_dat0,     	//data1
input                    lvds_hs_dat1,      //data2
//-------------------------------------------------------
output                   cam_resetb,
output                   cam_pwron,
inout                    mipi_i2c_export_0_scl_pad_io,
inout                    mipi_i2c_export_0_sda_pad_io,
input                    pb_export,
                
//input                    lvds_hs_dat2,    	//data3
//input                    lvds_hs_dat3,      //data4
//-------------------------------------------------------
output                   avl_valid,
output                   avl_sof,
output                   avl_eof,
output    [31:0]         avl_dat
);


//-------------------------------------------------------

//wire            rdclk;




//pll100M U_PLL100M_0(
//    .areset                         ( ~rst_n                        ),
//    .inclk0                         ( sysclk                        ),
//    .c0                             ( rdclk                         ),  //100Mhz
//    .locked                         (                             )
//);


//wire ov_reset_export;
//assign cam_resetb = ov_reset_export;
mip_control U_MIP_CONTROL_0(
    .clk_clk                        ( sysclk                        ),
    .mipi_i2c_export_0_scl_pad_io   ( mipi_i2c_export_0_scl_pad_io  ),
    .mipi_i2c_export_0_sda_pad_io   ( mipi_i2c_export_0_sda_pad_io  ),
    .ov_reset_export                ( ov_reset_export               ),
    .pb_export                      ( pb_export                     ),
    .reset_reset_n                  ( rst_n                         )
);




csi2_rx U_CSI2_RX_0(
    .rst_n                          ( rst_n                         ),
    .sysclk                         ( sysclk                        ),
    .rdclk                          ( rdclk                        ),// rdclk                         ),
    .clk_24m                        (                               ),
    .lvds_hs_clk                    ( lvds_hs_clk                   ),
    .LP_dp                          ( LP_dp                         ),
    .LP_dn                          ( LP_dn                         ),
    .lvds_hs_dat0                   ( lvds_hs_dat0                  ),
    .lvds_hs_dat1                   ( lvds_hs_dat1                  ),
    .lvds_hs_dat2                   ( ),//lvds_hs_dat2                  ),
    .lvds_hs_dat3                   ( ),//lvds_hs_dat3                  ),
    .avl_valid                      ( avl_valid                     ),
    .avl_sof                        ( avl_sof                       ),
    .avl_eof                        ( avl_eof                       ),
    .cam_resetb                     ( cam_resetb                    ),
    .cam_pwron                      ( cam_pwron                     ),
    .avl_dat                        ( avl_dat                       )
   
);



endmodule

