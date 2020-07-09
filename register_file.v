`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/22 21:04:02
// Design Name: 
// Module Name: register_file
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module register_file(
	input clk,
	input reset,
	input [4:0] RS_Addr_1,
	input [4:0] RS_Addr_2,
	input [4:0] RT_Addr_1,
	input [4:0] RT_Addr_2,
	input Write_Enable_1,
	input Write_Enable_2,
	input [4:0] Write_Addr_1,
	input [4:0] Write_Addr_2,
	input [31:0] Write_Data_1,
	input [31:0] Write_Data_2,
	// Output
	output [31:0] RS_Data_1,
	output [31:0] RS_Data_2,
	output [31:0] RT_Data_1,
	output [31:0] RT_Data_2
    );
	
	reg [31:0] Register[31:0];
	
	assign RS_Data_1 = (RS_Addr_1 == 0) ? 0 : Register[RS_Addr_1];
	assign RT_Data_1 = (RT_Addr_1 == 0) ? 0 : Register[RT_Addr_1];
	assign RS_Data_2 = (RS_Addr_2 == 0) ? 0 : Register[RS_Addr_2];
	assign RT_Data_2 = (RT_Addr_2 == 0) ? 0 : Register[RT_Addr_2];
	
	always @(posedge clk)
	begin
		if(Write_Enable_1 && (Write_Addr_1 != 0) )
		begin
			Register[Write_Addr_1] <= Write_Data_1;
		end
	end
	
	always @(posedge clk)
	begin
		if( Write_Enable_2 && (Write_Addr_2 != 0) )
		begin
			#5
			Register[Write_Addr_2] <= Write_Data_2;
		end
	end
	

always @ (negedge reset) begin //Execute when reset is asserted
	Register[0] <=32'b0 ;
	Register[1] <=32'b0 ;
	Register[2] <=32'b0 ;
	Register[3] <=32'b0 ;
	Register[4] <=32'b0 ;
	Register[5] <=32'b0 ;
	Register[6] <=32'b0 ;
	Register[7] <=32'b0 ;
	Register[8] <=32'b0 ;
	Register[9] <=32'b0 ;
	Register[10] <=32'b0 ;
	Register[11] <=32'b0 ;
	Register[12] <=32'b0 ;
	Register[13] <=32'b0 ;
	Register[14] <=32'b0 ;
	Register[15] <=32'b0 ;
	Register[16] <=32'b0 ;
	Register[17] <=32'b0 ;
	Register[18] <=32'b0 ;
	Register[19] <=32'b0 ;
	Register[20] <=32'b0 ;
	Register[21] <=32'b0 ;
	Register[22] <=32'b0 ;
	Register[23] <=32'b0 ;
	Register[24] <=32'b0 ;
	Register[25] <=32'b0 ;
	Register[26] <=32'b0 ;
	Register[27] <=32'b0 ;
	Register[28] <=32'b0 ;
	Register[29] <=32'b0 ;
	Register[30] <=32'b0 ;
	Register[31] <=32'b0 ;
end

	initial
	begin
		Register[0] <= 0;
	end
endmodule
