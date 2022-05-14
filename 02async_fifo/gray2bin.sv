module gray2bin 
#(
    parameter WIDTH = 4 
)(
    input  logic [WIDTH-1 : 0]      gray_in ,           


    output logic [WIDTH-1 : 0]      bin_out  
);

    always @(*) begin
        bin_out[WIDTH-1] = gray_in[WIDTH-1] ;
        for (int i=WIDTH-2; i>=0; i--) begin
            bin_out[i] = gray_in[i] ^ bin_out[i+1] ;
        end
    end

endmodule



