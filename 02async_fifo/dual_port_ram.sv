module dual_port_ram #(parameter DEPTH = 16,
		       parameter WIDTH = 8)
        (
	 input  logic                         wclk     ,
         input  logic                         wr_en    ,
         input  logic[$clog2(DEPTH)-1:0]      wr_addr  ,
         input  logic[WIDTH-1        :0]      wr_data  ,
         input  logic                         rclk     ,
         input  logic                         rd_en    ,
         input  logic[$clog2(DEPTH)-1:0]      rd_addr  ,
         output logic[WIDTH-1        :0]      rd_data 		
                      );

  reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

  always @(posedge wclk) begin
    if(wr_en)
      RAM_MEM[wr_addr] <= wr_data;
  end 

  always @(posedge rclk) begin
    if(rd_en) begin
      rd_data <= RAM_MEM[rd_addr];
 //     RAM_MEM[rd_addr] <= 'hffff     ;  //debug
    end
  end 

endmodule  
