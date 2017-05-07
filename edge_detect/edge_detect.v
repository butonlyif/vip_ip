module edge_detect (	input	[23:0]	video_in_data,
							input				video_in_valid,
							output			video_in_ready,
							
							output	[23:0] video_out_data,
							output				video_out_valid,
							input					video_out_ready,
							
							input		[35:0]	control_in_data,
							input					control_in_valid,
							
							output	[35:0]	control_out_data,
							output				control_out_valid,
							
							input					clk,	//clock
							input					rst	//reset
							
							);
//Instance: ./sub.v
							
parameter THRESHOLD = 50;
wire			compare_threshold;
wire	[7:0] d00, d10, d20;
reg	[7:0] d01, d02, d11, d12, d21, d22;
reg	[3:0] valid_d;
assign	d00 = video_in_data[23:16];
reg	[9:0] add00, add01, add02, add03;
wire	[10:0] sub_wire_0, sub_wire_1;
reg	[10:0] sub10, sub11;
reg	[11:0] add_final;
wire	[23:0] video_out;
reg	[23:0]	data_d1, data_d2, data_d3, data_out_reg;

assign	control_out_data = control_in_data;
assign	control_out_valid = control_in_valid;


always @(posedge clk or posedge rst	) begin
    if (rst	) begin
	    data_d1 <= 0;
	    data_d2 <= 0;
	    data_d3 <= 0;
    end
    else begin
	    data_d1 <= video_in_data;
	    data_d2 <= data_d1;
	    data_d3 <= data_d2;
    end
end


always @(posedge clk or posedge rst	) begin
    if (rst	) begin
	    data_out_reg <= 0;
    end
    else if (valid_d[2])begin
	    if (compare_threshold)
		    data_out_reg <= data_d3;
	    else 
		    data_out_reg <= 24'h008080;
//    data_out_reg <= {compare_threshold, data_d3[23:17],data_d3[15:0]};
    end
end


always @(posedge clk or posedge rst)
	if (rst) begin
		d01 <= 0;
		d02 <= 0;
		d11 <= 0;
		d12 <= 0;
		d21 <= 0;
		d22 <= 0;
		end
	else if (video_in_valid) begin
		d01 <= d00;
		d02 <= d01;
		d11 <= d10;
		d12 <= d11;
		d21 <= d20;
		d22 <= d21;
		end

always @(posedge clk or posedge rst)
	if (rst)
		valid_d <= 0;
	else 
		valid_d <= {valid_d[2:0],video_in_valid};
		
//stage 1 of adder
always @(posedge clk or posedge rst)
	if (rst) begin
		add00 <= 0;
		add01 <= 0;
		add02 <= 0;
		add03 <= 0;
	end
	else if (video_in_valid) begin
		add00 <= d00 + d10 + d20;
		add01 <= d02 + d12 + d22;
		add02 <= d00 + d01 + d02;
		add03 <= d20 + d21 + d22;
		end
		
//stage of adder 2
//assign sub_wire_0 = add01 - add00;
//assign sub_wire_1 = add02 - add03;
always @(posedge clk or posedge rst)
	if (rst) begin
		sub10 <= 0;
		sub11 <= 0;
		
	end
	else if (valid_d[0]) begin
		sub10 <= sub_wire_0[10] ? (~sub_wire_0 + 1) : sub_wire_0;
		sub11 <= sub_wire_1[10] ? (~sub_wire_1 + 1) : sub_wire_1;
		end
//stage of adder 3
always @(posedge clk or posedge rst)
			if (rst)
				add_final <= 0;
			else if (valid_d[1])
				add_final <= sub10 + sub11;

assign	compare_threshold = (add_final < THRESHOLD);
assign	video_out = compare_threshold ? 0 : 24'hffffff;
				
assign	video_out_data = data_out_reg;
assign	video_out_valid = valid_d[3];
assign	video_in_ready = video_out_ready;


	altshift_taps	ALTSHIFT_TAPS_component (
				.aclr (rst),
				.clken (video_in_valid),
				.clock (clk),
				.shiftin (d00),
				.shiftout (),
				.taps ({d20,d10})
				// synopsys translate_off
			//	.sclr ()
				// synopsys translate_on
				);
	defparam
		ALTSHIFT_TAPS_component.intended_device_family = "MAX 10",
		ALTSHIFT_TAPS_component.lpm_hint = "RAM_BLOCK_TYPE=AUTO",
		ALTSHIFT_TAPS_component.lpm_type = "altshift_taps",
		ALTSHIFT_TAPS_component.number_of_taps = 2,
		ALTSHIFT_TAPS_component.tap_distance = 1920,
		ALTSHIFT_TAPS_component.width = 8;
sub	sub	(/*autoinst*/
        //Inputs
        .dataa  ({1'b0,add01[9:0]}  ),
        .datab  ({1'b0,add00[9:0]}  ),
        //Outputs
        .result (sub_wire_0[10:0] ));

sub	sub2	(/*autoinst*/
        //Inputs
        .dataa  ({1'b0,add02[9:0]}  ),
        .datab  ({1'b0,add03[9:0]} ),
        //Outputs
        .result (sub_wire_1[10:0] ));

endmodule 
