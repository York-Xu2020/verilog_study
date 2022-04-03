
module div_8p7(
 input  wire clk_in,
 input  wire rst,
 output wire clk_8p7
);

//*************code***********//

  parameter  CNT_W = $clog2(8+1) ;
  parameter  NUM_W = $clog2(10) ;  

  wire rst_n = rst    ;
  wire clk   = clk_in ;

  reg [CNT_W-1:0] cnt_clk ;
  wire            clk_8p7_pulse ;
  reg [NUM_W-1:0] cnt_div_num ;
  wire            clr_cnt ;

  reg             clk_8p7_r ;

  always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt_clk <= 'd0 ;
    end
    else if (clr_cnt) begin
      cnt_clk <= 'd0 ;
    end
    else begin
      cnt_clk <= cnt_clk + 1'd1 ;
    end
  end

  assign clr_cnt = cnt_clk == 'd8 || ((cnt_div_num == 'd2 || cnt_div_num == 'd5 || cnt_div_num == 'd9 ) && cnt_clk =='d7 ) ;
  
  always @( posedge clk or negedge rst_n) begin
    if( !rst_n ) begin
      cnt_div_num <= 'd0 ;
    end
    else if (cnt_div_num == 'd9 && clr_cnt) begin
      cnt_div_num <= 'd0 ;
    end
    else if (cnt_clk == 'd8 || clr_cnt) begin
      cnt_div_num <= cnt_div_num + 'd1 ;
    end
  end    

  assign clk_8p7_pulse = clr_cnt ;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clk_8p7_r <= 1'b0 ;
    end 
    else if (cnt_clk == 'd3) begin
      clk_8p7_r <= 1'b1 ;
    end
    else if (clr_cnt) begin
      clk_8p7_r <= 1'b0 ;
    end
  end
  
  assign clk_8p7 = clk_8p7_r ;
//*************code***********//
endmodule
