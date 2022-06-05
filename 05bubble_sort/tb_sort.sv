//`timescale 1ns/100ps
module tb();
parameter DN = 4 ;
parameter DW = 4 ;

logic             clk ;
logic             reset;
logic[DW-1:0]     data_in[DN-1:0] ;

logic             sort_start ;
logic[DW-1:0]     data_out   ;
logic             out_vld    ;

//interface
sort_if    #(.DATA_N(DN),
             .DATA_W(DW)
            )  u_tb_if() ;

assign u_tb_if.data_in      = data_in;
assign u_tb_if.start_sort   = sort_start ;
assign data_out             = u_tb_if.data_out ;
assign out_vld              = u_tb_if.out_vld  ;        


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
    for(int i=0; i<DN;i++) begin
    data_in[i] = $urandom(); 
    end
    sort_start = 1'b0 ;
    repeat(8) @(posedge clk) ;
    sort_start <= 1'b1 ;
    @(posedge clk)
    sort_start <= 1'b0 ;
end

bubble_sort #(
                .DATA_W (DW),
                .DATA_N (DN)
            )U_TB(.clk       (clk           ),
                 .rst_n      (reset         ),
                
                 .bb_sort_if (u_tb_if       )
                );


initial begin
$fsdbDumpfile("sim.fsdb");
$fsdbDumpvars(0);
$fsdbDumpMDA();
end

endmodule

