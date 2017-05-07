// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) BITWIDTH16 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : \projects\mipi_project_edge_0215\mipi_project_edge_0215\ip\inst_enhance\p_collect.v
// Author        : 
// Created On    : BITWIDTH16-02-18 17:36
// Last Modified : 2016-02-23 08:53
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

module p_collect(/*autoarg*/
    //Inputs
    clk, rst, video_data, video_valid, video_eop, 
    data_load, data_load_addr, clean, 

    //Outputs
    data_out
);

parameter BITWIDTH = 16;
input                                   clk;
input                                   rst;
input      [7:0]                            video_data;
input                                   video_valid;
input                                   video_eop;

input                                   data_load;
input      [7:0]                        data_load_addr;
output     [BITWIDTH-1:0]                       data_out;
input                                   clean;

//{{{
/*autodef*/
// Define io wire here
wire                                    clk;
wire                                    rst;
wire [7:0]                              video_data;
wire                                    video_valid;
wire                                    video_eop;
wire                                    data_load;
wire [7:0]                              data_load_addr;
wire [BITWIDTH-1:0]                             data_out;
wire                                    clean;
// Define flip-flop registers here
reg  [7:0]                              clean_addr;
reg                                     clean_en;
reg                                     toggle;
reg                                     wr;
reg  [7:0]                              wraddr;
// Define combination registers here
// Define wires here
wire [BITWIDTH-1:0]                             data_0;
wire [BITWIDTH-1:0]                             data_1;
wire                                    rd;
wire [7:0]                              rdaddr;
wire [7:0]                              rdaddress_0;
wire [7:0]                              rdaddress_1;
wire                                    rden_0;
wire                                    rden_1;
wire [7:0]                              wraddress_0;
wire [7:0]                              wraddress_1;
wire                                    wren_0;
wire                                    wren_1;
// Define inst wires here
wire [BITWIDTH-1:0]                             q_0;
wire [BITWIDTH-1:0]                             q_1;
// Unresolved define signals here
wire [BITWIDTH-1:0]     data;
wire [BITWIDTH-1:0]     q;

reg                     eop_d;
// End of automatic define
//}}}

assign rd = video_valid;
assign rdaddr = video_data;


always @(posedge clk or posedge rst) begin
    if(rst) begin
        wr <= 0;
        wraddr <= 8'h0;
    end else begin
        wr <= rd;
        wraddr <= video_data;
    end
end

assign data[BITWIDTH-1:0] = q + 1;

//assign data_out[BITWIDTH:0] = load_q;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        eop_d <= 0;  
    end else begin
        eop_d <= video_eop;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        toggle <= 0;
    end else if(eop_d) begin
        toggle <= ~toggle;
    end
end

assign rden_0 = toggle ? rd : data_load;
assign wren_0 = toggle ? wr : clean_en;
assign wraddress_0 = toggle ? wraddr :clean_addr;
assign rdaddress_0 = toggle ? rdaddr :data_load_addr;
assign data_0 = toggle ? data : 0;
assign  q[BITWIDTH-1:0]  = toggle ? q_0 : q_1;
assign rden_1 = toggle ? data_load : rd ;
assign wren_1 = toggle ? clean_en : wr;
assign wraddress_1 = toggle ? clean_addr: wraddr;
assign rdaddress_1 = toggle ? data_load_addr: rdaddr;
assign data_1 = toggle ? 0: data;

assign  data_out = toggle ? q_1 : q_0;

//// Comment clean the RAM;


always @(posedge clk or posedge rst) begin
    if(rst) begin
        clean_addr[7:0] <= 0;
    end else if(clean_en) begin
        clean_addr <= clean_addr + 1;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        clean_en <= 0;
    end else if(clean) begin
        clean_en <= 1'b1;
    end else if (clean_addr==8'hff)begin
        clean_en <= 1'b0;
    end
end

ram_p ram1(/*autoinst*/
    .clk                      (clk                          ),
    .data                       (data_0[BITWIDTH-1:0]                     ),
    .rdaddress                  (rdaddress_0[7:0]                 ),
    .rden                       (rden_0                           ),
    .wraddress                  (wraddress_0[7:0]                 ),
    .wren                       (wren_0                           ),
    .q                          (q_0[BITWIDTH-1:0]                        )
);
defparam
ram1.BITWIDTH=BITWIDTH; 



ram_p ram2(/*autoinst*/
    .clk                      (clk                          ),
    .data                       (data_1[BITWIDTH-1:0]                     ),
    .rdaddress                  (rdaddress_1[7:0]                 ),
    .rden                       (rden_1                           ),
    .wraddress                  (wraddress_1[7:0]                 ),
    .wren                       (wren_1                           ),
    .q                          (q_1[BITWIDTH-1:0]                        )
);
defparam
ram2.BITWIDTH=BITWIDTH; 


endmodule
