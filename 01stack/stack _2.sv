`ifndef StcuIBranchStack_V
`define StcuIBranchStack_V
module StcuIBranchStack #( parameter
    DW    = 98,
    DEPTH = 32,
    AW    = $clog2(DEPTH>2?DEPTH:2)//,
)
(
input  wire                     clk                 ,
input  wire                     rst_n               ,
input  wire                     clear               ,

input  wire                     cur_pc_rdy          ,
input  wire                     stk_wren            ,
input  wire [DW-1:0]            stk_wrdata          ,
input  wire                     stk_rden            ,
output wire [DW-1:0]            stk_rddata          ,
output wire                     stk_full            ,
output wire                     stk_empty           ,
output wire                     stk_hold            ,
//usr_ram_if
StkRamIf.Master                 stk_ram_if          //,
);

    localparam REG_DEPTH = 8 ;
    localparam REG_AW    = $clog2(REG_DEPTH>2? REG_DEPTH : 2) ;
    localparam RAM_DEPTH = DEPTH > REG_DEPTH ? (DEPTH - REG_DEPTH) : 0 ;
    
    reg [AW-1:0] stk_ptr ;
    reg [REG_DEPTH-1:0] [DW-1:0] reg_stack ;

    reg [1:0]           wr_ram_cnt ;
    reg [1:0]           rd_ram_cnt ;
    
    
    wire                rd_ram_vld ;
    wire[AW-1:0]        rd_ram_adr ;
    wire[DW-1:0]        rd_ram_dat ;
    wire                rd_ram_ack ;
    wire                rd_ram_rdy ;

    wire                wr_ram_vld ;
    wire[AW-1:0]        wr_ram_adr ;
    wire[DW-1:0]        wr_ram_dat ;
    wire                wr_ram_rdy ;

    wire                stk_stall  ;
    

    assign stk_ram_if.rd_vld = rd_ram_vld ;
    assign stk_ram_if.rd_adr = rd_ram_adr ;
    assign rd_ram_dat        = stk_ram_if.rd_dat ;
    assign rd_ram_rdy        = stk_ram_if.rd_rdy ;
    assign rd_ram_ack        = stk_ram_if.rd_ack ;
    
    assign stk_ram_if.wr_vld = wr_ram_vld ;
    assign stk_ram_if.wr_adr = wr_ram_adr ;
    assign stk_ram_if.wr_dat = wr_ram_dat ;
    assign wr_ram_rdy        = stk_ram_if.wr_rdy ; 

    
    always @( posedge clk or negedge rst_n) begin
        if( !rst_n) begin
            stk_ptr <= 'b0 ;
        end
        else if (clear) begin
            stk_ptr <= 'b0 ;
        end
        else if (cur_pc_rdy && stk_wren && stk_rden )begin
            stk_ptr <= stk_ptr ;
        end
        else if (cur_pc_rdy && stk_wren && !stk_full && !stk_stall) begin
            stk_ptr <= stk_ptr + 1'd1 ;
        end
        else if (cur_pc_rdy && stk_rden && !stk_empty && !stk_stall) begin
            stk_ptr <= stk_ptr - 1'd1 ;
        end
    end      

    wire[AW-1:0]      wr_adr     = stk_ptr ;
    wire[AW-1:0]      wr_adrsub1 = wr_adr[AW-1:2] - 1'd1 ; //write ram
    wire[REG_AW-1:0]  fet_reg_adr= {!wr_adr[2],wr_ram_cnt} ;

    wire[AW-1:0]      rd_adr     = stk_ptr - 1'd1 ;
    wire[AW-1:0]      rd_adrsub1 = rd_adr[AW-1:2] - 1'd1 ; //read ram
    wire[AW-1:0]      fet_ram_adr= {rd_adrsub1,rd_ram_cnt} ;
    
    
