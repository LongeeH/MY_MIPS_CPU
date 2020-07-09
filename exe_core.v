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
	//test axi port here
	output reg arvalid,
	output reg [31:0]araddr,
	output reg [3:0]arid,
	output reg [3:0]arlen,
	output reg [1:0]arburst,
	output reg [1:0]arlock,
	output reg [3:0]arcache,
	output reg [2:0]arprot,
	output reg [2:0]arsize,
	output reg rready,
	
	input rvalid,
	input [31:0]rdata,
	input arready,
	//No function port (copied)
	input   [5 :0]      int,
    output              inst_req,
    output              inst_cache,
    output  [31:0]      inst_addr,
	//output  [2:0]		arsize,
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
    output  [31:0] debug_wb_pc_1,
    output  [3:0] debug_wb_rf_wen_1,
    output  [4:0] debug_wb_rf_wnum_1,
    output  [31:0] debug_wb_rf_wdata_1,
    output  [31:0] debug_wb_pc_2,
    output  [3:0] debug_wb_rf_wen_2,
    output  [4:0] debug_wb_rf_wnum_2,
    output  [31:0] debug_wb_rf_wdata_2
    );
	
	
	//wire put here
	//IF-IF
	wire [31:0]la_inst_1;
	wire [31:0]la_inst_2;
	//IF-ID
    wire [31:0]inst_1;
	wire [31:0]ID_PC_1;
	wire [1:0]IC_IF_1;
	wire [31:0]inst_2;
	wire [31:0]ID_PC_2;
	wire [1:0]IC_IF_2;
	wire branch_1;
	wire branch_2;//nouse
	wire J_1;
	wire J_2;//useless
	wire delay;
	//ID-EXE
	wire [6:0]alu_des_1;
	wire [6:0]alu_des_2;
	wire [1:0]alu_HiLo_1;
	wire [1:0]alu_HiLo_2;
	wire [31:0]alu_res_1;
	wire [31:0]alu_res_2;
	wire [31:0]alu_HiLo_res_1;
	wire [31:0]alu_HiLo_res_2;
	wire [31:0]contr_ID_1;
	wire [31:0]contr_ID_2;
	wire [7:0]IC_ID_1;
	wire [7:0]IC_ID_2;
	wire [31:0]exe_PC_1;
	wire [31:0]exe_PC_2;
	wire [31:0]reg_esa_1;
	wire [31:0]reg_esa_2;
	wire [31:0]reg_esb_1;
	wire [31:0]reg_esb_2;
	wire [31:0]immed_1;
	wire [31:0]immed_2;
	wire [6:0]iddes_1;
	wire [6:0]iddes_2;
	wire [1:0]ID_HiLo_1;
	wire [1:0]ID_HiLo_2;
	//ID-MEM
	wire [31:0]MEM_res_1;
	wire [31:0]MEM_res_2;
	wire [6:0]MEM_des1;
	wire [6:0]MEM_des2;
	wire [1:0]MEM_HiLo1;
	wire [1:0]MEM_HiLo2;
	wire [31:0]MEM_HiLo_res_1;
	wire [31:0]MEM_HiLo_res_2;
	//EXE-MEM
	wire [6:0]exe_des_1;
	wire [6:0]exe_des_2;
	wire [31:0]ALURES_1;
	wire [31:0]ALURES_2;
	wire [31:0]MEMDATA_1;
	wire [31:0]MEMDATA_2;
	wire [31:0]CONTROLEXE_1;
	wire [31:0]CONTROLEXE_2;
	wire [7:0]INTCONTROLEXE_1;
	wire [7:0]INTCONTROLEXE_2;
	wire [31:0]MEMPC_1;
	wire [31:0]MEMPC_2;
	wire [31:0]MEMHILO_1;
	wire [31:0]MEMHILO_2;
	wire [1:0]EXEWRITEHILO_1;
	wire [1:0]EXEWRITEHILO_2;
	//MEM-WB
	wire [31:0]RESULT_1;
	wire [31:0]RESULT_2;
	wire [31:0]CONTROLMEM_1;
	wire [31:0]CONTROLMEM_2;
	wire [31:0]WBHILO_1;
	wire [31:0]WBHILO_2;
	wire [31:0]WB_PC_1;
	wire [31:0]WB_PC_2;
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
	
	//model put here
	
    IF_1 _if1(
		.clk(clk),
		.reset(reset),
		.int(), //maybe need CP0
		.J(J_1),
		.branch_1(branch_1),
		.branch_2(branch_2),
		.inst_delay_fetch(inst_delay_fetch),
		.delay(if_delay_1),
		.IADEE(),
		.IADFE(),
		.exc_PC(),
		.MEM_inst(MEM_inst_1),
		.la_inst_in(la_inst_2),

		.PC(pc_1),
		.inst(inst_1),
		.ID_PC(ID_PC_1),
		.IC_IF(IC_IF_1),
		.la_inst_out(la_inst_1)
	);
    IF_2 _if2(
		.clk(clk),
		.reset(reset),
		.int(),
		.J(J_2),
		.branch_1(branch_1),
		.branch_2(branch_2),
		.inst_delay_fetch(inst_delay_fetch),
		.delay(if_delay_2),
		.IADEE(),
		.IADFE(),
		.exc_PC(),
		.MEM_inst(MEM_inst_2),
		.la_inst_in(la_inst_1),

		.PC(pc_2),
		.inst(inst_2),
		.ID_PC(ID_PC_2),
		.IC_IF(IC_IF_2),
		.la_inst_out(la_inst_2)
	);
    
	ID _id1(
		.clk(clk),.reset(reset),.inst(inst_1),.ID_PC(ID_PC_1),.IC_IF(IC_IF_1),
		.reg_rs(reg_rs_1),.reg_rt(reg_rt_1),
		.reg_Hi(reg_Hi),.reg_Lo(reg_Lo),
		.alu_des_1(alu_des_1),.alu_w_HiLo1(alu_HiLo_1),
		.alu_des_2(alu_des_2),.alu_w_HiLo2(alu_HiLo_2),
		.alu_res_1(alu_res_1),.alu_res_2(alu_res_2),
		.alu_HiLo_res_1(alu_HiLo_res_1),.alu_HiLo_res_2(alu_HiLo_res_2),
		.MEM_res_1(MEM_res_1),.MEM_res_2(MEM_res_2),
		.MEM_des1(MEM_des1),.MEM_w_HiLo1(MEM_HiLo1),
		.MEM_des2(MEM_des2),.MEM_w_HiLo2(MEM_HiLo2),
		.MEM_HiLo_res_1(MEM_HiLo_res_1),.MEM_HiLo_res_2(MEM_HiLo_res_2),
         //output
        .branch(branch_1),.J(J_1),.delay(delay),.contr_ID(contr_ID_1),.IC_ID(IC_ID_1),.exe_PC(exe_PC_1),
		.reg_esa(reg_esa_1),.reg_esb(reg_esb_1),.immed(immed_1),.iddes(iddes_1),
		.ID_w_HiLo(ID_HiLo_1),.RSO(RSO_1),.RTO(RTO_1)
	);	
	ID _id2(
		.clk(clk),.reset(reset),.inst(inst_2),.ID_PC(ID_PC_2),.IC_IF(IC_IF_2),
		.reg_rs(reg_rs_2),.reg_rt(reg_rt_2),
		.reg_Hi(reg_Hi),.reg_Lo(reg_Lo),
		.alu_des_1(alu_des_1),.alu_w_HiLo1(alu_HiLo_1),
		.alu_des_2(alu_des_2),.alu_w_HiLo2(alu_HiLo_2),
		.alu_res_1(alu_res_1),.alu_res_2(alu_res_2),
		.alu_HiLo_res_1(alu_HiLo_res_1),.alu_HiLo_res_2(alu_HiLo_res_2),
		.MEM_res_1(MEM_res_1),.MEM_res_2(MEM_res_2),
		.MEM_des1(MEM_des1),.MEM_w_HiLo1(MEM_HiLo1),
		.MEM_des2(MEM_des2),.MEM_w_HiLo2(MEM_HiLo2),
		.MEM_HiLo_res_1(MEM_HiLo_res_1),.MEM_HiLo_res_2(MEM_HiLo_res_2),
         //output
        .branch(branch_2),.J(J_2),.delay(delay),.contr_ID(contr_ID_2),.IC_ID(IC_ID_2),.exe_PC(exe_PC_2),
		.reg_esa(reg_esa_2),.reg_esb(reg_esb_2),.immed(immed_2),.iddes(iddes_2),
		.ID_w_HiLo(ID_HiLo_2),.RSO(RSO_2),.RTO(RTO_2)
	);
	
    exe _exe1(
		.clk(clk),
		.reset(reset),
		.CONTROLW_ID(contr_ID_1),	
		.INTCONTROLW_ID(IC_ID_1),	
		.EXEPC(exe_PC_1),
		.REGRESA(reg_esa_1),
		.REGRESB(reg_esb_1),
		.IDDES(iddes_1),
		.IDWRITEHILO(ID_HiLo_1),
		.IMMED(immed_1),
		.EXEDES(exe_des_1),
		.EXEWRITEHILO(EXEWRITEHILO_1),
		.ALUDES(alu_des_1),
		.ALUWRITEHILO(alu_HiLo_1),
		.ALURES(ALURES_1),
		.MEMDATA(MEMDATA_1),
		.CONTROLW_EXE(CONTROLEXE_1),
		.INTCONTROLW_EXE(INTCONTROLEXE_1),
		.MEMPC(MEMPC_1),
		.MEMHILO(MEMHILO_1),
		.ALURESULT(alu_res_1),
		.ALUHILORES(alu_HiLo_res_1)
	);
	exe _exe2(
		.clk(clk),
		.reset(reset),
		.CONTROLW_ID(contr_ID_2),	
		.INTCONTROLW_ID(IC_ID_2),	
		.EXEPC(exe_PC_2),
		.REGRESA(reg_esa_2),
		.REGRESB(reg_esb_2),
		.IDDES(iddes_2),
		.IDWRITEHILO(ID_HiLo_2),
		.IMMED(immed_2),
		.EXEDES(exe_des_2),
		.EXEWRITEHILO(EXEWRITEHILO_2),
		.ALUDES(alu_des_2),
		.ALUWRITEHILO(alu_HiLo_2),
		.ALURES(ALURES_2),
		.MEMDATA(MEMDATA_2),
		.CONTROLW_EXE(CONTROLEXE_2),
		.INTCONTROLW_EXE(INTCONTROLEXE_2),
		.MEMPC(MEMPC_2),
		.MEMHILO(MEMHILO_2),
		.ALURESULT(alu_res_2),
		.ALUHILORES(alu_HiLo_res_2)
	);
	
    mem _mem1(
		.clk(clk),
		.reset(reset),
		.CONTROLW_EXE(CONTROLEXE_1),
		.INTCONTROLW_EXE(INTCONTROLEXE_1),
		.ALURES(ALURES_1),
		.MEMDATAI(),
		.CP0DATAI(),
		.MEMHILO(MEMHILO_1),
		.MEMDATA(MEMDATA_1),
		.MEMPC(MEMPC_1),
		.EXEDES(exe_des_1),
		.EXEWRITEHILO(EXEWRITEHILO_1),
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
		.RESULT(RESULT_1),
		.CONTROLW_MEM(CONTROLMEM_1),
		.WBHILO(WBHILO_1),
		.MEMRESULT(MEM_res_1),
		.MEMHILORES(MEM_HiLo_res_1),
		.MEMDES(MEM_des1),
		.MEMWRITEHILO(MEM_HiLo1),
		.INTPC(),
		.WB_PC(WB_PC_1)
	);
	mem _mem2(
		.clk(clk),
		.reset(reset),
		.CONTROLW_EXE(CONTROLEXE_2),
		.INTCONTROLW_EXE(INTCONTROLEXE_2),
		.ALURES(ALURES_2),
		.MEMDATAI(),
		.CP0DATAI(),
		.MEMHILO(MEMHILO_2),
		.MEMDATA(MEMDATA_2),
		.MEMPC(MEMPC_2),
		.EXEDES(exe_des_2),
		.EXEWRITEHILO(EXEWRITEHILO_2),
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
		.RESULT(RESULT_2),
		.CONTROLW_MEM(CONTROLMEM_2),
		.WBHILO(WBHILO_2),
		.MEMRESULT(MEM_res_2),
		.MEMHILORES(MEM_HiLo_res_2),
		.MEMDES(MEM_des2),
		.MEMWRITEHILO(MEM_HiLo2),
		.INTPC(),
		.WB_PC(WB_PC_2)
	);
    
	WB _wb1(
		.clk(clk),
		.reset(reset),
		.controlw_MEM(CONTROLMEM_1),
		.result(RESULT_1),
		.WB_hi_lo(WBHILO_1),
		.WB_PC(WB_PC_1),
		//
		.reg_result(reg_result_1),
		.write_reg(write_reg_1),
		.write_hi(write_hi_1),
		.write_lo(write_lo_1),
		.result_des(result_des_1),
		.reg_hi(reg_hi_1),
		.reg_lo(reg_lo_1),
		.wb_pc_debug(debug_wb_pc_1)
	);
	WB _wb2(
		.clk(clk),
		.reset(reset),
		.controlw_MEM(CONTROLMEM_2),
		.result(RESULT_2),
		.WB_hi_lo(WBHILO_1),
		.WB_PC(WB_PC_2),
		//
		.reg_result(reg_result_2),
		.write_reg(write_reg_2),
		.write_hi(write_hi_2),
		.write_lo(write_lo_2),
		.result_des(result_des_2),
		.reg_hi(reg_hi_2),
		.reg_lo(reg_lo_2),
		.wb_pc_debug(debug_wb_pc_2)
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
	
	//instruction require
	wire [31:0] pc_1;
	wire [31:0] pc_2;
	wire [31:0]MEM_inst_1;
	wire [31:0]MEM_inst_2;
	wire waitinst;
	reg waitinst_1;
	reg waitinst_2;
	reg rready;
	wire inst_delay_fetch;
	wire inst_req;
	reg inst_rec;
	reg inst_req_1;
	reg inst_req_2;
	reg inst_req_en;//which pipeline req?
	reg arvalid_rst;
	reg arvalid_use;
	
	//req
	always@(posedge clk)
	begin
		if(inst_req & inst_rec & arready)
		begin
			araddr<=pc_1;// is new pc or before? perhaps late... 
			arvalid<=1;
			inst_rec<=0;
			arvalid_use<=1;
		end 
	end
	
	
	reg flag;
	reg [63:0]inst_2_if;
	//wire [31:0]pc; 
	//rec
	always @ (posedge clk)
	begin
		if(rvalid==1)
		begin
		// arvalid=0;
			if(flag)
			begin
				inst_2_if[31:0] <= rdata;
				inst_req_1<=0;
			end else
			begin
				inst_2_if[63:32] <= rdata;
				inst_req_2<=0;
				inst_rec<=1;
			end
			flag = !flag;
		end
	end
	
	assign MEM_inst_1 = inst_2_if[31:0];
	assign MEM_inst_2 = inst_2_if[63:32];
	// assign pc = rdata;
	
	
	
	always @(pc_1)
	begin
		inst_req_1<=1;
		inst_2_if[31:0]<=32'b0;
	end
	always @(pc_2)
	begin
		inst_req_2<=1;
		inst_2_if[63:32]<=32'b0;
	end
	
	// always@(posedge arready)
	// begin
		// if(arvalid_use)
		// begin
			// arvalid_rst<=1;
		// end
	// end
	// always@(posedge clk)
	// begin
		// if(arvalid_rst)
		// begin
			// arvalid<=0;
			// arvalid_rst<=0;
			// arvalid_use<=0;
		// end
	// end
	always@(posedge clk)
	begin
		if(arvalid)
		begin
			arvalid<=0;
		end
	end
	
	assign inst_req = inst_req_1 & inst_req_2;
	assign inst_delay_fetch = inst_req_1 | inst_req_2;
	
	initial
	begin
		flag = 1;
		arid=0;
		// arlen=4'b1111;
		arlen=4'b0001;
		arsize=3'b010;
		arburst=1'b1;
		arlock=0;
		arcache=0;
		arprot=0;
		rready=1;
		inst_req_en=0;
		waitinst_1=0;
		waitinst_2=0;
		inst_rec=1;
		arvalid_use=0;
		inst_req_1=1;
		inst_req_2=1;
	end

	
	wire if_delay_1;
	wire if_delay_2;
	// assign if_delay_1 = delay | inst_req_1;
	// assign if_delay_2 = delay | inst_req_2;
	assign if_delay_1 = delay;
	assign if_delay_2 = delay;
	// assign waitinst = waitinst_1 | waitinst_2;
	
	
	//need data distributor divide instruction or data
	
	
	
	//end here
	assign debug_wb_rf_wen_1 = {4{write_reg_1}};
	assign debug_wb_rf_wen_2 = {4{write_reg_2}};
	assign debug_wb_rf_wnum_1 = result_des_1;
	assign debug_wb_rf_wnum_2 = result_des_2;
	assign debug_wb_rf_wdata_1 = reg_result_1;
	assign debug_wb_rf_wdata_2 = reg_result_2;
	
endmodule
