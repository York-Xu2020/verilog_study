//`timescale 1ns/100ps
module tb();


logic          clk ;
logic          reset;
logic[3:0]     data_in[3:0] ;
logic          sort_start ;
logic[3:0]     data_out  ;


parameter T_HF = 10;
parameter T_CLK = 2 * T_HF;

//generate clk

initial begin
   clk = 1'b0 ;
//   rd_clk = 1'b0 ;
  forever begin
   # T_HF clk = ~ clk ;
//   #T_HF_R rd_clk = ~rd_clk ;
  end
end


//generate reset

initial begin
   reset = 1 ;
          @(posedge clk) #1 ;
           reset = 1'b0 ;
   # (3*T_CLK) reset = 1'b1 ;  //low reset

//  #(1000*T_CLK) reset = 1'b0 ; // high reset 
end

//finish
initial  begin
   #(300*T_CLK)  $finish;
end

//input
initial begin
    data_in[0] = 'd5; 
    data_in[1] = 'd8; 
    data_in[2] = 'd11; 
    data_in[3] = 'd6;
    sort_start = 1'b0 ;
    repeat(8) @(posedge clk) ;
    sort_start <= 1'b1 ;
    @(posedge clk)
    sort_start <= 1'b0 ;
end

bubble_sort U_TB(clk,reset,data_in,sort_start,data_out);


initial begin
$fsdbDumpfile("sim.fsdb");
$fsdbDumpvars(0);
$fsdbDumpMDA();
end

endmodule

