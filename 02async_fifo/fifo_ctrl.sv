module fifo_ctrl 
#(
    parameter FIFO_D = 32  ,
    parameter PTR_N  = $clog2(FIFO_D)  //pointer bit number
)(
    input  logic              wr_clk      ,
    input  logic              rd_clk      ,
    input  logic              rst_n       ,
    input  logic              wr_en       ,
    input  logic              rd_en       ,


    output                    wr_fifo     ,
    output                    rd_fifo     ,
    output logic[PTR_N:0]     wr_ptr      ,
    output logic[PTR_N:0]     rd_ptr      ,
    output logic[PTR_N:0]     data_avail  ,
    output logic[PTR_N:0]     room_avail  ,
    output logic              fifo_full   ,
    output logic              fifo_empty
);

    assign    wr_fifo = wr_en && !fifo_full  ;
    assign    rd_fifo = rd_en && !fifo_empty ;
    
    logic [PTR_N:0] wr_ptr_gray,wr_ptr_gray_sync,wr_ptr_rdclk_bin ;
    logic [PTR_N:0] rd_ptr_gray,rd_ptr_gray_sync,rd_ptr_wrclk_bin ;  
    
    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 'd0 ;
        end              
        else if (wr_fifo) begin
            wr_ptr <= wr_ptr + 1'd1 ;
        end
    end

    always @(posedge rd_clk or negedge rst_n) begin
        if(!rst_n) begin
            rd_ptr <= 'd0 ;
        end
        else if (rd_fifo) begin
            rd_ptr <= rd_ptr + 1'd1 ;
        end 
    end

 //   //--gray full and empty
 //   //in write clock domain
 //   assign fifo_full  =  !(rd_ptr_gray_sync[PTR_N] == wr_ptr_gray[PTR_N])          //MSB is n-eq
 //                     && !(rd_ptr_gray_sync[PTR_N-1] == wr_ptr_gray[PTR_N-1])      //MSB-1 is n-eq too
 //                     && (rd_ptr_gray_sync[PTR_N-2:0] == wr_ptr_gray[PTR_N-2:0]) ; //other bits is equal
 //   //in read  clock domain
 //   assign fifo_empty =   wr_ptr_gray_sync == rd_ptr_gray ;
   //--bin   full and empty
    assign fifo_full  = !(rd_ptr_wrclk_bin[PTR_N] == wr_ptr[PTR_N]) && (rd_ptr_wrclk_bin[PTR_N-1:0] == wr_ptr[PTR_N-1:0]) ;
    assign fifo_empty = wr_ptr_rdclk_bin == rd_ptr ;

 
    //data_avail and room avail 
    //same as "full": in write domain
    assign data_avail = (wr_ptr[PTR_N] == rd_ptr_wrclk_bin[PTR_N]) ? wr_ptr[PTR_N-1:0] - rd_ptr_wrclk_bin[PTR_N-1:0] 
                                                                   : (PTR_N+1)'(FIFO_D) - (rd_ptr_wrclk_bin[PTR_N-1:0] - wr_ptr[PTR_N-1:0]) ;
    //same as "empty":in read  domain
    assign room_avail = (wr_ptr_rdclk_bin[PTR_N] == rd_ptr[PTR_N]) ? (PTR_N+1)'(FIFO_D) - (wr_ptr[PTR_N-1:0] - rd_ptr_wrclk_bin[PTR_N-1:0])
                                                                   : rd_ptr[PTR_N-1:0] - wr_ptr_rdclk_bin[PTR_N-1:0]            ; 


    //wr_ptr bin2gray
    bin2gray #(.WIDTH(PTR_N+1)) 
            U_WR_GRAY(
                .clk      (wr_clk     ) ,
                .rst_n    (rst_n      ) ,
                .bin_in   (wr_ptr     ) ,
                .gray_out (wr_ptr_gray)
            );    
    //rd_ptr bin2gray
    bin2gray #(.WIDTH(PTR_N+1)) 
            U_RD_GRAY(
                .clk      (rd_clk     ) ,
                .rst_n    (rst_n      ) ,
                .bin_in   (rd_ptr     ) ,
                .gray_out (rd_ptr_gray)
            );  
    //synchro
    synchro #(.DATA_W(PTR_N+1))
            U_RD_SYNC(
                .b_clk    (wr_clk           ) ,
                .rst_n    (rst_n            ) ,
                .data_in  (rd_ptr_gray      ) ,
                .data_out (rd_ptr_gray_sync ) 
            );
    synchro #(.DATA_W(PTR_N+1))
            U_WR_SYNC(
                .b_clk    (rd_clk           ) ,
                .rst_n    (rst_n            ) ,
                .data_in  (wr_ptr_gray      ) ,
                .data_out (wr_ptr_gray_sync ) 
            );
    //rd_ptr gray2bin  ---rd_ptr recover
    gray2bin # (.WIDTH(PTR_N+1))
            U_RD_ROV(
                .gray_in  (rd_ptr_gray_sync) ,
                .bin_out  (rd_ptr_wrclk_bin)
            );
    //wr_ptr gray2bin  ---wr_ptr recover
    gray2bin # (.WIDTH(PTR_N+1))
            U_WR_ROV(
                .gray_in  (wr_ptr_gray_sync) ,
                .bin_out  (wr_ptr_rdclk_bin)
            );

endmodule




