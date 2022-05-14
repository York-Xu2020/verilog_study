// 1,random case, continuous write and continous read
// 2,only write  
// 3,no tasks or functions
// 4,not good
//------------------------------------------------------//

integer				i,j;
initial
begin
	//initialize input
	wr_data = 0;
	wr_en = 0;
        rd_en = 0 ;
end


//FIFO write control
initial
begin
	//Wait a few clock cycles
	#(T_CLK *10);
	
	for (i=0; i<16; i=i+1)
	begin
		@(posedge wr_clk)
		wr_en <= 1'b1;
		wr_data <= $random;
	end
	@(posedge wr_clk)
		wr_en <= 1'b0;
		
	#(T_CLK *10);
	for (i=0; i<16; i=i+1)
	begin
		@(posedge wr_clk)
		wr_en <= 1'b1;
		wr_data <= $random;
	end
	@(posedge wr_clk)
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
	#(T_CLK_R *10);
	
	for (j=0; j<16; j=j+1)
	begin
		@(posedge rd_clk)
		rd_en <= 1'b1;
	end
	@(posedge rd_clk)
		rd_en <= 1'b0;
		
	#(T_CLK_R *10);
	for (j=0; j<16; j=j+1)
	begin
		@(posedge rd_clk)
		rd_en <= 1'b1;
	end
	@(posedge rd_clk)
		rd_en <= 1'b0;
	#(T_CLK_R *10);

        for(int m=0; m<5; m++) begin:WR_ONLY
          @(posedge rd_clk)
            wr_en   <= 1'b1;
            wr_data <= $random ;
        end
        
       for (int n=0;n<10;n++) begin:WR_AND_RD
            @(posedge rd_clk)
                rd_en <= 1'b1 ;
        end
        @(posedge rd_clk)
            wr_en <= 1'b0 ;
      repeat(10) begin
          @ (posedge rd_clk ) ;
      end
          rd_en <= 1'b0 ;
      #(50*T_CLK)
        $finish;
end



