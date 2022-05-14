// 1, write and read fifo periodlly
// 2, write full and then read empty 
// 3, read clk is slower than write
// 4,checker is wrong
//--------------------------------------------------------------//
   
    //read clock period
    localparam  RD_PERIOD         = 84                  ; 
    // for read clk
    initial 
    begin
        forever #(RD_PERIOD/2) rd_clk = ~rd_clk ;
    end
   
    reg [FIFO_WIDTH-1:0]          buffer[255:0] ;

    initial
    begin
        $display("\nstatus: %t Testbench started\n\n", $time);
        #(PERIOD*10) rst_n  =  1;
        $display("status: %t done reset", $time);
        repeat(5) @(posedge wr_clk);
        write_and_read(100); 
        repeat(50) @(posedge wr_clk);
        write_then_read();
        repeat(20) @(posedge wr_clk);
        $finish;
    end


    task write_and_read;
      input [31:0]      num_write     ;
      integer           idx           ;
      reg[FIFO_WIDTH-1:0]   value_t       ;
      
      begin
        $display("status: %t write test is start..." , $time) ;
        $display("****read clock is  faster than write*****") ;
        $display("status: write test, the number of write data is %d", num_write) ;
        for (idx = 0; idx<num_write ; idx = idx+1) begin
          value_t       = $random ;
          buffer[idx]   = value_t ;
          write_fifo(value_t)     ;
          read_en       = 1'b1 && !(idx==num_write-1)    ;
        end
      end
    endtask
        
    reg [31:0]        read_idx = 0  ;
    always @(posedge rd_clk) begin
      if(read_en && !empty) begin
        if (read_data !== buffer[read_idx-1]) begin
          //$display("ERROR");
          read_idx = read_idx + 1 ;
        end
      end
    end

    task write_then_read;
      reg [FIFO_WIDTH-1:0]  value_tk ;
      reg [31:0]        idx      ;
      begin
        $display("write then read start");
        for ( idx=0; idx<(FIFO_DEPTH+1); idx=idx+1 ) begin
          value_tk    = ~(idx+1) ;
          write_fifo(value_tk)   ;
          buffer[idx] = value_tk ;
        end
        
        for (int j=0; j<FIFO_DEPTH; j=j+1 ) begin
          read_fifo();
       //   if(read_data !== buffer[j] ) begin
       //     $display("ERROR in write then read");
       //   end
        end
      end
    endtask



