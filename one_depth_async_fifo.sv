module one_depth_async_fifo 
#(
    parameter DEPTH = 1 ,
    parameter WIDTH = 8 
)(
    input  logic              clk_wr      ,
    input  logic              clk_rd      ,
    input  logic              rst_n       ,
    input  logic              wr_en       ,
    input  logic              data_in_vld ,
    input  logic              rd_en       ,
    input  logic[WIDTH-1:0]   data_in     ,          


    output logic              full        ,
    output logic              empty       ,
    output logic              data_out_vld,
    output logic              data_avail  ,
    output logic[WIDTH-1:0]   rd_data         
);

    logic [WIDTH-1:0] fifo_mem      ;
    logic             wr_fifo       ;
    logic             rd_fifo       ;
    logic             wr_fifo_wrclk,wr_fifo_ff1,wr_fifo_ff2,wr_fifo_ff3,wr_fifo_rdclk ;
    logic             rd_fifo_rdclk,rd_fifo_ff1,rd_fifo_ff2,rd_fifo_ff3,rd_fifo_wrclk ;
    logic             fifo_data_vld_wrclk,fifo_data_vld_rd_clk ;

// write and read fifo active
    assign   wr_fifo = wr_en && data_in_vld && !full  ;
    assign   rd_fifo = rd_en && ~empty ;

//full logic in write clk domain
//need synchronize rd_fifo
    always @(posedge clk_wr or negedge rst_n) begin
        if (!rst_n)
            full <= 1'b0 ;
        else if (wr_fifo && !rd_fifo_wrclk) 
            full <= 1'b1 ;
        else if (!wr_fifo && rd_fifo_wrclk)
            full <= 1'b0 ; 
    end

//empty logic in read  clk domain
//need synchronize wr_fifo
    always @(posedge clk_rd or negedge rst_n) begin
        if (!rst_n)
            empty <= 1'b1 ;
        else if (rd_fifo && !wr_fifo_rdclk) 
            empty <= 1'b1 ;
        else if (!rd_fifo && wr_fifo_rdclk)
            empty <= 1'b0 ;
    end
 
//two level synchronzer and edge detect
//because wr_fifo and rd_fifo signal is one-cycle active signals
    always @(posedge clk_wr or negedge rst_n) begin
        if (!rst_n) begin
            wr_fifo_wrclk <= 1'b0 ;
            rd_fifo_ff1   <= 1'b0 ;
            rd_fifo_ff2   <= 1'b0 ;
            rd_fifo_ff3   <= 1'b0 ;
        end
        else begin
            wr_fifo_wrclk <= wr_fifo       ; 
            rd_fifo_ff1   <= rd_fifo_rdclk ;
            rd_fifo_ff2   <= rd_fifo_ff1   ;
            rd_fifo_ff3   <= rd_fifo_ff2   ;
        end
    end
    
    always @(posedge clk_rd or negedge rst_n) begin
        if (!rst_n) begin
            rd_fifo_rdclk <= 1'b0 ;
            wr_fifo_ff1   <= 1'b0 ;
            wr_fifo_ff2   <= 1'b0 ;
            wr_fifo_ff3   <= 1'b0 ;
        end
        else begin
            rd_fifo_rdclk <= rd_fifo       ;
            wr_fifo_ff1   <= wr_fifo_wrclk ;
            wr_fifo_ff2   <= wr_fifo_ff1   ;
            wr_fifo_ff3   <= wr_fifo_ff2   ;
        end
    end
    
    assign wr_fifo_rdclk = wr_fifo_ff2 && ~wr_fifo_ff3 ;
    assign rd_fifo_wrclk = rd_fifo_ff2 && ~rd_fifo_ff3 ;
   
    always @(posedge clk_wr or negedge rst_n) begin
        if (!rst_n) begin
            fifo_data_vld_wrclk <= 1'b0 ;
        end
        else if (wr_fifo && !rd_fifo_wrclk) begin
            fifo_data_vld_wrclk <= 1'b1 ;
        end
        else if (!wr_fifo && rd_fifo_wrclk) begin
            fifo_data_vld_wrclk <= 1'b0 ;
        end
    end
    
    always @(posedge clk_rd or negedge rst_n) begin
        if (!rst_n) begin
            fifo_data_vld_rdclk <= 1'b0 ;
        end
        else if (rd_fifo && !wr_fifo_rdclk) begin
            fifo_data_vld_rdclk <= 1'b0 ;
        end
        else if (!rd_fifo && wr_fifo_rdclk) begin
            fifo_data_vld_rdclk <= 1'b1 ;
        end
    end
    
    assign data_avail = fifo_data_vld_wrclk && fifo_data_vld_rdclk ;

//read data valid 
    always @(posedge clk_rd or negedge rst_n) begin
        if (!rst_n) begin
            data_out_vld <= 1'b0 ;
        end
        else if (rd_fifo) begin
            data_out_vld <= 1'b1 ;
        end
        else begin
            data_out_vld <= 1'b0 ;
        end
    end      

//write and read fifo ram  
    always @(posedge clk_wr) begin
        if(wr_fifo) 
            fifo_mem <= data_in ;
    end
    
    always @(posedge clk_rd) begin
        if (rd_fifo)
            rd_data <= fifo_mem ;
    end    


endmodule

