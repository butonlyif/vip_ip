// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : hist_regenerate.v
// Author        : 
// Created On    : 2016-02-18 20:20
// Last Modified : 2016-02-21 19:59
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

module hist_regenerate(/*autoarg*/
    //Inputs
    clk, rst, update_data, update_address, 
    update, sink_eop, sink_data, sink_valid, 

    //Outputs
    source_valid, source_data
);

input                                   clk;
input                                   rst;
input       [7:0]                update_data;
input       [7:0]                update_address;
input                             update;

input                           sink_eop;
input       [7:0]               sink_data;
input                           sink_valid;

output                          source_valid;
output     [7:0]                source_data;
//{{{
/*autodef*/
// Define io wire here
wire                                    clk;
wire                                    rst;
wire [7:0]                              update_data;
wire [7:0]                              update_address;
wire                                    update;
wire                                    sink_eop;
wire [7:0]                              sink_data;
wire                                    sink_valid;
wire                                    source_valid;
wire [7:0]                              source_data;
// Define flip-flop registers here
reg                                     eop_d;
reg                                     sink_valid_d;
reg                                     toggle;
// Define combination registers here
// Define wires here
wire [7:0]                              address_0;
wire [7:0]                              address_1;
wire [7:0]                              data_0;
wire [7:0]                              data_1;
wire                                    rden_0;
wire                                    rden_1;
wire                                    wren_0;
wire                                    wren_1;
// Define inst wires here
wire [7:0]                              q_0;
wire [7:0]                              q_1;
// Unresolved define signals here
// End of automatic define
//}}}
//
//
//
//

always @(posedge clk or posedge rst) begin
    if(rst) begin
      eop_d <= 0;  
    end else begin
        eop_d <= sink_eop;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
       toggle <= 0; 
    end else if(eop_d) begin
        toggle <= ~toggle;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        sink_valid_d <= 1'b0;
    end else begin
        sink_valid_d <= sink_valid;
    end
end

assign  source_valid = sink_valid_d;
assign  source_data = toggle ? q_0 : q_1;

assign  address_0 = toggle ? sink_data : update_address;
assign  rden_0 = toggle ? sink_valid : 0;
assign  wren_0 = toggle ? 0 : update;
assign  data_0 = toggle ? 0 : update_data;

assign  address_1 = toggle ? update_address : sink_data;
assign  rden_1 = toggle ? 0 : sink_valid ;
assign  wren_1 = toggle ?  update :0 ;
assign  data_1 = toggle ?  update_data: 0;

ram_p ram0(/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .data                       (data_0             ),
    .rden                       (rden_0                           ),
    .wren                       (wren_0                           ),
    .q                          (q_0                ),
    .wraddress                  (address_0[7:0]                 ),
    .rdaddress                  (address_0[7:0]                 )
);
defparam
ram0.BITWIDTH=8;
ram_p ram1(/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .data                       (data_1             ),
    .rden                       (rden_1                           ),
    .wren                       (wren_1                           ),
    .q                          (q_1                ),
    .wraddress                  (address_1[7:0]                 ),
    .rdaddress                  (address_1[7:0]                 )
);
defparam
ram1.BITWIDTH=8;
endmodule
