`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/04 14:32:20
// Design Name: 
// Module Name: IF_2
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

module IF_2(//input:
              clk,reset,int,J,branch_1,branch_2,inst_delay_fetch,delay,IADEE,IADFE,exc_PC,MEM_inst,la_inst_in,
            //output:
              PC,inst,ID_PC,IC_IF,la_inst_out);

/*
    branch                                    分支指令（来自分支延迟槽）
    clk                                       时钟
    next_PC                                   下一个PC
    exc_PC(exception_PC)                      产生异常后IF_1下一条指令
    exc_PC+4(exception_PC+4)                  产生异常后IF_2下一条指令
    ID_PC                                     译码阶段PC
    int                                       中断
    IC_IF(int_control_IF);                    中断控制
    la_inst                                   load address 指令
    inst(instructions)                        分支指令自身中的部分
    MEM_inst（MEM instructions）              在存储器中的指令
    J                                         跳转指令
    delay                                     延迟
    IAEE(interrupt_address_error_exception)   中断地址错误异常
    IAFE(interrupt_address_file_exception)    中断文件错误异常
    PC                                        取码
    inst                                      指令
    reset                                     重置

                                    IF
            -------------------------------------------------
            |                                               |
            |  clk                            PC[31:0]      |
            |                                               |
            |  reset                          inst[31:0]    |
            |                                               |
            |  int                            ID_PC[31:0]   |
            |                                               |
            |  J                              IC_IF[1:0]    |
            |                                               |
            |  branch                                       |
            |                                               |
            |  delay                                        |
            |                                               |
            |  IAEE                                         |
            |                                               |
            |  IAFE                                         |
            |                                               |
            |  exc_PC[31:0]                                 |
            |                                               |
            |  MEM_inst[31:0]                               |
            |                                               |
            |  la_inst[31:0]                                |
            |                                               |
            -------------------------------------------------

*/
input clk;
input reset;
input int;
input J;
input branch_1;
input branch_2;
input inst_delay_fetch;
input delay;
input IADEE;
input IADFE;
input [31:0]exc_PC;
input [31:0]MEM_inst;
input [31:0]la_inst_in;

output [31:0]PC;
output [31:0]inst;
output [31:0]ID_PC;
output [1:0]IC_IF;
output [31:0]la_inst_out;

reg [31:0]next_PC;
reg [31:0]PC;
reg [31:0]inst;
reg [31:0]ID_PC;
reg [1:0]IC_IF;
reg [31:0]la_inst;
reg branch_req_1;
reg branch_req_2;

always @ (negedge reset or posedge clk)
    begin
        if (reset==0)
            next_PC<=32'hbfc0_0004;
        else if(int)
            next_PC<=exc_PC+4;
        else if(delay|inst_delay_fetch)
            next_PC<=PC;
        else if(branch_req_1)
            begin
                if(J)
                    next_PC<=PC+(la_inst_in[25:0]<<2)-4;
                else
                    next_PC<=PC+(la_inst_in[15:0]<<2)-4;
                branch_req_1<=1'b0;
            end
		
		else if(branch_req_2)
			begin
                if(J)
				begin
                    next_PC<=PC+(la_inst[25:0]<<2);
				end
                else
				begin
                    next_PC<=PC+(la_inst[15:0]<<2);
				end
                branch_req_2<=1'b0;
            end
			
        else
        next_PC<=PC+8;
    end

always @ (negedge reset or posedge clk)
	begin
		if (reset==0) 
		begin
			inst<=32'b0;
			IC_IF<=2'b0;
			//ID_PC<=32'hbfc0_0004;
		end else if(int)
		begin
			inst<=32'b0;
			ID_PC<=PC;
			IC_IF<={IADEE,IADFE};
		end else if(branch_req_1|branch_req_2)
		begin
			inst<=32'b0;
			ID_PC<=32'b0;
		end else if(delay|inst_delay_fetch)
		begin
			inst<=32'b0;
		end else if(!delay)
		begin
			la_inst<=MEM_inst;
			inst<=MEM_inst;
			ID_PC<=PC;
			IC_IF<=2'b0;
		end
	end

always @ (*)
	begin 
		PC<=next_PC;
	end

always @ (posedge branch_1 or posedge branch_2)
	begin
		if(branch_1)
			branch_req_1<=1'b1;
		else
			branch_req_2<=1'b0;
	end

assign la_inst_out=la_inst;

endmodule
