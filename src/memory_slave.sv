`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2021 09:40:00 PM
// Design Name: 
// Module Name: memory_slave
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


module memory_slave(pclk, preset, pwrite, psel, penable, paddr, pwait, pwdata, pready, prdata);
    input pclk, preset, pwrite, psel, penable;
    input [7:0] paddr, pwait;
    input [7:0] pwdata;
    output logic pready;
    output logic [7:0] prdata;
    
    logic [7:0] count;
    
    logic [7:0] mem [0:255];
    
    enum logic [1:0] {
        IDLE = 2'b00,
        SETUP = 2'b01,
        ACCESS = 2'b10
    } state, next_state;
        
    always_ff @(posedge pclk)
        if(!preset)
            state <= IDLE;
        else
            state <= next_state;
    
    //counter only updates during SETUP state to simulate wait state       
    always_ff @(posedge pclk) begin
        if(!preset)
            count <= 0;
        case (state)
            SETUP:
                if(count === pwait)
                    count = 0;
                else
                    count = count+1;     
        endcase  
    end     
    
    always_comb begin
        case (state)
            IDLE: begin 
                pready = 0; 
                if(psel) 
                    next_state = SETUP; 
            end
            SETUP: 
                if(penable)
                    if(count === pwait) begin
                        pready = 1;
                        next_state = ACCESS;
                        if (pwrite) 
                            mem[paddr] <= pwdata; 
                        else 
                            prdata <= mem[paddr]; 
                    end
                    else pready = 0;
            ACCESS: begin 
                pready = 1; 
                if(!penable) 
                    next_state = IDLE; 
            end
            default: next_state = IDLE;
        endcase        
    end

endmodule
