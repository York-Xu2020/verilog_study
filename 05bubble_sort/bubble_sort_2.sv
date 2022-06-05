module bubble_sort 
#(
    parameter DATA_N = 4 ,
    parameter DATA_W = 4  
)(
    input  logic              clk                 ,
    input  logic              rst_n               ,

    sort_if.master            bb_sort_if             
);

    localparam   CNT_W = $clog2(DATA_N) ;

//interface
    wire              start_sort          = bb_sort_if.start_sort ;
    logic[DATA_W-1:0] data_in[0:DATA_N-1] ;
    logic[DATA_W-1:0] data_out ;
    logic             out_vld  ;
    assign   bb_sort_if.data_out            = data_out ;
    assign   bb_sort_if.out_vld             = out_vld  ; 

    generate
        genvar gi;
        for (gi=0; gi<DATA_N; gi++) begin:IF_CONNECT
         assign    data_in[gi] = bb_sort_if.data_in[gi] ; 
        end
    endgenerate



    reg[DATA_W-1:0]     tmp_mem[0:DATA_N-1] ;
    logic               sorting             ;
    logic               sort_done           ;
    logic               out_en              ;
    
    logic[CNT_W-1:0] bit_swap_cnt ;  //bit 
    logic[CNT_W-1:0] rnd_incr_cnt ;  //round
    logic[CNT_W-1:0] data_idx     ;  //output address

    always_ff @( posedge clk, negedge rst_n) begin
        if( !rst_n ) begin
            sorting <= 1'b0 ;    
        end
        else if (start_sort) begin
            sorting <= 1'b1 ;
        end
        else if(sort_done) begin
            sorting <= 1'b0 ;
        end
    end      

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
            if (rnd_incr_cnt < DATA_N) begin
                if (tmp_mem[bit_swap_cnt + 1'b1] < tmp_mem[bit_swap_cnt]) begin
                    tmp_mem[bit_swap_cnt + 1'b1]  <= tmp_mem[bit_swap_cnt     ] ;
                    tmp_mem[bit_swap_cnt]         <= tmp_mem[bit_swap_cnt+1'b1] ;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            bit_swap_cnt  <= 'd0 ;
        end
        else if(sorting && !sort_done) begin
            if (bit_swap_cnt == DATA_N-2) begin
                bit_swap_cnt <=  'd0 ;
            end    
            else begin
                bit_swap_cnt <= bit_swap_cnt + 1'b1 ;
            end
        end
        else begin
            bit_swap_cnt <= 'd0 ;
        end
    end

   always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            rnd_incr_cnt  <= 'd0 ;
        end
        else if(sorting) begin
            if (bit_swap_cnt == DATA_N-2 && rnd_incr_cnt !== DATA_N-2) begin
                rnd_incr_cnt <= rnd_incr_cnt + 1'b1 ;
            end    
            else if(bit_swap_cnt == DATA_N-2 && rnd_incr_cnt == DATA_N-2) begin
                rnd_incr_cnt <= 'd0 ;
            end
        end
        else begin
            rnd_incr_cnt <= 'd0 ;
        end
    end


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sort_done <= 1'b0 ;
        end
        else if (rnd_incr_cnt == DATA_N-2 && bit_swap_cnt == DATA_N-2) begin
            sort_done <= 1'b1 ;
        end
        else begin
            sort_done <= 1'b0 ;
        end
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_en    <= 1'b0 ;
            data_idx  <=  'd0 ;
        end
        else if(data_idx == DATA_N-1) begin
            out_en    <= 1'b0 ;
            data_idx  <=  'd0 ;
        end
        else begin
             if (sort_done) begin
                out_en   <= 1'b1 ;
             end
             if(out_en) begin
                data_idx <= data_idx + 1'd1 ;
             end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_out <= 'b0 ;
        end
        else if (out_en) begin
            data_out <= tmp_mem[data_idx] ; 
        end
        else begin
            data_out <= 'b0 ;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_vld <= 1'b0 ;
        end
        else begin
            out_vld <= out_en ;
        end
    end
    

endmodule

