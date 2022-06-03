module multiplier_pipe_top 
#(
    parameter DW = 4 ,
    parameter RW = DW + DW  
)(
    input  logic              clk      ,
    input  logic              rst_n    ,
    input  logic[DW-1:0]      a        ,    
    input  logic[DW-1:0]      b        ,
    input  logic              in_vld   ,
    input  logic              mul_start, //pulse            
    input  logic              mul_stop , //pulse

    output logic[RW-1:0]      result   ,
    output logic              pipe_done
);

    logic          done   [DW-1:0]  ;
    logic [RW-1:0] acc_out[DW-1:0]  ;
    logic [RW-1:0] a_shift[DW-1:0]  ;
    logic [DW-1:0] b_shift[DW-1:0]  ;
    logic          pipe_en          ;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            pipe_en <= 1'b0 ;
        end
        else if (mul_start) begin
            pipe_en <= 1'b1 ;
        end
        else if (mul_stop) begin
            pipe_en <= 1'b0 ;
        end
    end

    genvar gi ;

    generate 
        for (gi=0; gi<DW; gi++ ) begin:MUL_PIPE_LEVEL
            multiplier_pipe_cell #(.DW(DW),.RW(RW))
            U_MUL (
                    .clk      (clk     ) ,
                    .rst_n    (rst_n   ) ,
                    .pipe_en  (pipe_en ) ,
                    .a        (gi? a_shift[gi-1] : RW'(a)) ,
                    .b        (gi? b_shift[gi-1] :     b ) ,
                    .acc_in   (gi? acc_out[gi-1] :   'd0 ) ,
                    .in_vld   (in_vld  ) ,
                    .done     (done[gi]) ,
                    .a_shift  (a_shift[gi]),
                    .b_shift  (b_shift[gi]),
                    .acc_out  (acc_out[gi])
                    );
        end   
    endgenerate

    assign result    = acc_out[3] ;
    assign pipe_done = done[3]    ; 

endmodule

