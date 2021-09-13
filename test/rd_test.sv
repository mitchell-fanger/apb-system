`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2021 09:29:08 PM
// Design Name: 
// Module Name: rd_test
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

class transaction;
  //declaring the transaction items
  rand bit       kmidatain;
       bit [15:0] init_addr;
  rand bit [15:0] init_data;
       bit  kmidataout;
  
  constraint addr1 { init_addr <= init_addr+1; };
  
  //postrandomize function, displaying randomized values of items 
  function void post_randomize();
    $display("--------- [Trans] post_randomize ------");
    //$display("\t addr  = %0h",addr);
    $display("\t kmidata  = %0h",this.kmidatain);
    $display("-----------------------------------------");
  endfunction

endclass

class generator;
  
  //declaring transaction class 
  rand transaction trans,tr;
  
  //repeat count, to specify number of items to generate
  int  repeat_count;
  
  //mailbox, to generate and send the packet to driver
  mailbox gen2driv;
  
  //event
  event ended;
  
  //constructor
  function new(mailbox gen2driv,event ended);
    //getting the mailbox handle from env, in order to share the transaction packet between the generator and driver, the same mailbox is shared between both.
    this.gen2driv = gen2driv;
    this.ended    = ended;
    trans = new();
  endfunction
  
  //main task, generates(create and randomizes) the repeat_count number of transaction packets and puts into mailbox
  task main();
    repeat(repeat_count) begin
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");      
    gen2driv.put(tr);
    end
    -> ended; 
  endtask
  
endclass
interface apb_intf(input logic clk,nreset, kmirefclk, kmiclkin);
  
  //declaring the signals
  logic init_done;
    logic [15:0] init_data;
    logic [15:0] init_addr;
    
    logic kmidatain;
    logic kmidataout;
    logic nkmidataen;
    logic nkmiclken;
    
    logic [7:0] pwait;
  
  //driver clocking block
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    output init_done;
    output init_data;
    output init_addr;
    
    output kmidatain;
    input kmidataout;
    input nkmidataen;
    input nkmiclken;
    
    output pwait; 
  endclocking
  
  //monitor clocking block
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input init_done;
    input init_data;
    input init_addr;
    
    input kmidatain;
    input kmidataout;
    input nkmidataen;
    input nkmiclken;
    
    input pwait;  
  endclocking
  
  //driver modport
  modport DRIVER  (clocking driver_cb,input clk,nreset, kmirefclk, kmiclkin);
  
  //monitor modport  
  modport MONITOR (clocking monitor_cb,input clk,nreset, kmirefclk, kmiclkin);
  
endinterface

`define DRIV_IF apb_vif.DRIVER.driver_cb
class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual apb_intf apb_vif;
  
  //creating mailbox handle
  mailbox gen2driv;
  
  //constructor
  function new(virtual apb_intf apb_vif,mailbox gen2driv);
    //getting the interface
    this.apb_vif = apb_vif;
    //getting the mailbox handles from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(apb_vif.nreset);
    $display("--------- [DRIVER] Reset Started ---------");

    `DRIV_IF.kmidatain <= 1;
    `DRIV_IF.init_done <= 0;
    `DRIV_IF.init_addr <= 16'h0020;
    `DRIV_IF.init_data <= 16'h0000;
    `DRIV_IF.pwait <= 8'b00001010;
           
    wait(!apb_vif.nreset);
    $display("--------- [DRIVER] Reset Ended ---------");
  endtask
  
  //drivers the transaction items to interface signals
  task drive;
      transaction trans;
      `DRIV_IF.kmidatain <= 0;
      gen2driv.get(trans);
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
      @(posedge apb_vif.DRIVER.clk);
        `DRIV_IF.init_addr <= trans.init_addr;
        `DRIV_IF.init_data <= trans.init_data;
        `DRIV_IF.kmidatain <= trans.kmidatain;
        trans.kmidataout = `DRIV_IF.kmidataout;
        $display("\tkmidatain = %0h \tkmidataout = %0h",trans.kmidatain,`DRIV_IF.kmidataout);
      $display("-----------------------------------------");
      no_transactions++;
  endtask
  
    
  //
  task main;
    forever begin
      fork
        //Thread-1: Waiting for reset
        begin
          wait(apb_vif.nreset);
        end
        //Thread-2: Calling drive task
        begin
          forever
            drive();
        end
      join_any
      disable fork;
    end
  endtask
        
endclass

`define MON_IF apb_vif.MONITOR.monitor_cb
class monitor;
  
  //creating virtual interface handle
  virtual apb_intf apb_vif;
  
  //creating mailbox handle
  mailbox mon2scb;
  
  //constructor
  function new(virtual apb_intf mem_vif,mailbox mon2scb);
    //getting the interface
    this.apb_vif = apb_vif;
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
  task main;
    forever begin
      transaction trans;
      trans = new();

      @(posedge apb_vif.MONITOR.clk);
        trans.kmidatain  = `MON_IF.kmidatain;
        trans.kmidataout = `MON_IF.kmidataout;
        trans.init_addr = `MON_IF.init_addr;
        trans.init_data = `MON_IF.init_data;
          @(posedge apb_vif.MONITOR.clk);
          @(posedge apb_vif.MONITOR.clk);     
        mon2scb.put(trans);
    end
  endtask
  
endclass

class scoreboard;
   
  //creating mailbox handle
  mailbox mon2scb;
  
  //used to count the number of transactions
  int no_transactions;
  
  //array to use as local memory
  logic [15:0] stack[0:255];
  
  //constructor
  function new(mailbox mon2scb);
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
    foreach(stack[i]) stack[i] = 16'hFFFF;
  endfunction
  
  //stores wdata and compare rdata with stored data
  task main;
    transaction trans;
    forever begin
      #50;
      mon2scb.get(trans);
//      case(trans.init_data[15:12])
        
//      endcase
      $display(" Data :: DataIn = %0h DataOut = %0h",trans.kmidatain,,trans.kmidataout);

      no_transactions++;
    end
  endtask
  
endclass

class environment;
  
  //generator and driver instance
  generator  gen;
  driver     driv;
  monitor    mon;
  scoreboard scb;
  
  //mailbox handle's
  mailbox gen2driv;
  mailbox mon2scb;
  
  //event for synchronization between generator and test
  event gen_ended;
  
  //virtual interface
  virtual apb_intf apb_vif;
  
  //constructor
  function new(virtual apb_intf apb_vif);
    //get the interface from test
    this.apb_vif = apb_vif;
    
    //creating the mailbox (Same handle will be shared across generator and driver)
    gen2driv = new();
    mon2scb  = new();
    
    //creating generator and driver
    gen  = new(gen2driv,gen_ended);
    driv = new(apb_vif,gen2driv);
    mon  = new(apb_vif,mon2scb);
    scb  = new(mon2scb);
  endfunction
  
  //
  task pre_test();
    driv.reset();
  endtask
  
  task test();
    fork 
    gen.main();
    driv.main();
    mon.main();
    scb.main();      
    join_any
  endtask
  
  task post_test();
    wait(gen_ended.triggered);
    wait(gen.repeat_count == driv.no_transactions);
    wait(gen.repeat_count == scb.no_transactions);
  endtask  
  
  //run task
  task run;
    pre_test();
    test();
    post_test();
    $finish;
  endtask
  
endclass

program test(apb_intf intf);
    
  //declaring environment instance
  environment env;
  
  initial begin
    //creating environment
    env = new(intf);
    
    //setting the repeat count of generator as 4, means to generate 4 packets
    env.gen.repeat_count = 10;
    
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
  end
endprogram

module rd_test();
  
  //clock and reset signal declaration
  bit clk;
  bit kmirefclk;
  bit kmiclkin;
  bit nreset;
  
  //clock generation
  always
        #1 clk = ~clk;
        
    always
        #4 kmirefclk = ~kmirefclk;
        
    always
        #2048 kmiclkin = ~kmiclkin;
  
  //reset Generation
  initial begin
        #5
        nreset = 0;
        #25
        nreset = 1;
  end
  
  
  //creatinng instance of interface, inorder to connect DUT and testcase
  apb_intf intf(clk,nreset,kmirefclk, kmiclkin);
  
  //Testcase instance, interface handle is passed to test as an argument
  test t1(intf);
  
  //DUT instance, interface signals are connected to the DUT ports
  APB_System DUT (
    .clk(intf.clk),
    .nreset(intf.nreset),
    .init_done(intf.init_done),
    .init_data(intf.init_data),
    .init_addr(intf.init_addr),
    .kmirefclk(intf.kmirefclk),
    .kmiclkin(intf.kmiclkin),
    .kmidatain(intf.kmidatain),
    .kmidataout(intf.kmidataout),
    .nkmidataen(intf.nkmidataen),
    .nkmiclken(intf.nkmiclken),
    .pwait(intf.pwait)
   );
  
  //enabling the wave dump
//  initial begin 
//    $dumpfile("dump.vcd"); $dumpvars;
//  end
endmodule

