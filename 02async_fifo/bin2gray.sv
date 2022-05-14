module bin2gray 
#(
    parameter WIDTH = 4 
)(
    input  logic                    clk    ,
    input  logic                    rst_n  ,
    input  logic [WIDTH-1 : 0]      bin_in ,           
    

    output logic [WIDTH-1 : 0]      gray_out  
);

    reg [WIDTH-1:0]     gray_out_nxt ;
    
    always @(*) begin
        gray_out_nxt[WIDTH-1] = bin_in[WIDTH-1] ;
        for(int i=WIDTH-2; i>=0 ; i--) begin
            gray_out_nxt[i] = bin_in[i] ^ bin_in[i+1] ;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            gray_out <= 'b0;
        else 
            gray_out <= gray_out_nxt ;
    end

endmodule



