//`timescale 1ns/100ps
module tb();
parameter DN = 4 ;
parameter DW = 4 ;

logic             clk ;
logic             reset;
logic[DN-1:0]       [DW-1:0]     data_in ;
logic[DN-1:0]       [DW-1:0]     data_o ;



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
   // data_in = {1,2,3,4} ;
   // #30;data_in = {4,3,2,1} ;
        repeat(50) begin
            @(posedge clk);
            if(!reset) 
                data_in <= {'0,'0,'0,'0};
            else begin
                for(int i=0; i<DN; i++) begin
                    data_in[i] <= $urandom(); 
                end
            end
        end
end
bubble_sort #(
                .DATA_W (DW),
                .DATA_N (DN)
            )U_TB(.clk       (clk           ),
                 .rst_n      (reset         ),
                
                 .data_in    (data_in       ),
                 .data_o     (data_o)
                );


initial begin
$fsdbDumpfile("sim.fsdb");
$fsdbDumpvars(0);
$fsdbDumpMDA();
end

endmodule

