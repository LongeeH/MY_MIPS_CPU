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
	
	这个alu不仅仅是组合逻辑，也负责保存了上次的计算结果在寄存器中�?�这个寄存器收到clk更新，收到reset置零�?
	alu_1和alu_2似乎完全�?�?
*/


module ALU(
	input clk,
	input reset,
	input signed[31:0]alu_a,
    input signed[31:0]alu_b,
    input [4:0]alu_op,
    input alu_srcA,
    output [31:0]alu_res,
    output alu_int_ov
    );
	wire [31:0]alu_a_u;
	wire [31:0]alu_b_u;
	assign alu_a_u=alu_a;
	assign alu_b_u=alu_b;
	reg alu_int_ov;
	
    //reg [31:0]alu_res;
	reg [32:0]result;//考虑�?位进�?
	always@(*)//纯硬布线的ALU实现
	begin
		case(alu_op)//ALUOP参�?�page45
			5'b00000:begin
				result=alu_a&alu_b;
			end
			5'b00001:begin
				result=alu_a+alu_b;
				alu_int_ov=(alu_a[31]^~alu_b[31])&&(result[31]!=alu_a[31]);
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
			5'b01001:begin
				result=alu_a-alu_b;
				alu_int_ov=(alu_a[31]^alu_b[31])&&(result[31]!=alu_a[31]);
			end
			5'b01010:begin
				// result=(alu_a-alu_b)<0?1:0;
				result=(alu_a<alu_b)?1:0;
			end
			5'b01011:begin
				// result=(alu_a-alu_b)<0?1:0;
				result=(alu_a_u<alu_b_u)?1:0;
			end
			5'b00100:begin//可以另一种实现方�?
				result=alu_srcA?alu_b_u>>alu_a_u[10:6]:alu_b_u>>alu_a_u[4:0];
			end
			5'b01100:begin
				result=alu_srcA?alu_b>>>alu_a[10:6]:alu_b>>>alu_a[4:0];
			end
			5'b10100:begin
				result=alu_srcA?alu_b<<alu_a[10:6]:alu_b<<alu_a[4:0];
			end
			5'b11100:begin
				result={alu_b[15:0],16'b0};
			end
			default:begin
				result=33'b0;//默认项，留作调试变量
			end
		endcase
	end
	// assign alu_int_ov=(alu_a[32]^~alu_b[32])&&(result[31]!=alu_a[31]);//溢出�?
	// assign alu_int_ov=result[32];//溢出�?
	assign alu_res=result;
/*	always@(posedge reset or negedge clk)//时序驱动这个时序驱动是推测的�?
	begin
		if(reset)
			alu_res<=32'b0;
		else
			alu_res<=result;
	end
*/
endmodule
