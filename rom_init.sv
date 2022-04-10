module rom(
	input logic clk,
	input logic rst_n,
//	input [7:0]addr,
	
//	output [3:0]data
        output logic [3:0] rm0,
        output logic [3:0] rm1,
        output logic [3:0] rm2,
        output logic [3:0] rm3,
        output logic [3:0] rm4,
        output logic [3:0] rm5,
        output logic [3:0] rm6,
        output logic [3:0] rm7

);


//    wire [7:0] addr ;
//    wire  [3:0] data;
(* ASYNC_REG = "TRUE" *) reg [3:0] rom_md[7:0];

//---solution 1 MUX ----------------
   // always @(posedge clk or negedge rst_n) begin
   //     if (!rst_n) begin
   //         rom_md[0] <= 4'd0  ;
   //         rom_md[1] <= 4'd2  ;
   //         rom_md[2] <= 4'd4  ;
   //         rom_md[3] <= 4'd6  ;
   //         rom_md[4] <= 4'd8  ;
   //         rom_md[5] <= 4'd10 ;
   //         rom_md[6] <= 4'd12 ;
   //         rom_md[7] <= 4'd14 ;
   //     end
   // end

 //--solution 2   for loop -------------
 //but it doesnot work because rom_md[0] is not initial to zero before for loop
 // "<=" revised as "=" it will work 

    parameter  DEPTH = 8 ;
    integer i ;
    always @(posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
 //           rom_md[0] <= 4'd0 ;
            rom_md[0] = 4'd0 ;
            for (i = 0; i <=DEPTH-2 ; i = i+1 ) begin
 //               rom_md[i+1] <= rom_md[i] + 4'd2 ; 
                rom_md[i+1] = rom_md[i] + 4'd2 ; 
            end
        end
    end

//    assign data = rom_md [addr] ;

    assign rm0 = rom_md[0];    
    assign rm1 = rom_md[1];
    assign rm2 = rom_md[2];
    assign rm3 = rom_md[3];
    assign rm4 = rom_md[4];
    assign rm5 = rom_md[5];
    assign rm6 = rom_md[6];
    assign rm7 = rom_md[7];


//generate
//    for (i=0;i<8;i++) begin
//        always @(posedge clk or negedge rst_n)
//            if (!rst_n) begin
//                rom[i]<= 2*i;
//            end
//        end
//endgenerate

endmodule
