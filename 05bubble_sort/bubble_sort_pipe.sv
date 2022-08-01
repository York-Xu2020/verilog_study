//-------------------------------\
// bubble sort for pipeline
// 2022/08/01
//-------------------------------\

module bubble_sort 
#(
    parameter DATA_N = 4 ,
    parameter DATA_W = 4 ,
    parameter PIPE_EN= 1 
)(
    input  logic              clk                    ,
    input  logic              rst_n                  ,

    input  logic[DATA_N-1:0]    [DATA_W-1:0]data_in  ,
    
    output logic[DATA_N-1:0]    [DATA_W-1:0]data_o

);

    genvar gi;
    generate 
        //DATA_N data_in will compare DATA_N-1 rounds  , 
        //And in one round,there need DATA_N-1 compares ,    
        //So, cmp and tmp we just need DATA_N-1 bit is enough. 
        logic[DATA_N-2:0][DATA_N-1:0]    [DATA_W-1:0]cmp;  //input data for 2-in comparing unit
        logic[DATA_N-2:0]                [DATA_W-1:0]tmp;  //temporary variable 
        logic[DATA_N-1:0][DATA_N-1:0]    [DATA_W-1:0]res,res_r; //combinational result of comparing,
                                                                //_r means inserted register's output 
       
        for(gi=0; gi<DATA_N-1; gi++) begin :GEN_LEV
            if(PIPE_EN) begin  
             //Insert registers for pipeline
              always_ff @(posedge clk, negedge rst_n) begin
                    if(!rst_n) begin
                        res_r[gi] <= 'b0 ;
                    end
                    else begin
                        res_r[gi] <= res[gi] ;
                    end
                end
            end
            else begin
             //Combinational connectiong without pipiline
              assign res_r[gi] = res[gi] ; 
            end
             //Combinational bubble  
            always_comb begin
                cmp[gi] = gi==0? data_in : res_r[gi-1];
                for(int i=0; i<DATA_N-1-gi; i++) begin
                    if(cmp[gi][i+1] > cmp[gi][i]) begin
                        tmp[gi]      = cmp[gi][i]   ;
                        cmp[gi][i]   = cmp[gi][i+1] ;
                        cmp[gi][i+1] = tmp[gi]      ;
                    end        
                end
                res[gi] = cmp[gi] ;
            end
            
        end
        
    endgenerate

    assign data_o = res[DATA_N-2] ;




endmodule

