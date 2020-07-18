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
              clk,reset,int,j,jr,jr_data,jr_data_ok,branch_1,branch_2,delay_soft,delay_hard,IADEE,IADFE,exc_pc,if_inst,last_inst_1,
            //output:
              pc,id_inst,id_pc,IC_IF,last_inst_2);

/*
    branch                                    ��ָ֧����Է�֧�ӳٲۣ�
    clk                                       ʱ��
    next_pc                                   ��һ��pc
    exc_pc(exception_pc)                      �����쳣��IF_1��һ��ָ��
    exc_pc+4(exception_pc+4)                  �����쳣��IF_2��һ��ָ��
    id_pc                                     ����׶�pc
    int                                       �ж�
    IC_IF(int_control_IF);                    �жϿ���
    last_inst                                   load address ָ��
    id_inst(instructions)                        ��ָ֧�������еĲ���
    if_inst��MEM instructions��              �ڴ洢���е�ָ��
    j                                         ��תָ��
    delay_hard                                     �ӳ�
    IAEE(interrupt_address_error_exception)   �жϵ�ַ�����쳣
    IAFE(interrupt_address_file_exception)    �ж��ļ������쳣
    pc                                        ȡ��
    id_inst                                      ָ��
    reset                                     ����

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
input [31:0]last_inst_1;

output [31:0]pc;
output [31:0]id_inst;
output [31:0]id_pc;
output [1:0]IC_IF;
output [31:0]last_inst_2;

reg [31:0]next_pc;
reg [31:0]pc;
reg [31:0]id_inst;
reg [31:0]id_pc;
reg [1:0]IC_IF;
reg [31:0]last_inst;
reg branch_req_1;
reg branch_req_2;
reg j_req;
reg jr_req;
reg [31:0]jr_data_cache;
//reg jr_data_ok;
wire [31:0]pc_slot;
wire [31:0]pc_slot_2;
assign pc_slot=pc-4;
assign pc_slot_2=pc-8;
reg [31:0]branch_offset;

always @ (negedge reset or posedge clk)
    begin
        if (reset==0)
            next_pc<=32'hbfc0_0004;
        else if(int)
            next_pc<=exc_pc+4;
        else if(delay_hard|delay_soft)
            next_pc<=pc;
        else if(branch_req_1)
            begin
                if(j_req)
				begin
                    next_pc[31:28]<=pc_slot_2[31:28];
					next_pc[27:0]<=(last_inst_1[25:0]<<2)+4;
					j_req<=1'b0;
				end
                else if(jr_req)
				begin
                    next_pc<=jr_data_cache+4;
					jr_req<=1'b0;
				end
				else
				begin
					next_pc<=pc_slot+(branch_offset<<2);
				end
				branch_req_1<=1'b0;
            end
		
		else if(branch_req_2)
			begin
                if(j_req)
				begin
                    next_pc[31:28]<=pc_slot[31:28];
					next_pc[27:0]<=(last_inst[25:0]<<2)+4;
					j_req<=1'b0;
				end
				else if(jr_req)
				begin
					next_pc<=jr_data_cache+4;
					jr_req<=0;
				end
                else
				begin
                    next_pc<=pc+(branch_offset<<2);
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
			//id_pc<=32'hbfc0_0004;
		end else if(int)
		begin
			id_inst<=32'b0;
			id_pc<=pc;
			IC_IF<={IADEE,IADFE};
		end else if(delay_hard)//Ӳ��ͣ��ͨ��������������أ�������ߣ�����������κΣ�������ˮ��
		begin
		end else if(branch_req_1|branch_req_2)//��ˮ�����
		begin
			id_inst<=32'b0;
			id_pc<=32'b0;
		end else if(delay_soft)
		begin
			id_inst<=32'b0;
		end else if(!delay_hard)
		begin
			last_inst<=if_inst;
			id_inst<=if_inst;
			id_pc<=pc;
			IC_IF<=2'b0;
		end
	end

always @ (*)
	begin 
		pc<=next_pc;
	end

//��֧��ת*3
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
	
assign last_inst_2=last_inst;

always@(*)
begin
	if(branch_req_1)
		begin
			branch_offset[31:16]<=last_inst_1[15]?16'hffff:16'h0;
			branch_offset[15:0]<=last_inst_1[15:0];
		end
	else
		begin
			branch_offset[31:16]<=last_inst[15]?16'hffff:16'h0;
			branch_offset[15:0]<=last_inst[15:0];
		end
end
endmodule
