`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/07 20:55:55
// Design Name: 
// Module Name: wb
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
	clk			                    时钟信号
	reset		                    重置信号
	controlw_MEM                    [24:20]寄存器堆中的寄存器号码（ID中的resultdes＿
                                    控制，[9]控制寄存器堆是否写入（ID中的write_reg＿
                                    控制，[27]和[28]分别控制lo和hi的写入（对应ID中的write_lo和write_hi＿
	result			                MEM指令数据结果
	WB_hi_lo(write_back_hight_low)  要写入的数据
	
    reg_result                      指令朿终运行结枿
	write_reg                       标志，是否把结果写入寄存器堆丿
    write_hi                        标志，是否把数据写入到寄存器hi丿
    write_lo                        标志，是否把数据写入到寄存器lo丿
    reg_hi                          寄存器hi
    reg_lo                          寄存器lo
    result_des                      标识WB执行阶段中结果需要写入的寄存器?

	
				            	wb
		-------------------------------------------------
		|								                |
		|	clk				        reg_result[31:0]    |
		|								                |
		|	reset				    write_reg           |
		|								                |
		|	controlw_MEM[31:0]		write_hi            |
		|								                |
		|	result[31:0]			write_lo            |
		|								                |
		|	WB_hi_lo[4:0]			reg_hi[31:0]        |
        |								                |
        |	WBPC[31:0] 				reg_lo[31:0]        |
		|								                |
        |	         				result_des[4:0]     |
        |								                |
		-------------------------------------------------

*/
module WB(
	input clk,
	input reset,
	input [31:0]controlw_MEM,
    input [31:0]result,
    input [31:0]WB_hi_lo,
    input [31:0]WB_PC,
    output [31:0]reg_result,
    output write_reg,
    output write_hi,
    output write_lo,
    output [4:0]result_des,
    output [31:0]reg_hi,
    output [31:0]reg_lo,
	output [31:0]wb_pc_debug
    );

reg write_reg;
reg write_hi;
reg write_lo;
reg [31:0]reg_hi;
reg [31:0]reg_lo;
reg [4:0]result_des;
reg [31:0]reg_result;
reg [31:0]wb_pc_debug;

// assign wb_pc_debug=WB_PC;

always @(negedge reset or posedge clk)
    begin
        if(reset==0)
            begin
                reg_result<=32'b0;
                reg_hi<=32'b0;
                reg_lo<=32'b0;
                result_des<=5'b0;
                write_reg<=0;
                write_hi<=0;
                write_lo<=0;
            end
        else
            begin
				wb_pc_debug<=WB_PC;
                reg_result<=result;
                result_des<=controlw_MEM[24:20];
                write_reg<=controlw_MEM[9];
                write_hi<=controlw_MEM[28];
                write_lo=controlw_MEM[27];
                reg_hi<=WB_hi_lo;
                reg_lo<=WB_hi_lo;
            end
    end
endmodule