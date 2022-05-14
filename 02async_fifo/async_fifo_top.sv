module async_fifo_top 
#(
    parameter DATA_W = 16 ,
    parameter FIFO_D = 32  
)(
    input  logic                      wr_clk      ,
    input  logic                      rd_clk      ,
    input  logic                      rst_n       ,
    input  logic[DATA_W-1:0]          wr_data     ,
    input  logic                      wr_en       ,
    input  logic                      rd_en       ,


    output logic[DATA_W-1:0]          rd_data     ,
    output logic                      fifo_full   ,
    output logic[$clog2(FIFO_D):0]    data_avail ,
    output logic[$clog2(FIFO_D):0]    room_avail ,
    output logic                      fifo_empty 
);

    localparam PTR_N = ($clog2(FIFO_D))    ;
    wire [PTR_N:0]          wr_ptr ;
    wire [PTR_N:0]          rd_ptr ;
    wire                    wr_fifo;
    wire                    rd_fifo;
        

    fifo_ctrl #(
                .FIFO_D(FIFO_D),
                .PTR_N (PTR_N )
                )
              U_FIFO_CTRL(
                .wr_clk    (wr_clk    ),
                .rd_clk    (rd_clk    ),
                .rst_n     (rst_n     ),
                .wr_en     (wr_en     ),
                .rd_en     (rd_en     ),
        
                .wr_fifo   (wr_fifo   ),
                .rd_fifo   (rd_fifo   ),
                .wr_ptr    (wr_ptr    ),                
                .rd_ptr    (rd_ptr    ),
                .data_avail(data_avail),
                .room_avail(room_avail),
                .fifo_full (fifo_full ),
                .fifo_empty(fifo_empty)                
                );
    
    dual_port_ram #(
                .DEPTH(FIFO_D),
                .WIDTH(DATA_W)    
                )
              U_FIFO_RAM(
                .wclk      (wr_clk    ),
                .wr_en     (wr_fifo   ),
                .wr_addr   (wr_ptr    ),
                .wr_data   (wr_data   ),
                .rclk      (rd_clk    ),
                .rd_en     (rd_fifo   ),
                .rd_addr   (rd_ptr    ),
                .rd_data   (rd_data   )
                );

endmodule

