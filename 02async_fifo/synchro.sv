module synchro 
#(
    parameter DATA_W = 4 
)(
    input  logic              b_clk    ,
    input  logic              rst_n    ,
    input  logic [DATA_W-1:0] data_in  ,           


    output logic [DATA_W-1:0] data_out 
);

    reg [DATA_W-1:0] data_ff1;

    always @(posedge b_clk or negedge rst_n) begin
        if (!rst_n) begin
            data_ff1 <= 'b0 ;
            data_out <= 'b0 ;
        end
        else begin
            data_ff1 <= data_in  ;
            data_out <= data_ff1 ;
        end
    end

endmodule

