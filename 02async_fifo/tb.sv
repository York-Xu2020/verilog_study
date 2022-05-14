module tb;      

    // synch_fifo Parameters   
    parameter PERIOD            = 10                 ;
    parameter FIFO_DEPTH        = 32                 ;
    parameter FIFO_PTR          = $clog2(FIFO_DEPTH) ;
    parameter FIFO_WIDTH        = 16                 ;



    // synch_fifo Inputs
    reg                         wr_clk = 0           ;
    reg                         rd_clk = 0           ;
    reg                         rst_n = 0            ;
    reg                         write_en = 0         ;
    reg [FIFO_WIDTH-1:0]        write_data = 0       ;
    reg                         read_en = 0          ;

    // synch_fifo Outputs
    wire [FIFO_WIDTH-1:0]       read_data            ;
    wire                        full                 ;
    wire                        empty                ;
    wire [FIFO_PTR:0]           room_avail           ;
    wire [FIFO_PTR:0]           data_avail           ;


    initial
    begin
        forever #(PERIOD/2)  wr_clk = ~wr_clk;
    end

    //write fifo task
    task write_fifo ;
        input [FIFO_WIDTH-1:0]   value ;
    begin
        @(posedge wr_clk) ;
        write_en      <= 1'b1     ;
        write_data    <= value    ;
        @(posedge wr_clk) ;
        write_en      <= 1'b0     ;
    end
    endtask
   
    //read fifo task
    task read_fifo ;
    begin
        @(posedge wr_clk) ;
        repeat(2)@(posedge rd_clk) ;
        read_en       <= 1'b1     ;
        @(posedge rd_clk) ;
        read_en       <= 1'b0     ;
        @(posedge rd_clk) ;
    end
    endtask

    //dump wave,fsdb for verdi
    initial
    begin
        $fsdbDumpfile("sim.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA();
    end


    async_fifo_top 
    #(
        .DATA_W                  (FIFO_WIDTH     ),
        .FIFO_D                  (FIFO_DEPTH     )
    )
    u_async_fifo 
    (
        .wr_clk                 (wr_clk         ),
        .rd_clk                 (rd_clk         ),
        .rst_n                  (rst_n          ),
        .wr_en                  (write_en       ),
        .wr_data                (write_data     ),
        .rd_en                  (read_en        ),

        .rd_data                (read_data      ),
        .fifo_full              (full           ),
        .fifo_empty             (empty          ),
        .room_avail             (room_avail     ),
        .data_avail             (data_avail     )
    );
    

    `include "test_case.sv"

endmodule
