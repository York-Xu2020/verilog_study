`timescale 1ns / 1ps
module tb_asynch_fifo_core;   

    // asynch_fifo_core Parameters
    parameter                       W_PERIOD = 50       ; // 20MHz
    parameter                       R_PERIOD_S = 100    ; // 10MHz
    parameter                       R_PERIOD_F = 10     ; // 100MHz
    parameter                       FIFO_PTR = 4        ;
    parameter                       FIFO_WIDTH = 32     ;

    // asynch_fifo_core Inputs
    reg                             wrclk = 0           ;
    wire                            write_en            ;
    reg [FIFO_WIDTH-1:0]            write_data = 0      ;
    reg                             rdclk = 0           ;
    wire                            read_en             ;
    reg                             rst_n = 0           ;

    // asynch_fifo_core Outputs
    wire [FIFO_WIDTH-1:0]           read_data           ;
    wire                            fifo_full           ;
    wire                            fifo_empty          ;
    wire [FIFO_PTR:0]               room_avail          ;
    wire [FIFO_PTR:0]               data_avail          ;

    real 			    rcp		        ;
    reg [FIFO_WIDTH-1:0]            buffer[0:1023]      ; // big enough

    reg [31:0]                      read_idx = 0        ;
    reg                             read_in = 0         ;
    reg                             write_in = 0        ;

    initial
    begin
        forever #(W_PERIOD/2)  wrclk = ~wrclk;
    end

    initial
    begin
        forever #(rcp)  rdclk = ~rdclk;
    end

    initial
    begin
        rcp = R_PERIOD_S;

        $display("\nstatus: %t Testbench started\n\n", $time);
        #(W_PERIOD*10) rst_n  =  1;
        $display("status: %t done reset", $time);
        $display("status: %t the depth of the dc-fifo is : %d", $time,2**FIFO_PTR);
        repeat(5) @(posedge wrclk);
        write_test(16,0);
        repeat(100) @(posedge rdclk);
        repeat(5) @(posedge wrclk);
        write_test(16,1);
        repeat(100) @(posedge rdclk);
        $finish;      
    end

    asynch_fifo_core 
    #(
        .FIFO_PTR                   (FIFO_PTR               ),
        .FIFO_WIDTH                 (FIFO_WIDTH             )
    )
    u_asynch_fifo_core 
    (
        .wrclk                      (wrclk                  ),
        .rstb_wrclk                 (rst_n                  ),
        .write_en                   (write_en               ),
        .write_data                 (write_data             ),
        .rdclk                      (rdclk                  ),
        .rstb_rdclk                 (rst_n                  ),
        .read_en                    (read_en                ),

        .read_data                  (read_data              ),
        .fifo_full                  (fifo_full              ),
        .fifo_empty                 (fifo_empty             ),
        .room_avail                 (room_avail             ),
        .data_avail                 (data_avail             )
    );

    //--------------------------------------------------------------------------
    // write test task
    //--------------------------------------------------------------------------
    task write_test;
	input [31:0] 	        num_write		; 
        input                   mode                    ;
	reg [31:0] 		idx_w			; 
	reg [FIFO_WIDTH-1:0] 	valW			;
	begin
        $display("status: %t total number of write data : %d", $time,num_write);
        if (mode == 0) begin
            rcp = R_PERIOD_S; // read is slower than write
            $display("status: %t read is slower than write", $time);
        end
        else begin
            rcp = R_PERIOD_F; // read is faster than write
            $display("status: %t read is faster than write", $time);
        end

        for (idx_w = 0; idx_w < num_write; idx_w = idx_w + 1) begin
            valW = $random;
            buffer[idx_w] = valW;
            write_fifo(fifo_full, valW);
        end
	end
	endtask

    //--------------------------------------------------------------------------
    // write fifo task
    //--------------------------------------------------------------------------
    task write_fifo;
        input                   fifo_full       ;
        input [FIFO_WIDTH-1:0]  value           ;
    begin
        write_in    <= 1'b1;
        write_data  <= value;
        @(posedge wrclk);
        write_in    <= 1'b0;
    end
    endtask

    assign write_en = write_in & (~fifo_full);

    always @(posedge rdclk or negedge rst_n)
    begin
        if (!rst_n) begin
            read_in <= 1'b0;
        end
        else begin
            read_in <= 1'b1;
        end
    end

    assign read_en = read_in & (!fifo_empty);

    always @(posedge rdclk)
    begin
        if (read_en) begin
            #3;
            if (read_data != buffer[read_idx])
                $display("status: %t Data (%0d) mismatch, expected %h got %h", $time,
					read_idx, buffer[read_idx], read_data);
            read_idx = read_idx + 1;
        end
    end

endmodule
