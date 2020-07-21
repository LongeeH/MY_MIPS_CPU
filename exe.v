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
	id_contr_word[31:0]		ID提供的控制字
	id_int_contr_word[7:0]	ID提供的中断控制字
	exe_pc[31:0]			ID提供的PC。一周期后给MEMPC[31:0]
	exe_reg_res_A[31:0]		寄存器A数据
	exe_reg_res_B[31:0]		寄存器B数据
	id_des[6:0]				ID提供的结果控制信号DES。一周期后给MEMDES[7:0]、ALUDES[6:0]
	id_wr_hilo[1:0]			ID提供的WIRITEHILO。一周期后给EXEWRITEHILO[1:0]	、ALUWRITEHILO[1:0]	
	exe_immed[31;0]			32位立即数
	
	exe_des[6:0]			向后传�?�判断数据相关的信号
	exe_wr_hilo[1:0]		向后传�?�判断数据相关的信号
	exe_alu_des[6:0]		�??给ID判断数据相关的控制信�?
	exe_alu_wr_hilo[1:0]	�??给ID判断数据相关的控制信�?
	exe_res[31:0]			ALU计算结果输出EXE
	mem_data[31:0]			输入寄存器REGRESB的数
	exe_contr_word[31:0]	id_contr_word[31:0]流水
	exe_int_contr_word[7:0]	id_int_contr_word[7:0]流水，INTCONTROLW_ID[2]替换为移溢出信号
	mem_pc[31:0]			exe_pc[31:0]流水
	exe_lo_data[31:0]			输入寄存器REGRESA的数�?
	alu_2id_res[31:0]		ALU计算结果输出，数据相关时前�?�给ID
	alu_2id_hilo[31:0]		ALU计算结果输出，数据相关时前�?�给ID
	
*/

