module ecc_check (
    input                   reset,
    input                   clk,
	input                   lp_in,
	input       [31:0]      mipi_dat,
	input                   pkt_sof,
	output reg              ecc_end,
    output reg [5:0]        dat_type,
	output reg [15:0]       WC,	
	output reg              EccErr
	);

//----------------------------------------------------------------------------------------------------
	reg	                    eccerr_flag;
	reg        [23:0]   	xor_mask;	
	wire       [7:0]        Syndrome;
    wire       [5:0]        P;

//---------according the csi-2 spec--------------------------------------------------------------------
assign	P[5] =  mipi_dat[10]^mipi_dat[11]^mipi_dat[12]^mipi_dat[13]^
				mipi_dat[14]^mipi_dat[15]^mipi_dat[16]^mipi_dat[17]^
				mipi_dat[18]^mipi_dat[19]^mipi_dat[21]^mipi_dat[22]^mipi_dat[23];

assign	P[4] =	mipi_dat[4]^mipi_dat[5]^mipi_dat[6]^mipi_dat[7]^mipi_dat[8]^
				mipi_dat[9]^mipi_dat[16]^mipi_dat[17]^mipi_dat[18]^
				mipi_dat[19]^mipi_dat[20]^mipi_dat[22]^mipi_dat[23];

assign	P[3] =  mipi_dat[1]^mipi_dat[2]^mipi_dat[3]^mipi_dat[7]^mipi_dat[8]^
				mipi_dat[9]^mipi_dat[13]^mipi_dat[14]^mipi_dat[15]^
				mipi_dat[19]^mipi_dat[20]^mipi_dat[21]^mipi_dat[23];

assign	P[2] =  mipi_dat[0]^mipi_dat[2]^mipi_dat[3]^mipi_dat[5]^mipi_dat[6]^
			    mipi_dat[9]^mipi_dat[11]^mipi_dat[12]^mipi_dat[15]^mipi_dat[18]^
				mipi_dat[20]^mipi_dat[21]^mipi_dat[22];

assign	P[1] =  mipi_dat[0]^mipi_dat[1]^mipi_dat[3]^mipi_dat[4]^mipi_dat[6]^
				mipi_dat[8]^mipi_dat[10]^mipi_dat[12]^mipi_dat[14]^mipi_dat[17]^
				mipi_dat[20]^mipi_dat[21]^mipi_dat[22]^mipi_dat[23];

assign	P[0] =  mipi_dat[0]^mipi_dat[1]^mipi_dat[2]^mipi_dat[4]^mipi_dat[5]^
				mipi_dat[7]^mipi_dat[10]^mipi_dat[11]^mipi_dat[13]^mipi_dat[16]^
				mipi_dat[20]^mipi_dat[21]^mipi_dat[22]^mipi_dat[23];
assign	Syndrome = {2'b0, P[5:0]^mipi_dat[29:24]};
	
	
always @(*)	begin
  
    eccerr_flag	= 'b1;
    xor_mask	= 24'b0;
    case (Syndrome[5:0])
        6'h00     : begin
                      eccerr_flag	= 'b0;
				  end
		6'h07     : begin
					  eccerr_flag	= 'b0;
					  xor_mask[0]	= 1'b1;
				  end
	   6'h0b     : begin
					  eccerr_flag	= 'b0;
					  xor_mask[1]	= 1'b1;
				  end
	   6'h0d     : begin
					  eccerr_flag	= 'b0;
					  xor_mask[2]	= 1'b1;
				  end
	   6'h0e     : begin
					  eccerr_flag	= 'b0;
					  xor_mask[3]	= 1'b1;
			      end
	   6'h13     : begin
					  eccerr_flag	= 'b0;
					  xor_mask[4]	= 1'b1;
			       end
	  6'h15 :      begin
					  eccerr_flag	= 'b0;
					  xor_mask[5]	= 1'b1;
				   end
	  6'h16 :      begin
					   eccerr_flag	= 'b0;
					   xor_mask[6]	= 1'b1;
				   end
	  6'h19 :      begin
                       eccerr_flag	= 'b0;
                       xor_mask[7]	= 1'b1;
                   end
	  6'h1a :      begin
                       eccerr_flag	= 'b0;
                       xor_mask[8]	= 1'b1;
                   end
	 6'h1c :       begin
                       eccerr_flag	= 'b0;
                       xor_mask[9]	= 1'b1;
				   end
	 6'h23 :       begin
                       eccerr_flag	= 'b0;
                       xor_mask[10]	= 1'b1;
				  end
	 6'h25 :      begin
					   eccerr_flag	= 'b0;
					   xor_mask[11]	= 1'b1;
				  end
	 6'h26 :      begin	
					   eccerr_flag	= 'b0;
					   xor_mask[12]	= 1'b1;
				  end
	 6'h29 :      begin
				       eccerr_flag	= 'b0;
				       xor_mask[13]	= 1'b1;
				  end
     6'h2a :      begin
					   eccerr_flag	= 'b0;
					   xor_mask[14]	= 1'b1;
				  end
     6'h2c :      begin
					  eccerr_flag	= 'b0;
					  xor_mask[15]	= 1'b1;
				  end
     6'h31 :      begin
					  eccerr_flag	= 'b0;
				      xor_mask[16]	= 1'b1;
				  end
     6'h32 :      begin
					  eccerr_flag	= 'b0;
					  xor_mask[17]	= 1'b1;
				  end
     6'h34 :      begin
				      eccerr_flag	= 'b0;
			          xor_mask[18]	= 1'b1;
				  end
     6'h38 :      begin
					  eccerr_flag	= 'b0;
					  xor_mask[19]	= 1'b1;
				  end
     6'h1f :      begin 
					  eccerr_flag	= 'b0;
					  xor_mask[20]	= 1'b1;
				  end
     6'h2f :      begin
					  eccerr_flag	= 'b0;
					  xor_mask[21]	= 1'b1;
			 	  end
     6'h37 :      begin
					  eccerr_flag	= 'b0;
					  xor_mask[22]	= 1'b1;
				  end
     6'h3b :      begin
					  eccerr_flag	= 'b0;
					  xor_mask[23]	= 1'b1;
				  end
     default:     begin
					  eccerr_flag	= 'b1;
					  xor_mask	= 24'b0;
				  end
			endcase
end
	
always @(posedge clk or posedge reset)
    if(reset)begin
        dat_type	<=	6'h00;
		WC	<=	16'h00;
	end
    else if(pkt_sof)
    begin
		dat_type	<=	mipi_dat[5:0];
		WC			<=	mipi_dat[23:8];
    end


always @(posedge clk)
if(lp_in)begin
	EccErr	<= 1'b0;
	end
else if(pkt_sof)
begin
	EccErr	<= eccerr_flag;
end

always @(posedge clk)
		ecc_end	<=	pkt_sof;
	
endmodule
						
			
					
			
	
	
