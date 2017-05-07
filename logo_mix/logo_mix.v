module logo_mix	(/*autoarg*/
    //Inputs
    slave_address, slave_wrdata, slave_wr, 
    slave_rd, video_in_data, video_in_valid, 
    video_in_sop, video_in_eop, video_logo_data, 
    video_logo_valid, video_logo_sop, video_logo_eop, 
    video_out_ready, control_in_data, control_in_valid, 
    control_logo_data, control_logo_valid, 
    video_fifo_empty, clk, rst, 

    //Outputs
    slave_rddata, video_in_ready, video_logo_ready, 
    video_out_data, video_out_valid, control_out_data, 
    control_out_valid
);
input   wire    [1:0]   slave_address;
input   wire    [31:0]  slave_wrdata;
input   wire            slave_wr;
output  wire    [31:0]          slave_rddata;
input   wire            slave_rd;
                                    input	wire	[23:0]	video_in_data;
									input	wire					video_in_valid;
									input	wire					video_in_sop;
									input	wire					video_in_eop;
									output	wire				video_in_ready;
									
									input	wire	[23:0]	video_logo_data;
									input	wire					video_logo_valid;
									input	wire					video_logo_sop;
									input	wire					video_logo_eop;
									output	wire				video_logo_ready;
									
									output	wire	[23:0]	video_out_data;
									output	wire					video_out_valid;
									input		wire					video_out_ready;
									
									input		wire	[35:0]	control_in_data;
									input		wire					control_in_valid;
									
									input		wire	[35:0]	control_logo_data;
									input		wire					control_logo_valid;
									
									output	wire	[35:0]	 control_out_data;
									output	wire					control_out_valid;
									
									input		wire					video_fifo_empty;
									
									input		wire					clk;
									input		wire					rst;
									
parameter INIT_X = 10;
parameter INIT_Y = 100;



reg	[15:0]	video_width, video_height;
reg	[15:0]	logo_width, logo_height;
reg	[15:0]	cnt_x, cnt_y;
wire	[15:0]			logo_x_end, logo_y_end;
//wire	[15:0]			start_x, start_y;
wire			det_draw;

reg			rst_d;
reg   [15:0]    start_x;
reg   [15:0]    start_x_reg;
reg     [15:0]  start_y;
reg     [15:0]  start_y_reg;
always @(posedge clk ) rst_d <= rst;


always @(posedge clk or posedge rst) begin
    if(rst) begin
       start_x <= INIT_X;
       start_y <= INIT_Y;
    end else if(slave_wr) begin
        case (slave_address) 
            0: start_x <= slave_wrdata[15:0];
            1: start_y <= slave_wrdata[15:0];
    endcase
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
       start_x_reg <= INIT_X;
       start_y_reg <= INIT_Y;
    end else if(video_in_eop) begin
        start_x_reg <= start_x;
        start_y_reg <= start_y;
    end 
end

assign slave_rddata = (slave_address==0) ? {15'h0,start_x} : {15'h0,start_y};

assign	logo_x_end = logo_width + start_x_reg -1;
assign	logo_y_end = logo_height + start_y_reg -1;
assign	control_out_data = {video_width, video_height, 4'h0};
assign	control_out_valid = control_in_valid | ((!rst)&rst_d);
always @(posedge clk or posedge rst)
	if (rst) begin		
		video_width <= 1920;
		video_height <= 1080;
	end 
	else if (control_in_valid) begin
		video_width <= control_in_data[35:20];
		video_height <= control_in_data[19:4];
		end

always @(posedge clk or posedge rst)
	if (rst) begin		
		logo_width <= 0;
		logo_height <= 0;
	end 
	else if (control_logo_valid) begin
		logo_width <= control_logo_data[35:20];
		logo_height <= control_logo_data[19:4];
		end		



wire	x_logo_en, y_logo_en;

always @(posedge clk or posedge rst)
	if (rst) begin
		cnt_x <= INIT_X;
		cnt_y <= INIT_Y;
	end 
	else if (video_in_ready) begin	
		if (cnt_x == video_width-1) begin	
			if (cnt_y == video_height-1)
				cnt_y <= 0;
			else
				cnt_y <= cnt_y +1;
			cnt_x <= 0;
			end
		else 
			cnt_x <= cnt_x + 1;
	end

assign	x_logo_en = (cnt_x >= start_x_reg) & ( cnt_x <= logo_x_end);
assign	y_logo_en = (cnt_y >= start_y_reg) & ( cnt_y <= logo_y_end);


assign video_in_ready = video_out_ready & (!video_fifo_empty);
assign video_logo_ready = x_logo_en & y_logo_en & video_out_ready & (!video_fifo_empty);
assign video_out_valid = video_in_valid;
assign video_out_data = det_draw ? 24'h00ff00 :(video_logo_valid ? ( (video_logo_data[23]) ? video_in_data : video_logo_data) : video_in_data);

w_detect U_W_DETECT_0(
    .video_in_data                  ( video_in_data                 ),
    .video_in_valid                 ( video_in_valid                ),
    .video_in_eop                   ( video_in_eop                  ),
    //.logo_in_eop                    ( logo_in_eop                   ),
    .cnt_x                          ( cnt_x                         ),
    .cnt_y                          ( cnt_y                         ),
   // .                        ( start_x                       ),
    .det_draw                        ( det_draw                       ),
    .clk                            ( clk                           ),
    .rst                            ( rst                           )
);



endmodule 
