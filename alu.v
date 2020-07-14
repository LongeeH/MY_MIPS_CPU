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
	clk				时钟信号
	reset			重置信号（未使用
	alu_a[31:0]		操作数a
	alu_b[31:0]		操作数b
	alu_op[4:0]		aluop
	alu_int_ov		溢出
	alu_res[31:0]	结果
	
					alu
		---------------------------------
		|								|
		|	clk			alu_res[31:0]	|
		|								|
		|	reset			alu_int_ov	|
		|								|
		|	alu_a[31:0]					|
		|								|
		|	alu_b[31:0]					|
		|								|
		|	alu_op[4:0]					|
		|								|
		---------------------------------
	
	这个alu不仅仅是组合逻辑，也负责保存了上次的计算结果在寄存器中。这个寄存器收到clk更新，收到reset置零。
	alu_1和alu_2似乎完全一致
*/


module ALU(
	input clk,
	input reset,
	input [31:0]alu_a,
    input [31:0]alu_b,
    input [4:0]alu_op,
    output [31:0]alu_res,
    output alu_int_ov
    );
    //reg [31:0]alu_res;
	reg [32:0]result;//考虑一位进位
	always@(*)//纯硬布线的ALU实现
	begin
		case(alu_op)//ALUOP参考page45
			5'b00000:begin
				result=alu_a&alu_b;
			end
			5'b01000:begin
				result=alu_a|alu_b;
			end
			5'b10000:begin
				result=~(alu_a|alu_b);
			end
			5'b11000:begin
				result=alu_a^alu_b;
			end
			5'b00001:begin
				result=alu_a+alu_b;
			end
			5'b01001:begin
				result=alu_a-alu_b;
			end
			5'b01010:begin
				result=(alu_a-alu_b)<0?1:0;
			end
			5'b00100:begin//可以另一种实现方法
				if(alu_a==0) {result[31:0],result[32]}={alu_b,1'b0};
                else {result[31:0],result[32]}=alu_b>>(alu_a-1);
			end
			5'b01100:begin
				if(alu_a==0) {result[31:0],result[32]}={alu_b,1'b0};
                else {result[31:0],result[32]}=alu_b>>>(alu_a-1);
			end
			5'b10100:begin
				result=alu_b<<alu_a[10:6];
			end
			5'b11100:begin
				result={alu_b[15:0],16'b0};
			end
			default:begin
				result=33'b0;//默认项，留作调试变量
			end
		endcase
	end
	assign alu_int_ov=result[32];//溢出位
	assign alu_res=result;
/*	always@(posedge reset or negedge clk)//时序驱动这个时序驱动是推测的！
	begin
		if(reset)
			alu_res<=32'b0;
		else
			alu_res<=result;
	end
*/
endmodule
