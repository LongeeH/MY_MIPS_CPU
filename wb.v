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
	clk			                    ʱ���ź�
	reset		                    �����ź�
	controlw_MEM                    [24:20]�Ĵ������еļĴ������루ID�е�resultdes��
                                    ���ƣ�[9]���ƼĴ������Ƿ�д�루ID�е�write_reg��
                                    ���ƣ�[27]��[28]�ֱ����lo��hi��д�루��ӦID�е�write_lo��write_hi��
	result			                MEMָ�����ݽ��
	WB_hi_lo(write_back_hight_low)  Ҫд�������
	
    reg_result                      ָ��c�����нᖨ
	write_reg                       ��־���Ƿ�ѽ��д��Ĵ�����د
    write_hi                        ��־���Ƿ������д�뵽�Ĵ���hiد
    write_lo                        ��־���Ƿ������д�뵽�Ĵ���loد
    reg_hi                          �Ĵ���hi
    reg_lo                          �Ĵ���lo
    result_des                      ��ʶWBִ�н׶��н����Ҫд��ļĴ���?

	
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