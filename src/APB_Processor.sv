`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 04:42:16 PM
// Design Name: 
// Module Name: APB_Processor
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


module APB_Processor(clk, nreset, kmiintr, 
                     init_done, init_data, init_addr,
                     pready, pr_data, psel1, psel2, penable, pwrite, paddr, pw_data);
    
    input clk;
    input nreset;
    input kmiintr;
    
    input init_done;
    input [15:0] init_data;
    input [15:0] init_addr;

    //apb bus inputs/outputs
    input pready;
    input [15:0] pr_data;
    output logic psel1;             //to select kmi peripheral
    output logic psel2;             //to select external memory peripheral
    output logic penable;
    output logic pwrite;
    output logic [7:0] paddr;
    output logic [15:0] pw_data;

    //alu/processor wires
    logic alu_enable;
    logic alu_control;
    logic [15:0] A;
    logic [15:0] B;
    logic [15:0] alu_output;
    
    //apb master/processor wires
    logic wr_en;                    //flag indicating pwrite operation
    logic [8:0] wr_addr;            //write address; wr_addr[8] indicates peripheral; 1 for psel2, 0 for psel1
    logic [15:0] wr_data;           //write data
    logic wr_done;                  //flag to processor when write is done
    logic rd_en;                    //request to read data from processor
    logic [8:0] rd_addr;            //address to read from
    logic rd_done;                  //flag from processor when data has been read
    logic [15:0] rd_data;           //data sent to processor

    alu alu(.clk(clk), .nreset(nreset), .alu_enable(alu_enable), .alu_control(alu_control), .A(A), .B(B), .alu_output(alu_output));
    
    master mst(.pclk(clk), .presetn(nreset), 
               .pready(pready), .pr_data(pr_data), .psel1(psel1), .psel2(psel2), .penable(penable), .pwrite(pwrite), .paddr(paddr), .pw_data(pw_data), 
               .wr_en(wr_en), .wr_addr(wr_addr), .wr_data(wr_data), .wr_done(wr_done), 
               .rd_en(rd_en), .rd_addr(rd_addr), .rd_done(rd_done), .rd_data(rd_data));
           
    processor prc(.nreset(nreset), .clk(clk), 
                  .init_done(init_done), .init_data(init_data), .init_addr(init_addr), 
                  .wr_data(wr_data), .wr_en(wr_en), .wr_addr(wr_addr), .wr_done(wr_done), 
                   .rd_addr(rd_addr), .rd_en(rd_en), .rd_data(rd_data), .rd_done(rd_done), 
                   .kmiintr(kmiintr), 
                   .alu_enable(alu_enable), .alu_control(alu_control), .A(A), .B(B), .alu_output(alu_output));

endmodule
