// sub sequence A : 11111...0000....
//*****************\__N___/+\__N___/**********
//
// sequence M :     AAAAAAA...
//*****************\____M_____/**************
// dec_pulse will be actived while detected one M  

module sub_sequence_detector 
(
    input  logic              clk      ,
    input  logic              rst_n    ,
    input  logic              data_in  ,           
    input  logic[5:0]         N        ,
    input  logic[4:0]         M        ,

    output logic              dec_pulse
);

    enum{ IDLE, SEQ1, SEQ0, SEQ10} state, next_state ;  // double-state 
    
    logic[$bits(N)-1:0]         cnt_seq      ; 
    logic[$bits(N)-1:0]         cnt_seq_nxt  ;
    logic                       cnt_seq_clr  ;
    logic                       seq_vld      ; // 1111... or 0000...

    logic[$bits(M)-1:0]         cnt_sub      ; //sub-sequence A
    logic[$bits(M)-1:0]         cnt_sub_nxt  ;
    logic                       cnt_sub_en   ;
    logic                       cnt_sub_clr  ;
    logic                       sub_vld      ;

    logic                       dec_pulse_nxt;
    
    assign cnt_seq_clr = state == IDLE || cnt_seq == N ;
    assign seq_vld     = (state == SEQ1 || state == SEQ0) && cnt_seq_nxt == N ; 

    assign cnt_seq_clr = state == SEQ10 && cnt_seq == M || state == IDLE; 
    assign sub_vld     = state == SEQ0  && cnt_seq_nxt == M && cnt_sub_nxt == N ; // have detected AAAA...
    assign cnt_sub_en  = seq_vld ;
    assign cnt_sub_nxt = state == SEQ10 && cnt_sub_en ? cnt_sub + 1'd1 : cnt_sub ;    
    
    always_comb begin
        cnt_seq_nxt = cnt_seq ;
        if(state==SEQ1 || state==SEQ0 )begin
            cnt_seq_nxt = cnt_seq_clr ? 'd0 : cnt_seq + 1'd1 ; 
        end
    end
 
    always_ff @( posedge clk, negedge rst_n) begin
        if( !rst_n ) begin
            state <= IDLE ; 
        end
        else begin
            state <= next_state ;
        end
    end      

    always_comb begin
        next_state = state ;
        case (state) 
            IDLE: begin
                    data_in ? next_state = SEQ1 : IDLE ;
                  end
            SEQ1: begin
                    if (data_in && seq_vld) begin
                        next_state = SEQ0 ;
                    end
                    else if (!data_in ) begin
                        next_state = IDLE ;
                    end
                  end
            SEQ0: begin
                    if (!data_in && seq_vld) begin
                        if(sub_vld) begin
                            next_state = SEQ10 ;
                        end
                        else begin
                            next_state = SEQ1  ;
                        end
                    end
                    else if (data_in) begin
                        next_state = IDLE  ;
                    end
                  end
            SEQ10:begin
                    if(data_in) begin
                        next_state = SEQ1 ;
                    end
                    else begin
                        next_state = IDLE ;
                    end
                  end
            default: begin end ;
        endcase
    end

    assign dec_pulse_nxt = next_state == SEQ10 ;
 
    always_ff (posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            cnt_seq     <=  'd0 ;
            cnt_sub     <=  'd0 ;
            dec_pulse   <= 1'b0 ;
        end
        else begin
            cnt_seq     <= cnt_seq_nxt   ;
            cnt_sub     <= cnt_sub_nxt   ;
            dec_pulse   <= dec_pulse_nxt ; 
        end
    end

endmodule   
