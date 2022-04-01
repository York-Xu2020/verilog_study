
module div_freq_decimal 
#(
    parameter N_FREQ = 3.5 
)(
    input  logic                clk         ,
    input  logic                rst_n       ,


    output logic                clk_3p5   
);


  reg[2:0] cnt_clk_pos ;
  reg[2:0] cnt_clk_neg ;
  wire     clk_pos ;
  wire     clk_neg ;
 
always @( posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    cnt_clk_pos <= 'd0 ;
  end
  else if (cnt_clk_pos == 'd6) begin
    cnt_clk_pos <= 'd0 ;
  end 
  else begin
    cnt_clk_pos <= cnt_clk_pos + 1'd1 ;
  end
end     

always @(negedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cnt_clk_neg <= 'd0 ;
  end
  else if (cnt_clk_neg == 'd6) begin
    cnt_clk_neg <= 'd0 ;
  end
  else 
    cnt_clk_neg <= cnt_clk_neg + 1'd1 ;
end

  assign clk_pos = (cnt_clk_pos >= 'd4) ;
  assign clk_neg = (cnt_clk_neg <= 'd2) ;


  assign clk_3p5 = !(clk_pos ^ clk_neg) ;

//----- resister middle clock
  reg  clk_neg_r ;
  reg  clk_pos_r ;
  wire clk_3p5_r ;

  always @( posedge clk or negedge rst_n) begin
    if( !rst_n ) begin
      clk_pos_r <= 1'b0 ; 
    end
    else if (cnt_clk_pos == 'd2) begin
      clk_pos_r <= 1'b1 ;
    end
    else if (cnt_clk_pos == 'd6) begin
      clk_pos_r <= 1'b0 ;
    end
  end    


  always @( negedge clk or negedge rst_n) begin
    if( !rst_n ) begin
      clk_neg_r <= 1'b1 ;
    end
    else if (cnt_clk_pos == 'd3)begin
      clk_neg_r <= 1'b0 ;
    end
    else if (cnt_clk_pos == 'd6)begin
      clk_neg_r <= 1'b1 ;
    end
  end    

  assign clk_3p5_r = clk_pos_r && clk_neg_r ;

//----- another way for better duty
//--use counter
  wire  clk_neg_better_duty ;
  wire  clk_pos_better_duty ;
  wire  clk_3p5_better_duty ;

  assign clk_pos_better_duty = cnt_clk_pos == 'd1 || cnt_clk_pos == 'd2 || cnt_clk_pos == 'd3 || cnt_clk_pos == 'd4 || cnt_clk_pos == 'd5 ;
  assign clk_neg_better_duty = cnt_clk_neg == 'd0 || cnt_clk_neg == 'd1 || cnt_clk_neg == 'd4 || cnt_clk_neg == 'd5 ;
  
  assign clk_3p5_better_duty = clk_neg_better_duty && clk_pos_better_duty ;

//----- another another for better duty
//----use 3443 half Tclk
//---- only use one counter 


  reg  clk_neg_3443 ;
  reg  clk_pos_3443 ;
  wire clk_3p5_3443 ;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      clk_pos_3443 <= 1'b1 ;
    end
    else if (cnt_clk_pos == 'd0 || cnt_clk_pos == 'd6 ) begin
      clk_pos_3443 <= 1'b1 ;
    end
    else if (cnt_clk_pos == 'd5) begin
      clk_pos_3443 <= 1'b0 ;
    end
  end


  always @( negedge clk or negedge rst_n) begin
    if( !rst_n ) begin
      clk_neg_3443 <= 1'b1 ;
    end
    else if (cnt_clk_pos == 'd1 || cnt_clk_pos == 'd5)begin
      clk_neg_3443 <= 1'b0 ;
    end
    else if (cnt_clk_pos == 'd3 || cnt_clk_pos == 'd6) begin
      clk_neg_3443 <= 1'b1 ; 
    end
  end     

  assign clk_3p5_3443 = clk_pos_3443 && clk_neg_3443 ;

endmodule

