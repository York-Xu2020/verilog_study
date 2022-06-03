module multiplier_pipe_cell 
#(
    parameter DW = 4        ,
    parameter RW = DW + DW 
)(
    input  logic              clk           ,
    input  logic              rst_n         ,
    input  logic              pipe_en       , //electrical level
    input  logic [RW-1:0]     a             , //multiplicant
    input  logic [DW-1:0]     b             , //multiplier relevant          
    input  logic [RW-1:0]     acc_in        ,
    input  logic              in_vld        ,

    output logic              done          ,
    output logic [RW-1:0]     a_shift       ,
    output logic [DW-1:0]     b_shift       ,
    output logic [RW-1:0]     acc_out   
);

    logic [DW-1:0] pipe_exit_dly ;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pipe_exit_dly <= DW'(0) ;
        end
        else if (pipe_en && in_vld) begin
            pipe_exit_dly <= DW'(1) ;
        end
        else if (!pipe_en && |pipe_exit_dly) begin
            pipe_exit_dly <= {pipe_exit_dly[DW-2:0],1'b0};
        end
    end


    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            a_shift <=  'd0 ;
            b_shift <= 1'b0 ;
            acc_out <=  'd0 ;
        end
        else if (pipe_en && in_vld || (|pipe_exit_dly)) begin
            a_shift <= (RW'(a) << 1) ;
            b_shift <= (    b  >> 1) ;
            acc_out <= b[0] ? acc_in + RW'(a) : acc_in ;
        end
        else begin
               a_shift <=  'd0 ;
               b_shift <= 1'b0 ;
               acc_out <=  'd0 ;
        end
    end


    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'b0 ;
        end
        else if (pipe_exit_dly[DW-1])begin
            done <= 1'b1 ;
        end
    end    

endmodule
