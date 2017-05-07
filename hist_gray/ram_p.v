// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : ram_p.v
// Author        : 
// Created On    : 2016-02-18 21:11
// Last Modified : 2016-02-18 21:16
// -------------------------------------------------------------------------------------------------
// Svn Info:
//   $Revision::                                                                                $:
//   $Author::                                                                                  $:
//   $Date::                                                                                    $:
//   $HeadURL::                                                                                 $:
// -------------------------------------------------------------------------------------------------
// Description:
//
//
// -FHDR--------------------------------------------------------------------------------------------

module ram_p(/*autoarg*/
    //Inputs
    clk, rst, data, rden, wren, wraddress, 
    rdaddress, 

    //Outputs
    q
);
parameter   BITWIDTH = 16;
input                                   clk;
input                                   rst;

input   [BITWIDTH-1:0]  data;
input                   rden;
input                   wren;
output  [BITWIDTH-1:0]  q;
input   [7:0]           wraddress;
input   [7:0]           rdaddress;
//{{{
/*autodef*/
// Define io wire here
wire                                    clk;
wire                                    rst;
wire [BITWIDTH-1:0]                     data;
wire                                    rden;
wire                                    wren;
wire [BITWIDTH-1:0]                     q;
wire [7:0]                              wraddress;
wire [7:0]                              rdaddress;
// Define flip-flop registers here
// Define combination registers here
// Define wires here
// Define inst wires here
// Unresolved define signals here
// End of automatic define
//}}}
//

altsyncram	altsyncram_component (
				.address_a (wraddress),
				.address_b (rdaddress),
				.clock0 (clk),
				.data_a (data),
				.rden_b (rden),
				.wren_a (wren),
				.q_b (q),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b ({BITWIDTH{1'b1}}),
				.eccstatus (),
				.q_a (),
				.rden_a (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_b = "NONE",
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.intended_device_family = "MAX 10",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 256,
		altsyncram_component.numwords_b = 256,
		altsyncram_component.operation_mode = "DUAL_PORT",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_b = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.rdcontrol_reg_b = "CLOCK0",
		altsyncram_component.read_during_write_mode_mixed_ports = "OLD_DATA",
		altsyncram_component.widthad_a = 8,
		altsyncram_component.widthad_b = 8,
		altsyncram_component.width_a = BITWIDTH,
		altsyncram_component.width_b = BITWIDTH,
		altsyncram_component.width_byteena_a = 1;
endmodule
