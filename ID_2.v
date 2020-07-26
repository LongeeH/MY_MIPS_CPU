`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/05 11:05:10
// Design Name: 
// Module Name: ID
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


module ID_2(//input
            clk,reset,id_inst,id_pc,IC_IF,
            reg_rs,reg_rt,
            hi_r_data,lo_r_data,
            alu_des_1,alu_w_hilo_1,
            alu_des_2,alu_w_hilo_2,
            alu_res_1,alu_res_2,
            alu_hilo_res_1,alu_hilo_res_2,
            mem_res_1,mem_res_2,
            mem_des_1,mem_wr_hilo_1,
            mem_des_2,mem_wr_hilo_2,
            mem_hilo_res_1,mem_hilo_res_2,self_des,self_hilo,delay_in,id_cln_in,cp0_epc,
         //output
            branch,j,jr,jr_data,jr_data_ok,delay_out,delay_mix,id_contr_word,id_int_contr_word,id_size_contr,exe_pc,
            reg_esa,reg_esb,immed,id_des,
            id_wr_hilo,RSO,RTO
    );


/*                                    ID
        -------------------------------------------------------------
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        |                                                           |
        -------------------------------------------------------------

*/

input clk;
input reset;
input [31:0]id_inst;
input [31:0]id_pc;
input [1:0]IC_IF;
input [31:0]reg_rs;
input [31:0]reg_rt;
input [31:0]hi_r_data;
input [31:0]lo_r_data;
input [6:0]alu_des_1;
input [1:0]alu_w_hilo_1;
input [6:0]alu_des_2;
input [1:0]alu_w_hilo_2;
input [31:0]alu_res_1;
input [31:0]alu_res_2;
input [31:0]alu_hilo_res_1;
input [31:0]alu_hilo_res_2;
input [31:0]mem_res_1;
input [31:0]mem_res_2;
input [6:0]mem_des_1;
input [1:0]mem_wr_hilo_1;
input [6:0]mem_des_2;
input [1:0]mem_wr_hilo_2;
input [31:0]mem_hilo_res_1;
input [31:0]mem_hilo_res_2;
input [6:0]self_des;
input delay_in;
input id_cln_in;
input [1:0]self_hilo;
input [31:0]cp0_epc;

output branch;
output j;
output jr;
output [31:0]jr_data;
output jr_data_ok;
output delay_out;
output delay_mix;
output [31:0]id_contr_word;
output [15:0]id_int_contr_word;
output [7:0]id_size_contr;
output [31:0]exe_pc;
output [31:0]reg_esa;
output [31:0]reg_esb;
output [31:0]immed;
output [6:0]id_des;

output [1:0]id_wr_hilo;
output [4:0]RSO;
output [4:0]RTO;

//输出
reg branch;
reg j;
reg jr;
reg [31:0]jr_data;
reg jr_data_ok;
wire delay;
reg delay_self;
reg delay_self_mix;
reg [31:0]id_contr_word;
reg [15:0]id_int_contr_word;
reg [31:0]exe_pc;
reg [31:0]reg_esa;
reg [31:0]reg_esb;
reg [31:0]immed;
reg [6:0]id_des;
reg [1:0]id_wr_hilo;
reg [4:0]RSO;
reg [4:0]RTO;

//中间变量
reg [4:0]alu_op;
reg [1:0]tlb_OP;
reg [4:0]result_des;
reg [31:0]contr_word;
reg [15:0]int_contr_word;
reg [3:0]FWDA;
reg [3:0]FWDB;
reg [31:0]reg_A;
reg [31:0]reg_B;
reg r_slt_z;
reg rs_eq_z;
reg rs_eq_rt;
reg [4:0]RDO;
reg [6:0]des;
reg [1:0]write_hilo;


wire [5:0]OP;
wire [5:0]func;
wire [4:0]RSI;
wire [4:0]OP_subA;
wire [4:0]OP_subB;
wire [4:0]RTI;
wire [4:0]RDI;
wire [1:0]alu_srcA;
wire [1:0]alu_srcB;
wire [4:0]cp0_reg_index;
wire add_inst;
wire addu_inst;
wire sub_inst;
wire subu_inst;
wire and_inst;
wire or_inst;
wire nor_inst;
wire xor_inst;
wire slt_inst;
wire sltu_inst;
wire sll_inst;
wire sllv_inst;
wire sra_inst;
wire srav_inst;
wire srl_inst;
wire srlv_inst;
wire mflo_inst;
wire mfhi_inst;
wire mtlo_inst;
wire mthi_inst;
wire addi_inst;
wire addiu_inst;
wire andi_inst;
wire ori_inst;
wire xori_inst;
wire slti_inst;
wire sltiu_inst;
wire lui_inst;
wire lb_inst;
wire lbu_inst;
wire lh_inst;
wire lhu_inst;
wire lw_inst;
wire sb_inst;
wire sh_inst;
wire sw_inst;
wire j_inst;
wire jr_inst;
wire jal_inst;
wire jalr_inst;
wire beq_inst;
wire bne_inst;
wire bltz_inst;
wire bltzal_inst;
wire blez_inst;
wire bgtz_inst;
wire bgez_inst;
wire bgezal_inst;
wire syscall_inst;
wire mtc0_inst;
wire mfc0_inst;
wire tlbp_inst;
wire tlbr_inst;
wire tlbwi_inst;
wire tlbwr_inst;
wire eret_inst;
wire break_inst;
wire nop_inst;
wire div_inst;
wire divu_inst;
wire mult_inst;
wire multu_inst;
wire unknown_inst;



assign OP[5:0]     = id_inst[31:26];
assign func[5:0]   = id_inst[5:0];
assign RSI[4:0]    = id_inst[25:21];
assign OP_subA[4:0]= id_inst[25:21];
assign OP_subB[4:0]= id_inst[20:16];
assign RTI[4:0]    = id_inst[20:16];
assign RDI[4:0]    = id_inst[15:11];
assign Rtype       = (OP == 6'b000000);
assign cp0type     = (OP == 6'b010000);
assign add_inst    = Rtype && (func == 6'b100000);
assign addu_inst   = Rtype && (func == 6'b100001);
assign sub_inst    = Rtype && (func == 6'b100010);
assign subu_inst   = Rtype && (func == 6'b100011);
assign and_inst    = Rtype && (func == 6'b100100);
assign or_inst     = Rtype && (func == 6'b100101);
assign nor_inst    = Rtype && (func == 6'b100111);
assign xor_inst    = Rtype && (func == 6'b100110);
assign slt_inst    = Rtype && (func == 6'b101010);
assign sltu_inst   = Rtype && (func == 6'b101011);
assign sll_inst    = Rtype && (func == 6'b000000);
assign sllv_inst   = Rtype && (func == 6'b000100);
assign sra_inst    = Rtype && (func == 6'b000011);
assign srav_inst   = Rtype && (func == 6'b000111);
assign srl_inst    = Rtype && (func == 6'b000010);
assign srlv_inst   = Rtype && (func == 6'b000110);
assign mflo_inst   = Rtype && (func == 6'b010010);
assign mfhi_inst   = Rtype && (func == 6'b010000);
assign mtlo_inst   = Rtype && (func == 6'b010011);
assign mthi_inst   = Rtype && (func == 6'b010001);
assign addi_inst   = (OP == 6'b001000);
assign addiu_inst  = (OP == 6'b001001);
assign andi_inst   = (OP == 6'b001100);
assign ori_inst    = (OP == 6'b001101);
assign xori_inst   = (OP == 6'b001110);
assign slti_inst   = (OP == 6'b001010);
assign sltiu_inst  = (OP == 6'b001011);
assign lui_inst    = (OP == 6'b001111);
assign lb_inst     = (OP == 6'b100000);
assign lbu_inst     = (OP == 6'b100100);
assign lh_inst     = (OP == 6'b100001);
assign lhu_inst     = (OP == 6'b100101);
assign lw_inst     = (OP == 6'b100011);
assign sb_inst     = (OP == 6'b101000);
assign sh_inst     = (OP == 6'b101001);
assign sw_inst     = (OP == 6'b101011);
assign j_inst      = (OP == 6'b000010);
assign jr_inst     = Rtype && (func == 6'b001000);
assign jal_inst    = (OP == 6'b000011);
assign jalr_inst    = Rtype && (func == 6'b001001);
assign beq_inst    = (OP == 6'b000100);
assign bne_inst    = (OP == 6'b000101);
assign bltz_inst   = (OP == 6'b000001)&&(OP_subB==5'b00000);
assign bltzal_inst   = (OP == 6'b000001)&&(OP_subB==5'b10000);
assign blez_inst   = (OP == 6'b000110)&&(OP_subB==5'b00000);
assign bgtz_inst   = (OP == 6'b000111)&&(OP_subB==5'b00000);
assign bgez_inst   = (OP == 6'b000001)&&(OP_subB==5'b00001);
assign bgezal_inst   = (OP == 6'b000001)&&(OP_subB==5'b10001);
assign syscall_inst= Rtype && (func==6'b001100);
assign mtc0_inst   = cp0type && (OP_subA==5'b00100);
assign mfc0_inst   = cp0type && (OP_subA==5'b00000);
assign tlbp_inst   = cp0type && OP_subA[4] && (func==6'b001000);
assign tlbr_inst   = cp0type && OP_subA[4] && (func==6'b000001);
assign tlbwi_inst  = cp0type && OP_subA[4] && (func==6'b000010);
assign tlbwr_inst  = cp0type && OP_subA[4] && (func==6'b000110);
assign eret_inst    = cp0type && OP_subA[4] && (func==6'b011000);
assign break_inst  = Rtype && (func==6'b001101);
assign nop_inst    = (id_inst == 32'b0);
assign div_inst = Rtype && (func == 6'b011010);
assign divu_inst= Rtype && (func == 6'b011011);
assign mult_inst = Rtype && (func == 6'b011000);;
assign multu_inst = Rtype && (func == 6'b011001);;
assign unknown_inst = !(add_inst||addu_inst||sub_inst||subu_inst||and_inst||or_inst||nor_inst||xor_inst||slt_inst||sltu_inst||sll_inst||sllv_inst||sra_inst||srav_inst||srl_inst||srlv_inst||mflo_inst||mfhi_inst||mtlo_inst||mthi_inst||addi_inst||addiu_inst||andi_inst||ori_inst||xori_inst||slti_inst||sltiu_inst||lui_inst||lb_inst||lbu_inst||lh_inst||lhu_inst||lw_inst||sb_inst||sh_inst||sw_inst||j_inst||jr_inst||jal_inst||jalr_inst||beq_inst||bne_inst||bltz_inst||bltzal_inst||blez_inst||bgtz_inst||bgez_inst||bgezal_inst||syscall_inst||mtc0_inst||mfc0_inst||tlbp_inst||tlbr_inst||tlbwi_inst||tlbwr_inst||eret_inst||break_inst||nop_inst||div_inst||divu_inst||mult_inst||multu_inst);


//alu_op
always@(and_inst  or andi_inst  or or_inst or ori_inst or add_inst or 
        addu_inst or addiu_inst or subu_inst or slt_inst or sltu_inst or
        slti_inst or sltiu_inst or srl_inst or srlv_inst or sra_inst or
        sll_inst or sllv_inst or nor_inst or xor_inst or xori_inst or lw_inst or sw_inst or lui_inst)
begin
        if (and_inst || andi_inst) 
                alu_op<=5'b00000;
        else if(or_inst || ori_inst||mflo_inst||mfhi_inst)
                alu_op<=5'b01000;
        else if(add_inst || addi_inst || addu_inst || addiu_inst || lw_inst || sw_inst || jal_inst||jalr_inst||bltzal_inst|| bgezal_inst||lb_inst||lbu_inst||lh_inst||lhu_inst||sb_inst||sh_inst)
                alu_op<=5'b00001;
        else if(sub_inst || subu_inst)
                alu_op<=5'b01001;
        else if(slt_inst || slti_inst)
                alu_op<=5'b01010;
        else if(sltu_inst || sltiu_inst)
                alu_op<=5'b01011;
        else if(srl_inst || srlv_inst)
                alu_op<=5'b00100;
        else if(sra_inst || srav_inst)
                alu_op<=5'b01100;
        else if(sll_inst || sllv_inst)
                alu_op<=5'b10100;
        else if(xor_inst || xori_inst)
                alu_op<=5'b11000;
        else if(nor_inst)
                alu_op<=5'b10000;
		else if(lui_inst)
				alu_op<=5'b11100;
		else if(mult_inst)
				alu_op<=5'b00010;
		else if(multu_inst)
				alu_op<=5'b00110;
		else if(div_inst)
				alu_op<=5'b00011;
		else if(divu_inst)
				alu_op<=5'b00111;
        else
                alu_op<=5'b00000;
end


//cp0
assign write_cp0_reg = mtc0_inst;
assign read_cp0_reg  = mfc0_inst;
assign cp0_reg_index = RDI;
assign tlb_OP_e = (tlbp_inst || tlbr_inst || tlbwi_inst || tlbwr_inst);

always @ (tlbp_inst or tlbr_inst or tlbwi_inst or tlbwr_inst)
        begin
                if(tlbp_inst)
                        tlb_OP<=2'b00;
                else if(tlbr_inst)
                        tlb_OP<=2'b01;
                else if(tlbwi_inst)
                        tlb_OP<=2'b10;
                else if(tlbwr_inst)
                        tlb_OP<=2'b11;
        end

//通用信号
assign reg_des = Rtype;
assign write_reg = (add_inst || addu_inst || addi_inst || addiu_inst || sub_inst ||
                     subu_inst || and_inst || andi_inst || or_inst || ori_inst || slt_inst ||
                     sltu_inst || slti_inst || sltiu_inst || sll_inst || sllv_inst ||
                     sra_inst || srav_inst ||srl_inst ||srlv_inst ||nor_inst||xor_inst||
                     xori_inst ||lw_inst||lb_inst||lbu_inst||lh_inst||lhu_inst||mfc0_inst||mfhi_inst||mflo_inst||lui_inst || jal_inst||jalr_inst||bltzal_inst|| bgezal_inst);
assign write_mem = sw_inst||sb_inst||sh_inst;
assign mem_2_reg = lw_inst||lb_inst||lbu_inst||lh_inst||lhu_inst;
assign write_lo = mtlo_inst||div_inst||divu_inst||mult_inst||multu_inst;
assign write_hi = mthi_inst||div_inst||divu_inst||mult_inst||multu_inst;
assign alu_srcA = (sll_inst || sra_inst || srl_inst);
assign alu_srcB[0] = (addi_inst || addiu_inst || slti_inst || sltiu_inst || lw_inst||sw_inst||lui_inst||jal_inst||jalr_inst||bltzal_inst|| bgezal_inst||lb_inst||lbu_inst||lh_inst||lhu_inst||sb_inst||sh_inst);
assign alu_srcB[1] = (ori_inst || andi_inst ||xori_inst);
assign alu_res_ok = (add_inst || addu_inst || addi_inst || addiu_inst || sub_inst || subu_inst ||
                     and_inst || andi_inst || or_inst || ori_inst || slt_inst || sltu_inst ||
                     slti_inst || sltiu_inst ||sll_inst ||sllv_inst|| sra_inst || srav_inst || srl_inst || srlv_inst||nor_inst||
                     xor_inst || xori_inst||lui_inst||jal_inst||jalr_inst||bltzal_inst|| bgezal_inst||div_inst||divu_inst||mult_inst||multu_inst);
assign mem_res_ok = (lw_inst || lb_inst || lbu_inst || lh_inst || lhu_inst || mfc0_inst);

assign delay = delay_in | delay_self | delay_self_mix;
assign delay_out = delay_self;
assign delay_mix = delay_self_mix;

always @ (reg_des or RDI or RTI)
    begin
		if(jal_inst||jalr_inst||bltzal_inst|| bgezal_inst)
			result_des <=5'b11111;
        else if(reg_des)
            result_des <= RDI;
        else
            result_des <= RTI;
	end

always @ (*)//changed
	begin
		if(!delay)
			begin
				contr_word[4:0]<=alu_op[4:0];
				contr_word[5] <= alu_srcA;
				contr_word[6] <= reg_des;
				contr_word[7] <= write_mem;
				contr_word[8] <= mem_2_reg;
				contr_word[9] <= write_reg;
				contr_word[14:10] <= cp0_reg_index[4:0];
				contr_word[15] <= write_cp0_reg;
				contr_word[16] <= read_cp0_reg;
				contr_word[18:17] <= tlb_OP[1:0];
				contr_word[19] <= tlb_OP_e;
				contr_word[24:20] <= result_des[4:0];//
				contr_word[25] <= alu_res_ok;
				contr_word[26] <= mem_res_ok;
				contr_word[27] <= write_lo;
				contr_word[28] <= write_hi;
				contr_word[29] <= cp0type;
				contr_word[31:30] <= alu_srcB[1:0];
			end
		else
			contr_word<=32'b0;
	end
always @ (*)
	begin
		if(!delay)
			begin
				// int_contr_word[1:0]<=IC_IF[1:0];
				// int_contr_word[0]<=(jalr_inst||jr_inst)&&(reg_A[1:0]!=2'b00);
				int_contr_word[0]<=(id_pc[1:0]!=2'b00);
				int_contr_word[1]<=unknown_inst;
				int_contr_word[2]<=(add_inst || addi_inst ||sub_inst);
				int_contr_word[3]<=break_inst;
				int_contr_word[4]<=syscall_inst;
				int_contr_word[5]<=lw_inst||lh_inst||lhu_inst;//1'b0;
				int_contr_word[6]<=eret_inst;
				// int_contr_word[6]<=write_mem;
				int_contr_word[7]<=sw_inst||sh_inst;//1'b0;
				int_contr_word[8]<=self_branch;
				int_contr_word[15]<=syscall_inst||eret_inst||break_inst;
			end
		else
			int_contr_word<=16'b0;
	end

//数据相关
assign rs_source = (and_inst || andi_inst || or_inst || ori_inst || add_inst ||
                    addi_inst || addu_inst || addiu_inst || lw_inst ||
                    sw_inst || sub_inst || subu_inst ||slt_inst || sltu_inst ||
                    slti_inst || sltiu_inst || srlv_inst || srav_inst ||
                    sllv_inst || nor_inst || xor_inst || xori_inst || beq_inst ||
                    bne_inst || bltz_inst || blez_inst || bgtz_inst || bgez_inst || jr_inst||jalr_inst||
					bltzal_inst|| bgezal_inst
					||div_inst||divu_inst||mult_inst||multu_inst
					||mthi_inst||mtlo_inst||lb_inst||lbu_inst||lh_inst||lhu_inst||sb_inst||sh_inst
					)&&(!nop_inst);
					
assign rt_source = (and_inst || or_inst || add_inst || addu_inst || lw_inst ||
                    sw_inst || sub_inst || subu_inst || slt_inst || sltu_inst ||
                    srlv_inst || srav_inst || sllv_inst || nor_inst || xor_inst ||beq_inst ||
                    bne_inst || bltz_inst ||blez_inst ||bgez_inst||sll_inst||
					bltzal_inst|| bgezal_inst
					||div_inst||divu_inst||mult_inst||multu_inst||mtc0_inst
					)&&(!nop_inst);

assign hi_source = mfhi_inst ;
assign hi_target = mthi_inst||div_inst||divu_inst||mult_inst||multu_inst;
assign lo_source = mflo_inst;
assign lo_target = mtlo_inst||div_inst||divu_inst||mult_inst||multu_inst;
//id-id conflict
// wire non_zero;
// assign non_zero=|RSI;
always@(*)
	begin
		if(
			(
				((|self_des[4:0])||(hi_target||lo_target)) //target en
					&& (self_des[6]||self_des[5]) //line1 wr
					&& ((rs_source && (RSI[4:0]==self_des[4:0]))||(rt_source && (RTI[4:0]==self_des[4:0])))//line1 target eq line2 source
			)
			||((self_hilo[0]&&lo_source)||(self_hilo[1]&&hi_source))
		)
		begin
			delay_self_mix<=1;//id-id conflict
		end 
		else
			delay_self_mix<=0;
	end

//FWDA 
//参�?�图5-10 FWDA可能不受clk控制
always @ (*)
    begin
        if((alu_des_1[6] && ((rs_source && (RSI[4:0] == alu_des_1[4:0]))||(rt_source && (RTI[4:0] == alu_des_1[4:0]))))||
		(alu_des_2[6] && ((rs_source && (RSI[4:0] == alu_des_2[4:0]))|| (rt_source && (RTI[4:0] == alu_des_2[4:0])))))
		begin
			delay_self<=1;
            // RSO<=5'b00000;
            // RTO<=5'b00000;
            // RDO<=5'b00000; 

        end else 
			begin

				delay_self<=0;
				if ((alu_w_hilo_1[0] && lo_source)||(alu_w_hilo_1[1] && hi_source))
					FWDA<=04'b0111;
                else if ((alu_w_hilo_2[0]&&lo_source)
                        || (alu_w_hilo_2[1] && hi_source))            
						FWDA<=4'b1000;
                else if((alu_des_1[5] && ((rs_source && (RSI[4:0] == alu_des_1[4:0]))))) 
						FWDA<=4'b0011;
                else if((alu_des_2[5] && ((rs_source && (RSI[4:0] == alu_des_2[4:0])))))      
						FWDA<=4'b0100;
                else if((mem_wr_hilo_1[0] && lo_source)
                        || (mem_wr_hilo_1[1] && hi_source))              
						FWDA<=4'b1001;
                else if((mem_wr_hilo_2[0] && lo_source)
                        || (mem_wr_hilo_2[1] && hi_source))        
						FWDA<=4'b1010;
                else if((mem_des_1[5] || mem_des_1[6]) && rs_source &&
                        (RSI[4:0] == mem_des_1[4:0])) 
						FWDA<=4'b0101;
                else if((mem_des_2[5] || mem_des_2[6]) && rs_source &&
                        (RSI[4:0] == mem_des_2[4:0]))
						FWDA<=4'b0110;
                else if (lo_source)   
						FWDA<=4'b0010;
                else if (hi_source)
						FWDA<=4'b0001;
                else				
						FWDA<=4'b0000;
			end
    end
                
//FWDB
//参�?�图5-10 FWDB可能不受clk控制
always @ (*)
        begin
                if(alu_des_1[5] && rt_source && (RTI[4:0] == alu_des_1[4:0]))
                        FWDB<=3'b001;
                else if (alu_des_2[5] && rt_source && (RTI[4:0] == alu_des_2[4:0]))
                        FWDB<=3'b010;
                else if ((mem_des_1[5] || mem_des_1[6]) && rt_source && (RTI[4:0] == mem_des_1[4:0]))
                        FWDB<=3'b011;
                else if ((mem_des_2[5] || mem_des_2[6]) && rt_source && (RTI[4:0] == mem_des_2[4:0]))
                        FWDB<=3'b100;
                else
                        FWDB<=3'b000;
        end
//新增模块 参�?�图4-8
always @ (*)
	begin
		RSO<=id_inst[25:21];
		RTO<=id_inst[20:16];
	end


always @ (*)
        begin
                des<={mem_res_ok,alu_res_ok,result_des[4:0]};
                write_hilo = {write_hi,write_lo};
        end
//参�?�图5-10 reg_A reg_B可能不受clk控制
always @(*)
        begin
                case (FWDA)
                        4'b0000 : reg_A <= reg_rs;
                        4'b0001 : reg_A <= hi_r_data;
                        4'b0010 : reg_A <= lo_r_data;
                        4'b0011 : reg_A <= alu_res_1;
                        4'b0100 : reg_A <= alu_res_2;
                        4'b0101 : reg_A <= mem_res_1;
                        4'b0110 : reg_A <= mem_res_2;
                        4'b0111 : reg_A <= alu_hilo_res_1;
                        4'b1000 : reg_A <= alu_hilo_res_2;
                        4'b1001 : reg_A <= mem_hilo_res_1;
                        4'b1010 : reg_A <= mem_hilo_res_2;
                        default: reg_A <= 32'b0;
                endcase

                case (FWDB)
                        3'b000 : reg_B <= reg_rt;
                        3'b001 : reg_B <= alu_res_1;
                        3'b010 : reg_B <= alu_res_2;
                        3'b011 : reg_B <= mem_res_1;
                        3'b100 : reg_B <= mem_res_2;
                        default: reg_B <= 32'b0;
                endcase

        end

always @ (reg_A, reg_B)
begin
        if(reg_A == reg_B)
                rs_eq_rt <= 1;
        else
                rs_eq_rt <= 0;
end

always @ (reg_A)
begin
        if(reg_A == 0)
                rs_eq_z <= 1;
        else
                rs_eq_z <= 0;        
end

always @ (reg_A)
begin
        if(reg_A[31] == 0)
                r_slt_z <= 0;
        else
                r_slt_z <= 1;        
end

reg self_branch;
reg self_j;
reg self_jr;

always @ (j_inst or jr_inst or jal_inst or jalr_inst or beq_inst or rs_eq_rt or bne_inst or bltz_inst or r_slt_z or 
          blez_inst or rs_eq_z or bgtz_inst or r_slt_z or bgez_inst)
begin
        self_branch <= j_inst || jr_inst || jal_inst ||jalr_inst||eret_inst||(beq_inst && rs_eq_rt) || (bne_inst && !rs_eq_rt) ||((bltz_inst||bltzal_inst) && r_slt_z)||
                  (blez_inst && ((rs_eq_z)||(r_slt_z))) || (bgtz_inst && ! (rs_eq_rt || r_slt_z)) ||
                  ((bgez_inst|| bgezal_inst) && !r_slt_z);
        self_j<= j_inst||jal_inst;
        self_jr<=jr_inst||jalr_inst||eret_inst;
end
// assign jr_data = jr_data_ok?reg_A:32'bZ;
always@(*)
begin
	if(jr_data_ok)
		jr_data<=eret_inst?cp0_epc:reg_A;
	else
		jr_data<=32'bZ;
end
always@(*)
begin
	if((jr_inst||jalr_inst||eret_inst)&&(!delay))
		jr_data_ok<=1'b1;
	else
		jr_data_ok<=1'bZ;
end
// assign jr_data_ok = jr_inst&&(!delay)?1'b1:1'bZ;
reg [2:0]size_contr;
reg [2:0]id_size_contr;
always@(*)
begin
	size_contr[0]<=lb_inst||lbu_inst||sb_inst||lw_inst||sw_inst;
	size_contr[1]<=lh_inst||lhu_inst||sh_inst||lw_inst||sw_inst;
	size_contr[2]<=lbu_inst||lhu_inst;
end

wire id_cln;
assign id_cln = delay_self_mix|id_cln_in;

reg id_cln_req;
always @(posedge id_cln)
begin
	id_cln_req<=1'b1;
end

always @ (negedge reset or posedge clk)
	begin
        if(reset==0||(!delay&&id_cln_req)||delay_self_mix)//这里的mix暂时还不能删除,同阶冲突时，由于delay无法立即更新exe，产生重复的exe。
            begin
                id_des[6:0]<=7'b0;
                id_wr_hilo[1:0] <= 2'b0;
                reg_esa[31:0] <= 32'b0;
                reg_esb[31:0] <= 32'b0;
                exe_pc[31:0] <= 32'b0;
                id_contr_word[31:0] <= 32'b0;
                id_int_contr_word[15:0] <= 16'b0;
                immed[31:0] <= 32'b0;
                id_cln_req <= 1'b0;
                end
		// else if(delay)
			// ;
		// else if(id_cln)
			// begin
				// id_des[6:0]<=7'b0;
                // id_wr_hilo[1:0] <= 2'b0;
                // reg_esa[31:0] <= 32'b0;
                // reg_esb[31:0] <= 32'b0;
                // exe_pc[31:0] <= 32'b0;
                // id_contr_word[31:0] <= 32'b0;
                // id_int_contr_word[15:0] <= 16'b0;
                // immed[31:0] <= 32'b0;			
			// end
        else if(!delay)
            begin
                id_des[6:0]<=des[6:0];
                id_wr_hilo[1:0] <=write_hilo[1:0];
				if(jal_inst||jalr_inst||bltzal_inst|| bgezal_inst)
					reg_esa[31:0] <= 32'b0;//如果不冲突，改成由FWDA选择也许更好
				else
					reg_esa[31:0] <= reg_A[31:0];
                reg_esb[31:0] <= reg_B[31:0];
                exe_pc[31:0] <= id_pc[31:0];
                id_contr_word[31:0] <= contr_word[31:0];
                id_int_contr_word[15:0] <= int_contr_word[15:0];
                id_size_contr[2:0] <= size_contr[2:0];
				if(jal_inst||jalr_inst||bltzal_inst|| bgezal_inst)
					immed<=id_pc+8;
                else if(id_inst[15])
                    immed[31:0]<={16'b1111111111111111,id_inst[15:0]};
                else
                    immed[31:0]<={16'b0,id_inst[15:0]};
				branch<=self_branch;
				j<=self_j;
				jr<=self_jr;
            end

	end

endmodule
