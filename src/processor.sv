`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2021 06:35:09 PM
// Design Name: 
// Module Name: processor
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


module processor(nreset, clk, 
                 init_done, init_data, init_addr, 
                 wr_data, wr_en, wr_addr, wr_done, 
                 rd_addr, rd_en, rd_data, rd_done, 
                 kmiintr, 
                 alu_enable, alu_control, A, B, alu_output);

    //ADD:      0000 xxxxxxxxxxxxx;                             A = A+B
    //SUB:      0001 xxxxxxxxxxxxx;                             A = A-B
    //MOVE:     0010 [-12 bit destination-];                    stack[dest] = stack[src]
    //          [------16 bit source------];
    //MOVEIM:   0011 [-12 bit destination-];                    stack[dest] = data
    //          [-------16 bit data-------];
    //LOAD:     0100 [--------12 bit dest addr----------];      stack[dest] = memory[src]
    //          xxxxxxx [1 bit selector] [8 bit src addr];
    //STORE:    0101 xxx [1 bit selector] [8 bit dest addr];    memory[dest] = stack[src]
    //          [--------------16 bit src addr------------];
    //JUMP:     0110 [-12 bit dest addr-];                      pc = dest
    //JEZ:      0111 [-12 bit dest addr-];                      if(A == 0) pc = dest
    //HALT:     1000 xxxxxxxxxxxxx;                             Halt processor operation

    input nreset;                   //reset     
    input clk;                      //processor clock
    
    //initialization signals
    input init_done;                //initializing stack program; set HIGH to move out of initialization
    input [15:0] init_data;                //data to initialize at init_addr
    input [15:0] init_addr;                //address to initiaze data to
    
    //pwrite to/from apb master
    output logic [15:0] wr_data;    //data to write
    output logic wr_en;             //write enable
    output logic [8:0] wr_addr;     //address to write to, if wr_addr[7] is 0, write to psel1, if wr_addr[7] is high, write to psel2
    input wr_done;                  //flag from master indicating pwrite is complete
    
    //pread to/from apb master
    output logic [8:0] rd_addr;           //address to read from
    output logic rd_en;             //read enable
    input [15:0] rd_data;           //data read from apb master
    input rd_done;                  //flag from master indicating pread is complete
    
    //do I need an alu?
    //alu inputs/outputs
    output logic alu_enable;        //enables alu
    output logic alu_control;       //indicates alu operation; 0 for ADD, 1 for SUB
    output logic [15:0] A;          //data register A
    output logic [15:0] B;          //data register B
    input [15:0] alu_output;        //output from alu operation
    
    input kmiintr;                  //kmi interrupt signal, from kmi peripheral
    
    logic [15:0] pc;                //program counter; stores next instruction address
    logic [15:0] ir;                //instruction register; stores current instruction
    logic [15:0] mar;               //memory address register
    logic [15:0] mdr;               //memory data register
    
    logic [15:0] next_pc;           //intermediary for pc
    logic [15:0] next_ir;           //intermediary for ir
    logic [15:0] next_mar;          //intermediary for mar
    logic [15:0] next_mdr;          //intermediary for mdr
     
    logic [15:0] stack[0:255];      //stack
                                    //stack[0x00] = register A
                                    //stack[0x01] = register B
                                    //stack[0x02] = kmi data register
                                    //stack[0x20] = start of program

    enum logic [4:0]{
        INIT =      5'b00000, 
        INTERRUPT = 5'b00001, 
        FETCH1 =    5'b00010, 
        FETCH2 =    5'b00011, 
        FETCH3 =    5'b00100,
        EXECUTE =   5'b00101, 
        KMIRX =     5'b00110, 
        MOVE1 =     5'b00111,
        MOVE2 =     5'b01000,
        MOVE3 =     5'b01001,
        MOVE4 =     5'b01010,
        MOVE5 =     5'b01011,
        MOVEIM1 =   5'b01100,
        MOVEIM2 =   5'b01101,
        LOAD =      5'b01110,
        STORE =     5'b01111,
        HALT =      5'b10000,
        ALU =       5'b10001
    } state, next_state;
    
    assign A = stack[0];           //assign A output to A register
    assign B = stack[1];           //assign B output to B register
    
    always_ff @(posedge clk)
        if(!nreset) begin
            state <= INIT;          //reset state back to initialization
            pc <= 16'h0020;
            next_pc <= 16'h0020;
            stack[0] <= 16'h0000;
            stack[1] <= 16'h0000;
            stack[2'b10] <= 16'h0000;
        end
        else begin
            state <= next_state;
            pc <= next_pc;
            ir <= next_ir;
            mar <= next_mar;
            mdr <= next_mdr;
        end
    always_comb
        case(state)
            INIT: 
                if(init_done)
                    next_state = INTERRUPT;
                else begin
                    stack[init_addr] = init_data;
                    next_state = INIT;
                end
            INTERRUPT: begin
                wr_en = 0;
                rd_en = 0;
                alu_enable = 0;
                if(kmiintr == 1)
                    next_state = KMIRX;
                else
                    next_state = FETCH1;
            end
            FETCH1: begin
                next_mar = pc;
                next_pc = pc + 1;
                next_state = FETCH2;    
            end
            FETCH2: begin
                next_mdr = stack[mar];
                next_state = FETCH3;
            end
            FETCH3: begin
                next_ir = mdr;
                next_mar = pc;
                next_state = EXECUTE;
            end   
            EXECUTE:
                case(ir[15:12])
                    4'b0000: begin                       //add; A = A+B
                        alu_enable = 1;
                        alu_control = 0;
                        next_state = ALU;
                    end
                    4'b0001: begin                       //sub; A = A-B
                        alu_enable = 1;
                        alu_control = 1; 
                        next_state = ALU;
                    end
                    4'b0010: next_state = MOVE1;         //move
                    4'b0011: next_state = MOVEIM1;       //moveIm
                    4'b0100: begin                       //load
                        rd_en = 1;
                        rd_addr = stack[mar[8:0]];
                        next_mar = {4'b0000, ir[11:0]};
                        next_pc = pc+1;
                        next_state = LOAD;
                    end    
                    4'b0101: begin                       //store
                        wr_en = 1;
                        wr_data = stack[stack[mar]];
                        wr_addr = ir[8:0];
                        next_pc = pc+1;
                        next_state = STORE;
                    end    
                    4'b0110: begin                       //jump
                        next_pc = {4'b0000, ir[11:0]};
                        next_state = INTERRUPT;
                    end
                    4'b0111: begin                       //jump if A == 0
                        if(stack[0] == 0) 
                            next_pc = {4'b0000, ir[11:0]};
                        next_state = INTERRUPT;
                    end
                    4'b1000: 
                        next_state = HALT;
                endcase
            ALU: begin
                stack[0] = alu_output;
                next_state = INTERRUPT;
            end
            MOVE1: begin
                next_mdr = stack[mar];
                next_pc = pc+1;                 
                next_state = MOVE2;
            end
            MOVE2: begin
                next_mar = mdr;
                next_state = MOVE3;
            end
            MOVE3: begin
                next_mdr = stack[mar];
                next_mar = {4'b0000, ir[11:0]};
                next_state = MOVE4;
            end 
            MOVE4: begin
                stack[mar] = mdr;
                next_state = INTERRUPT;
            end    
            MOVEIM1: begin
                next_mdr = stack[mar];
                next_mar = {4'b0000, ir[11:0]};
                next_pc = pc+1; 
                next_state = MOVEIM2;
            end
            MOVEIM2: begin
                stack[mar] = mdr;                     
                next_state = INTERRUPT;
            end
            KMIRX: begin
                rd_en = 1;
                rd_addr = 9'b100000000;                  //indicate to apb master psel2
                next_mar = 16'b0000000000000010;         //write kmi data into 0x0002
                next_state = LOAD;
            end
            LOAD:
                if(rd_done) begin
                    rd_en = 0;
                    stack[mar] = rd_data;
                    next_state = INTERRUPT; 
                end    
                else
                    next_state = LOAD;
            STORE:
                if(wr_done) begin
                    wr_en = 0;
                    next_state = INTERRUPT; 
                end
                else
                    next_state = STORE;
            HALT:
                next_state = HALT;
            default: next_state = INIT;
        endcase

endmodule
