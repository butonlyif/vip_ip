//
// Created by         :Dylan
// Filename           :gaussian_filter.v
// Author             :(RDC)
// Created On         :2016-02-09 23:21
// Last Modified      : 
// Update Count       :2016-02-09 23:21
// Description        :
//                     
//                     
//=======================================================================

module gaussian_filter ( /*autoarg*/
    //Inputs
    video_in_data, video_in_valid, video_out_ready, 
    clk, rst, 

    //Outputs
    video_in_ready, video_out_data, video_out_valid);


input		[23:0]	video_in_data;
input			video_in_valid;
output			video_in_ready;

output		[23:0]	video_out_data;
output			video_out_valid;
input			video_out_ready;

input			clk; //clock
input			rst; //reset

reg		[7:0]	d01, d02, d11, d12, d21, d22;
wire		[7:0]	d10, d20, d00;
reg		[1:0]	valid_d;
reg		[11:0]	add00, add01, add02;
reg		[13:0]	add10;

reg	[15:0]	data_d1, data_d2;
assign	d00 = video_in_data[23:16];


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
		valid_d <= {valid_d[0],video_in_valid};

//stage 1 adder


always @(posedge clk or posedge rst) begin
    if (rst) begin
	    add00 <= 0;
	    add01 <= 0;
	    add02 <= 0;
    end
    else if (video_in_valid) begin
	    add00 <= d00 + {d01,1'b0} + d02;
	    add01 <= {d10,1'b0} + {d11, 2'b00} + {d12,1'b0};
	    add02 <= d20 + {d21,1'b0} + d22;
    end
end

//stage 2 adder


always @(posedge clk or posedge rst) begin
    if (rst) begin
	add10 <= 0;
    end
    else if (valid_d[0]) begin
	add10 <= add00 + add01 + add02;
    end
end

always @(posedge clk or posedge rst	) begin
    if (rst	) begin
	    data_d1 <= 0;
	    data_d2 <= 0;
//	    data_d3 <= 0;
    end
    else begin
	    data_d1 <= video_in_data[15:0];
	    data_d2 <= data_d1;
//	    data_d3 <= data_d2;
    end
end

assign video_out_data = {add10[11:4],data_d2};
assign video_out_valid = valid_d[1];
assign video_in_ready = video_out_ready;

altshift_taps	ALTSHIFT_TAPS_component (
				.aclr (rst),
				.clken (video_in_valid),
				.clock (clk),
				.shiftin (d00),
				.shiftout (),
				.taps ({d20,d10})
				);
	defparam
		ALTSHIFT_TAPS_component.intended_device_family = "MAX 10",
		ALTSHIFT_TAPS_component.lpm_hint = "RAM_BLOCK_TYPE=AUTO",
		ALTSHIFT_TAPS_component.lpm_type = "altshift_taps",
		ALTSHIFT_TAPS_component.number_of_taps = 2,
		ALTSHIFT_TAPS_component.tap_distance = 1920,
		ALTSHIFT_TAPS_component.width = 8;

endmodule 