module EXE(
	input clk,
	input reset,
	input delay,
	input [31:0]id_contr_word,	
	input [7:0]id_int_contr_word,
	input [2:0]id_size_contr,	
	input [31:0]exe_pc,
	input [31:0]exe_reg_res_A,
	input [31:0]exe_reg_res_B,
	input [6:0]id_des,
	input [1:0]id_wr_hilo,
	input [31:0]exe_immed,
	output [6:0]exe_des,
	output [1:0]exe_wr_hilo,
	output [6:0]exe_alu_des,
	output [1:0]exe_alu_wr_hilo,
	output [31:0]exe_res,
	output [31:0]mem_data,
	output [31:0]exe_contr_word,
	output [7:0]exe_int_contr_word,
	output [2:0]exe_size_contr,
	output [31:0]mem_pc,
	output [31:0]exe_hi_data,
	output [31:0]exe_lo_data,
	output [31:0]alu_2id_res,
	output [31:0]alu_2id_hilo
    );
	reg [31:0]alu_data_A;
	reg [31:0]alu_data_B;
	wire [31:0]alu_res;
	wire alu_int_ov;
	
	reg [6:0]exe_alu_des;
	reg [1:0]exe_alu_wr_hilo;
	reg [31:0]exe_res;
	reg [31:0]mem_data;
	reg [31:0]exe_contr_word;
	reg [7:0]exe_int_contr_word;
	reg [2:0]exe_size_contr;
	reg [31:0]mem_pc;
	reg [31:0]exe_hi_data;
	reg [31:0]exe_lo_data;
	reg [6:0]exe_des;
	reg [1:0]exe_wr_hilo;
	reg [63:0]mult_res;
	reg [63:0]multu_res;
	reg [63:0]div_res;
	reg [63:0]divu_res;
	reg [63:0]alu_hilo_res;
	reg [32:0]alu_2id_hilo;
	
	always@(*)//MUX2决定A输入
	begin
		case(id_contr_word[5])
			1'b0:begin
				alu_data_A=exe_reg_res_A;
			end
			1'b1:begin
				{alu_data_A[31:16],alu_data_A[15:0]}={16'b0,exe_immed[15:0]};
			end
			default:begin
				alu_data_A=32'b0;//默认项，留作调试变量
			end
		endcase
	end
	
	always@(*)//MUX4决定B输入
	begin
		case({id_contr_word[31],id_contr_word[30]})
			2'b00:begin
				alu_data_B=exe_reg_res_B;
			end
			2'b01:begin
				alu_data_B=exe_immed;
			end
			2'b10:begin
				{alu_data_B[31:16],alu_data_B[15:0]}={16'b0,exe_immed[15:0]};
			end
			2'b11:begin
				alu_data_B=exe_reg_res_A;
			end
			default:begin
				alu_data_B=32'b0;//默认项，留作调试变量
			end
		endcase
	end
	
	always @(id_des or id_wr_hilo)//数据相关的控制信号?
	begin
		exe_alu_des<=id_des;
		exe_alu_wr_hilo<=id_wr_hilo;
    end

	always @(negedge reset or posedge clk)//流水线处理?
	begin
		if(reset==0)
		begin
			exe_res<=32'b0;
			mem_data<=32'b0;
			exe_contr_word<=32'b0;
			exe_int_contr_word<=8'b0;
			mem_pc<=32'b0;
			exe_lo_data<=32'b0;
			exe_des<=7'b0;
			exe_wr_hilo<=2'b0;
            end
        else if(!delay)
		begin
			exe_res<=alu_res;
            mem_data<=exe_reg_res_B;
            mem_pc<=exe_pc;		
			exe_hi_data<=alu_hilo_res[63:32];
			exe_lo_data<=alu_hilo_res[31:0];
            exe_des<=id_des;
            exe_wr_hilo<=id_wr_hilo;
			exe_contr_word[31:0]<=id_contr_word[31:0];
			exe_int_contr_word[7:0]<={id_int_contr_word[7:3],alu_int_ov,id_int_contr_word[1:0]};
			exe_size_contr<=id_size_contr;
		end
	end
	
	
	always@(*)
	begin
		case(id_contr_word[4:0])//ALUOP参迃page45
			5'b00010:begin
				alu_hilo_res<=mult_res;
			end
			5'b00011:begin
				alu_hilo_res<=div_res;//除法lo商hi�?
				// alu_hilo_res<={div_res[31:0],div_res[63:32]};//除法lo商hi�?
			end
			5'b00110:begin
				alu_hilo_res<=multu_res;
			end
			5'b00111:begin
				alu_hilo_res<=divu_res;//除法lo商hi使
				// alu_hilo_res<={div_res[31:0],div_res[63:32]};//除法lo商hi使
			end
			default:begin
				alu_hilo_res={exe_reg_res_A,exe_reg_res_A};//数据从寄存器堆来
			end
		endcase		
	end
	
	ALU alu(
		.clk(clk),
		.reset(reset),
		.alu_a(alu_data_A),
		.alu_b(alu_data_B),
		.alu_op(id_contr_word[4:0]),
		.alu_srcA(id_contr_word[5]),
		.alu_res(alu_res),
		.alu_int_ov(alu_int_ov)
	);

	// mult_gen_0 mult (
	  // .A(alu_data_A),  // input wire [31 : 0] A
	  // .B(alu_data_B),  // input wire [31 : 0] B
	  // .P(mult_res)  // output wire [63 : 0] P
	// );
	
	// div_gen_0 div (
	  // .s_axis_divisor_tvalid(1),    // input wire s_axis_divisor_tvalid
	  // .s_axis_divisor_tdata(alu_data_B),      // input wire [31 : 0] s_axis_divisor_tdata
	  // .s_axis_dividend_tvalid(1),  // input wire s_axis_dividend_tvalid
	  // .s_axis_dividend_tdata(alu_data_A),    // input wire [31 : 0] s_axis_dividend_tdata
	  // .m_axis_dout_tvalid(m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
	  // .m_axis_dout_tdata(div_res)            // output wire [63 : 0] m_axis_dout_tdata
	// );
	//

	always@(*)//fake div
	begin
		div_res[31:0]<=$signed(alu_data_A)/$signed(alu_data_B);
		div_res[63:32]<=$signed(alu_data_A)%$signed(alu_data_B);
	end
	always@(*)//fake divu
	begin
		divu_res[31:0]<=alu_data_A/alu_data_B;
		divu_res[63:32]<=alu_data_A%alu_data_B;
	end
	always@(*)//fake mul
	begin
		mult_res<=$signed(alu_data_A)*$signed(alu_data_B);
	end
	always@(*)//fake mulu
	begin
		multu_res<=alu_data_A*alu_data_B;
	end
	
	
	//以下两行为推测，直连能跳过一个寄存器，但仍然不正常�?��?��??
	//进行数据相关的�?�择
	assign alu_2id_res=alu_res;
	// assign alu_2id_hilo=alu_res;
	always@(*)
	begin
		case(exe_alu_wr_hilo)//ALUOP参迃page45
			2'b01:begin
				alu_2id_hilo<=alu_hilo_res[31:0];
			end
			2'b10:begin
				alu_2id_hilo<=alu_hilo_res[63:32];
			end			
			default:begin
				alu_2id_hilo<=alu_hilo_res[31:0];//通过
				// alu_2id_hilo<=alu_res;//通过
			end
		endcase			
	end
	
endmodule
