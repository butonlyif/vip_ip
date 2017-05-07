module ram_control (	input	i_ram_wr,
			input	i_ram_rd,
			input	[7:0]	i_ram_addr,
			input	[19:0]	i_ram_wrdata,
			output	[19:0]	i_ram_rddata,

			input	d_ram_rd,
			input	[7:0]	d_ram_addr,
			output	[7:0]	d_ram_rddata,

			input		i_frame_sync,
			input		d_frame_sync,

			input		clk, 
			input		rst
		);
parameter OUT_BIT_NUM=17;
reg	[1:0]	uploading_bank;
reg	[1:0]	downloading_bank;
reg	[1:0]	clean_bank;
reg	[7:0]	c_ram_addr;
wire			c_ram_wr;
wire	[19:0]	c_ram_wrdata;
reg		cleaning;
reg	[1:0] scale_reg;
reg	[1:0] d_scale_reg;
wire	[4:0] scale_case;
wire	[19:0] d_ram_rddata_20;



assign	scale_case = {i_ram_wrdata[17:15] , scale_reg};

always @(posedge clk or posedge rst)
	if (rst)
		scale_reg <= 0;
	else if (i_frame_sync)
		scale_reg <= 0;
	else if (i_ram_wr) begin
		case (scale_case) 
		5'b00100: scale_reg <= 2'b01;
		5'b01001: scale_reg <= 2'b10;
		5'b10010: scale_reg <= 2'b11;
		default: scale_reg <= scale_reg;
		endcase
	end
		
	
always @(posedge clk or posedge rst)
	if (rst)
		d_scale_reg <= 0;
	else if (d_frame_sync)
		d_scale_reg <= scale_reg;
		

assign	c_ram_wrdata = 0;

always @(posedge clk or posedge rst)
	if (rst)
		uploading_bank <= 0;
	else if (i_frame_sync) 
		uploading_bank <= uploading_bank + 1;

always @(posedge clk or posedge rst)
	if (rst)
		downloading_bank <= 0;
	else if (d_frame_sync)
		downloading_bank <= uploading_bank + 2;
		
always @(posedge clk or posedge rst)
	if (rst)
		clean_bank <= 0;
	else if (d_frame_sync)
		clean_bank <= downloading_bank;		

always @(posedge clk or posedge rst)
	if (rst)
		cleaning <= 0;
	else if (d_frame_sync)
		cleaning <= 1'b1;
	else if (c_ram_addr==8'hff)
		cleaning <= 1'b0;

assign	c_ram_wr = cleaning;

always @(posedge clk or posedge rst)
	if (rst)
		c_ram_addr <= 0;
	else if (cleaning)
		c_ram_addr <= c_ram_addr + 1;








		
wire	[7:0]		address_0, address_1, address_2, address_3;
wire	[19:0]	data_0, data_1, data_2, data_3;
wire	[19:0]	q_0, q_1, q_2, q_3;
wire					rden_0, rden_1, rden_2, rden_3;
wire					wren_0, wren_1, wren_2, wren_3;


assign	address_0 = (uploading_bank == 0) ? i_ram_addr :
										(downloading_bank == 0) ? d_ram_addr : 
										(clean_bank == 0) ? c_ram_addr : 0;

assign	address_1 = (uploading_bank == 1) ? i_ram_addr :
										(downloading_bank == 1) ? d_ram_addr : 
										(clean_bank == 1) ? c_ram_addr : 0;
										
assign	address_2 = (uploading_bank == 2) ? i_ram_addr :
										(downloading_bank == 2) ? d_ram_addr : 
										(clean_bank == 2) ? c_ram_addr : 0;
										
assign	address_3 = (uploading_bank ==3) ? i_ram_addr :
										(downloading_bank == 3) ? d_ram_addr :				
										(clean_bank == 3) ? c_ram_addr : 0;
										
assign	wren_0 = (uploading_bank == 0) ? i_ram_wr :
									(clean_bank == 0) ? c_ram_wr : 0;
									
assign	wren_1 = (uploading_bank == 1) ? i_ram_wr :
									(clean_bank == 1) ? c_ram_wr : 0;
									
assign	wren_2 = (uploading_bank == 2) ? i_ram_wr :
									(clean_bank == 2) ? c_ram_wr : 0;
									
assign	wren_3 = (uploading_bank == 3) ? i_ram_wr :
									(clean_bank == 3) ? c_ram_wr : 0;
									
assign	data_0 = (uploading_bank == 0) ? i_ram_wrdata :
									(clean_bank == 0) ? c_ram_wrdata : 0;
									
assign	data_1 = (uploading_bank == 1) ? i_ram_wrdata :
									(clean_bank == 1) ? c_ram_wrdata : 0;
									
assign	data_2 = (uploading_bank == 2) ? i_ram_wrdata :
									(clean_bank == 2) ? c_ram_wrdata : 0;
									
assign	data_3 = (uploading_bank == 3) ? i_ram_wrdata :
									(clean_bank == 3) ? c_ram_wrdata : 0;

assign	rden_0 = (uploading_bank == 0) ? i_ram_rd :
										(downloading_bank == 0) ? d_ram_rd : 0;

assign	rden_1 = (uploading_bank == 1) ? i_ram_rd :
										(downloading_bank == 1) ? d_ram_rd : 0;
										
assign	rden_2 = (uploading_bank == 2) ? i_ram_rd :
										(downloading_bank == 2) ? d_ram_rd : 0;
										
assign	rden_3 = (uploading_bank ==3) ? i_ram_rd :
										(downloading_bank == 3) ? d_ram_rd : 0;		


assign	i_ram_rddata = (uploading_bank==0) ? q_0 :
											(uploading_bank==1) ? q_1 :
											(uploading_bank==2) ? q_2 : q_3;

assign d_ram_rddata_20 = (downloading_bank==0) ? q_0 :
											(downloading_bank==1) ? q_1:
											(downloading_bank==2) ? q_2: q_3;	
									
assign	d_ram_rddata = (d_scale_reg==0) ? d_ram_rddata_20[14:7] :
								(d_scale_reg==1) ? d_ram_rddata_20[15:8] :
								(d_scale_reg==2) ? d_ram_rddata_20[16:9] : d_ram_rddata_20[17:10];
																		
ram256x8 U_RAM256X8_0(
    .aclr                           ( rst                          ),
    .address                        ( address_0                       ),
    .clock                          ( clk                         ),
    .data                           ( data_0                          ),
    .rden                           ( rden_0                          ),
    .wren                           ( wren_0                          ),
    .q                              ( q_0                             )
);

ram256x8 U_RAM256X8_1(
    .aclr                           ( rst                          ),
    .address                        ( address_1                       ),
    .clock                          ( clk                         ),
    .data                           ( data_1                          ),
    .rden                           ( rden_1                          ),
    .wren                           ( wren_1                          ),
    .q                              ( q_1                             )
);

ram256x8 U_RAM256X8_2(
    .aclr                           ( rst                          ),
    .address                        ( address_2                       ),
    .clock                          (  clk                        ),
    .data                           ( data_2                          ),
    .rden                           ( rden_2                          ),
    .wren                           ( wren_2                          ),
    .q                              ( q_2                             )
);

ram256x8 U_RAM256X8_3(
    .aclr                           ( rst                          ),
    .address                        ( address_3                       ),
    .clock                          ( clk                         ),
    .data                           ( data_3                          ),
    .rden                           ( rden_3                          ),
    .wren                           ( wren_3                          ),
    .q                              ( q_3                             )
);


endmodule 