//write and read reg stack
    always @(posedge clk) begin
        if (stk_wren && !stk_full && !stk_stall) 
            reg_stack[stk_ptr[REG_AW-1:0]] <= stk_wrdata ;
        if (rd_ram_ack)
            reg_stack[rd_ram_cnt] <= rd_ram_dat ;
    end    

   // wire  ptr_class_0 = !stk_ptr[2] ; //ptr= 0~3,8~11 ,16~19,24~27
   // wire  ptr_class_1 =  stk_ptr[2] ; //ptr= 4~7,12~15,20~23,28~31

    reg  [1:0]          wr_ram_cnt       ; //0~3     
    reg  [1:0]          rd_ram_cnt       ; //0~3         

    reg not_wr_ram  ;
    reg not_rd_ram  ;
    reg write_state ;

    wire wr_ram_start = stk_wren && wr_adr[1:0] == 2'd3 && !wr_adr[AW-1:2] == 'd0 ; 
    reg  wr_ram_start_lock ;
    wire wr_ram_done  = wr_ram_vld && wr_ram_rdy && wr_ram_cnt == 2'd3 ;
    wire wr_ram_en    = (wr_ram_start || wr_ram_start_lock) && !not_wr_ram ;

    wire rd_ram_start = stk_rden && rd_adr[1:0] == 2'd0 && !rd_adr[AW-1:2] == 'd7 ;
    reg  rd_ram_start_lock ;
    wire rd_ram_done  = rd_ram_vld && rd_ram_rdy && rd_ram_cnt == 2'd3 ;
    wire rd_ram_en    = (rd_ram_start || rd_ram_start_lock) && !not_rd_ram ;

//--last state     
    always @( posedge clk or negedge rst_n) begin
        if( !rst_n ) begin
            write_state <= 1'b0 ;
        end
        else if (wr_ram_start)begin
            write_state <= 1'b1 ;
        end
        else if (rd_ram_start) begin
            write_state <= 1'b0 ;
        end
    end  

//--write ram control logic       
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ram_start_lock <= 1'b0 ;
        end
        else if (clear) begin
            wr_ram_start_lock <= 1'b0 ;
        end
        else if (wr_ram_done) begin
            wr_ram_start_lock <= 1'b0 ;
        end
        else  if (wr_ram_start)begin
            wr_ram_start_lock <= 1'b1 ;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ram_cnt <= 2'd0 ;
        end
        else if (clear || wr_ram_start) begin
            wr_ram_cnt <= 2'd0 ;
        end
        else if (wr_ram_en && wr_ram_rdy) begin
            wr_ram_cnt <= wr_ram_cnt + 1'd1 ;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            not_wr_ram <= 1'b0 ;
        end
        else if (rd_ram_start) begin
            not_wr_ram <= 1'b1 ;
        end
        else if (wr_ram_start) begin
            not_wr_ram <= 1'b0 ;
        end
    end  

//--read ram control logic ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ram_start_lock <= 1'b0 ;
        end
        else if (clear) begin
            rd_ram_start_lock <= 1'b0 ;
        end
        else if (rd_ram_done) begin
            rd_ram_start_lock <= 1'b0 ;
        end
        else if (rd_ram_start) begin
            rd_ram_start_lock <= 1'b1 ;
        end
    end
    

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ram_cnt <= 2'd0 ;
        end
        else if (clear || rd_ram_start) begin
            rd_ram_cnt <= 2'd0 ;
        end
        else if (rd_ram_en && rd_ram_rdy) begin
            rd_ram_cnt <= rd_ram_cnt + 1'd1 ;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            not_rd_ram <= 1'b0 ;
        end
        else if ( rd_ram_start) begin
                if (write_state) begin
                    not_rd_ram <= 1'b1 ;
                end
                else begin 
                    not_rd_ram <= 1'b0 ; 
                end
        end
    end


    assign wr_ram_vld = wr_ram_en ;               //o  stk_ram_if.wr_vld
    assign wr_ram_adr = {wr_adrsub1,wr_ram_cnt} ; //o  stk_ram_if.wr_adr
    assign wr_ram_dat = reg_stack[fet_reg_adr]  ; //o  stk_ram_if.wr_dat

    assign rd_ram_vld = rd_ram_en   ;             //o  stk_ram_if.rd_vld
    assign rd_ram_adr = fet_ram_adr ;             //o  stk_ram_if.rd_adr

    assign stk_rddata = reg_stack[rd_adr[REG_AW-1:0]] ; // top of stack
    assign stk_full   = stk_ptr == AW'(DEPTH-1) ;
    assign stk_empty  = stk_ptr == AW'(0      ) ;
//    assign stk_stall  = wr_adr == 2'd3 && wr_ram_en && stk_wren
//                     || rd_adr == 2'd0 && rd_ram_en && stk_rden ;
    assign stk_stall  = 1'b0 ;
    assign stk_hold   = stk_wren && stk_full || stk_rden && stk_empty ;

endmodule
`endif
