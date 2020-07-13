`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/04 12:37:27
// Design Name: 
// Module Name: IF_1
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



module IF_1(//input:
              clk,reset,int,j,jr,jr_data,jr_data_ok,branch_1,branch_2,delay_soft,delay_hard,IADEE,IADFE,exc_pc,if_inst,last_inst_2,
            //output:
              pc,id_inst,id_pc,IC_IF,last_inst_1);

/*
    branch                                    分支指令（来自分支延迟槽�?
    clk                                       时钟
    next_pc                                   下一个pc
    exc_pc(exception_pc)                      产生异常后IF_1下一条指�?
    exc_pc+4(exception_pc+4)                  产生异常后IF_2下一条指�?
    id_pc                                     译码阶段pc
    int                                       中断
    IC_IF(int_control_IF);                    中断控制
    last_inst                                   load address 指令
    id_inst(instructions)                        分支指令自身中的部分
    if_inst（MEM instructions�?              在存储器中的指令
    j                                         跳转指令
    IAEE(interrupt_address_error_exception)   中断地址错误异常
    delay_hard                                     延迟
    IAFE(interrupt_address_file_exception)    中断文件错误异常
    pc                                        取码
    id_inst                                      指令
    reset                                     重置

                                    IF
            -------------------------------------------------
            |                                               |
            |  clk                            pc[31:0]      |
            |                                               |
            |  reset                          id_inst[31:0]    |
            |                                               |
            |  int                            id_pc[31:0]   |
            |                                               |
            |  j                              IC_IF[1:0]    |
            |                                               |
            |  branch                                       |
            |                                               |
            |  delay_hard                                        |
            |                                               |
            |  IAEE                                         |
            |                                               |
            |  IAFE                                         |
            |                                               |
            |  exc_pc[31:0]                                 |
            |                                               |
            |  if_inst[31:0]                               |
            |                                               |
            |  last_inst[31:0]                                |
            |                                               |
            -------------------------------------------------

*/
input clk;
input reset;
input int;
input j;
input jr;
input [31:0]jr_data;
input jr_data_ok;
input branch_1;
input branch_2;
input delay_soft;
input delay_hard;
input IADEE;
input IADFE;
input [31:0]exc_pc;
input [31:0]if_inst;
input [31:0]last_inst_2;


output [31:0]pc;
output [31:0]id_inst;
output [31:0]id_pc;
output [1:0]IC_IF;
output [31:0]last_inst_1;

reg [31:0]next_pc;
reg [31:0]pc;
reg [31:0]id_inst;
reg [31:0]id_pc;
reg [1:0]IC_IF;
reg [31:0]last_inst;
// reg inst_emp;
reg branch_req_1;
reg branch_req_2;
reg j_req;
reg jr_req;
reg [31:0]jr_data_cache;
//reg jr_data_ok;


always @ (negedge reset or posedge clk)
    begin
        if (reset==0)
            next_pc<=32'hbfc0_0000;			
        else if(int)
            next_pc<=exc_pc;
        else if(delay_hard|delay_soft)
            next_pc<=pc;
        else if(branch_req_1)
            begin
                if(j_req)
				begin
                    next_pc<=pc+(last_inst[25:0]<<2)-4;
					j_req<=1'b0;
				end
                else if (jr_req)
				begin
					next_pc<=jr_data_cache;
					jr_req<=1'b0;
				end 
				else
				begin
                    next_pc<=pc+(last_inst[15:0]<<2)-4;
				end
				branch_req_1<=1'b0;
            end
		else if(branch_req_2)
            begin
                if(j)
				begin
                    next_pc<=pc+(last_inst_2[25:0]<<2);
				end
				else if (jr_req)
				begin
					next_pc<=jr_data_cache;
					jr_req<=1'b0;
				end 
                else
				begin
                    next_pc<=pc+(last_inst_2[15:0]<<2);
				end
				branch_req_2<=1'b0;
            end

        else
			next_pc<=pc+8;
    end

always @ (negedge reset or posedge clk)
	begin
		if (reset==0) 
		begin
				id_inst<=32'b0;
				IC_IF<=2'b0;
				//id_pc<=32'hbfc0_0000;
		end 
		else if(int)
			begin
				id_inst<=32'b0;
				id_pc<=pc;
				IC_IF<={IADEE,IADFE};
			end 		
		else if(delay_hard)
			begin
			end
		else if(branch_req_1)//流水线清�?
			begin
				id_inst<=32'b0;
				id_pc<=32'b0;
			end
		else if(delay_soft)
			begin	
				id_inst<=32'b0;
			end
		else if(!delay_hard)
			begin
				last_inst<=if_inst;
				id_inst<=if_inst;
				id_pc<=pc;
				IC_IF<=2'b00;
			end
	end
always @ (*)
	begin 
		pc<=next_pc;
	end
//用于分支指令的机�?*3 日后尝试整合
always @ (posedge branch_1 or posedge branch_2)
	begin
		if(branch_1)
			branch_req_1<=1'b1;
		else
			branch_req_2<=1'b1;
	end
always @ (posedge j)
	begin
		j_req<=1'b1;
	end
always @ (posedge jr)
	begin
		jr_req<=1;
		
	end
always @ (jr_data)
	begin
		if(jr_data_ok)
			jr_data_cache<=jr_data;
	end

assign last_inst_1=last_inst;

endmodule
