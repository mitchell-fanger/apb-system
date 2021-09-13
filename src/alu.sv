`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2021 08:10:36 PM
// Design Name: 
// Module Name: ALU
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


module alu(clk, nreset, alu_enable, alu_control, A, B, alu_output);
    
    input clk;
    input nreset;
    input alu_enable;   
    input alu_control;
    input [15:0] A;
    input [15:0] B;
    output logic [15:0] alu_output;
    
    always_ff @(posedge clk)
        if(!nreset)
            alu_output <= 16'b0000000000000000;
        else
            if(alu_enable)
                if(alu_control)
                    alu_output <= A-B;
                else
                    alu_output <= A+B;
            else
                alu_output <= A;
 
endmodule
