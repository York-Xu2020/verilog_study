
module sync_fifo 
#(
    parameter F_WIDTH  = 32 ,
    parameter F_DEPTH  = 16 ,
    parameter P_N      = $clog2(F_DEPTH)
)(
    input  logic                clk      ,
    input  logic                rst_n    ,
    input  logic                wr_en    ,
    input  logic                rd_en    ,
    input  logic[F_WIDTH-1:0]   wr_data  ,


    output logic[F_WIDTH-1:0]   rd_data  ,
    output logic                full     ,
    output logic                empty        
);

    reg[F_WIDTH-1:0]    fifo_mem[F_DEPTH-1:0];

    reg[P_N-1:0]        wr_ptr ,wr_ptr_nxt ;
    reg[P_N-1:0]        rd_ptr ,rd_ptr_nxt ;
    reg                 full_nxt           ;
    reg                 empty_nxt          ;
    wire                wr_flag,rd_flag    ;

    assign wr_flag = wr_en && ~full ;
    assign rd_flag = rd_en && ~empty;

 
//--write pointer control logic
    always @(*) begin
        wr_ptr_nxt = wr_ptr ;
        if(wr_ptr == F_DEPTH - 1'd1) begin
            wr_ptr_nxt = 'd0 ;
        end
        else if(wr_flag)begin
            wr_ptr_nxt = wr_ptr + 'd1 ;
        end
    end

//--read pointer  control logic
    always @(*) begin
        rd_ptr_nxt = rd_ptr ;
        if(rd_ptr == F_DEPTH - 1'd1) begin
            rd_ptr_nxt = 'd0 ;
        end
        else if(rd_flag)begin
                rd_ptr_nxt = rd_ptr + 'd1 ;
        end
    end
//--full flag
    always @(*) begin
        full_nxt = full ;
        if (rd_en && !wr_en) begin
            full_nxt = 1'b0 ;
        end
        else if (wr_en && rd_ptr == wr_ptr + 1'd1) begin
            full_nxt = 1'b1 ;
        end
    end
//--empty flag 
    always @(*) begin
        empty_nxt = empty ;
        if (wr_en && !rd_en) begin
            empty_nxt = 1'b0 ;
        end
        else if (rd_en && wr_ptr == rd_ptr + 1'd1) begin
            empty_nxt = 1'b1 ;
        end
    end
//--write or read data
    always @(posedge clk ) begin
        if (wr_flag)begin
            fifo_mem[wr_ptr] <= wr_data ;
        end
        if (rd_flag) begin
            rd_data          <= fifo_mem[rd_ptr] ;
        end
    end
//--dff out 
    always @( posedge clk or negedge rst_n) begin
        if( !rst_n ) begin
            wr_ptr <= 'd0 ;
            rd_ptr <= 'd0 ;
            full   <= 'b0 ;
            empty  <= 'b0 ;
        end
        else begin
            wr_ptr <= wr_ptr_nxt ;
            rd_ptr <= rd_ptr_nxt ;
            empty  <= empty_nxt  ;
            full   <= full_nxt   ;
        end
    end      
endmodule

