// 1, write and read fifo periodlly
// 2, write full and then read empty 
// 3, read clk is faster than write
//
//--------------------------------------------------------------//
   
    //read clock period
    localparam  RD_PERIOD         = 6                  ; 
    // for read clk
    initial 
    begin
        forever #(RD_PERIOD/2) rd_clk = ~rd_clk ;
    end
   

    initial
    begin
        $display("\nstatus: %t Testbench started\n\n", $time);
        #(PERIOD*10) rst_n  =  1;
        $display("status: %t done reset", $time);
        repeat(5) @(posedge wr_clk);
        write_and_read(30); 
        repeat(5) @(posedge wr_clk);
        write_full_then_read();
        repeat(5) @(posedge wr_clk);
        $finish;
    end

       
    // write and read  (write,read,write,read...)
    task write_and_read ;
        input  [15:0]              repeat_num  ;
        integer                    idx         ;
        reg    [FIFO_WIDTH-1:0]    wr_value    ;
        integer                    error       ;        

    begin
        $display("***write and then read periodically***") ;
        $display("status: %t total number of write data : %d", $time, repeat_num) ;
        error = 0 ;
        for (idx=0;idx<repeat_num;idx=idx+1) begin
            wr_value      = $random ;
            write_fifo(wr_value)    ;
            read_fifo ()            ;
            if (read_data !== wr_value) begin
                error = error + 1 ;
                $display("ERROR @time %t, idx:%d, read_data is %h, but the expected is %h",$time,idx,read_data,wr_value) ;
            end
        end
        
        if(error == 0) 
            $display("***@@@@@@ write_and_read PASS @@@@@@***") ;
 
    end
    endtask

    // write full then read
    task write_full_then_read ;
        integer                    idx               ;
        integer                    error             ;
        reg    [FIFO_WIDTH-1:0]    wr_value          ;
        reg    [FIFO_WIDTH-1:0]    expected_value    ;
    
        $display("***write_full_then_read***") ;
        error = 0 ;
        for (idx=0;idx<FIFO_DEPTH;idx=idx+1) begin
            wr_value    = ~(idx+1) ;
            write_fifo(wr_value)   ;          
        end
        
        for (idx=0;idx<FIFO_DEPTH;idx=idx+1) begin
           expected_value = ~(idx+1) ;
           read_fifo();
           if (read_data != expected_value) begin
              error = error + 1 ;
              $display("ERROR @time %t, idx:%d, read_data is %h, but the expected is %h",$time,idx,read_data,expected_value) ;
           end 
        end
        
        if(error == 0) 
              $display("***@@@@@ write_full_then_read PASS @@@@@@***") ;

    endtask




