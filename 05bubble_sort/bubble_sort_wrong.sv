module bubble_sort 
#(
    parameter DATA_N = 4 ,
    parameter DATA_W = 4  
)(
    input  logic              clk                 ,
    input  logic              rst_n               ,
    input  logic[DATA_W-1:0]  data_in[DATA_N-1:0] ,           
    input  logic              start_sort          ,

    output logic[DATA_W-1:0]  data_out
);

    reg[DATA_W-1:0]     tmp_mem[DATA_N-1:0] ;
    logic               sorting             ;
    logic               sort_done           ;


    always_ff @( posedge clk, negedge rst_n) begin
        if( !rst_n ) begin
            sorting <= 1'b0 ;    
        end
        else if (start_sort) begin
            sorting <= 1'b1 ;
        end
    end      

   // genvar gi ;
   // generate 
   //     for(int gi=0; gi<DATA_N;i++) begin: LOAD
   //         always_ff @(posedge clk) begin
   //             tmp_mem[gi] <= data_in[gi] ;
   //         end
   //     end
   // endgenerate      

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            for(int i=0;i<DATA_N;i++) begin
                tmp_mem[i] <= 'b0 ;
            end
        end
        else if(start_sort) begin
            for(int i=0;i<DATA_N;i++) begin
                tmp_mem[i] <= data_in[i] ;
            end
        end
        else if(sorting)begin
            for(int i=1; i<DATA_N; i++) begin
                for (int j=1; j<DATA_N; j++) begin
                    if(tmp_mem[j] < tmp_mem[j-1]) begin:SWAP
                        tmp_mem[j]   <= tmp_mem[j-1] ;
                        tmp_mem[j-1] <= tmp_mem[j]   ;
                    end
                end
            end
        end
    end

    assign data_out = 'd1 ;

endmodule

