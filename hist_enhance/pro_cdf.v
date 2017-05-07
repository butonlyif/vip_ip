// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) BITWIDTH-116 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : pro_cdf.v
// Author        : 
// Created On    : BITWIDTH-116-02-18 19:39
// Last Modified : 2016-02-23 14:31
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

module pro_cdf(/*autoarg*/
    //Inputs
    clk, rst, video_eop, load_data, 

    //Outputs
    load_addr, load, update_addr, update, 
    update_data, clean
);
parameter BITWIDTH=21;
parameter TOTOLNUM=1920*1080/4;
parameter LATENCY = 21;
input                                   clk;
input                                   rst;

input                                   video_eop;

output      [7:0]                       load_addr;
output                                  load;
input       [BITWIDTH-1:0]                      load_data;

output      [7:0]                       update_addr;
output                                  update;
output      [7:0]                       update_data;
output                                  clean;
//{{{
/*autodef*/
// Define io wire here
wire                                    clk;
wire                                    rst;
wire                                    video_eop;
reg  [7:0]                              load_addr;
wire                                    load;
wire [BITWIDTH-1:0]                     load_data;
wire [7:0]                              update_addr;
wire                                    update;
wire [7:0]                              update_data;
wire                                    clean;
// Define flip-flop registers here
wire [BITWIDTH-1:0]                      ram_data;
reg  [BITWIDTH-1:0]                              accum;
reg  [LATENCY-1:0]                              calcu_valid;
reg                                     load_p;
reg  [BITWIDTH-1:0]                              minus_1;
reg  [BITWIDTH-1:0]                              minus_2;
reg  [17:0]                              mult_res;
reg  [BITWIDTH-1:0]                             p_min;
reg  [7:0]                              update_addr_reg;
reg  [7:0]                              wraddress;
reg                                     wren;
reg                                     eop_d;
// Define combination registers here
// Define wires here
wire [17:0]                              denom;
reg [17:0]                              denom_reg;
wire                                    start_calculate;
// Define inst wires here
reg [7:0]                              rdaddress;
reg                                    rden;
// Unresolved define signals here
wire    [17:0] numer;
wire    [17:0] quotient;
wire    [BITWIDTH-1:0]   q;
reg             update_d;
wire               addr0;
// End of automatic define
//}}}
///////////////loading p data////////////////

always @(posedge clk or posedge rst) begin
    if(rst) begin
       eop_d <= 0; 
    end else begin
        eop_d <= video_eop;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        load_p <= 0;
    end else if(eop_d) begin
        load_p <= 1'b1;
    end else if (load_addr==8'hff)begin
        load_p <= 1'b0;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        load_addr  <= 0; 
    end else if(load_p) begin
        load_addr <= load_addr + 1;
    end
end
assign  load = load_p;

///////////////////get the minum///////////////
always @(posedge clk or posedge rst) begin
    if(rst) begin
        p_min <= 21'h1fffff;
    end else if( eop_d) begin
        p_min <= 21'h1fffff;
    end else if( p_min > load_data)begin
        p_min <= load_data;
    end
end

/////////////////push the data into ram///////

always @(posedge clk or posedge rst) begin
    if(rst) begin
        wraddress <= 0;    
    end else begin
        wraddress <= load_addr;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        wren <= 0;   
    end else begin
        wren <= load;
    end
end


/*always @(posedge clk or posedge rst) begin
    if(rst) begin
        ram_data <= 0;
    end else begin
        ram_data <= load_data;
    end
end*/

assign  ram_data = load_data;

ram_p ram(/*autoinst*/
    .clk                      (clk                          ),
    .data                       (ram_data[BITWIDTH-1:0]                     ),
    .rdaddress                  (rdaddress[7:0]                 ),
    .rden                       (rden                           ),
    .wraddress                  (wraddress[7:0]                 ),
    .wren                       (wren                           ),
    .q                          (q[BITWIDTH-1:0]                        )
);
defparam
ram.BITWIDTH=BITWIDTH;

assign  start_calculate = wren & (!load);
assign  clean = start_calculate;


//////////////////////calculate the h//////////////
// cdf/resolution, resolution here is 256x256, thus truncate 16 bits. 

always @(posedge clk or posedge rst) begin
    if(rst) begin
        rden <= 0;
    end else if( start_calculate) begin
        rden <= 1'b1;
    end else if ( rdaddress==8'hff)begin
        rden <= 0;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        rdaddress <= 0;
    end else if(rden) begin
        rdaddress <= rdaddress + 1;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
       calcu_valid <= 0; 
    end else begin
        calcu_valid <= {calcu_valid[LATENCY-2:0],rden};
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        accum <= 0;
    end else if(eop_d) begin
        accum <= 0;
    end else if (calcu_valid[0]) begin
        accum <= accum + q;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        minus_1 <= 0;
    end else if(calcu_valid[1]) begin
        minus_1 <= accum - p_min;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        minus_2 <= 0;
    end else begin
        minus_2 <= TOTOLNUM - p_min;
    end
end

//assign  denom = minus_2;
//assign  numer = minus_1;
//assign denom = {8'h0,minus_2[BITWIDTH-1:BITWIDTH-10]};
//generate begin
//    if (BITWIDTH>=18)begin
 //       assign  numer = minus_1[BITWIDTH-1: BITWIDTH-18] & 18'h3ff00;
  //  end
   // else begin
    //    assign numer = {minus_1[BITWIDTH-1:0],{(18-BITWIDTH) {1'b0}}} & 18'h3ff00;
   // end
//end
//endgenerate



always @(posedge clk or posedge rst) begin
    if(rst) begin
        mult_res <= 0;
    end else  begin
        mult_res <= minus_1[BITWIDTH-1:BITWIDTH-10] * 8'hfe;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        denom_reg <= 0;
    end else begin
        denom_reg <= {10'h0,minus_2[BITWIDTH-1:BITWIDTH-9]};
    end
end

assign  denom= denom_reg;
assign  numer= mult_res;

always @(posedge clk or posedge rst) begin
    if(rst) begin
       update_addr_reg <= 0; 
    end else if( calcu_valid[LATENCY-1]) begin
        update_addr_reg <= update_addr_reg + 1;
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
       update_d <= 0;
    end else begin
        update_d <= update;
    end
end

assign  addr0 = update & (!update_d);

assign  update = calcu_valid[LATENCY-1];
assign  update_data = addr0 ? 0 : (quotient[0] ? (quotient[8:1] + 2) : (quotient[8:1]+1));
assign  update_addr = update_addr_reg;


	lpm_divide	LPM_DIVIDE_component (
				.clock (clk),
				.denom (denom),
				.numer (numer),
				.quotient (quotient),
				.remain (remain),
				.aclr (1'b0),
				.clken (1'b1));
	defparam
		LPM_DIVIDE_component.lpm_drepresentation = "UNSIGNED",
		LPM_DIVIDE_component.lpm_hint = "LPM_REMAINDERPOSITIVE=TRUE",
		LPM_DIVIDE_component.lpm_nrepresentation = "UNSIGNED",
		LPM_DIVIDE_component.lpm_pipeline = 18-1,
		LPM_DIVIDE_component.lpm_type = "LPM_DIVIDE",
		LPM_DIVIDE_component.lpm_widthd = 18,
		LPM_DIVIDE_component.lpm_widthn = 18;

endmodule
