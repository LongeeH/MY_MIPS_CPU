`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/22 22:27:36
// Design Name: 
// Module Name: register_hilo
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

//hilo寄存器都用这一个文件生成
module register_hilo(
	input clk,
	input reset,
	input Write_Enable_1,
	input Write_Enable_2,
	input [31:0] Write_Data_1,
	input [31:0] Write_Data_2,
	output [31:0] HILO_Data
    );
	
	reg [31:0] Register;
	assign HILO_Data=Register;
	
	always @(posedge clk)
	begin
		if(Write_Enable_1)
		begin
			Register<= Write_Data_1;
		end
	end
	
	always @(posedge clk)
	begin
		if(Write_Enable_2)
		begin
			Register<= Write_Data_2;
		end
	end
	
	always @ (posedge reset) begin
		Register <= 32'b0 ;
	end
endmodule
