module tb();

reg          clk ;
reg          reset;

wire         clk_3p5 ;

parameter T_HF = 10;
parameter T_CLK = 2 * T_HF;

//generate clk

initial begin
   clk = 1'b0 ;
  forever begin
   # T_CLK clk = ~ clk ;
end
end

//generate reset

initial begin
   reset = 1 ;
          @(posedge clk) #1 ;
           reset = 1'b0 ;
   # T_CLK reset = 1'b1 ;  //low reset

//  #(1000*T_CLK) reset = 1'b0 ; // hign reset 
end

//input

  initial  begin
    
   #(500*T_CLK)  $finish;
  end


div_freq_decimal U_TB(clk,reset,clk_3p5);

initial begin
$fsdbDumpfile("study.fsdb");
$fsdbDumpvars(0);
$fsdbDumpMDA();
end

endmodule

