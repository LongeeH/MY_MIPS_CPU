`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/07 22:27:08
// Design Name: 
// Module Name: exe
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
	clk
	reset
	CONTROLW_ID[31:0]		ID提供的控制字
	INTCONTROLW_ID[7:0]		ID提供的中断控制字
	EXEPC[31:0]				ID提供的PC。一周期后给MEMPC[31:0]
	REGRESA[31:0]			寄存器A数据
	REGRESB[31:0]			寄存器B数据
	IDDES[6:0]				ID提供的结果控制信号DES。一周期后给MEMDES[7:0]、ALUDES[6:0]
	IDWRITEHILO[1:0]		ID提供的WIRITEHILO。一周期后给EXEWRITEHILO[1:0]	、ALUWRITEHILO[1:0]	
	IMMED[31;0]				32位立即数
	
	EXEDES[6:0]				
	EXEWRITEHILO[1:0]		
	ALUDES[6:0]				前?给ID判断数据相关的控制信号
	ALUWRITEHILO[1:0]		前?给ID判断数据相关的控制信号
	ALURES[31:0]			ALU计算结果输出EXE
	MEMDATA[31:0]			输入寄存器REGRESB的数
	CONTROLW_EXE[31:0]		CONTROLW_ID[31:0]流水
	INTCONTROLW_EXE[7:0]	INTCONTROLW_ID[7:0]流水，INTCONTROLW_ID[2]替换为移溢出信号
	MEMPC[31:0]				EXEPC[31:0]流水
	MEMHILO[31:0]			输入寄存器REGRESA的数捿
	ALURESULT[31:0]			ALU计算结果输出，数据相关时前递给ID
	ALUHILORES[31:0]		ALU计算结果输出，数据相关时前递给ID
	
*/

module exe(
	input clk,
	input reset,
	input [31:0]CONTROLW_ID,	
	input [7:0]INTCONTROLW_ID,	
	input [31:0]EXEPC,
	input [31:0]REGRESA,
	input [31:0]REGRESB,
	input [6:0]IDDES,
	input [1:0]IDWRITEHILO,
	input [31:0]IMMED,
	output [6:0]EXEDES,
	output [1:0]EXEWRITEHILO,
	output [6:0]ALUDES,
	output [1:0]ALUWRITEHILO,
	output [31:0]ALURES,
	output [31:0]MEMDATA,
	output [31:0]CONTROLW_EXE,
	output [7:0]INTCONTROLW_EXE,
	output [31:0]MEMPC,
	output [31:0]MEMHILO,
	output [31:0]ALURESULT,
	output [31:0]ALUHILORES
    );
	reg [31:0]mux2_out;
	reg [31:0]mux4_out;
	wire [31:0]ALURESB;
	wire ALUINTOV;
	
	reg [7:0]ALUDES;
	reg [1:0]ALUWRITEHILO;
	reg [31:0]ALURES;
	reg [31:0]MEMDATA;
	reg [31:0]CONTROLW_EXE;
	reg [7:0]INTCONTROLW_EXE;
	reg [31:0]MEMPC;
	reg [31:0]MEMHILO;
	reg [6:0]EXEDES;
	reg [1:0]EXEWRITEHILO;
	always@(*)//MUX2决定A输入
	begin
		case(CONTROLW_ID[5])
			1'b0:begin
				mux2_out=REGRESA;
			end
			1'b1:begin
				{mux2_out[31:16],mux2_out[15:0]}={16'b0,IMMED[15:0]};
			end
			default:begin
				mux2_out=32'b0;//默认项，留作调试变量
			end
		endcase
	end
	
	always@(*)//MUX4决定B输入
	begin
		case({CONTROLW_ID[31],CONTROLW_ID[30]})
			2'b00:begin
				mux4_out=REGRESB;
			end
			2'b01:begin
				mux4_out=IMMED;
			end
			2'b10:begin
				{mux4_out[31:16],mux4_out[15:0]}={16'b0,IMMED[15:0]};
			end
			2'b11:begin
				mux4_out=REGRESA;
			end
			default:begin
				mux4_out=32'b0;//默认项，留作调试变量
			end
		endcase
	end
	
	always @(IDDES or IDWRITEHILO)//数据相关的控制信号
	begin
		ALUDES<=IDDES;
		ALUWRITEHILO<=IDWRITEHILO;
    end

	always @(negedge reset or posedge clk)//流水线处理
	begin
		if(reset==0)
		begin
			ALURES<=32'b0;
			MEMDATA<=32'b0;
			CONTROLW_EXE<=32'b0;
			INTCONTROLW_EXE<=8'b0;
			MEMPC<=32'b0;
			MEMHILO<=32'b0;
			EXEDES<=7'b0;
			EXEWRITEHILO<=2'b0;
            end
        else
		begin
			ALURES<=ALURESB;
            MEMDATA<=REGRESB;
            MEMPC<=EXEPC;
            MEMHILO<=REGRESA;
            EXEDES<=IDDES;
            EXEWRITEHILO<=IDWRITEHILO;
			CONTROLW_EXE[31:0]<=CONTROLW_ID[31:0];
			INTCONTROLW_EXE[7:0]<={INTCONTROLW_ID[7:3],ALUINTOV,INTCONTROLW_ID[1:0]};
		end
	end
	
	alu  _ALU(
		.clk(clk),
		.reset(reset),
		.a(mux2_out),
		.b(mux4_out),
		.control(CONTROLW_ID[4:0]),
		.r(ALURESB),
		.intov(ALUINTOV)
	);
	
	//以下两行为推测，直连能跳过一个寄存器，但仍然不正常。。。
	assign ALURESULT=ALURESB;
	assign ALUHILORES=ALURESB;
	
	
endmodule
