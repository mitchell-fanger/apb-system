`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 12:02:52 PM
// Design Name: 
// Module Name: alu_TB
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


module alu_TB();
    logic clk;
    logic nreset;
    logic alu_enable;
    logic alu_control;
    logic [15:0] A;
    logic [15:0] B;
    logic [15:0] alu_output;
    
    alu dut(.*);
    
    always 
        #5 clk = ~clk;
        
    initial begin
        clk = 0;
        nreset = 1;
        alu_enable = 0;
        alu_control = 0;
        A = 16'h0000;
        B = 16'h0000;
        
        //reset alu
        #25 nreset = 0;
        #25 nreset = 1;
        
        //perform alu_output = A+B; A = 16'h00A4; B = 16'h003B; alu_output = 16'h00DF
        #25 
        alu_enable = 1;
        alu_control = 0;
        A = 16'h00A4;
        B = 16'h003B;
        
        //set alu_enable to 0, alu_output = A; A = 16'h0022;
        #25
        alu_enable = 0;
        A = 16'h0022;
    
        //perform alu_output = A-B; A = 16'h00A4; B = 16'h003B; alu_output = 16'h0069
        #25 
        alu_enable = 1;
        alu_control = 1;
        A = 16'h00A4;
        B = 16'h003B;
    
    end

endmodule
