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


module ID(//input
            clk,reset,inst,ID_PC,IC_IF,
            reg_rs,reg_rt,
            reg_Hi,reg_Lo,
            alu_des_1,alu_w_HiLo1,
            alu_des_2,alu_w_HiLo2,
            alu_res_1,alu_res_2,
            alu_HiLo_res_1,alu_HiLo_res_2,
            MEM_res_1,MEM_res_2,
            MEM_des1,MEM_w_HiLo1,
            MEM_des2,MEM_w_HiLo2,
            MEM_HiLo_res_1,MEM_HiLo_res_2,
         //output
            branch,J,delay,contr_ID,IC_ID,exe_PC,
            reg_esa,reg_esb,immed,iddes,
            ID_w_HiLo,RSO,RTO
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
input [31:0]inst;
input [31:0]ID_PC;
input [1:0]IC_IF;
input [31:0]reg_rs;
input [31:0]reg_rt;
input [31:0]reg_Hi;
input [31:0]reg_Lo;
input [6:0]alu_des_1;
input [1:0]alu_w_HiLo1;
input [6:0]alu_des_2;
input [1:0]alu_w_HiLo2;
input [31:0]alu_res_1;
input [31:0]alu_res_2;
input [31:0]alu_HiLo_res_1;
input [31:0]alu_HiLo_res_2;
input [31:0]MEM_res_1;
input [31:0]MEM_res_2;
input [6:0]MEM_des1;
input [1:0]MEM_w_HiLo1;
input [6:0]MEM_des2;
input [1:0]MEM_w_HiLo2;
input [31:0]MEM_HiLo_res_1;
input [31:0]MEM_HiLo_res_2;

output branch;
output J;
output delay;
output [31:0]contr_ID;
output [7:0]IC_ID;
output [31:0]exe_PC;
output [31:0]reg_esa;
output [31:0]reg_esb;
output [31:0]immed;
output [6:0]iddes;
output [1:0]ID_w_HiLo;
output [4:0]RSO;
output [4:0]RTO;

//输出
reg branch;
reg J;
reg delay;
reg [31:0]contr_ID;
reg [7:0]IC_ID;
reg [31:0]exe_PC;
reg [31:0]reg_esa;
reg [31:0]reg_esb;
reg [31:0]immed;
reg [6:0]iddes;
reg [1:0]ID_w_HiLo;
reg [4:0]RSO;
reg [4:0]RTO;

//中间变量
reg [4:0]ALU_OP;
reg [1:0]TLB_OP;
reg [4:0]result_des;
reg [31:0]control;
reg [7:0]control_w;
reg [3:0]FWDA;
reg [3:0]FWDB;
reg [31:0]reg_A;
reg [31:0]reg_B;
reg r_slt_z;
reg rseq_z;
reg rseq_rt;
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
wire [1:0]ALU_srcA;
wire [1:0]ALU_srcB;
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
wire lw_inst;
wire sw_inst;
wire j_inst;
wire beq_inst;
wire bne_inst;
wire bltz_inst;
wire blez_inst;
wire bgtz_inst;
wire bgez_inst;
wire syscall_inst;
wire mtc0_inst;
wire mfc0_inst;
wire tlbp_inst;
wire tlbr_inst;
wire tlbwi_inst;
wire tlbwr_inst;
wire rfe_inst;
wire break_inst;
wire nop_inst;


assign OP[5:0]     = inst[31:26];
assign func[5:0]   = inst[5:0];
assign RSI[4:0]    = inst[25:21];
assign OP_subA[4:0]= inst[25:21];
assign OP_subB[4:0]= inst[20:16];
assign RTI[4:0]    = inst[20:16];
assign RDI[4:0]    = inst[15:11];
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
assign lw_inst     = (OP == 6'b100011);
assign sw_inst     = (OP == 6'b101011);
assign j_inst      = (OP == 6'b000010);
assign beq_inst    = (OP == 6'b000100);
assign bne_inst    = (OP == 6'b000101);
assign bltz_inst   = (OP == 6'b000001)&&(OP_subB==5'b00000);
assign blez_inst   = (OP == 6'b000110)&&(OP_subB==5'b00000);
assign bgtz_inst   = (OP == 6'b000111)&&(OP_subB==5'b00000);
assign bgez_inst   = (OP == 6'b000001)&&(OP_subB==5'b00001);
assign syscall_inst= Rtype && (func==6'b001100);
assign mtc0_inst   = cp0type && (OP_subA==5'b00100);
assign mfc0_inst   = cp0type && (OP_subA==5'b00000);
assign tlbp_inst   = cp0type && OP_subA[4] && (func==6'b001000);
assign tlbr_inst   = cp0type && OP_subA[4] && (func==6'b000001);
assign tlbwi_inst  = cp0type && OP_subA[4] && (func==6'b000010);
assign tlbwr_inst  = cp0type && OP_subA[4] && (func==6'b000110);
assign rfe_inst    = cp0type && OP_subA[4] && (func==6'b011000);
assign break_inst  = Rtype && (func==6'b001101);
assign nop_inst    = (inst == 32'b0);

//ALU_OP
always@(and_inst  or andi_inst  or or_inst or ori_inst or add_inst or 
        addu_inst or addiu_inst or subu_inst or slt_inst or sltu_inst or
        slti_inst or sltiu_inst or srl_inst or srlv_inst or sra_inst or
        sll_inst or sllv_inst or nor_inst or xor_inst or xori_inst or lw_inst or sw_inst)
begin
        if (and_inst || andi_inst) 
                ALU_OP<=5'b00000;
        else if(or_inst || ori_inst)
                ALU_OP<=5'b01000;
        else if(add_inst || addi_inst || addu_inst || addiu_inst || lw_inst || sw_inst)
                ALU_OP<=5'b00001;
        else if(sub_inst || subu_inst)
                ALU_OP<=5'b01001;
        else if(slt_inst || sltu_inst || slti_inst || sltiu_inst)
                ALU_OP<=5'b01010;
        else if(srl_inst || srlv_inst)
                ALU_OP<=5'b00100;
        else if(sra_inst || srav_inst)
                ALU_OP<=5'b01100;
        else if(sll_inst || sllv_inst)
                ALU_OP<=5'b10100;
        else if(xor_inst || xori_inst)
                ALU_OP<=5'b11000;
        else
                ALU_OP<=5'b00000;
end


//cp0
assign write_cp0_reg = mtc0_inst;
assign read_cp0_reg  = mfc0_inst;
assign cp0_reg_index = RDI;
assign TLB_OP_e = (tlbp_inst || tlbr_inst || tlbwi_inst || tlbwr_inst);

always @ (tlbp_inst or tlbr_inst or tlbwi_inst or tlbwr_inst)
        begin
                if(tlbp_inst)
                        TLB_OP<=2'b00;
                else if(tlbr_inst)
                        TLB_OP<=2'b01;
                else if(tlbwi_inst)
                        TLB_OP<=2'b10;
                else if(tlbwr_inst)
                        TLB_OP<=2'b11;
        end

//通用信号
 assign reg_des = Rtype;
 assign write_reg = (add_inst || addu_inst || addi_inst || addiu_inst || sub_inst ||
                     subu_inst || and_inst || or_inst || ori_inst || slt_inst ||
                     sltu_inst || slti_inst || sltiu_inst || sll_inst || sllv_inst ||
                     sra_inst || srav_inst ||srl_inst ||srlv_inst ||nor_inst||xor_inst||
                     xori_inst ||lw_inst||mfc0_inst||mfhi_inst||mflo_inst);
assign write_MEM = sw_inst;
assign MEM_2_reg = lw_inst;
assign write_lo = mtlo_inst;
assign write_hi = mthi_inst;
assign ALU_srcA = (sll_inst || sra_inst || srl_inst);
assign ALU_srcB[0] = (addi_inst || addiu_inst || slti_inst || sltiu_inst || lw_inst||sw_inst);
assign ALU_srcB[1] = (ori_inst || andi_inst ||xori_inst);
assign ALU_res_ok = (add_inst || addu_inst || addi_inst || addiu_inst || sub_inst || subu_inst ||
                     and_inst || andi_inst || or_inst || ori_inst || slt_inst || sltu_inst ||
                     slti_inst || sltiu_inst ||sll_inst || sra_inst || srav_inst || srl_inst ||nor_inst||
                     xor_inst || xori_inst);
assign MEM_res_ok = (lw_inst || mfc0_inst);
always @ (reg_des or RDI or RTI)
        begin
                if(reg_des)
                        result_des <= RDI;
                else
                        result_des <= RTI;
        end

always @ (*)//changed
        if(!delay)
                begin
                        control[4:0]<=ALU_OP[4:0];
                        control[5] <= ALU_srcA;
                        control[6] <= reg_des;
                        control[7] <= write_MEM;
                        control[8] <= MEM_2_reg;
                        control[9] <= write_reg;
                        control[14:10] <= cp0_reg_index[4:0];
                        control[15] <= write_cp0_reg;
                        control[16] <= read_cp0_reg;
                        control[18:17] <= TLB_OP[1:0];
                        control[19] <= TLB_OP_e;
                        control[24:20] <= result_des[4:0];
                        control[25] <= ALU_res_ok;
                        control[26] <= MEM_res_ok;
                        control[27] <= write_lo;
                        control[28] <= write_hi;
                        control[29] <= cp0type;
                        control[31:30] <= ALU_srcB[1:0];
                end; 

always @ (posedge clk)
        if(!delay)
                begin
                        control_w[1:0]<=IC_IF[1:0];
                        control_w[2]<=(add_inst || addi_inst ||sub_inst);
                        control_w[3]<=break_inst;
                        control_w[4]<=syscall_inst;
                        control_w[5]<=rfe_inst;
                        control_w[6]<=write_MEM;
                        control_w[7]<=branch;
                end; 


//数据相关
assign rs_source = (and_inst || andi_inst || or_inst || ori_inst || add_inst ||
                    addi_inst || addu_inst || addiu_inst || lw_inst ||
                    sw_inst || sub_inst || subu_inst ||slt_inst || sltu_inst ||
                    slti_inst || sltiu_inst || srlv_inst || srav_inst ||
                    sllv_inst || nor_inst || xor_inst || xori_inst || beq_inst ||
                    bne_inst || bltz_inst || blez_inst || bgtz_inst || bgez_inst);
assign rt_source = (and_inst || or_inst || add_inst || addu_inst || lw_inst ||
                    sw_inst || sub_inst || subu_inst || slt_inst || sltu_inst ||
                    srlv_inst || srav_inst || sllv_inst || nor_inst || xor_inst ||beq_inst ||
                    bne_inst || bltz_inst ||blez_inst ||bgez_inst);

assign hi_source =  mfhi_inst ;
assign hi_target = mthi_inst;
assign lo_source = mflo_inst;
assign lo_target = mtlo_inst;

//FWDA 
//参考图5-10 FWDA可能不受clk控制
always @ (*)
    begin
        if((alu_des_1[6] && ((rs_source && (RSI[4:0] == alu_des_1[4:0]))||(rt_source && (RTI[4:0] == alu_des_1[4:0]))))||(alu_des_2[6] && ((rs_source && (RSI[4:0] == alu_des_2[4:0]))|| (rt_source && (RTI[4:0] == alu_des_2[4:0])))))
		begin
			delay<=1;
            RSO<=5'b00000;
            RTO<=5'b00000;
            RDO<=5'b00000; 
        end else 
			begin
				delay<=0;
				if ((alu_w_HiLo1[0] && lo_source)||(alu_w_HiLo1[1] && hi_source))
					FWDA<=04'b111;
                else if ((alu_w_HiLo2[0]&&lo_source)
                        || (alu_w_HiLo2[1] && hi_source))            
						FWDA<=4'b1000;
                else if((alu_des_1[5] && ((rs_source && (RSI[4:0] == alu_des_1))))) 
						FWDA<=4'b0011;
                else if((alu_des_2[5] && ((rs_source && (RSI[4:0] == alu_des_2)))))      
						FWDA<=4'b0100;
                else if((MEM_w_HiLo1[0] && lo_source)
                        || (MEM_w_HiLo1[1] && hi_source))              
						FWDA<=4'b0111;
                else if((MEM_w_HiLo2[0] && lo_source)
                        || (MEM_w_HiLo2[1] && hi_source))        
						FWDA<=4'b1000;
                else if((MEM_des1[5] || MEM_des1[6]) && rs_source &&
                        (RSI[4:0] == MEM_des1[4:0])) 
						FWDA<=4'b1010;
                else if((MEM_des2[5] || MEM_des2[6]) && rs_source &&
                        (RSI[4:0] == MEM_des2[4:0]))
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
//参考图5-10 FWDB可能不受clk控制
always @ (*)
        begin
                if(alu_des_1[5] && rt_source && (RTI[4:0] == alu_des_1[4:0]))
                        FWDB<=3'b001;
                else if (alu_des_2[5] && rt_source && (RTI[4:0] == alu_des_2[4:0]))
                        FWDB<=3'b010;
                else if ((MEM_des1[5] || MEM_des1[6]) && rt_source && (RTI[4:0] == MEM_des1[4:0]))
                        FWDB<=3'b011;
                else if ((MEM_des2[5] || MEM_des2[6]) && rt_source && (RTI[4:0] == MEM_des2[4:0]))
                        FWDB<=3'b100;
                else
                        FWDB<=3'b000;
        end
//新增模块 参考图4-8
always @ (*)
	begin
		RSO<=inst[25:21];
		RTO<=inst[20:16];
	end


always @ (posedge clk)
        begin
                des<={MEM_res_ok,ALU_res_ok,result_des[4:0]};
                write_hilo = {write_hi,write_lo};
        end
//参考图5-10 reg_A reg_B可能不受clk控制
always @(*)
        begin
                case (FWDA)
                        4'b0000 : reg_A <= reg_rs;
                        4'b0001 : reg_A <= reg_Hi;
                        4'b0010 : reg_A <= reg_Hi;
                        4'b0000 : reg_A <= alu_res_1;
                        4'b0000 : reg_A <= alu_res_2;
                        4'b0000 : reg_A <= MEM_res_1;
                        4'b0000 : reg_A <= MEM_res_2;
                        4'b0000 : reg_A <= alu_HiLo_res_1;
                        4'b0000 : reg_A <= alu_HiLo_res_2;
                        4'b0000 : reg_A <= MEM_HiLo_res_1;
                        4'b0000 : reg_A <= MEM_HiLo_res_2;
                        default: reg_A <= 32'b0;
                endcase

                case (FWDB)
                        3'b000 : reg_B <= reg_rt;
                        3'b000 : reg_B <= alu_res_1;
                        3'b000 : reg_B <= alu_res_2;
                        3'b000 : reg_B <= MEM_res_1;
                        3'b000 : reg_B <= MEM_res_2;
                        default: reg_B <= 32'b0;
                endcase

        end

always @ (reg_rs, reg_rt)
begin
        if(reg_rs == reg_rt)
                rseq_rt <= 1;
        else
                rseq_rt <= 0;
end

always @ (reg_rs)
begin
        if(reg_rs == 0)
                rseq_z <= 1;
        else
                rseq_z <= 0;        
end

always @ (reg_rs)
begin
        if(reg_rs[31] == 0)
                r_slt_z <= 1;
        else
                r_slt_z <= 0;        
end

always @ (j_inst or beq_inst or rseq_rt or bne_inst or bltz_inst or r_slt_z or 
          blez_inst or rseq_z or bgtz_inst or r_slt_z or bgez_inst)
begin
        branch <= j_inst || (beq_inst && rseq_rt) || (bne_inst && !rseq_rt) ||
                  (blez_inst && rseq_z) || (bgtz_inst && ! (rseq_rt || r_slt_z)) ||
                  (bgez_inst && !r_slt_z);
        J<= j_inst;
end

always @ (negedge reset or posedge clk)
        if(reset==0)
                begin
                        iddes[6:0]<=7'b0;
                        ID_w_HiLo[1:0] <= 2'b0;
                        reg_esa[31:0] <= 32'b0;
                        reg_esb[31:0] <= 32'b0;
                        exe_PC[31:0] <= 32'b0;
                        contr_ID[31:0] <= 32'b0;
                        IC_ID[7:0] <= 32'b0;
                        immed[31:0] <= 32'b0;
                end
        else
                begin
                        iddes[6:0]<=des[6:0];
                        ID_w_HiLo[1:0] <=write_hilo[1:0];
                        reg_esa[31:0] <= reg_A[31:0];
                        reg_esb[31:0] <= reg_B[31:0];
                        exe_PC[31:0] <= ID_PC[31:0];
                        contr_ID[31:0] <= control[31:0];
                        IC_ID[7:0] <= control_w[7:0];
                        if(inst[15])
                                immed[31:0]<={16'b1111111111111111,inst[15:0]};
                        else
                                immed[31:0]<={16'b0,inst[15:0]};
                end


endmodule
