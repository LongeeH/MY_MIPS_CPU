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
module Register_HiLo(
	input clk,
	input reset,
	input hilo_w_en_1,
	input hilo_w_en_2,
	input [31:0] hilo_w_data_1,
	input [31:0] hilo_w_data_2,
	output [31:0] hilo_r_data
    );
	
	reg [31:0] Register;
	assign hilo_r_data=Register;
	
	always @(negedge clk)
	begin
		if(hilo_w_en_1)
		begin
			Register<= hilo_w_data_1;
		end
		else if(hilo_w_en_2)
		begin
			Register<= hilo_w_data_2;
		end
	end
	
	// always @(negedge clk)
	// begin
		// if(hilo_w_en_2)
		// begin
			// Register<= hilo_w_data_2;
		// end
	// end
	
	always @ (negedge reset) begin
		Register <= 32'b0 ;
	end
endmodule
