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
	clk			                            时钟信号
	reset		                            重置信号
	mem_contr_word_                          [24:20]寄存器堆中的寄存器号码（ID中的resultdes＿
                                            控制，[9]控制寄存器堆是否写入（ID中的write_reg＿
                                            控制，[27]和[28]分别控制lo和hi的写入（对应ID中的write_lo和write_hi＿
	result			                        MEM指令数据结果
	wb_hilo_data(write_back_hight_low)      要写入的数据
	
    wb_reg_data                             指令朿终运行结枿
	wb_reg_wr                               标志，是否把结果写入寄存器堆丿
    wb_hi_wr                                标志，是否把数据写入到寄存器hi丿
    wb_lo_wr                                标志，是否把数据写入到寄存器lo丿
    wb_hi_data                              寄存器hi
    wb_lo_data                              寄存器lo
    wb_res_des                              标识WB执行阶段中结果需要写入的寄存器?

	
				            	wb
		-------------------------------------------------
		|								                |
		|	clk				        wb_reg_data[31:0]   |
		|								                |
		|	reset				    wb_reg_wr           |
		|								                |
		|	mem_contr_word_[31:0]		wb_hi_wr        |
		|								                |
		|	mem_res[31:0]			wb_lo_wr            |
		|								                |
		|	wb_hilo_data[4:0]			wb_hi_data[31:0]|
        |								                |
        |	WBPC[31:0] 				wb_lo_data[31:0]    |
		|								                |
        |	         				wb_res_des[4:0]     |
        |								                |
		-------------------------------------------------

*/
module WB(
	input clk,
	input reset,
	input [31:0]mem_contr_word,
    input [31:0]mem_res,
    input [31:0]mem_hi_data,
    input [31:0]mem_lo_data,
    input [31:0]wb_pc,
    output [31:0]wb_reg_data,
    output wb_reg_wr,
    output wb_hi_wr,
    output wb_lo_wr,
    output [4:0]wb_res_des,
    output [31:0]wb_hi_data,
    output [31:0]wb_lo_data,
	output [31:0]wb_pc_debug
    );

// reg wb_reg_wr;
// reg wb_hi_wr;
// reg wb_lo_wr;
// reg [31:0]wb_hi_data;
// reg [31:0]wb_lo_data;
// reg [4:0]wb_res_des;
// reg [31:0]wb_reg_data;
// reg [31:0]wb_pc_debug;

// assign wb_pc_debug=wb_pc;

// always @(negedge reset or negedge clk)
    // begin
        // if(reset==0)
            // begin
                // wb_reg_data<=32'b0;
                // wb_hi_data<=32'b0;
                // wb_lo_data<=32'b0;
                // wb_res_des<=5'b0;
                // wb_reg_wr<=0;
                // wb_hi_wr<=0;
                // wb_lo_wr<=0;
            // end
        // else
            // begin
				// wb_pc_debug<=wb_pc;
                // wb_reg_data<=mem_res;
                // wb_res_des<=mem_contr_word[24:20];
                // wb_reg_wr<=mem_contr_word[9];
                // wb_hi_wr<=mem_contr_word[28];
                // wb_lo_wr=mem_contr_word[27];
                // wb_hi_data<=wb_hilo_data;
                // wb_lo_data<=wb_hilo_data;
            // end
    // end
	assign wb_pc_debug=wb_pc;
    assign wb_reg_data=mem_res;
    assign wb_res_des=mem_contr_word[24:20];
	assign wb_reg_wr=mem_contr_word[9];
	assign wb_hi_wr=mem_contr_word[28];
    assign wb_lo_wr=mem_contr_word[27];
    assign wb_hi_data=mem_hi_data;
    assign wb_lo_data=mem_lo_data;	
	
	
endmodule