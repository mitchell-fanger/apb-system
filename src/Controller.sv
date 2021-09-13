`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2021 09:44:06 PM
// Design Name: 
// Module Name: Controller
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


module Controller(ref_clk, nreset, rx_in, tx_in, tx_done, rx_done, rx_out, tx_out, received);
    
    input ref_clk;      //8 MHz internal clock
    input nreset;       //reset
    input rx_in;        //flag indicates request to receive from receive block
    input tx_in;        //flag indicates request to transmit from APB slave
    input tx_done;      //flag indicates when transmission is done (from transmit block)
    input rx_done;      //flag indicates when receiving is done (from APB Slave)
    
    output logic rx_out;      //flag indicates request to receive to APB slave
    output logic tx_out;      //flag indicates request to transmit to transmit block
    output logic received;    //flag indicates to receive block when data has been received
    
    logic next_tx_out;
    logic next_rx_out;
    logic next_received;
    
    enum logic [2:0] {
        IDLE = 2'b00,
        RECEIVE = 2'b01,
        TRANSMIT = 2'b10,
        WAITING = 2'b11
    } state, next_state; 
    
    always_comb
        case (state)
            IDLE:
                if(tx_in) begin                 //if a request to transmit is made
                    next_state = TRANSMIT;
                    next_tx_out = 1'b1;
                    next_rx_out = 1'b0;
                end
                else if(rx_in) begin            //if a request to receive is made
                    next_state = RECEIVE;
                    next_tx_out = 1'b0;
                    next_rx_out = 1'b1;
                    next_received = 1'b0;
                end
                else begin                      //else, return to idle state
                    next_state = IDLE;
                    next_tx_out = 1'b0;
                    next_rx_out = 1'b0;
                    next_received = 1'b0;
                end
            TRANSMIT:                           //wait until transmit block indicates tranmit is done, then return to idle
                if(tx_done) begin               
                    next_state = IDLE;
                    next_tx_out = 1'b0;
                    next_rx_out = 1'b0;
                    next_received = 1'b0;
                end
                else 
                    next_state = TRANSMIT;
            RECEIVE: 
                if(rx_done) begin               //wait until slave confirms receive is done, then return to idle
                    next_state = WAITING;
                    next_tx_out = 1'b0;
                    next_rx_out = 1'b0;
                    next_received = 1'b1;
                end
                else 
                    next_state = RECEIVE;
            WAITING:
                if(!rx_in)
                    next_state = IDLE;
                else
                    next_state = WAITING;
            default: next_state = IDLE;
        endcase

    always_ff @(posedge ref_clk)
        if(!nreset) begin
            state <= IDLE;
            tx_out <= 1'b0;
            rx_out <= 1'b0;
        end
        else begin
            state <= next_state;
            tx_out <= next_tx_out;
            rx_out <= next_rx_out;
            received <= next_received;
        end
        
    
endmodule
            


