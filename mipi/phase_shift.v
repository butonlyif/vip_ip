////////////////////////////////////////////////////////////
//   Function   : CSI2 receiver
//  Module Name: csi2_rx
/////////////////////////////////////////////////////////////

module phase_shift(
    input                    rst_i, 
    input                    clk,
    input                    phasedone,
    input                    pll_lock,
	output    reg [2:0]      phasecounterselect,
    output    reg            phasestep,
	output    reg            phaseupdown,

//--------------------------------------------------------------
    input                    cfg_start,
    input                    err_msg,
    output   reg             cfg_rdy

);

//-----------------------parameter define-------------------------
parameter            IDLE            = "IDLE",                   //IDLE
                     CONFIG          = "CONFIG",                 //TX  data  state
                     WAIT            = "WAIT";                   // h blanking state


reg       [255:0]    curr_state;
reg       [255:0]    next_state;
reg       [1:0]           state;
//----------------------------------------------------------------
//reg           cfg_rdy;
reg           phasedone_dly1;
reg           phasedone_dly2;

//reg           cfg_done
//----------------------------------------------------------------
always@(posedge clk or posedge rst_i)
    if(rst_i)
    begin
        cfg_rdy <= 1'b0;
        phasedone_dly1 <=1'b0;
        phasedone_dly2 <=1'b0;
    end
    else
    begin
        phasedone_dly1 <= phasedone;
        phasedone_dly2 <= phasedone_dly1;
        cfg_rdy <=phasedone_dly2;
    end



always@(posedge clk or posedge rst_i)
begin
    if(rst_i )
    begin    
       phasecounterselect  <= 3'b0;
       phasestep <=1'b0;
       phaseupdown <= 1'b0;
       state  <= 2'b00;     
    end
    else if(curr_state == IDLE)
    begin
        state <= 2'b00;
        phasestep     <=1'b0;
    end
    else if(curr_state == CONFIG)       
    begin
        case(state)
            2'b00 :                              //reg 0x00
            begin
                phasestep   <= 1'b1;
                phaseupdown <= 1'h0;
                phasecounterselect <= 3'b0;
                state <= 2'b01;
            end
            2'b01 :
            begin
                phasestep   <= 1'b1;
                phaseupdown <= 1'h1;
                phasecounterselect <= 3'b0;
                state <= 2'b10;
            end
            2'b10 :
            begin
                phasestep   <= 1'b1;
                phaseupdown <= 1'h0;
                phasecounterselect <= 3'b0;
                state <= 2'b11;
            end
            2'b11 :                               //reg 0x06
            begin
                phasestep   <= 1'b0;
                phaseupdown <= 1'h0;
                phasecounterselect <= 3'b0;
                state <= 2'b00;
            end
            default :
            begin
                 state <=2'b00;
            end
        endcase
    end
    else if(curr_state == WAIT)
    begin
        state <= 2'b00;
        phasestep     <=1'b0;
    end
end

         
//--------------------------------------------------------------------------------------//

//=============================================================================//
//state machine current state machine
//=============================================================================//
//assign main_stat = {curr_state==IDLE,curr_state==CONFIG,curr_state==WAIT};
always@(posedge clk or posedge rst_i)
begin
    if(rst_i)
    begin
        curr_state <= IDLE;
    end
    else
    begin
        curr_state <=next_state;
    end
end
//state machine next state machine

always@(*)
begin
    next_state = IDLE;
    case (curr_state) 
        IDLE:
        begin
            if(pll_lock & err_msg & cfg_start & (~phasestep))
                next_state = CONFIG;
            else
                next_state =IDLE;                
        end
        CONFIG:
        begin
            if(cfg_rdy)
                next_state = WAIT;
            else
                next_state = CONFIG;
        end
        WAIT:
        begin
            next_state = IDLE;                                       
	    end   
        default:
        begin 
            next_state =IDLE;
        end
    endcase
end
//-------------------------------------------------------------------------------------//
endmodule
//-------------------------------------------------------------------------------------//
                   

