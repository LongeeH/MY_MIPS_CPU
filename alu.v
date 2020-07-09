`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/04 21:14:55
// Design Name: 
// Module Name: alu
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
/*
	clk			时钟信号
	reset		重置信号（未使用
	a[31:0]		操作数a
	b[31:0]		操作数b
	control[4:0]aluop
	intov		溢出
	r[31:0]			结果
	
					alu
		---------------------------------
		|								|
		|	clk					r[31:0]	|
		|								|
		|	reset				intov	|
		|								|
		|	a[31:0]						|
		|								|
		|	b[31:0]						|
		|								|
		|	control[4:0]				|
		|								|
		---------------------------------
	
	这个alu不仅仅是组合逻辑，也负责保存了上次的计算结果在寄存器中。这个寄存器收到clk更新，收到reset置零。
	alu_1和alu_2似乎完全一致
*/


module alu(
	input clk,
	input reset,
	input [31:0]a,
    input [31:0]b,
    input [4:0]control,
    output [31:0]r,
    output intov
    );
    //reg [31:0]r;
	reg [32:0]result;//考虑一位进位
	always@(*)//纯硬布线的ALU实现
	begin
		case(control)//ALUOP参考page45
			5'b00000:begin
				result=a&b;
			end
			5'b01000:begin
				result=a|b;
			end
			5'b10000:begin
				result=~(a|b);
			end
			5'b11000:begin
				result=a^b;
			end
			5'b00001:begin
				result=a+b;
			end
			5'b01001:begin
				result=a-b;
			end
			5'b01010:begin
				result=(a-b)<0?1:0;
			end
			5'b00100:begin//可以另一种实现方法
				if(a==0) {result[31:0],result[32]}={b,1'b0};
                else {result[31:0],result[32]}=b>>(a-1);
			end
			5'b01100:begin
				if(a==0) {result[31:0],result[32]}={b,1'b0};
                else {result[31:0],result[32]}=b>>>(a-1);
			end
			5'b10100:begin
				result=b<<a;
			end
			5'b11100:begin
				result={b[15:0],16'b0};
			end
			default:begin
				result=33'b0;//默认项，留作调试变量
			end
		endcase
	end
	assign intov=result[32];//溢出位
	assign r=result;
/*	always@(posedge reset or negedge clk)//时序驱动这个时序驱动是推测的！
	begin
		if(reset)
			r<=32'b0;
		else
			r<=result;
	end
*/
endmodule
