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
              clk,reset,int,j,jr,jr_data,jr_data_ok,branch_1,branch_2,delay_soft,delay_hard,if_cln,IADEE,IADFE,exc_pc,if_inst,last_inst_1,cp0_epc,
            //output:
              pc,id_inst,id_pc,IC_IF,last_inst_2,pcn);

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
input [31:0]cp0_epc;
input jr_data_ok;
(*mark_debug = "true" *)input branch_1;
(*mark_debug = "true" *)input branch_2;
(*mark_debug = "true" *)input delay_soft;
input delay_hard;
(*mark_debug = "true" *)input if_cln;
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
output pcn;

reg pcn;
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
reg int_req;
reg [31:0]jr_data_cache;
//reg jr_data_ok;
wire [31:0]pc_slot;
wire [31:0]pc_slot_2;
assign pc_slot=pc-4;
assign pc_slot_2=pc-8;
reg [31:0]branch_offset;
reg if_cln_req;

reg j_fin;
reg jr_fin;
reg if_cln_fin;
reg branch_fin;
reg int_fin;

always @ (posedge clk)
    begin
        if (reset==0)
		begin
            next_pc<=32'hbfc0_0004;
			if_cln_fin<=0;
			branch_fin<=0;
			j_fin<=0;
			jr_fin<=0;
			int_fin<=0;
			pcn<=1;
		end
        else if(delay_hard||delay_soft)
		begin
            next_pc<=pc;
			if_cln_fin<=0;
			pcn<=0;
		end
        else if(int_req||int)
			begin
				next_pc<=32'hbfc0_0384;
				int_fin<=1;
				if_cln_fin<=1;
				branch_fin<=1;
				j_fin<=1;
				jr_fin<=1;
				pcn<=1;
			end
        else if(branch_req_1||branch_1)
            begin
				pcn<=1;
                if(j_req||j)
				begin
                    next_pc[31:28]<=pc_slot_2[31:28];
					next_pc[27:0]<=(last_inst_1[25:0]<<2)+4;
					j_fin<=1;
				end
                else if(jr_req||jr)
				begin
                    next_pc<=jr_data_ok?jr_data+4:jr_data_cache+4;
					jr_fin<=1;
				end
				else
				begin
					next_pc<=pc_slot+(branch_offset<<2);
				end
				branch_fin<=1;
				if_cln_fin<=1;
            end
		
		else if(branch_req_2||branch_1)
			begin
				pcn<=1;
                if(j_req||j)
				
				begin
                    next_pc[31:28]<=pc_slot[31:28];
					next_pc[27:0]<=(last_inst[25:0]<<2)+4;
					j_fin<=1;
				end
				else if(jr_req||jr)
				begin
					next_pc<=jr_data_ok?jr_data+4:jr_data_cache+4;
					jr_fin<=1;
				end
                else
				begin
                    next_pc<=pc+(branch_offset<<2);
				end
				branch_fin<=1;
				if_cln_fin<=1;
            end
			
        else
			begin
				next_pc<=pc+8;
				
				int_fin<=0;
				if_cln_fin<=1;
				branch_fin<=0;
				j_fin<=0;
				jr_fin<=0;
				
				pcn<=1;
			end
    end

always @ (negedge reset or posedge clk)
	begin
		if (reset==0) 
		begin
			id_inst<=32'b0;
			IC_IF<=2'b0;
	
		end else if(int_req||int)
		begin
			id_inst<=32'b0;
			id_pc<=32'b0;

		end else if(delay_hard)//Ӳ��ͣ��ͨ��������������أ�������ߣ�����������κΣ�������ˮ��
		begin
		end else if(branch_req_1||branch_1||branch_req_2||branch_2||if_cln_req||if_cln)//��ˮ�����
		begin
			id_inst<=32'b0;
			id_pc<=32'b0;
		end else if(delay_soft)
		begin
			id_inst<=32'b0;
		end else if(!delay_hard)//��������id
		begin
			last_inst<=if_inst;
			id_inst<=if_inst;
			id_pc<=pc;
			IC_IF<=2'b0;
		end
	end

always @ (*)
	begin 
		pc=next_pc;
	end

//��֧��ת*3
always @ (posedge clk)
	begin
		if(delay_hard||delay_soft)
		begin
			case({branch_1,branch_2,int})
				3'b001:begin
					int_req<=1'b1;
					branch_req_1<=1'b0;	
					branch_req_2<=1'b0;
				end
				3'b101,3'b011,3'b111:begin//ͬʱ����iһ����ǰ
					int_req<=1'b1;
				end
				3'b100:begin
					branch_req_1<=1'b1;			
				end
				3'b010:begin
					branch_req_2<=1'b1;			
				end
			endcase
		end
		if(int_fin&&int_req)
			int_req<=0;			
		if(branch_fin&&branch_req_1)
			branch_req_1<=0;
		if(branch_fin&&branch_req_2)
			branch_req_2<=0;
	end
always @ (posedge clk)
	begin
		if(j_fin)
			j_req<=1'b0;
		else if(j&&(delay_hard||delay_soft))
			j_req<=1'b1;
		if(jr_fin)
			jr_req<=1'b0;
		else if(jr&&(delay_hard||delay_soft))
			jr_req<=1'b1;
		if(if_cln_fin)
			if_cln_req<=1'b0;
		else if(if_cln&&(delay_hard||delay_soft))
			if_cln_req<=1'b1;
			
		if(jr_data_ok)
			jr_data_cache<=jr_data;
			
	end

	
assign last_inst_2=last_inst;

always@(*)
begin
	if(branch_req_1)
		branch_offset={{16{last_inst_1[15]}},last_inst_1[15:0]};
	else
		branch_offset={{16{last_inst[15]}},last_inst[15:0]};
end
endmodule
