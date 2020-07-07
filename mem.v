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
	TRANDATADDR			是否需要协处理器 CP0 进行虚拟地址到物理地址的地址转换。 
	SORL				存取存储器的操作是写操作还是读操作。
	WRITEMEM			是否把数据写入存储器
	READCP0REG			存取 CP0 的操作是读操作。
	WRITECP0REG			存取 CP0 的操作是写操作。
	TLBOPE				为 CP0 进行 TLB 操作的使能信号。
	DADDR[31:0]			需要存储的数据地址
	DATAO[31:0]			cpu输出的数据
	INTV[7:0]			中断控制信号
	CP0REGINDEX[4:0]	CP0相关寄存器操作的选址信号。 
	TLBOP[1:0]			CP0进行的 TLB 操作类型。
	RESULT[31:0]		MEM级的指令数据结果？？
	CONTROLW_MEM[31:0]	流水下一阶段
	WBHILO[31:0]		流水下一阶段
	MEMRESULT[31:0]		数据相关时前递给ID替换来源
	MEMHILORES[31:0]	数据相关时前递给ID替换来源
	MEMDES[6:0]			反馈ID，处理数据相关的控制信号
	MEMWRITEHILO[1:0]	反馈ID，处理数据相关的控制信号
	INTPC[31:0]			中断恢复地址。


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
	
	always@(*)//CP0操作相关指令
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
	
	always@(*)//将原设计的串联2_1译码器改作一个四输入译码器
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
	
	always @(negedge reset or posedge clk) //原设计的流水线，结合上一个always重新实现
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
	
	//和EXE一样的处理方式，在寄存器前直接相连结果，将数据前递提前，也许并不正确
	assign MEMRESULT=MEMRES;
	assign MEMHILORES=MEMRES;


endmodule
