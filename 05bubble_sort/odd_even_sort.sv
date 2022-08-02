module odd_even_sort 
#(
    parameter DATA_N = 4 ,
    parameter DATA_W = 4 ,
    parameter PIPE_EN= 1 
)( 
    input logic                          clk    ,
    input logic                          rst_n  ,

    input logic[DATA_N-1:0][DATA_W-1:0]  data_in,

    output logic[DATA_N-1:0][DATA_W-1:0] data_o
);

    localparam EVEN_N = DATA_N%2 ? (DATA_N+1)/2 : DATA_N/2 ;
    
    logic[ EVEN_N   -1:0][DATA_N-1:0][DATA_W-1:0] even_i;
    logic[ EVEN_N   -1:0][DATA_N-1:0][DATA_W-1:0] even_o;
    logic[(DATA_N/2)-1:0][DATA_N-1:0][DATA_W-1:0] odd_i ;
    logic[(DATA_N/2)-1:0][DATA_N-1:0][DATA_W-1:0] odd_o ;
    logic[ DATA_N     :0][DATA_N-1:0][DATA_W-1:0] result,result_r;


    genvar gi,gj,gk ;
    generate

        assign result[0]   = data_in ; 
        assign result_r[0] = data_in ; 
        for(gi=0; gi<DATA_N; gi++) begin:ROUND
            assign  result[gi+1] = gi%2==0 ? even_o[gi/2] : odd_o[(gi-1)/2];
        //Insert register if defined PIPELINE 
            if(PIPE_EN) begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if(!rst_n) begin
                        result_r[gi+1] <= '0 ;
                    end
                    else begin
                        result_r[gi+1] <= result[gi+1] ;
                    end
                end
            end
            else begin
                assign result_r[gi+1] = result[gi+1] ;
            end

        end

        for(gj=0; gj<DATA_N; gj=gj+2) begin:EVEN_I
            assign even_i[gj/2] = result_r[gj] ;
            always_comb begin
                even_o[gj/2] = result_r[gj] ;
                for(int i=0; i<DATA_N-1; i=i+2) begin
                    even_o[gj/2][i]      = even_i[gj/2][i+1] > even_i[gj/2][i]? result_r[gj][i+1] : result_r[gj][i  ];
                    even_o[gj/2][i+1]    = even_i[gj/2][i+1] > even_i[gj/2][i]? result_r[gj][i  ] : result_r[gj][i+1];
                end
            end
        end

        for(gk=1; gk<DATA_N; gk=gk+2) begin:ODD_I
            assign odd_i[(gk-1)/2] = result_r[gk];
            always_comb begin
                odd_o[(gk-1)/2] = result_r[gk] ;
                for(int i=1; i<DATA_N-1; i=i+2) begin
                    odd_o[(gk-1)/2][i]   = odd_i[(gk-1)/2][i+1] > odd_i[(gk-1)/2][i] ? result_r[gk][i+1] : result_r[gk][i  ]; 
                    odd_o[(gk-1)/2][i+1] = odd_i[(gk-1)/2][i+1] > odd_i[(gk-1)/2][i] ? result_r[gk][i  ] : result_r[gk][i+1]; 
                end
            end
        end

    endgenerate

    assign data_o = result_r[DATA_N] ;


endmodule

