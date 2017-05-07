// --------------------------------------------------------------------
// Copyright (c) 2007 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	Bayer to RGB format support row and column mirror
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| 		Changes Made:
//   V1.0 :| Johnny Fan        :| 07/07/09:|      Initial Revision
//   V2.0 :| Peli Li           :| 2010/11/09:|    Revised for row mirror
// --------------------------------------------------------------------
module	RAW2RGB		(	iCLK,
                        iRST_n,
								//Read Port 1
								iData,
								iDval,
								oRed,
								oGreen,
								oBlue,
								oDval,
								iMIRROR,
								iX_Cont,
								iY_Cont
							);

parameter DEPTH = 8;
input			iCLK;
input			iRST_n;
input	[DEPTH-1:0]	iData;
input			iDval;
output reg	[DEPTH-1:0]	oRed;
output reg	[DEPTH-1:0]	oGreen;
output reg	[DEPTH-1:0]	oBlue;
output			oDval;
input		      iMIRROR;
input	iX_Cont;
input	iY_Cont;

wire	[DEPTH-1:0]	wData0_d0;
wire	[DEPTH-1:0]	wData1_d0;
wire	[DEPTH-1:0]	wData2_d0;

reg		[DEPTH+1:0]	rRed;
reg		[DEPTH+1:0]	rGreen;
reg		[DEPTH+1:0]	rBlue;
reg				   rDval;
reg		[DEPTH-1:0]	wData0_d1,wData0_d2;
reg		[DEPTH-1:0]	wData1_d1,wData1_d2;
reg		[DEPTH-1:0]	wData2_d1,wData2_d2;

reg				oDval;
//wire			oDval_i;


reg				dval_ctrl;
reg				dval_ctrl_en;
wire  [1:0]  data_control;

reg  [1:0]  data_control_q;

Line_Buffer	L1	(
					.aclr(!iRST_n),
					.clken(iDval),
					.clock(iCLK),
					.shiftin(iData),
					.shiftout(),
					.taps0x(wData0_d0),
					.taps1x(wData1_d0),
					.taps2x(wData2_d0)
				);

//always@(posedge iCLK or negedge iRST_n)
//	begin
//		if (!iRST_n)
//				dval_ctrl<=0;
//		else
//				if(iY_Cont>1)
//					dval_ctrl<=1;
//				else
//					dval_ctrl<=0;
//	end
//
//always@(posedge dval_ctrl or negedge iRST_n)
//	begin
//		if (!iRST_n)
//				dval_ctrl_en<=0;
//		else
//				dval_ctrl_en<=1;
//	end

//assign oDval_i 		= dval_ctrl_en ?  rDval : 1'b0;

//assign  data_control = {iMIRROR?~iY_Cont[0]:iY_Cont[0],iMIRROR?iX_Cont[0]:~iX_Cont[0]};
assign  data_control = {iY_Cont,iMIRROR?~iX_Cont:iX_Cont};

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				wData0_d1<=0;
				wData1_d1<=0;
				wData2_d1<=0;
				wData0_d2<=0;
				wData1_d2<=0;
				wData2_d2<=0;
				end
		else if (iDval) begin
				wData0_d1<=wData0_d0;
				wData1_d1<=wData1_d0;
				wData2_d1<=wData2_d0;
				wData0_d2<=wData0_d1;
				wData1_d2<=wData1_d1;
				wData2_d2<=wData2_d1;				
			end
end
			


always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				rDval    <=0;			
				data_control_q    <=0;			
				oDval    <=0;			
			end
		else
			begin
			
				rDval	 <=iDval;
				data_control_q <= data_control;
				oDval <= rDval;

				if ( data_control_q == 2'b10)
					begin
						oRed <= rRed[DEPTH-1:0];
						oGreen <= rGreen[DEPTH+1:2] + rGreen[1];
						oBlue <= rBlue[DEPTH+1:2] + rBlue[1];
					end	
				else if ( data_control_q == 2'b11)
					begin
						oRed <= rRed[DEPTH:1] + rRed[0];
						oGreen <= rGreen[DEPTH-1:0];
						oBlue <= rBlue[DEPTH:1] + rBlue[0];
					end
					
				else if ( data_control_q == 2'b00)
					begin
						oRed <= rRed[DEPTH:1] + rRed[0];
						oGreen <= rGreen[DEPTH-1:0];
						oBlue <= rBlue[DEPTH:1] + rBlue[0];
					end	
				
			   else if ( data_control_q == 2'b01)
					begin
						oRed <= rRed[DEPTH+1:2] + rRed[1];
						oGreen <= rGreen[DEPTH+1:2] + rGreen[1];
						oBlue <= rBlue[DEPTH-1:0];
					end											
			  end
	end		
	
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				rRed<=0;
				rGreen<=0;
				rBlue<=0;	
			end

		else if ( data_control== 2'b10)
			begin
				rRed	 <=	wData1_d1;
				rGreen 	 <= wData1_d2 + wData1_d0 + wData0_d1 + wData2_d1; //up down left right
				rBlue	 <=	wData0_d0 + wData2_d2 + wData2_d0 + wData0_d2; // diagonal 
			end	
		else if ( data_control== 2'b11)
			begin
				rRed	 <=	wData1_d2 + wData1_d0; // left right
				rGreen <=	wData1_d1;
				rBlue	 <=	wData0_d1 + wData2_d1; // up down
			end
	    	
		else if ( data_control== 2'b00)
			begin
				rRed	 <=	wData0_d1 + wData2_d1; // up down
				rGreen <=	wData1_d1;
				rBlue	 <=	wData1_d2 + wData1_d0; // left right
			end	
		
	   else if ( data_control== 2'b01)
			begin
				rRed	 <=	wData0_d0 + wData2_d2 + wData2_d0 + wData0_d2; // diagonal 
				rGreen 	<=	wData1_d2 + wData1_d0 + wData0_d1 + wData2_d1; //up down left right
				rBlue	 <=	wData1_d1;
			end		
		 
		
	end


endmodule
