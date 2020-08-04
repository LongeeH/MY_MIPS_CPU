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
	exe_contr_word[31:0]	
	exe_int_contr_word[7:0]	
	exe_res[31:0]	
	mem_data_in[31:0]	
	mem_cp0_data_in[31:0]	
	mem_hilo_data[31:0]	
	mem_data[31:0]	
	mem_pc[31:0]	
	exe_des[6:0]	
	exe_wr_hilo[1:0]	
	mem_tran_data_addr			是否�?要协处理�? CP0 进行虚拟地址到物理地�?的地�?转换 
	mem_sorl					存取存储器的操作是写操作还是读操�?
	mem_wr_en						是否把数据写入存储器
	mem_rd_cp0_reg				存取 CP0 的操作是读操�?
	mem_wr_cp0_reg				存取 CP0 的操作是写操�?
	mem_tlb_op_en				�? CP0 进行 TLB 操作的使能信�?
	mem_data_addr[31:0]			�?要存储的数据地址
	mem_data_out[31:0]			cpu输出的数�?
	mem_int_contr[7:0]			中断控制信号
	mem_cp0_reg_index[4:0]		CP0相关寄存器操作的选址信号 
	mem_tlb_op[1:0]				CP0进行�? TLB 操作类型
	mem_res[31:0]				MEM级的指令数据结果？？
	mem_contr_word[31:0]		流水下一阶段
	wb_hilo_data[31:0]			流水下一阶段
	mem_2id_res[31:0]			数据相关时前递给ID替换来源
	mem_2id_hilo[31:0]			数据相关时前递给ID替换来源
	mem_des[6:0]				反馈ID，处理数据相关的控制信号
	mem_wr_hilo[1:0]			反馈ID，处理数据相关的控制信号
	mem_int_pc[31:0]			中断恢复地址�?


*/

