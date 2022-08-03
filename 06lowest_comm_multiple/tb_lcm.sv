//`timescale 1ns/100ps
module tb();
//parameter DN = 4 ;
parameter DW = 8 ;

logic             clk ;
logic             reset;
logic [DW-1:0]     data_a ;
logic [DW-1:0]     data_b ;
logic [DW-1:0]     data_o1 ;
logic [DW-1:0]     data_o2 ;



parameter T_HF = 0.5;
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
    repeat(50) begin
        @(posedge clk);
        if(!reset) begin
            data_a <= '0;
            data_b <= '0;
        end 
        else begin
            for(int i=0; i<10; i++) begin
                data_a <= $urandom_range(1,2**DW-1); 
                data_b <= $urandom_range(1,2**DW-1); 
            end
        end
    end
    
    repeat(20) @(posedge clk) ;
    data_a <= 'd36;
    data_b <= 'd24;

end

     lcm      #(
                .DW (DW)
             )U_TB(
                 .clk        (clk           ),
                 .rst_n      (reset         ),
                
                 .data_a     (data_a        ),
                 .data_b     (data_b        ),
                 .lcm_o      (data_o2       ),
                 .gcd_o      (data_o1       )
                );


initial begin
$fsdbDumpfile("sim.fsdb");
$fsdbDumpvars(0);
$fsdbDumpMDA(); //dump array
end

endmodule

