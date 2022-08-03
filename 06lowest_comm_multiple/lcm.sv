// lcm and gcd
// lcm = A * B / gcd
// Algorithm (example):     
// A     B   
// 36    24
// 12    24
// 24    12
// 12    12
// ---->>>>>>> gcd = 12

module lcm 
#(
    parameter DW = 8 
)(
    input  logic              clk      ,
    input  logic              rst_n    ,
    input  logic[DW-1:0]      data_a   ,       
    input  logic[DW-1:0]      data_b   ,       

    output logic[DW*2-1:0]    lcm_o    ,// The lowest common multiple (min gongbeishu)
    output logic[DW-1:0]      gcd_o     // The greatest common denominator (max gongyueshu) 
);
    
    localparam DATA_MAX = 2**DW ;

    wire [DW-1:0] max_i = data_a > data_b ? data_a : data_b ;
    wire [DW-1:0] min_i = data_a > data_b ? data_b : data_a ;

    
    logic[DW-1:0] tmp ;
    logic[DW-1:0] res_a, res_b;    

    always_comb begin
        res_a = max_i;
        res_b = min_i;
        tmp   = res_a ;
        for(int i=0; i<DATA_MAX-1; i++) begin
            if(res_a > res_b) begin
                tmp   = res_a ;
                res_a = tmp - res_b ;
            end
            else if(res_a < res_b) begin
                tmp   = res_a ;
                res_a = res_b ;
                res_b = tmp   ;        
            end
            else begin
                tmp   = res_a ;
                break ;
            end
        end
    end

    assign gcd_o = tmp ;
    assign lcm_o = (data_a/gcd_o) * data_b ;

endmodule

