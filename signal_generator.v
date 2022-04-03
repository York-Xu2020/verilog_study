module signal_generator(
	input clk,
	input rst_n,
	input [1:0] wave_choise,
	output reg [4:0]wave
	);

   
    reg [4:0] wave_nxt ;
    reg       cnt_sub  ;
    wire      cnt_add  ;
    reg [4:0] cnt      ;
    
    wire [4:0] squre_wave    ;
    wire [4:0] sawtooth_wave ;
    wire [4:0] triangle_wave ;
    wire [4:0] same_clk      ;

    always @(*) begin
        case (wave_choise) 
        2'b00: wave_nxt = squre_wave    ;
        2'b01: wave_nxt = sawtooth_wave ;
        2'b10: wave_nxt = triangle_wave ;
        2'b11: wave_nxt = same_clk      ;
        default: begin  end
        endcase
    end
     
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            cnt <= 5'b0 ;
        else if (cnt_sub) 
            cnt <= cnt - 1'b1 ;
        else if (cnt_add)
            cnt <= cnt + 1'b1 ;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            cnt_sub <= 1'b0 ;
        else if (cnt == 5'd4)
            cnt_sub <= 1'b1 ;
        else if (cnt == 5'd1)
            cnt_sub <= 1'b0;
    end
    
    assign cnt_add = ~cnt_sub ;

    assign squre_wave    = {2'b0,{3{cnt_add}}} ;
    assign sawtooth_wave = cnt_add ?  cnt : (5'd5 - cnt) ;
    assign triangle_wave = cnt ;
    assign same_clk      = clk ;

    
    always @( posedge clk or negedge rst_n) begin
      if( !rst_n ) begin
         wave <= 'b0;
      end
      else begin
         wave <= wave_nxt ;
      end
    end      
 
endmodule