module MEM(
    input clk,
    input reset,
    input delay,
	input [31:0]exe_contr_word,
	input [15:0]exe_int_contr_word,
	input [2:0]exe_size_contr,
	input [31:0]exe_res,
	input [31:0]mem_data_in,
	input [31:0]mem_cp0_data_in,
	input [31:0]exe_hi_data,
	input [31:0]exe_lo_data,
	input [31:0]mem_data,
	input [31:0]mem_pc,
	input [6:0]exe_des,
	input [1:0]exe_wr_hilo,
	input mem_cln,
	output mem_tran_data_addr,
	output mem_sorl,
	output mem_load_en,
	output mem_wr_en,
	output mem_rd_cp0_reg,
	output mem_wr_cp0_reg,
	output mem_tlb_op_en,
	output [31:0]mem_data_addr,
	output [31:0]mem_data_out,
	output [15:0]mem_int_contr,
	output [4:0]mem_cp0_reg_index,
	output [31:0]mem_cp0_data_out,
	output [1:0]mem_tlb_op,
	output [31:0]mem_res,
	output [31:0]mem_contr_word,
	output [2:0]mem_size_contr,
	output [31:0]mem_hi_data,
	output [31:0]mem_lo_data,
	output [31:0]mem_2id_res,
	output [31:0]mem_2id_hilo,
	output [6:0]mem_des,
	output [1:0]mem_wr_hilo,
	output [31:0]mem_int_pc,
	output [31:0]wb_pc


    );
	reg [31:0]mem_mux;
	reg [31:0]mem_data_addr;
	reg [31:0]mem_data_out;
	reg mem_tran_data_addr;
	reg mem_sorl;
	reg mem_load_en;
	reg [15:0]mem_int_contr;
	reg mem_wr_en;
	reg	mem_rd_cp0_reg;
	reg	mem_wr_cp0_reg;
	reg	mem_tlb_op_en;
	reg	[4:0]mem_cp0_reg_index;
	reg	[31:0]mem_cp0_data_out;
	reg	[1:0]mem_tlb_op;
	reg	[31:0]mem_int_pc;
	reg	[31:0]mem_hi_data;
	reg	[31:0]mem_lo_data;
	reg	[31:0]mem_contr_word;
	wire[2:0]mem_size_contr;
	reg	[31:0]mem_res;
	reg	[31:0]wb_pc;
	wire[31:0]mem_2id_res;
	reg[31:0]mem_2id_hilo;
	reg[6:0]mem_des;
	reg[1:0]mem_wr_hilo;
	reg mem_cln_req;
	
	assign mem_size_contr=exe_size_contr; 
	
	always@(*)//CP0操作相关指令
	begin 
		mem_data_addr=exe_res; 
		// mem_data_out<=mem_data; 
		mem_tran_data_addr=(exe_contr_word[7]||exe_contr_word[8]); //
		mem_sorl=exe_contr_word[7]; 
		mem_int_contr=exe_int_contr_word; //
		mem_wr_en=exe_contr_word[7]; 
		mem_load_en=exe_contr_word[8];
		mem_rd_cp0_reg=exe_contr_word[16]; //
		mem_wr_cp0_reg=exe_contr_word[15]; //
		mem_tlb_op_en=exe_contr_word[19]; //
		mem_cp0_reg_index=exe_contr_word[14:10]; //
		mem_tlb_op=exe_contr_word[18:17]; //
		mem_int_pc=mem_pc; //
		mem_cp0_data_out=mem_data;
	end 
	always@(*)
	begin
		begin 
		case(exe_size_contr)
			3'b001:begin
				// mem_data_out={24'b0,mem_data[7:0]};;
				mem_data_out={4{mem_data[7:0]}};
			end
			3'b010:begin
				mem_data_out={2{mem_data[15:0]}};
			end			
			3'b011:begin
				mem_data_out=mem_data;
			end			
			default:begin
				mem_data_out=32'b0;
			end			
		endcase
	end 
	end
	
	always@(*)//将原设计的串�?2_1译码器改作一个四输入选择�?//关于输入数据的�?�择
	begin 
		case({exe_contr_word[16],exe_contr_word[8],exe_size_contr})
			5'b00000:begin
				mem_mux[31:0]=exe_res;
			end
			5'b01001:begin
				mem_mux[31:0]={{24{byte_data[7]}},byte_data[7:0]};//b
			end			
			5'b01101:begin
				mem_mux[31:0]={24'b0,byte_data};//ub
			end			
			5'b01010:begin
				mem_mux[31:0]={{16{hawo_data[15]}},hawo_data[15:0]};//hw
			end			
			5'b01110:begin
				mem_mux[31:0]={16'b0,hawo_data};//uhw
			end
			5'b01011:begin
				mem_mux[31:0]=mem_data_in;//w
			end
			5'b10000:begin
				mem_mux[31:0]=mem_cp0_data_in;
			end
			5'b11000:begin
				mem_mux[31:0]=mem_cp0_data_in;
			end
			default:begin
				mem_mux[31:0]=32'b0;
			end
		endcase
	end 
	
	reg [7:0]byte_data;
	reg [15:0]hawo_data;
	
	always@(*)//从内存输入中选择正确的半字和字节
	begin 
		case({mem_data_addr[1],mem_data_addr[0]})
			2'b00:begin
				byte_data=mem_data_in[7:0];
			end
			2'b01:begin
				byte_data=mem_data_in[15:8];
			end			
			2'b10:begin
				byte_data=mem_data_in[23:16];
			end			
			2'b11:begin
				byte_data=mem_data_in[31:24];
			end			
		endcase
		case(mem_data_addr[1])
			1'b0:begin
				hawo_data=mem_data_in[15:0];
			end
			1'b1:begin
				hawo_data=mem_data_in[31:16];
			end				
		endcase
	end
	
	always @(negedge reset or posedge clk) //原设计的流水线，结合上一个always重新实现
    begin  
		if(reset==0||(!delay&&(mem_cln_req||mem_cln))) 
			begin 
				mem_res<=32'b0; 
				mem_contr_word<=32'b0; 
				mem_hi_data<=32'b0; 
				mem_lo_data<=32'b0; 
				mem_cln_fin<=1'b1;
				// mem_cln_req<=1'b0;
			end 
		// else if(mem_cln)
			// begin
				// mem_hi_data<=32'b0; 
				// mem_lo_data<=32'b0;
				// mem_contr_word<=32'b0; 
				// mem_res<=32'b0; 
				// wb_pc<=32'b0; 
			// end			
        else if(!delay)
			begin 
				mem_hi_data<=exe_hi_data; 
				mem_lo_data<=exe_lo_data; 
				mem_contr_word<=exe_contr_word; 
				mem_res<=mem_mux; 
				wb_pc<=mem_pc;
				mem_cln_fin<=1'b0;
            end
		else
			begin
				mem_hi_data<=32'b0; 
				mem_lo_data<=32'b0;
				mem_contr_word<=32'b0; 
				mem_res<=32'b0; 
				wb_pc<=32'b0; 
				mem_cln_fin<=1'b1;
			end			
			
    end 
	
	reg mem_cln_fin;
	always@(posedge clk)
	begin
		if(!delay&&mem_cln_req)
			mem_cln_req<=1'b0;
		else if(mem_cln&&delay)
			mem_cln_req<=1'b1;
	end
	
	
	always @(exe_des or exe_wr_hilo) 
	begin  
		mem_des=exe_des; 
		mem_wr_hilo=exe_wr_hilo; 
	end 
	
	//和EXE�?样的处理方式，在寄存器前直接相连结果，将数据前�?�提前，也许并不正确
	assign mem_2id_res=mem_mux;
	// assign mem_2id_hilo=mem_mux;
	always@(*)
	begin
		case(mem_wr_hilo)//ALUOP参迃page45
			2'b01:begin
				mem_2id_hilo=exe_hi_data;
			end
			2'b10:begin
				mem_2id_hilo=exe_lo_data;
			end			
			default:begin
				mem_2id_hilo=exe_lo_data;//数据从寄存器堆来hi==lo
				
			end
		endcase			
	end

endmodule
