interface StkRamIf;
    parameter  AW    = 5;
    parameter  DW    = 32;
    parameter  STB_N = 1;//write strobe

    wire             rd_vld   ;
    wire [AW   -1:0] rd_adr   ;
    wire [DW   -1:0] rd_dat   ;
    wire             rd_ack   ;
    wire             rd_rdy   ;

    wire [STB_N-1:0] wr_vld   ;
    wire [AW   -1:0] wr_adr   ;
    wire [DW   -1:0] wr_dat   ;
    wire             wr_rdy   ;

    modport Master(
        input  rd_dat,rd_ack,rd_rdy, wr_rdy,
        output rd_vld,rd_adr, wr_vld,wr_adr,wr_dat
        );

    modport Slave(
        output rd_dat,rd_ack,rd_rdy, wr_rdy,
        input  rd_vld,rd_adr, wr_vld,wr_adr,wr_dat
        );
endinterface
