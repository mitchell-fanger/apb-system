`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2021 09:42:29 PM
// Design Name: 
// Module Name: APB_System
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


module APB_System(nreset, clk, 
                  init_done, init_data, init_addr,
                  kmirefclk, kmiclkin, kmidatain, kmidataout, nkmidataen, nkmiclken,
                  pwait);

    input nreset;               //reset
    input clk;                  //processor/pclk
    
    input init_done;            //
    input [15:0] init_data;
    input [15:0] init_addr;
    
    input kmirefclk;            //clock for kmi
    input kmiclkin;             //clock from k/m peripheral
    input kmidatain;            //input from k/m peripheral
    output logic kmidataout;    //output to k/m peripheral
    output logic nkmidataen;    //data enable for k/m
    output logic nkmiclken;     //not used
    
    input [7:0] pwait;          //input for wait states of memory module
    
    logic kmiintr;
    
    logic pwrite;
    logic psel1;
    logic psel2;
    logic penable;
    logic [7:0] paddr;
    logic [31:0] pwdata;
    logic pready;
    logic [31:0] prdata;

    APB_Processor processor(.clk(clk), .nreset(nreset), .kmiintr(kmiintr), 
                             .init_done(init_done), .init_data(init_data), .init_addr(init_addr),
                             .pready(pready), .pr_data(prdata), .psel1(psel1), .psel2(psel2), .penable(penable), .pwrite(pwrite), .paddr(paddr), .pw_data(pwdata));
                     
    memory_slave mem(.pclk(clk), .preset(nreset), 
                     .pwrite(pwrite), .psel(psel1), .penable(penable), .paddr(paddr), .pwdata(pwdata), .pready(pready), .prdata(prdata),
                     .pwait(pwait));

    KMI kmi(.kmiintr(kmiintr), .kmirefclk(kmirefclk), .nkmirst(nreset), 
            .kmidatain(kmidatain), .kmidataout(kmidataout), .nkmidataen(nkmidataen), .kmiclkin(kmiclkin), .nkmiclken(nkmiclken),
            .pclk(clk), .pwrite(pwrite), .psel(psel2), .penable(penable), .pready(pready), .pwdata(pwdata), .prdata(prdata));

endmodule
