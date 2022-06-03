module multiplier_nopipe 
#(
    parameter DW = 4        ,
    parameter RW = DW + DW 
)(
    input  logic              clk      ,
    input  logic              rst_n    ,
    input  logic [DW-1:0]     a        ,
    input  logic [DW-1:0]     b        ,           
    input  logic              in_vld   ,

    output logic              res_done ,
    output logic [RW-1:0]     result   
);

    localparam CNTW = $clog2(DW) ;        

    logic [CNTW-1:0]           multi_bit         ;
    logic [CNTW-1:0]           multi_bit_nxt     ;
    logic                      mul_working       ;
    logic                      mul_working_lock  ;
    logic [RW-1:0]             acc_res           ;
    logic [RW-1:0]             a_shift           ;
    logic [DW-1:0]             b_shift           ;
    logic [RW-1:0]             result_lock       ;

     
    always_ff @( posedge clk or negedge rst_n) begin
        if( !rst_n ) begin
            acc_res <= 'd0 ;
            a_shift <= RW'(a)   ;
            b_shift <= b        ;
        end
        else if(in_vld && !mul_working_lock) begin
            a_shift <= a << 1 ;
            b_shift <= b >> 1 ;
            acc_res <= b[0]? a : 'd0    ;
        end 
        else if( mul_working) begin
            a_shift <= a_shift << 1 ;
            b_shift <= b_shift >> 1 ; 
            if (b_shift[0]) begin
                acc_res <= acc_res + a_shift ;
            end
        end
    end      

    assign multi_bit_nxt   = (mul_working && multi_bit !== DW-1)? multi_bit + 1'd1 : 'd0 ;
    assign mul_working     = in_vld || mul_working_lock ;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            multi_bit        <=  'd0 ;
            mul_working_lock <= 1'b0 ;
            res_done         <= 1'b0 ;
        end  
        else if ((multi_bit == DW-1 )&& mul_working)begin
            multi_bit        <=  'd0 ;
            mul_working_lock <= 1'b0 ;
            res_done         <= 1'b1 ;
        end
        else if (in_vld) begin
            multi_bit        <= multi_bit_nxt ;
            mul_working_lock <= 1'b1 ;
            res_done         <= 1'b0 ;
        end
        else begin
            multi_bit        <= multi_bit_nxt ;
            mul_working_lock <= mul_working_lock ;
            res_done         <= 1'b0 ;
        end
    end
    
    always_ff @(posedge clk,negedge rst_n) begin
        if (!rst_n) begin
            result_lock <= 'd0 ;
        end
        else if (res_done ) begin
            result_lock <= result ;
        end
    end    
    
    assign result = res_done ? acc_res : result_lock ;  

endmodule

