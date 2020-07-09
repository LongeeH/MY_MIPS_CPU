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
	clk			ʱ���ź�
	reset		�����źţ�δʹ��
	a[31:0]		������a
	b[31:0]		������b
	control[4:0]aluop
	intov		���
	r[31:0]			���
	
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
	
	���alu������������߼���Ҳ���𱣴����ϴεļ������ڼĴ����С�����Ĵ����յ�clk���£��յ�reset���㡣
	alu_1��alu_2�ƺ���ȫһ��
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
	reg [32:0]result;//����һλ��λ
	always@(*)//��Ӳ���ߵ�ALUʵ��
	begin
		case(control)//ALUOP�ο�page45
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
			5'b00100:begin//������һ��ʵ�ַ���
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
				result=33'b0;//Ĭ����������Ա���
			end
		endcase
	end
	assign intov=result[32];//���λ
	assign r=result;
/*	always@(posedge reset or negedge clk)//ʱ���������ʱ���������Ʋ�ģ�
	begin
		if(reset)
			r<=32'b0;
		else
			r<=result;
	end
*/
endmodule
