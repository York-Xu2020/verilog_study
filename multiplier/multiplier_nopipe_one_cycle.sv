module multiplier_nopipe_one_cycle 
#(
    parameter DW = 4        ,
    parameter RW = DW + DW 
)(
    input  logic              clk      ,
    input  logic              rst_n    ,
    input  logic [DW-1:0]     a        ,
    input  logic [DW-1:0]     b        ,           
   // input  logic              in_vld   ,

   // output logic              res_done ,
    output logic [RW-1:0]     result   
);

    always @(*) begin
            result = (b[0] ? RW'(a)      : 'b0 )
                   + (b[1] ? RW'(a) << 1 : 'b0 )
                   + (b[2] ? RW'(a) << 2 : 'b0 )
                   + (b[3] ? RW'(a) << 3 : 'b0 ) ;
    end


endmodule         
