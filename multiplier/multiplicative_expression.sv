// Q           =K              x  (D -16)
// unsigned     signed(1,8)        unsigned  
module multi_expression 
#(
    parameter DW1 = 8  ,
    parameter DW2 = 10 ,
    parameter RW  = 8  
)(
    input  logic signed      [DW2-1:0]  K ,           
    input  logic unsigned    [DW1-1:0]  D ,

    output logic unsigned    [RW-1 :0]  Q   
);

  
    localparam KDW = DW1 + DW2 + 1  ;

    logic signed[DW1:0]    d_sub_16    ; //9bit  , signed
    logic signed[KDW-1:0]  k_mul       ; //19bit , signed
    logic                  decimal_carry_in ;

    assign d_sub_16 = $signed(D) - $signed(8'd16) ;
    assign k_mul    = K * d_sub_16 ;
    assign decimal_carry_in = $unsigned({k_mul[7:0]}) > 4 ? 1'b1 : 1'b0 ; 
    
    assign Q = k_mul[15:8] + (RW)'(decimal_carry_in) ;

    logic overflow ;
    logic wrong    ;

    assign wrong    = |k_mul[18:16] ; //result is negetive or big enough ;
    assign overflow = &k_mul[15:8] & decimal_carry_in ;    
    


endmodule   
