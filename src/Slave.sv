`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2021 09:49:39 PM
// Design Name: 
// Module Name: Slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Slave(pclk, ref_clk, npreset, pwrite, psel, penable, pready, pwdata, prdata, rx_data, receive, transmit, tx_data, tx_done, rx_done, rx_interrupt);
    input pclk;
    input npreset;
    input pwrite;
    input psel;
    input penable;
    input [7:0] pwdata;
    
    input ref_clk;                      //internal reference clock

    input [7:0] rx_data;                //data input from Receive block
    input receive;                      //flag indicating request to receive
    output logic rx_interrupt;          //interrupt indicating data is ready to be read in from k/m 
    output logic rx_done;               //flag to controller indicating read is done

    output logic pready;                //pready signal to APB System
    output logic [7:0] prdata;          //prdata to APB System 

    input tx_done;
    output logic transmit;              //flag output to Controller block
    output logic [7:0] tx_data;         //data output to Transmit block
    
    assign rx_interrupt = receive;      //when controller sets receive high, send interrupt to cpu
    
    enum logic [2:0] {
        IDLE = 3'b000,
        SETUP = 3'b001,
        TRANSMIT = 3'b010,
        ACCESS = 3'b011,
        WAITING = 3'b100
    } state, next_state;
    
    always_comb
        case (state)
            IDLE: begin 
                pready = 0;
                rx_done = 1'b0;
                transmit = 1'b0;
                if(psel & penable) 
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end
            SETUP: 
                if(pwrite) begin                //if request to write/transmit is made
                    next_state = TRANSMIT;      //enter transmit state
                    tx_data = pwdata;           //set transmit data to write data
                    transmit = 1'b1;            //indicate to controller that transmit is ready
                end    
                else begin                      //if request to receive is made
                    next_state = ACCESS;        //enter access state
                    prdata = rx_data;           //set prdata to received data
                    rx_done = 1'b1;             //indicate to controller receive is done
                end
            TRANSMIT:
                if(tx_done)                     //wait until transmit is done (from controller)
                    next_state = ACCESS;
                else
                    next_state = TRANSMIT;
            ACCESS: begin 
                pready = 1;                     //set pready high to indicate data transfer is complete
                if(!penable)                    //keep pready high until penable goes low, then return to idle
                    next_state = WAITING;
                else
                    next_state = ACCESS;
            end
            WAITING: begin
                pready = 0;
                if(!receive)
                    next_state = IDLE;
                else
                    next_state = WAITING;
            end
            default: next_state = IDLE;
        endcase        
        
    always_ff @(posedge pclk)
        if(!npreset)
            state <= IDLE;
        else
            state <= next_state;
    
endmodule
