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
              clk,reset,int,j,jr,jr_data,jr_data_ok,branch_1,branch_2,delay_soft,delay_hard,if_cln,IADEE,IADFE,exc_pc,if_inst,last_inst_2,cp0_epc,
            //output:
              pc,id_inst,id_pc,IC_IF,last_inst_1,pcn);

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
input [31:0]cp0_epc;
input jr_data_ok;
input branch_1;
input branch_2;
input delay_soft;
input delay_hard;
input if_cln;
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
output pcn;

reg pcn;
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
reg int_req;
reg [31:0]jr_data_cache;
//reg jr_data_ok;
wire [31:0]pc_slot;
assign pc_slot=pc-4;
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
            next_pc<=32'hbfc0_0000;			
            // next_pc<=32'h1faf_f02c;
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
        else if(int_req)
			begin
				next_pc<=32'hbfc0_0380;
				int_fin<=1;
				if_cln_fin<=1;
				branch_fin<=1;
				j_fin<=1;
				jr_fin<=1;
				pcn<=1;
			end      
        else if(branch_req_1)
            begin
                if(j_req)
				begin
                    next_pc[31:28]<=pc_slot[31:28];
					next_pc[27:0]<=(last_inst[25:0]<<2);
					j_fin<=1;
				end
                else if (jr_req)
				begin
					next_pc<=(jr_data_ok==1)?jr_data:jr_data_cache;
					jr_fin<=1;
				end 
				else
				begin
                    next_pc<=pc_slot+(branch_offset<<2);
				end
				branch_fin<=1;
				if_cln_fin<=1;
				pcn<=1;
            end
		else if(branch_req_2)
            begin
                if(j_req)
				begin
                    next_pc[31:28]<=pc[31:28];
					next_pc[27:0]<=(last_inst_2[25:0]<<2);
					// j_req<=1'b0;
					j_fin<=1;
				end
				else if (jr_req)
				begin
					next_pc<=(jr_data_ok==1)?jr_data:jr_data_cache;
					// jr_req<=1'b0;
					jr_fin<=1;
				end 
                else
				begin
                    next_pc<=pc+(branch_offset<<2);
				end
				// branch_req_2<=1'b0;
				// if_cln_req<=1'b0;
				branch_fin<=1;
				if_cln_fin<=1;
				pcn<=1;
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
			//id_pc<=32'hbfc0_0000;
		end 
		else if(int_req)
			begin
				id_inst<=32'b0;
				id_pc<=32'b0;
				//IC_IF<={IADEE,IADFE};
			end 		
		else if(delay_hard)
			begin
			end
		else if(branch_req_1||if_cln_req)//流水线清�?
			begin
				id_inst<=32'b0;
				id_pc<=32'b0;
			end
		else if(delay_soft)
			begin	
				id_inst<=32'b0;
				// id_pc<=32'b0////try
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
		pc=next_pc;
	end
//用于分支指令的机�?*3 日后尝试整合
// always @ (posedge branch_1 or posedge branch_2 or posedge int)
always @ (*)
	begin
		case({branch_1,branch_2,int})
			3'b001:begin
				// if(!branch_req_1)//避免1b2i同时进入的情况，只有1非分支，才认�?2i有效。反�?1i2b则清2
				// begin
					int_req=1'b1;
					branch_req_2=1'b0;
					branch_req_1=1'b0;
				// end 
				// else
				// ;
			end
			3'b101,3'b011,3'b111:begin//同时到则i�?定提�?
				int_req=1'b1;
			end
			3'b100:begin
				branch_req_1=1'b1;			
			end
			3'b010:begin
				branch_req_2=1'b1;			
			end
		endcase
		
		if(int_fin&&int_req)
			int_req=0;			
		if(branch_fin&&branch_req_1)
			branch_req_1=0;
		if(branch_fin&&branch_req_2)
			branch_req_2=0;
	end
	
// always@(posedge branch_2)begin
	// issolt<=1'b1;
// end
// always@(pc)begin
	// if(issolt)
		// if_solt<=1'b1;
	// else
		// if_solt<=1'b0;
	
	// issolt
// end



always @ (posedge j or posedge j_fin)
	begin
		if(j_fin)
			j_req<=1'b0;
		else if(j)
			j_req<=1'b1;
	end
always @ (posedge jr or posedge jr_fin)
	begin
		if(jr_fin)
			jr_req<=1'b0;
		else if(jr)
			jr_req<=1'b1;
	end
always @ (posedge if_cln or posedge if_cln_fin)
	begin
		if(if_cln_fin)
			if_cln_req<=1'b0;
		else if(if_cln)
			if_cln_req<=1'b1;
	end
always @ (posedge clk)
	begin
		if(jr_data_ok)
			jr_data_cache<=jr_data;
	end

assign last_inst_1=last_inst;
//分支跳转的偏移量转换
always@(*)
begin
	if(branch_req_1)
		begin
			// branch_offset[31:16]=last_inst[15]?16'hffff:16'h0;
			branch_offset={{16{last_inst[15]}},last_inst[15:0]};
		end
	else
		begin
			// branch_offset[31:16]=last_inst_2[15]?16'hffff:16'h0;
			branch_offset={{16{last_inst_2[15]}},last_inst_2[15:0]};
		end
end

endmodule
