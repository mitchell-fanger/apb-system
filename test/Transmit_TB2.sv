`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2021 03:11:08 PM
// Design Name: 
// Module Name: Transmit_TB2
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


module Transmit_TB2();
    logic ref_clk;          //input kmi internal clock
    logic nreset;           //input reset
    logic transmit;         //input set high to transmit
    logic clk_in;           //input k/m clock, slower than ref_clk
    logic [7:0] data_in;    //input data to transmit
    logic serial_out;       //output data
    logic ndata_en;         //output data enable
    logic tx_done;          //output transmission is complete
    
    Transmit dut(.*);
    
    initial begin
        ref_clk = 0;
        nreset = 1; 
        transmit = 0;
        clk_in = 0;
        data_in = 8'b00000000;
        
        //reset transmit block
        #5 nreset = 0; 
        #5 nreset = 1;
        
        //transmit 8'b10110011, serial output should be 0 1 1 0 0 1 1 0 1 0 1
        #5 data_in = 8'b10110011;
        #5 transmit = 1;
        #5 transmit = 0;
        
        #15360
        
        //transmit 8'b10110011, serial output should be 0 1 1 0 0 1 1 0 1 0 1
        #5 data_in = 8'b10110011;
        #5 transmit = 1;
        #5 transmit = 0;
        
    end
    
    //pulse ref_clk every 1 ms
    always
        #1 ref_clk = ~ref_clk;
        
    //pulse clk_in every 512 ref_clks
    always
        #512 clk_in = ~clk_in;
        
endmodule
