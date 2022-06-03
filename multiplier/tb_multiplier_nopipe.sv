//`timescale 1ns/100ps
module tb();


logic          clk ;
logic          reset;
logic[3:0]     a      ;
logic[3:0]     b      ;
logic          in_vld ;
logic[7:0]     result ;
logic          res_done;


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
    a      <= 0;
    b      <= 0;
    in_vld <= 0;
    repeat(5) @(posedge clk) ;
    for (int i=0;i<31;i++) begin
       repeat($urandom_range(4,10)) @(posedge clk);  
         a <= $urandom()   ;
         b <= $urandom()   ;
         in_vld <= 1'b1 ;
       @(posedge clk) 
         in_vld <= 1'b0 ;
    end
end

//checker
logic [3:0] buffer_a , buffer_b ;
logic [7:0] product_ref ;

always @(posedge clk ) begin
    if (in_vld) begin
        buffer_a <= a ;
        buffer_b <= b ;
    end
end

always @(posedge clk) begin
    product_ref <= buffer_a * buffer_b ;
    if (res_done) begin
        if (result !== product_ref) begin
            $display("ERROR @%t,reference result is %d,but RTL is %d",$time,product_ref,result) ;
        end
    end
end



//multiplier_nopipe U_TB(clk,reset,a,b,in_vld,res_done, result);
multiplier_nopipe_one_cycle U_TB(clk,reset,a,b,result);


initial begin
$fsdbDumpfile("study.fsdb");
$fsdbDumpvars(0);
$fsdbDumpMDA();
end

endmodule

