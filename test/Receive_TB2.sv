`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2021 03:11:22 PM
// Design Name: 
// Module Name: Receive_TB2
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


module Receive_TB2();
    logic ref_clk;              //input; kmi internal clock
    logic nreset;               //input; reset
    logic receive;              //output; flag indicating data can be received
    logic clk_in;               //input; k/m clock
    logic [7:0] data_out;       //output; parallel data output
    logic serial_in;            //input; serial data input
    logic rx_done;              //input; flag indicating data has been received
    
    Receive dut(.*);
    
    initial begin
        ref_clk = 0;
        nreset = 1; 
        clk_in = 0;
        serial_in = 1'b1;
        
        //reset transmit block
        #5 nreset = 0; 
        #5 nreset = 1;
        
        //input 0 | 1 0 1 1 0 0 1 1 | 0 | 1 serially; output should be 2'hCD
        //valid input, so receive should go HIGH
        #512 serial_in = 0; //low start bit
        #1024 serial_in = 1; //data bit index 0
        #1024 serial_in = 0; //data bit index 1
        #1024 serial_in = 1; //data bit index 2
        #1024 serial_in = 1; //data bit index 3
        #1024 serial_in = 0; //data bit index 4
        #1024 serial_in = 0; //data bit index 5
        #1024 serial_in = 1; //data bit index 6
        #1024 serial_in = 1; //data bit index 7
        #1024 serial_in = 0; //parity bit
        #1024 serial_in = 1; //high stop bit

        #2048
        rx_done = 1;
        #2048
        rx_done = 0;

        //input 0 | 1 0 1 1 0 0 1 1 | 1 | 1 serially; output should be 2'hCD
        //invalid input, invalid parity bit, so receive should stay LOW
        #1024 serial_in = 0; //low start bit
        #1024 serial_in = 1; //data bit index 0
        #1024 serial_in = 0; //data bit index 1
        #1024 serial_in = 1; //data bit index 2
        #1024 serial_in = 1; //data bit index 3
        #1024 serial_in = 0; //data bit index 4
        #1024 serial_in = 0; //data bit index 5
        #1024 serial_in = 1; //data bit index 6
        #1024 serial_in = 1; //data bit index 7
        #1024 serial_in = 1; //invalid parity bit
        #1024 serial_in = 1; //high stop bit
        
        #2048
        rx_done = 1;
        #2048
        rx_done = 0;

        //input 0 | 1 0 1 1 0 0 1 1 | 0 | 0 serially; output should be 2'hCD
        //invalid input, low stop bit, so receive should stay LOW
        #1024 serial_in = 0; //low start bit
        #1024 serial_in = 1; //data bit index 0
        #1024 serial_in = 0; //data bit index 1
        #1024 serial_in = 1; //data bit index 2
        #1024 serial_in = 1; //data bit index 3
        #1024 serial_in = 0; //data bit index 4
        #1024 serial_in = 0; //data bit index 5
        #1024 serial_in = 1; //data bit index 6
        #1024 serial_in = 1; //data bit index 7
        #1024 serial_in = 0; //valid parity bit
        #1024 serial_in = 0; //low stop bit
        #1024 serial_in = 1; //late high stop bit
        
        #2048
        rx_done = 1;
        #2048
        rx_done = 0;
        
        //input 0 | 1 1 1 0 0 0 1 0 | 1 | 1 serially; output should be 2'h47
        //valid input, so receive should go HIGH
        #512 serial_in = 0; //low start bit
        #1024 serial_in = 1; //data bit index 0
        #1024 serial_in = 1; //data bit index 1
        #1024 serial_in = 1; //data bit index 2
        #1024 serial_in = 0; //data bit index 3
        #1024 serial_in = 0; //data bit index 4
        #1024 serial_in = 0; //data bit index 5
        #1024 serial_in = 1; //data bit index 6
        #1024 serial_in = 0; //data bit index 7
        #1024 serial_in = 1; //valid parity bit
        #1024 serial_in = 1; //high stop bit


    end
    
    //pulse ref_clk every 1 ms
    always
        #1 ref_clk = ~ref_clk;
        
    //pulse clk_in every 512 ref_clks
    always
        #512 clk_in = ~clk_in;
endmodule
