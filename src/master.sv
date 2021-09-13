`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2021 08:12:25 PM
// Design Name: 
// Module Name: master
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


module master(pclk, presetn, pready, 
              pr_data, psel1, psel2, penable, pwrite, paddr, pw_data, 
              wr_en, wr_addr, wr_data, wr_done, rd_en, rd_addr, rd_done, rd_data);
    //input: wr_data, wr_en, wr_address
    //output to peripherals: psel1, psel2, penable, paddr, pwdata, pwrite
    //output to processor: prdata, pr_done
    
    input pclk;
    input presetn;
    input pready;
    input [7:0] pr_data;
    
    //outputs to peripherals
    output logic psel1;             //to select kmi peripheral
    output logic psel2;             //to select external memory peripheral
    output logic penable;
    output logic pwrite;
    output logic [7:0] paddr;
    output logic [7:0] pw_data;
    
    //write signals to/from processor
    input wr_en;                    //flag indicating pwrite operation
    input [8:0] wr_addr;             //write address; wr_addr[8] indicates peripheral; 1 for psel2, 0 for psel1
    input [15:0] wr_data;           //write data
    output logic wr_done;           //flag to processor when write is done
    
    //read signals to/from processor
    input rd_en;                    //request to read data from processor
    input [8:0] rd_addr;                  //address to read from
    output logic rd_done;                  //flag from processor when data has been read
    output logic [15:0] rd_data;   //data sent to processor
    
    logic next_rd_done;
    logic next_wr_done;
    
    enum logic [2:0] { 
        IDLE = 2'b00, 
        SETUP = 2'b01, 
        ACCESS=2'b10
    } state, next_state;
       
    always_ff @(posedge pclk) begin
        if(!presetn)
            state<=IDLE;
        else begin
            state <=next_state;  
            rd_done <= next_rd_done;
            wr_done <= next_wr_done;
        end    
    end
    
    always_comb 
        case(state)
            IDLE: begin
                psel1 = 0;
                psel2 = 0;
                penable=0;
                if(rd_en | wr_en) begin
                    next_state = SETUP;
                    next_rd_done = 0;
                    next_wr_done = 0;
                end
                else
                    next_state = IDLE;
            end
            
            SETUP: begin
                if(rd_en) begin
                    pwrite = 0;
                    paddr = rd_addr[7:0];
                    if(rd_addr[8])
                        psel2 = 1;
                    else
                        psel1 = 1;
                end
                else begin
                    pwrite = 1;
                    paddr = wr_addr[7:0];
                    pw_data = wr_data;
                    if(wr_addr[8])
                        psel2 = 1;
                    else
                        psel1 = 1;
                end
                next_state = ACCESS;
            end
            
            ACCESS: begin
                penable = 1;
                if(pready) begin
                    if(rd_en) begin
                        next_rd_done = 1;
                        rd_data = {8'b00000000, pr_data};
                    end
                    else
                        next_wr_done = 1;
                    next_state = IDLE;
                end
                else
                    next_state = ACCESS;
            end
            default: begin 
                next_state = IDLE;
                psel1 = 0; 
                psel2 = 0;
                penable = 0;
                next_rd_done = 0;
                next_wr_done = 0;
            end
        
        endcase     
     
endmodule
