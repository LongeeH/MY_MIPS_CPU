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
	CONTROLW_ID[31:0]		ID�ṩ�Ŀ�����
	INTCONTROLW_ID[7:0]		ID�ṩ���жϿ�����
	EXEPC[31:0]				ID�ṩ��PC��һ���ں��MEMPC[31:0]
	REGRESA[31:0]			�Ĵ���A����
	REGRESB[31:0]			�Ĵ���B����
	IDDES[6:0]				ID�ṩ�Ľ�������ź�DES��һ���ں��MEMDES[7:0]��ALUDES[6:0]
	IDWRITEHILO[1:0]		ID�ṩ��WIRITEHILO��һ���ں��EXEWRITEHILO[1:0]	��ALUWRITEHILO[1:0]	
	IMMED[31;0]				32λ������
	
	EXEDES[6:0]				
	EXEWRITEHILO[1:0]		
	ALUDES[6:0]				ǰ?��ID�ж�������صĿ����ź�
	ALUWRITEHILO[1:0]		ǰ?��ID�ж�������صĿ����ź�
	ALURES[31:0]			ALU���������EXE
	MEMDATA[31:0]			����Ĵ���REGRESB����
	CONTROLW_EXE[31:0]		CONTROLW_ID[31:0]��ˮ
	INTCONTROLW_EXE[7:0]	INTCONTROLW_ID[7:0]��ˮ��INTCONTROLW_ID[2]�滻Ϊ������ź�
	MEMPC[31:0]				EXEPC[31:0]��ˮ
	MEMHILO[31:0]			����Ĵ���REGRESA������
	ALURESULT[31:0]			ALU������������������ʱǰ�ݸ�ID
	ALUHILORES[31:0]		ALU������������������ʱǰ�ݸ�ID
	
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
	always@(*)//MUX2����A����
	begin
		case(CONTROLW_ID[5])
			1'b0:begin
				mux2_out=REGRESA;
			end
			1'b1:begin
				{mux2_out[31:16],mux2_out[15:0]}={16'b0,IMMED[15:0]};
			end
			default:begin
				mux2_out=32'b0;//Ĭ����������Ա���
			end
		endcase
	end
	
	always@(*)//MUX4����B����
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
				mux4_out=32'b0;//Ĭ����������Ա���
			end
		endcase
	end
	
	always @(IDDES or IDWRITEHILO)//������صĿ����ź�
	begin
		ALUDES<=IDDES;
		ALUWRITEHILO<=IDWRITEHILO;
    end

	always @(negedge reset or negedge clk)//��ˮ�ߴ���
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
	
	//��������Ϊ�Ʋ⣬ֱ��������һ���Ĵ���������Ȼ������������
	assign ALURESULT=ALURESB;
	assign ALUHILORES=ALURESB;
	
	
endmodule
