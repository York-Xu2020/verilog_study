module dual_port_RAM #(parameter DEPTH = 16,
					   parameter WIDTH = 8)(
	 input wclk
	,input wr_en
	,input [$clog2(DEPTH)-1:0] wr_addr  
	,input [WIDTH-1:0] wr_data      	
	,input rclk
	,input rd_en
	,input [$clog2(DEPTH)-1:0] rd_addr 
	,output reg [WIDTH-1:0] rd_data 		
);

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

always @(posedge wclk) begin
	if(wr_en)
		RAM_MEM[wr_addr] <= wr_data;
end 

always @(posedge rclk) begin
	if(rd_en)
		rd_data <= RAM_MEM[rd_addr];
end 

endmodule  
