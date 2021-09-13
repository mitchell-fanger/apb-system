`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2021 04:53:31 PM
// Design Name: 
// Module Name: KMI
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


module KMI(kmiintr, kmirefclk, nkmirst, kmidatain, kmidataout, nkmidataen, kmiclkin, nkmiclken,
           pclk, pwrite, psel, penable, pready, pwdata, prdata);
    
    input pclk;
    input pwrite;
    input psel;
    input penable;   
    input [7:0] pwdata;
    output [7:0] prdata;
    output pready;
           
    //interrupt signal
    output kmiintr;             //indicates to processor when data is ready to be received
                                
    //clock and reset inputs
    input kmirefclk;
    input nkmirst;
    
    //km inputs/outputs
    input kmiclkin;             
    input kmidatain;          
    output kmidataout;
    
    //control signals
    output nkmidataen;          //indicates when transmitting serial data across kmidatain
    output nkmiclken;           //when should I set this?
    
    logic [7:0] rx_data;
    logic [7:0] tx_data;
    logic rx_done;
    logic tx_done;
    logic transmit_slv_cnt;
    logic transmit_cnt_trn;
    logic receive_cnt_slv;
    logic receive_rcv_cnt;
    logic received_cnt_rcv;
    
    Slave slv(.pclk(pclk), .ref_clk(kmirefclk), .npreset(nkmirst), .pwrite(pwrite), .psel(psel), .penable(penable), 
              .pready(pready), .pwdata(pwdata), .prdata(prdata), 
              .rx_data(rx_data), .receive(receive_cnt_slv), .transmit(transmit), .tx_data(tx_data), .tx_done(tx_done), .rx_done(rx_done), .rx_interrupt(kmiintr));
    
    Controller cnt(.ref_clk(kmirefclk), .nreset(nkmirst), 
                   .rx_in(receive_rcv_cnt), .tx_in(transmit), .tx_done(tx_done), .rx_done(rx_done), .rx_out(receive_cnt_slv), .tx_out(transmit_cnt_trn), .received(received_cnt_rcv));
                   
    Transmit trn(.ref_clk(kmirefclk), .nreset(nkmirst),
                 .transmit(transmit_cnt_trn), .clk_in(kmiclkin), .data_in(tx_data), .serial_out(kmidataout), .ndata_en(nkmidataen), .tx_done);
    
    Receive rcv(.ref_clk(kmirefclk), .nreset(nkmirst), 
                .receive(receive_rcv_cnt), .clk_in(kmiclkin), .data_out(rx_data), .serial_in(kmidatain), .rx_done(received_cnt_rcv));
    
    
    
endmodule
