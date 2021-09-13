`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2021 03:11:35 PM
// Design Name: 
// Module Name: Controller_TB2
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


module Controller_TB2();
    logic ref_clk;          //internal kmi clock
    logic nreset;           //reset
    logic rx_in;            //input; flag to receive; from receive block
    logic tx_in;            //input; flag to transmit; from slave block
    logic tx_done;          //input; flag transmitting is done; from transmit block
    logic rx_done;          //input; flag receiving is done; from slave
    logic rx_out;           //output; flag indicating request to receive; to slave
    logic tx_out;           //output; flag indicating request to transmit; to transmit block
    logic received;         //output; flag indicating when data has been received; to receive block
    
    Controller dut(.*);
    
    initial begin
        ref_clk = 0;
        nreset = 1;
        rx_in = 0;
        tx_in = 0;
        tx_done = 0;
        rx_done = 0;
        
        #5 nreset = 0;
        #5 nreset = 1;
        
        #25
        
        //transmit test; tx_out should be HIGH
        tx_in = 1;           //request to transmit
        #5 
        tx_done = 1;         //transmitting is done
        tx_in = 0;
        
        #5 tx_done = 0;    //reset signals
        
        #25
        
        //receive test; rx_out should be HIGH
        rx_in = 1;           //request to receive
        #5 
        rx_done = 1;         //receiving is done
        rx_in = 0;
        
        #5 rx_in = 0;   rx_done = 0;    //reset signals
        
        #25
        
        //simultaneous transmit and receive test; tx_out should be HIGH
        rx_in = 1;           //request to receive
        tx_in = 1;           //request to transmit
        
        #5
        tx_done = 1;         //receiving is done
        rx_in = 0;           
        tx_in = 0;           
        
        //reset signals
        #5   
        tx_done = 0;    
        
        
        
    end
    
    always
        #1 ref_clk = ~ref_clk;
    
endmodule
