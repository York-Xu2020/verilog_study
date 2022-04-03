module tb();
parameter F_WIDTH  = 32 ;
parameter F_DEPTH  = 16 ;
parameter P_N      = $clog2(F_DEPTH);


logic          clk ;
logic          reset;

logic                wr_en  ;
logic                rd_en  ;
logic[F_WIDTH-1:0]   data_in;
                            ;
                            ;
logic[F_WIDTH-1:0]   rd_data;
logic                full   ;
logic                empty  ;

parameter T_HF = 10;
parameter T_CLK = 2 * T_HF;

//generate clk

initial begin
   clk = 1'b0 ;
  forever begin
   # T_CLK clk = ~ clk ;
end
end

//generate reset

initial begin
   reset = 1 ;
          @(posedge clk) #1 ;
           reset = 1'b0 ;
   # T_CLK reset = 1'b1 ;  //low reset

//  #(1000*T_CLK) reset = 1'b0 ; // high reset 
end

//finish
//  initial  begin
//   #(300*T_CLK)  $finish;
//  end

//input
integer				i,j;

initial
begin
	//initialize input
	data_in = 0;
	wr_en = 0;
end


//FIFO write control
initial
begin
	//Wait a few clock cycles
	#(T_CLK *10);
	
	for (i=0; i<16; i=i+1)
	begin
		@(posedge clk)
		wr_en <= 1'b1;
		data_in <= $random;
	end
	@(posedge clk)
		wr_en <= 1'b0;
		
	#(T_CLK *10);
	for (i=0; i<16; i=i+1)
	begin
		@(posedge clk)
		wr_en <= 1'b1;
		data_in <= $random;
	end
	@(posedge clk)
		wr_en <= 1'b0;
	#(T_CLK *10);
	
//end

//FIFO read control
//assign rd_en = ~empty;
// always_ff@(posedge clk or posedge rstb)
// begin
	// if (rstb)
		// rd_en <= 0;
	// else
		// rd_en <= ~empty;
// end

//initial
//begin
	rd_en = 0;
	//Wait a few clock cycles
	#(T_CLK *10);
	
	for (j=0; j<16; j=j+1)
	begin
		@(posedge clk)
		rd_en <= 1'b1;
	end
	@(posedge clk)
		rd_en <= 1'b0;
		
	#(T_CLK *10);
	for (j=0; j<16; j=j+1)
	begin
		@(posedge clk)
		rd_en <= 1'b1;
	end
	@(posedge clk)
		rd_en <= 1'b0;
	#(T_CLK *10);

        for(int m=0; m<5; m++) begin
          @(posedge clk)
            wr_en   <= 1'b1;
            data_in <= $random ;
        end
        
       for (int n=0;n<10;n++) begin
            @(posedge clk)
                rd_en <= 1'b1 ;
        end
        @(posedge clk)
            wr_en <= 1'b0 ;
      repeat(10) begin
          @ (posedge clk ) ;
      end
          rd_en <= 1'b0 ;
      #(50*T_CLK)
        $finish;
end
sync_fifo U_TB(clk,reset,wr_en,rd_en,data_in,rd_data,full,empty);

initial begin
$fsdbDumpfile("study.fsdb");
$fsdbDumpvars(0);
$fsdbDumpMDA();
end

endmodule

