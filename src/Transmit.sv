`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2021 12:15:09 PM
// Design Name: 
// Module Name: Transmit
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


module Transmit(ref_clk, nreset, transmit, clk_in, data_in, serial_out, ndata_en, tx_done);
    
    input ref_clk;
    input nreset;
    input transmit;
    input clk_in;
    input [7:0] data_in;
    output logic serial_out;
    output logic ndata_en;
    output logic tx_done;	 //flag indicating transmission is complete
    
    logic [10:0] parallel_out;   //parallel data with start bit, parity bit, and stop bit
    logic [3:0] index;           //serial data index to transmit
    logic next_tx_done;  
    
    logic [3:0] next_index;  
    
    enum logic [1:0] {
        IDLE = 2'b00,
        TRANSMIT = 2'b01,
        DONE = 2'b10
    } state, next_state;
    
    always_comb begin
        case (state)
            IDLE:
                if(transmit) begin
                    next_state = TRANSMIT;
                    parallel_out = {1'b1, (^data_in)^1'b1, data_in, 1'b0}; //generate serial output with parity bit
                    next_tx_done = 1'b0;                                        //set done flag to 0
                    index = 1'b0;                                             //set transmission index to 0
                    ndata_en = 1'b0;                                          //indicate transmitting has begun
                end
                else
                    next_state = IDLE;              
            TRANSMIT:
                if(tx_done) begin           //if transmit is done, return to idle
                    next_state = DONE;
                    ndata_en = 1'b1;
                end
                else
                    next_state = TRANSMIT;
            DONE: 
                if(!transmit) begin         //when transmit goes low, return to idle
                    next_state = IDLE;
                    next_tx_done = 1'b0;
                end
                else
                    next_state = DONE;
            default: next_state = IDLE;
        endcase
    end
    
    //perform serial data transmission
    always_ff @(posedge clk_in or negedge nreset)
        if(!nreset) begin
            next_tx_done <= 1'b0;
            next_index <= 1'b0;
        end    
        else if(state === TRANSMIT) begin
            if(index === 11) begin
                next_index <= 1'b0;
                next_tx_done <= 1'b1;               //once index reaches 11, set done flag high, 
                                                    //indicate to controller that transmit is complete
            end
            else begin
                serial_out <= parallel_out[index];  //set serial out to parallel out value at index 
                next_index <= index + 1;            //increment index
                next_tx_done <= 1'b0;
            end
            
        end
        
    //update state
    always_ff @(posedge ref_clk or negedge nreset)
        if(!nreset) begin
            state <= IDLE;
            serial_out <= 1'b1;
            ndata_en <= 1'b1;
        end        
        else begin
            state <= next_state; 
            tx_done <= next_tx_done;
            index <= next_index;
        end

endmodule
