`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/10 16:46:07
// Design Name: 
// Module Name: mem
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
    reset
    clk
	CONTROLW_EXE[31:0]	
	INTCONTROLW_EXE[7:0]	
	ALURES[31:0]	
	MEMDATAI[31:0]	
	CP0DATAI[31:0]	
	MEMHILO[31:0]	
	MEMDATA[31:0]	
	MEMPC[31:0]	
	EXEDES[6:0]	
	EXEWRITEHILO[1:0]	
	TRANDATADDR			�Ƿ���ҪЭ������ CP0 ���������ַ�������ַ�ĵ�ַת���� 
	SORL				��ȡ�洢���Ĳ�����д�������Ƕ�������
	WRITEMEM			�Ƿ������д��洢��
	READCP0REG			��ȡ CP0 �Ĳ����Ƕ�������
	WRITECP0REG			��ȡ CP0 �Ĳ�����д������
	TLBOPE				Ϊ CP0 ���� TLB ������ʹ���źš�
	DADDR[31:0]			��Ҫ�洢�����ݵ�ַ
	DATAO[31:0]			cpu���������
	INTV[7:0]			�жϿ����ź�
	CP0REGINDEX[4:0]	CP0��ؼĴ���������ѡַ�źš� 
	TLBOP[1:0]			CP0���е� TLB �������͡�
	RESULT[31:0]		MEM����ָ�����ݽ������
	CONTROLW_MEM[31:0]	��ˮ��һ�׶�
	WBHILO[31:0]		��ˮ��һ�׶�
	MEMRESULT[31:0]		�������ʱǰ�ݸ�ID�滻��Դ
	MEMHILORES[31:0]	�������ʱǰ�ݸ�ID�滻��Դ
	MEMDES[6:0]			����ID������������صĿ����ź�
	MEMWRITEHILO[1:0]	����ID������������صĿ����ź�
	INTPC[31:0]			�жϻָ���ַ��


*/

module mem(
    input clk,
    input reset,
	input [31:0]CONTROLW_EXE,
	input [7:0]INTCONTROLW_EXE,
	input [31:0]ALURES,
	input [31:0]MEMDATAI,
	input [31:0]CP0DATAI,
	input [31:0]MEMHILO,
	input [31:0]MEMDATA,
	input [31:0]MEMPC,
	input [6:0]EXEDES,
	input [1:0]EXEWRITEHILO,
	output TRANDATADDR,
	output SORL,
	output WRITEMEM,
	output READCP0REG,
	output WRITECP0REG,
	output TLBOPE,
	output [31:0]DADDR,
	output [31:0]DATAO,
	output [7:0]INTV,
	output [4:0]CP0REGINDEX,
	output [1:0]TLBOP,
	output [31:0]RESULT,
	output [31:0]CONTROLW_MEM,
	output [31:0]WBHILO,
	output [31:0]MEMRESULT,
	output [31:0]MEMHILORES,
	output [6:0]MEMDES,
	output [1:0]MEMWRITEHILO,
	output [31:0]INTPC,
	output [31:0]WB_PC


    );
	reg [31:0]MEMRES;
	reg [31:0]DADDR;
	reg [31:0]DATAO;
	reg TRANDATADDR;
	reg SORL;
	reg [7:0]INTV;
	reg WRITEMEM;
	reg	READCP0REG;
	reg	WRITECP0REG;
	reg	TLBOPE;
	reg	[4:0]CP0REGINDEX;
	reg	[1:0]TLBOP;
	reg	[31:0]INTPC;
	reg	[31:0]WBHILO;
	reg	[31:0]CONTROLW_MEM;
	reg	[31:0]RESULT;
	reg	[31:0]WB_PC;
	wire[31:0]MEMRESULT;
	wire[31:0]MEMHILORES;
	
	always@(*)//CP0�������ָ��
	begin 
		DADDR<=ALURES; 
		DATAO<=MEMDATA; 
		TRANDATADDR<=(CONTROLW_EXE[7]||CONTROLW_EXE[8]); 
		SORL<=CONTROLW_EXE[7]; 
		INTV<=INTCONTROLW_EXE; 
		WRITEMEM<=CONTROLW_EXE[7]; 
		READCP0REG<=CONTROLW_EXE[16]; 
		WRITECP0REG<=CONTROLW_EXE[15]; 
		TLBOPE<=CONTROLW_EXE[19]; 
		CP0REGINDEX<=CONTROLW_EXE[14:10]; 
		TLBOP<=CONTROLW_EXE[18:17]; 
		INTPC<=MEMPC; 
	end 
	
	always@(*)//��ԭ��ƵĴ���2_1����������һ��������������
	begin 
		case({CONTROLW_EXE[16],CONTROLW_EXE[8]})
			2'b00:begin
				MEMRES[31:0]=ALURES;
			end
			2'b01:begin
				MEMRES[31:0]=MEMDATAI;
			end
			2'b10:begin
				MEMRES[31:0]=CP0DATAI;
			end
			2'b11:begin
				MEMRES[31:0]=CP0DATAI;
			end
		endcase
	end 
	
	always @(negedge reset or posedge clk) //ԭ��Ƶ���ˮ�ߣ������һ��always����ʵ��
    begin  
		if(reset==0) 
			begin 
				RESULT<=32'b0; 
				CONTROLW_MEM<=32'b0; 
				WBHILO<=32'b0; 
			end 
        else  
			begin 
				WBHILO<=MEMHILO; 
				CONTROLW_MEM<=CONTROLW_EXE; 
				RESULT<=MEMRES; 
				WB_PC<=MEMPC; 
            end 
    end 
	
	//��EXEһ���Ĵ���ʽ���ڼĴ���ǰֱ�����������������ǰ����ǰ��Ҳ������ȷ
	assign MEMRESULT=MEMRES;
	assign MEMHILORES=MEMRES;


endmodule
