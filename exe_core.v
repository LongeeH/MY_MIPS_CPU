`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/19 21:48:26
// Design Name: 
// Module Name: exe_core
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


module exe_core(
	input clk,
	input reset,

	input   [5 :0]      int,
    output              inst_req,
    output              inst_cache,
    output  [31:0]      inst_addr,
    input   [31:0]      inst_rdata,
    input               inst_addr_ok,
    input               inst_data_ok,

    output              data_req,
    output              data_cache,
    output              data_wr,
    output  [3 :0]      data_wstrb,
    output  [31:0]      data_addr,
    output  [2 :0]      data_size,
    output  [31:0]      data_wdata,
    input   [31:0]      data_rdata,
    input               data_addr_ok,
    input               data_data_ok,
    
    output              cache_req,
    output  [6 :0]      cache_op,
    output  [31:0]      cache_tag,
    input               cache_op_ok,

    //debug interface
    output  [31:0]      debug_wb_pc,
    output  [3 :0]      debug_wb_rf_wen,
    output  [4 :0]      debug_wb_rf_wnum,
    output  [31:0]      debug_wb_rf_wdata
    );
	//w_ ��ʾ���ӽӿڼ�ĵ���
	//IF-ID
    wire [31:0]W_inst_1;
	wire [31:0]W_ID_PC_1;
	wire [1:0]W_IC_IF_1;
	wire [31:0]W_inst_2;
	wire [31:0]W_ID_PC_2;
	wire [1:0]W_IC_IF_2;
	wire W_branch;
	wire W_J;
	wire W_dalay;
	
	//ID-EXE
	wire [6:0]W_alu_des_1;
	wire [6:0]W_alu_des_2;
	wire [1:0]W_alu_w_HiLo_1;
	wire [1:0]W_alu_w_HiLo_2;
	wire [31:0]W_alu_res_1;
	wire [31:0]W_alu_res_2;
	wire [31:0]W_alu_HiLo_res_1;
	wire [31:0]W_alu_HiLo_res_2;
	wire [31:0]W_contr_ID_1;
	wire [31:0]W_contr_ID_2;
	wire [7:0]W_IC_ID_1;
	wire [7:0]W_IC_ID_2;
	wire [31:0]W_exe_PC_1;
	wire [31:0]W_exe_PC_2;
	wire [31:0]W_reg_esa_1;
	wire [31:0]W_reg_esa_2;
	wire [31:0]W_reg_esb_1;
	wire [31:0]W_reg_esb_2;
	wire [31:0]W_immed_1;
	wire [31:0]W_immed_2;
	wire [6:0]W_iddes_1;
	wire [6:0]W_iddes_2;
	wire [1:0]W_ID_w_HiLo_1;
	wire [1:0]W_ID_w_HiLo_2;
	
	
	//ID-MEM
	wire [31:0]W_MEM_res_1;
	wire [31:0]W_MEM_res_2;
	wire [6:0]W_MEM_des1;
	wire [6:0]W_MEM_des2;
	wire [1:0]W_MEM_w_HiLo1;
	wire [1:0]W_MEM_w_HiLo2;
	wire [31:0]W_MEM_HiLo_res_1;
	wire [31:0]W_MEM_HiLo_res_2;
	//EXE-MEM
	wire [6:0]W_exe_des_1;
	wire [6:0]W_exe_des_2;
	wire [31:0]W_ALURES_1;
	wire [31:0]W_ALURES_2;
	wire [31:0]W_MEMDATA_1;
	wire [31:0]W_MEMDATA_2;
	wire [31:0]W_CONTROLW_EXE_1;
	wire [31:0]W_CONTROLW_EXE_2;
	wire [7:0]W_INTCONTROLW_EXE_1;
	wire [7:0]W_INTCONTROLW_EXE_2;
	wire [31:0]W_MEMPC_1;
	wire [31:0]W_MEMPC_2;
	wire [31:0]W_MEMHILO_1;
	wire [31:0]W_MEMHILO_2;
	wire [1:0]W_EXEWRITEHILO_1;
	wire [1:0]W_EXEWRITEHILO_2;
	//MEM-WB
	wire [31:0]W_RESULT_1;
	wire [31:0]W_RESULT_2;
	wire [31:0]W_CONTROLW_MEM_1;
	wire [31:0]W_CONTROLW_MEM_2;
	wire [31:0]W_WBHILO_1;
	wire [31:0]W_WBHILO_2;
	
	//ID-REG
	wire [4:0]RSO_1;
	wire [4:0]RSO_2;
	wire [4:0]RTO_1;
	wire [4:0]RTO_2;
	wire [31:0]reg_rs_1;
	wire [31:0]reg_rs_2;
	wire [31:0]reg_rt_1;
	wire [31:0]reg_rt_2;
	wire [31:0]reg_Hi;
	wire [31:0]reg_Lo;
	
	//WB-REG
	wire [31:0]reg_result_1;
	wire [31:0]reg_result_2;
	wire write_reg_1;
	wire write_reg_2;
	wire [4:0]result_des_1;
	wire [4:0]result_des_2;
	wire write_hi_1;
	wire write_hi_2;
	wire write_lo_1;
	wire write_lo_2;
	wire [31:0]reg_hi_1;
	wire [31:0]reg_hi_2;
	wire [31:0]reg_lo_1;
	wire [31:0]reg_lo_2;

	
	
	
	
	
    IF_1 _if1(
		.clk(clk),
		.reset(reset),
		.int(), //�������п�������CP0
		.J(W_J),
		.branch(W_branch),
		.delay(W_dalay),
		.IADEE(),
		.IADFE(),
		.exc_PC(),
		.MEM_inst(),
		.LA_inst(),

		.PC(),
		.inst(W_inst_1),
		.ID_PC(W_ID_PC_1),
		.IC_IF(W_IC_IF_1)
	);
    IF_2 _if2(
		.clk(clk),
		.reset(reset),
		.int(),
		.J(W_J),
		.branch(W_branch),
		.delay(W_dalay),
		.IADEE(),
		.IADFE(),
		.exc_PC(),
		.MEM_inst(),
		.LA_inst(),

		.PC(),
		.inst(W_inst_2),
		.ID_PC(W_ID_PC_2),
		.IC_IF(W_IC_IF_2)
	);
    ID _id1(
		.clk(clk),.reset(reset),.inst(W_inst_1),.ID_PC(W_ID_PC_1),.IC_IF(W_IC_IF_1),
		.reg_rs(reg_rs_1),.reg_rt(reg_rt_1),
		.reg_Hi(reg_Hi),.reg_Lo(Lo),
		.alu_des_1(W_alu_des_1),.alu_w_HiLo1(W_alu_w_HiLo_1),
		.alu_des_2(W_alu_des_2),.alu_w_HiLo2(W_alu_w_HiLo_2),
		.alu_res_1(W_alu_res_1),.alu_res_2(W_alu_res_2),
		.alu_HiLo_res_1(W_alu_HiLo_res_1),.alu_HiLo_res_2(W_alu_HiLo_res_2),
		.MEM_res_1(W_MEM_res_1),.MEM_res_2(W_MEM_res_2),
		.MEM_des1(W_MEM_des1),.MEM_w_HiLo1(W_MEM_w_HiLo1),
		.MEM_des2(W_MEM_des2),.MEM_w_HiLo2(W_MEM_w_HiLo2),
		.MEM_HiLo_res_1(W_MEM_HiLo_res_1),.MEM_HiLo_res_2(W_MEM_HiLo_res_2),
         //output
        .branch(W_branch),.J(W_J),.delay(W_dalay),.contr_ID(W_contr_ID_1),.IC_ID(W_IC_ID_1),.exe_PC(W_exe_PC_1),
		.reg_esa(W_reg_esa_1),.reg_esb(W_reg_esb_1),.immed(W_immed_1),.iddes(W_iddes_1),
		.ID_w_HiLo(W_ID_w_HiLo_1),.RSO(RSO_1),.RTO(RTO_1)
	);
	
	ID _id2(
		.clk(clk),.reset(reset),.inst(W_inst_2),.ID_PC(W_ID_PC_2),.IC_IF(W_IC_IF_2),
		.reg_rs(reg_rs_2),.reg_rt(reg_rt_2),
		.reg_Hi(reg_Hi),.reg_Lo(Lo),
		.alu_des_1(W_alu_des_1),.alu_w_HiLo1(W_alu_w_HiLo_1),
		.alu_des_2(W_alu_des_2),.alu_w_HiLo2(W_alu_w_HiLo_2),
		.alu_res_1(W_alu_res_1),.alu_res_2(W_alu_res_2),
		.alu_HiLo_res_1(W_alu_HiLo_res_1),.alu_HiLo_res_2(W_alu_HiLo_res_2),
		.MEM_res_1(W_MEM_res_1),.MEM_res_2(W_MEM_res_2),
		.MEM_des1(W_MEM_des1),.MEM_w_HiLo1(W_MEM_w_HiLo1),
		.MEM_des2(W_MEM_des2),.MEM_w_HiLo2(W_MEM_w_HiLo2),
		.MEM_HiLo_res_1(W_MEM_HiLo_res_1),.MEM_HiLo_res_2(W_MEM_HiLo_res_2),
         //output
        .branch(W_branch),.J(W_J),.delay(W_dalay),.contr_ID(W_contr_ID_2),.IC_ID(W_IC_ID_2),.exe_PC(W_exe_PC_2),
		.reg_esa(W_reg_esa_2),.reg_esb(W_reg_esb_2),.immed(W_immed_2),.iddes(W_iddes_2),
		.ID_w_HiLo(W_ID_w_HiLo_2),.RSO(RSO_2),.RTO(RTO_2)
	);
	
    exe _exe1(
		.clk(clk),
		.reset(reset),
		.CONTROLW_ID(W_contr_ID_1),	
		.INTCONTROLW_ID(W_IC_ID_1),	
		.EXEPC(W_exe_PC_1),
		.REGRESA(W_reg_esa_1),
		.REGRESB(W_reg_esb_1),
		.IDDES(W_iddes_1),
		.IDWRITEHILO(W_ID_w_HiLo_1),
		.IMMED(W_immed_1),
		.EXEDES(W_exe_des_1),
		.EXEWRITEHILO(W_EXEWRITEHILO_1),
		.ALUDES(W_alu_des_1),
		.ALUWRITEHILO(W_alu_w_HiLo_1),
		.ALURES(W_ALURES_1),
		.MEMDATA(W_MEMDATA_1),
		.CONTROLW_EXE(W_CONTROLW_EXE_1),
		.INTCONTROLW_EXE(W_INTCONTROLW_EXE_1),
		.MEMPC(W_MEMPC_1),
		.MEMHILO(W_MEMHILO_1),
		.ALURESULT(W_alu_res_1),
		.ALUHILORES(W_alu_HiLo_res_1)
	);
	exe _exe2(
		.clk(clk),
		.reset(reset),
		.CONTROLW_ID(W_contr_ID_2),	
		.INTCONTROLW_ID(W_IC_ID_2),	
		.EXEPC(W_exe_PC_2),
		.REGRESA(W_reg_esa_2),
		.REGRESB(W_reg_esb_2),
		.IDDES(W_iddes_2),
		.IDWRITEHILO(W_ID_w_HiLo_2),
		.IMMED(W_immed_2),
		.EXEDES(W_exe_des_2),
		.EXEWRITEHILO(W_EXEWRITEHILO_2),
		.ALUDES(W_alu_des_2),
		.ALUWRITEHILO(W_alu_w_HiLo_2),
		.ALURES(W_ALURES_2),
		.MEMDATA(W_MEMDATA_2),
		.CONTROLW_EXE(W_CONTROLW_EXE_2),
		.INTCONTROLW_EXE(W_INTCONTROLW_EXE_2),
		.MEMPC(W_MEMPC_2),
		.MEMHILO(W_MEMHILO_2),
		.ALURESULT(W_alu_res_2),
		.ALUHILORES(W_alu_HiLo_res_2)
	);
	
    mem _mem1(
		.clk(clk),
		.reset(reset),
		.CONTROLW_EXE(W_CONTROLW_EXE_1),
		.INTCONTROLW_EXE(W_INTCONTROLW_EXE_1),
		.ALURES(W_ALURES_1),
		.MEMDATAI(),
		.CP0DATAI(),
		.MEMHILO(W_MEMHILO_1),
		.MEMDATA(W_MEMDATA_1),
		.MEMPC(W_MEMPC_1),
		.EXEDES(W_exe_des_1),
		.EXEWRITEHILO(W_EXEWRITEHILO_1),
		.TRANDATADDR(),
		.SORL(),
		.WRITEMEM(),
		.READCP0REG(),
		.WRITECP0REG(),
		.TLBOPE(),
		.DADDR(),
		.DATAO(),
		.INTV(),
		.CP0REGINDEX(),
		.TLBOP(),
		.RESULT(W_RESULT_1),
		.CONTROLW_MEM(W_CONTROLW_MEM_1),
		.WBHILO(W_WBHILO_1),
		.MEMRESULT(W_MEM_res_1),
		.MEMHILORES(W_MEM_HiLo_res_1),
		.MEMDES(W_MEM_des1),
		.MEMWRITEHILO(W_MEM_w_HiLo1),
		.INTPC()
	);
	mem _mem2(
		.clk(clk),
		.reset(reset),
		.CONTROLW_EXE(W_CONTROLW_EXE_2),
		.INTCONTROLW_EXE(W_INTCONTROLW_EXE_2),
		.ALURES(W_ALURES_2),
		.MEMDATAI(),
		.CP0DATAI(),
		.MEMHILO(W_MEMHILO_2),
		.MEMDATA(W_MEMDATA_2),
		.MEMPC(W_MEMPC_2),
		.EXEDES(W_exe_des_2),
		.EXEWRITEHILO(W_EXEWRITEHILO_2),
		.TRANDATADDR(),
		.SORL(),
		.WRITEMEM(),
		.READCP0REG(),
		.WRITECP0REG(),
		.TLBOPE(),
		.DADDR(),
		.DATAO(),
		.INTV(),
		.CP0REGINDEX(),
		.TLBOP(),
		.RESULT(W_RESULT_2),
		.CONTROLW_MEM(W_CONTROLW_MEM_2),
		.WBHILO(W_WBHILO_2),
		.MEMRESULT(W_MEM_res_2),
		.MEMHILORES(W_MEM_HiLo_res_2),
		.MEMDES(W_MEM_des2),
		.MEMWRITEHILO(W_MEM_w_HiLo2),
		.INTPC()
	);
    
	WB _wb1(
		.clk(clk),
		.reset(reset),
		.controlw_MEM(W_CONTROLW_MEM_1),
		.result(W_RESULT_1),
		.WB_hi_lo(W_WBHILO_1),
		.reg_result(reg_result_1),
		.write_reg(write_reg_1),
		.write_hi(write_hi_1),
		.write_lo(write_lo_1),
		.result_des(result_des_1),
		.reg_hi(reg_hi_1),
		.reg_lo(reg_lo_1)
	);
	WB _wb2(
		.clk(clk),
		.reset(reset),
		.controlw_MEM(W_CONTROLW_MEM_2),
		.result(W_RESULT_2),
		.WB_hi_lo(W_WBHILO_1),
		.reg_result(reg_result_2),
		.write_reg(write_reg_2),
		.write_hi(write_hi_2),
		.write_lo(write_lo_2),
		.result_des(result_des_2),
		.reg_hi(reg_hi_2),
		.reg_lo(reg_lo_2)
	);
	
	register_file register(
		.clk(clk),
		.reset(reset),
		.RS_Addr_1(RSO_1),
		.RS_Addr_2(RSO_2),
		.RT_Addr_1(RTO_1),
		.RT_Addr_2(RTO_2),
		.Write_Enable_1(write_reg_1),
		.Write_Enable_2(write_reg_2),
		.Write_Addr_1(result_des_1),
		.Write_Addr_2(result_des_2),
		.Write_Data_1(reg_result_1),
		.Write_Data_2(reg_result_2),
		//output
		.RS_Data_1(reg_rs_1),
		.RS_Data_2(reg_rs_2),
		.RT_Data_1(reg_rt_1),
		.RT_Data_2(reg_rs_2)
	);
	register_hilo register_hi(
		.clk(clk),
		.reset(reset),
		.Write_Enable_1(write_hi_1),
		.Write_Enable_2(write_hi_2),
		.Write_Data_1(reg_hi_1),
		.Write_Data_2(reg_hi_2),
		.HILO_Data(reg_Hi)
	);
	register_hilo register_lo(
		.clk(clk),
		.reset(reset),
		.Write_Enable_1(write_lo_1),
		.Write_Enable_2(write_lo_2),
		.Write_Data_1(reg_lo_1),
		.Write_Data_2(reg_lo_2),
		.HILO_Data(reg_Lo)
	);
	
endmodule
