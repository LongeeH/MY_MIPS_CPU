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
	//read address channel
	output reg [3:0]arid,
	output reg [31:0]araddr_v,
	output reg [3:0]arlen,
	output reg [2:0]arsize,
	output reg [1:0]arburst,
	output reg [1:0]arlock,
	output reg [3:0]arcache,
	output reg [2:0]arprot,	
	output reg arvalid,
	input arready,
	
	//read data channel
	input [3:0]rid,
	input rvalid,
    input [1:0] rresp,	
	input rlast,
	input [31:0]rdata,
	output reg rready,	
	
    //write address channel
    output reg [3 :0] awid         ,
    output reg [31:0] awaddr_v       ,
    output reg [3 :0] awlen        ,
    output reg [2 :0] awsize       ,
    output reg [1 :0] awburst      ,
    output reg [1 :0] awlock       ,
    output reg [3 :0] awcache      ,
    output reg [2 :0] awprot       ,
    output reg awvalid      ,
    input         awready      ,
    //write data channel
    output reg [3 :0] wid          ,
    output reg [31:0] wdata        ,
    output reg [3 :0] wstrb        ,
    output reg       wlast        ,
    output reg       wvalid       ,
    input         wready       ,
    //write response channel
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output reg bready       ,
	
	
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
	wire [31:0]last_inst_1;
	wire [31:0]last_inst_2;
	//IF-ID
    wire [31:0]id_inst_1;
	wire [31:0]id_pc_1;
	wire [1:0]IC_IF_1;
	wire [31:0]id_inst_2;
	wire [31:0]id_pc_2;
	wire [1:0]IC_IF_2;
	wire branch_1;
	wire branch_2;
	wire j_1;
	wire j_2;//useless
	wire jr_1;
	wire jr_2;
	wire [31:0]jr_data;//三�?�门
	wire jr_data_ok;//三�?�门
	wire delay;
	//ID-ID
	wire delay_mix;
	wire delay_out_1;
	wire delay_out_2;
	wire [6:0]self_des;
	//ID-EXE
	wire [6:0]alu_des_1;
	wire [6:0]alu_des_2;
	wire [1:0]alu_hilo_1;
	wire [1:0]alu_hilo_2;
	wire [31:0]alu_res_1;
	wire [31:0]alu_res_2;
	wire [31:0]alu_2id_hilo_1;
	wire [31:0]alu_2id_hilo_2;
	wire [31:0]id_contr_word_1;
	wire [31:0]id_contr_word_2;
	wire [7:0]id_int_contr_word_1;
	wire [7:0]id_int_contr_word_2;
	wire [31:0]exe_pc_1;
	wire [31:0]exe_pc_2;
	wire [31:0]reg_esa_1;
	wire [31:0]reg_esa_2;
	wire [31:0]reg_esb_1;
	wire [31:0]reg_esb_2;
	wire [31:0]immed_1;
	wire [31:0]immed_2;
	wire [6:0]id_des_1;
	wire [6:0]id_des_2;
	wire [1:0]id_wr_hilo_1;
	wire [1:0]id_wr_hilo_2;
	//ID-MEM
	wire [31:0]mem_2id_res_1;
	wire [31:0]mem_2id_res_2;
	wire [6:0]mem_des_1;
	wire [6:0]mem_des_2;
	wire [1:0]mem_wr_hilo_1;
	wire [1:0]mem_wr_hilo_2;
	wire [31:0]mem_2id_hilo_1;
	wire [31:0]mem_2id_hilo_2;
	//EXE-MEM
	wire [6:0]exe_des_1;
	wire [6:0]exe_des_2;
	wire [31:0]exe_res1;
	wire [31:0]exe_res2;
	wire [31:0]mem_data_1;
	wire [31:0]mem_data_2;
	wire [31:0]exe_contr_word_1;
	wire [31:0]exe_contr_word_2;
	wire [7:0]exe_int_contr_word_1;
	wire [7:0]exe_int_contr_word_2;
	wire [31:0]mem_pc_1;
	wire [31:0]mem_pc_2;
	wire [31:0]exe_hi_data_1;
	wire [31:0]exe_lo_data_1;
	wire [31:0]exe_hi_data_2;
	wire [31:0]exe_lo_data_2;
	wire [1:0]exe_wr_hilo_1;
	wire [1:0]exe_wr_hilo_2;
	//MEM-WB
	wire [31:0]mem_res_1;
	wire [31:0]mem_res_2;
	wire [31:0]mem_contr_word_1;
	wire [31:0]mem_contr_word_2;
	wire [31:0]mem_hi_data_1;
	wire [31:0]mem_lo_data_1;
	wire [31:0]mem_hi_data_2;
	wire [31:0]mem_lo_data_2;
	wire [31:0]wb_pc_1;
	wire [31:0]wb_pc_2;
	//ID-REG
	wire [4:0]RSO_1;
	wire [4:0]RSO_2;
	wire [4:0]RTO_1;
	wire [4:0]RTO_2;
	wire [31:0]reg_rs_data_1;
	wire [31:0]reg_rs_data_2;
	wire [31:0]reg_rt_data_1;
	wire [31:0]reg_rt_data_2;
	wire [31:0]lo_r_data;
	wire [31:0]hi_r_data;
	//WB-REG
	wire [31:0]wb_reg_data_1;
	wire [31:0]wb_reg_data_2;
	wire wb_reg_wr_1;
	wire wb_reg_wr_2;
	wire [4:0]wb_res_des1;
	wire [4:0]wb_res_des2;
	wire wb_hi_wr_1;
	wire wb_hi_wr_2;
	wire wb_lo_wr_1;
	wire wb_lo_wr_2;
	wire [31:0]wb_hi_data_1;
	wire [31:0]wb_hi_data_2;
	wire [31:0]wb_lo_data_1;
	wire [31:0]wb_lo_data_2;
	
	//model put here
	
    IF_1 _if1(
		.clk(clk),
		.reset(reset),
		.int(), //maybe need CP0
		.j(j_1|j_2),
		.jr(jr_1|jr_2),
		.jr_data(jr_data),
		.jr_data_ok(jr_data_ok),
		.branch_1(branch_1),
		.branch_2(branch_2),
		.delay_soft(delay_soft_inst|delay_mix),
		.delay_hard(if_delay|delay_hard_data_req),
		.IADEE(),
		.IADFE(),
		.exc_pc(),
		.if_inst(if_inst_1),
		.last_inst_2(last_inst_2),

		.pc(pc_1),
		.id_inst(id_inst_1),
		.id_pc(id_pc_1),
		.IC_IF(IC_IF_1),
		.last_inst_1(last_inst_1)
	);
    IF_2 _if2(
		.clk(clk),
		.reset(reset),
		.int(),
		.j(j_1|j_2),
		.jr(jr_1|jr_2),
		.jr_data(jr_data),
		.jr_data_ok(jr_data_ok),
		.branch_1(branch_1),
		.branch_2(branch_2),
		.delay_soft(delay_soft_inst),
		.delay_hard(if_delay|delay_mix|delay_hard_data_req),
		.IADEE(),
		.IADFE(),
		.exc_pc(),
		.if_inst(if_inst_2),
		.last_inst_1(last_inst_1),

		.pc(pc_2),
		.id_inst(id_inst_2),
		.id_pc(id_pc_2),
		.IC_IF(IC_IF_2),
		.last_inst_2(last_inst_2)
	);
    
	ID _id1(
		.clk(clk),.reset(reset),.id_inst(id_inst_1),.id_pc(id_pc_1),.IC_IF(IC_IF_1),
		.reg_rs(reg_rs_data_1),.reg_rt(reg_rt_data_1),
		.lo_r_data(lo_r_data),.hi_r_data(hi_r_data),
		.alu_des_1(alu_des_1),.alu_w_hilo_1(alu_hilo_1),
		.alu_des_2(alu_des_2),.alu_w_hilo_2(alu_hilo_2),
		.alu_res_1(alu_res_1),.alu_res_2(alu_res_2),
		.alu_hilo_res_1(alu_2id_hilo_1),.alu_hilo_res_2(alu_2id_hilo_2),
		.mem_res_1(mem_2id_res_1),.mem_res_2(mem_2id_res_2),
		.mem_des_1(mem_des_1),.mem_wr_hilo_1(mem_wr_hilo_1),
		.mem_des_2(mem_des_2),.mem_wr_hilo_2(mem_wr_hilo_2),
		.mem_hilo_res_1(mem_2id_hilo_1),.mem_hilo_res_2(mem_2id_hilo_2),.delay_mix(delay_mix),.delay_in(delay_hard_data_req),
         //output
        .branch(branch_1),.j(j_1),.jr(jr_1),.jr_data(jr_data),.jr_data_ok(jr_data_ok),.delay_out(delay_out_1),.id_contr_word(id_contr_word_1),.id_int_contr_word(id_int_contr_word_1),.exe_pc(exe_pc_1),
		.reg_esa(reg_esa_1),.reg_esb(reg_esb_1),.immed(immed_1),.id_des(id_des_1),.self_des(self_des),.self_hilo(self_hilo),
		.id_wr_hilo(id_wr_hilo_1),.RSO(RSO_1),.RTO(RTO_1)
	);	
	ID_2 _id2(
		.clk(clk),.reset(reset),.id_inst(id_inst_2),.id_pc(id_pc_2),.IC_IF(IC_IF_2),
		.reg_rs(reg_rs_data_2),.reg_rt(reg_rt_data_2),
		.lo_r_data(lo_r_data),.hi_r_data(hi_r_data),
		.alu_des_1(alu_des_1),.alu_w_hilo_1(alu_hilo_1),
		.alu_des_2(alu_des_2),.alu_w_hilo_2(alu_hilo_2),
		.alu_res_1(alu_res_1),.alu_res_2(alu_res_2),
		.alu_hilo_res_1(alu_2id_hilo_1),.alu_hilo_res_2(alu_2id_hilo_2),
		.mem_res_1(mem_2id_res_1),.mem_res_2(mem_2id_res_2),
		.mem_des_1(mem_des_1),.mem_wr_hilo_1(mem_wr_hilo_1),
		.mem_des_2(mem_des_2),.mem_wr_hilo_2(mem_wr_hilo_2),
		.mem_hilo_res_1(mem_2id_hilo_1),.mem_hilo_res_2(mem_2id_hilo_2),.delay_in(delay_hard_data_req),
         //output
        .branch(branch_2),.j(j_2),.jr(jr_2),.jr_data(jr_data),.jr_data_ok(jr_data_ok),.delay_out(delay_out_2),.delay_mix(delay_mix),.id_contr_word(id_contr_word_2),.id_int_contr_word(id_int_contr_word_2),.exe_pc(exe_pc_2),
		.reg_esa(reg_esa_2),.reg_esb(reg_esb_2),.immed(immed_2),.id_des(id_des_2),.self_des(self_des),.self_hilo(self_hilo),
		.id_wr_hilo(id_wr_hilo_2),.RSO(RSO_2),.RTO(RTO_2)
	);
	
    EXE exe1(
		.clk(clk),
		.reset(reset),
		.delay(delay_hard_data_req),
		.id_contr_word(id_contr_word_1),	
		.id_int_contr_word(id_int_contr_word_1),	
		.exe_pc(exe_pc_1),
		.exe_reg_res_A(reg_esa_1),
		.exe_reg_res_B(reg_esb_1),
		.id_des(id_des_1),
		.id_wr_hilo(id_wr_hilo_1),
		.exe_immed(immed_1),
		.exe_des(exe_des_1),
		.exe_wr_hilo(exe_wr_hilo_1),
		.exe_alu_des(alu_des_1),
		.exe_alu_wr_hilo(alu_hilo_1),
		.exe_res(exe_res1),
		.mem_data(mem_data_1),
		.exe_contr_word(exe_contr_word_1),
		.exe_int_contr_word(exe_int_contr_word_1),
		.mem_pc(mem_pc_1),
		.exe_hi_data(exe_hi_data_1),
		.exe_lo_data(exe_lo_data_1),
		.alu_2id_res(alu_res_1),
		.alu_2id_hilo(alu_2id_hilo_1)
	);
	EXE exe2(
		.clk(clk),
		.reset(reset),
		.delay(delay_hard_data_req),
		.id_contr_word(id_contr_word_2),	
		.id_int_contr_word(id_int_contr_word_2),	
		.exe_pc(exe_pc_2),
		.exe_reg_res_A(reg_esa_2),
		.exe_reg_res_B(reg_esb_2),
		.id_des(id_des_2),
		.id_wr_hilo(id_wr_hilo_2),
		.exe_immed(immed_2),
		.exe_des(exe_des_2),
		.exe_wr_hilo(exe_wr_hilo_2),
		.exe_alu_des(alu_des_2),
		.exe_alu_wr_hilo(alu_hilo_2),
		.exe_res(exe_res2),
		.mem_data(mem_data_2),
		.exe_contr_word(exe_contr_word_2),
		.exe_int_contr_word(exe_int_contr_word_2),
		.mem_pc(mem_pc_2),
		.exe_hi_data(exe_hi_data_2),
		.exe_lo_data(exe_lo_data_2),
		.alu_2id_res(alu_res_2),
		.alu_2id_hilo(alu_2id_hilo_2)
	);
	
    MEM mem1(
		.clk(clk),
		.reset(reset),
		.delay(delay_hard_data_req),
		.exe_contr_word(exe_contr_word_1),
		.exe_int_contr_word(exe_int_contr_word_1),
		.exe_res(exe_res1),
		.mem_data_in(mem_data_in_1),
		.mem_cp0_data_in(),
		.exe_hi_data(exe_hi_data_1),
		.exe_lo_data(exe_lo_data_1),
		.mem_data(mem_data_1),
		.mem_pc(mem_pc_1),
		.exe_des(exe_des_1),
		.exe_wr_hilo(exe_wr_hilo_1),
		.mem_tran_data_addr(),
		.mem_sorl(),
		.mem_load_en(mem_load_en_1),
		.mem_wr_en(mem_wr_en_1),
		.mem_rd_cp0_reg(),
		.mem_wr_cp0_reg(),
		.mem_tlb_op_en(),
		.mem_data_addr(mem_data_addr_1),
		.mem_data_out(mem_data_out_1),
		.mem_int_contr(),
		.mem_cp0_reg_index(),
		.mem_tlb_op(),
		.mem_res(mem_res_1),
		.mem_contr_word(mem_contr_word_1),
		.mem_hi_data(mem_hi_data_1),
		.mem_lo_data(mem_lo_data_1),
		.mem_2id_res(mem_2id_res_1),
		.mem_2id_hilo(mem_2id_hilo_1),
		.mem_des(mem_des_1),
		.mem_wr_hilo(mem_wr_hilo_1),
		.mem_int_pc(),
		.wb_pc(wb_pc_1)
	);
	MEM mem2(
		.clk(clk),
		.reset(reset),
		.delay(delay_hard_data_req),
		.exe_contr_word(exe_contr_word_2),
		.exe_int_contr_word(exe_int_contr_word_2),
		.exe_res(exe_res2),
		.mem_data_in(mem_data_in_2),
		.mem_cp0_data_in(),
		.exe_hi_data(exe_hi_data_2),
		.exe_lo_data(exe_lo_data_2),
		.mem_data(mem_data_2),
		.mem_pc(mem_pc_2),
		.exe_des(exe_des_2),
		.exe_wr_hilo(exe_wr_hilo_2),
		.mem_tran_data_addr(),
		.mem_sorl(),
		.mem_load_en(mem_load_en_2),
		.mem_wr_en(mem_wr_en_2),
		.mem_rd_cp0_reg(),
		.mem_wr_cp0_reg(),
		.mem_tlb_op_en(),
		.mem_data_addr(mem_data_addr_2),
		.mem_data_out(mem_data_out_2),
		.mem_int_contr(),
		.mem_cp0_reg_index(),
		.mem_tlb_op(),
		.mem_res(mem_res_2),
		.mem_contr_word(mem_contr_word_2),
		.mem_hi_data(mem_hi_data_2),
		.mem_lo_data(mem_lo_data_2),
		.mem_2id_res(mem_2id_res_2),
		.mem_2id_hilo(mem_2id_hilo_2),
		.mem_des(mem_des_2),
		.mem_wr_hilo(mem_wr_hilo_2),
		.mem_int_pc(),
		.wb_pc(wb_pc_2)
	);
    
	WB wb1(
		.clk(clk),
		.reset(reset),
		.mem_contr_word(mem_contr_word_1),
		.mem_res(mem_res_1),
		.mem_hi_data(mem_hi_data_1),
		.mem_lo_data(mem_lo_data_1),
		.wb_pc(wb_pc_1),
		//
		.wb_reg_data(wb_reg_data_1),
		.wb_reg_wr(wb_reg_wr_1),
		.wb_hi_wr(wb_hi_wr_1),
		.wb_lo_wr(wb_lo_wr_1),
		.wb_res_des(wb_res_des1),
		.wb_hi_data(wb_hi_data_1),
		.wb_lo_data(wb_lo_data_1),
		.wb_pc_debug(debug_wb_pc_1)
	);
	WB wb2(
		.clk(clk),
		.reset(reset),
		.mem_contr_word(mem_contr_word_2),
		.mem_res(mem_res_2),
		.mem_hi_data(mem_hi_data_2),
		.mem_lo_data(mem_lo_data_2),
		.wb_pc(wb_pc_2),
		//
		.wb_reg_data(wb_reg_data_2),
		.wb_reg_wr(wb_reg_wr_2),
		.wb_hi_wr(wb_hi_wr_2),
		.wb_lo_wr(wb_lo_wr_2),
		.wb_res_des(wb_res_des2),
		.wb_hi_data(wb_hi_data_2),
		.wb_lo_data(wb_lo_data_2),
		.wb_pc_debug(debug_wb_pc_2)
	);
	
	Register_File register(
		.clk(clk),
		.reset(reset),
		.reg_rs_addr_1(RSO_1),
		.reg_rs_addr_2(RSO_2),
		.reg_rt_addr_1(RTO_1),
		.reg_rt_addr_2(RTO_2),
		.reg_w_en_1(wb_reg_wr_1),
		.reg_w_en_2(wb_reg_wr_2),
		.reg_w_addr_1(wb_res_des1),
		.reg_w_addr_2(wb_res_des2),
		.reg_w_data_1(wb_reg_data_1),
		.reg_w_data_2(wb_reg_data_2),
		//output
		.reg_rs_data_1(reg_rs_data_1),
		.reg_rs_data_2(reg_rs_data_2),
		.reg_rt_data_1(reg_rt_data_1),
		.reg_rt_data_2(reg_rt_data_2)
	);
	Register_HiLo register_hi(
		.clk(clk),
		.reset(reset),
		.hilo_w_en_1(wb_hi_wr_1),
		.hilo_w_en_2(wb_lo_wr_2),
		.hilo_w_data_1(wb_hi_data_1),
		.hilo_w_data_2(wb_hi_data_2),
		.hilo_r_data(hi_r_data)
	);
	Register_HiLo register_lo(
		.clk(clk),
		.reset(reset),
		.hilo_w_en_1(wb_lo_wr_1),
		.hilo_w_en_2(wb_lo_wr_2),
		.hilo_w_data_1(wb_lo_data_1),
		.hilo_w_data_2(wb_lo_data_2),
		.hilo_r_data(lo_r_data)
	);
	
	//instruction require
	wire [31:0] pc_1;
	wire [31:0] pc_2;
	wire [31:0]if_inst_1;
	wire [31:0]if_inst_2;
	wire waitinst;
	reg waitinst_1;
	reg waitinst_2;
	reg rready;
	// wire delay_soft;
	wire inst_req;
	reg inst_rec;
	reg inst_req_1;
	reg inst_req_2;
	//reg inst_req_en;//which pipeline req?
	reg arvalid_rst;
	reg arvalid_use;
	//mem signal
	reg data_r_req_1;
	reg data_r_req_2;
	reg data_r_ok_1;
	reg data_r_ok_2;
	wire [31:0]mem_data_addr_1;
	wire [31:0]mem_data_addr_2;
	wire [31:0]mem_data_in_1;
	wire [31:0]mem_data_in_2;

	// always @ (posedge clk)
	// begin
		// if(data_req&inst_req_use)
		// begin
			// data_req_wait<=1;
		// end
		// else if(data_req&!inst_req_use)
		// begin
			// data_req_use<=1;
		// end 
		// else if(data_req_use&inst_req)
		// begin
			// inst_req_wait<=1;
		// end
		// else if(!data_req_use&inst_req)
		// begin
			// inst_req_use<=1;
		// end
	// end
	// always@(posedge clk)
	// begin
		// if(data_r_req_1 & data_r_ok_1 & arready)//有效请求and前指到齐and外设可用
		// begin
			// araddr_v<=mem_data_addr_1;// 
			// arvalid<=1;
			// data_r_ok_1<=0;
			// arid<=1;
			// arvalid_use<=1;
			// arlen<=4'b0000;
		// end 
	// end
	
	// always@(posedge clk)
	// begin
	
		// if(data_r_req_2 & data_r_ok_2 & arready)//有效请求and前指到齐and外设可用
		// begin
			// araddr_v<=mem_data_addr_2;// 
			// arvalid<=1;
			// data_r_ok_2<=0;
			// arid<=2;
			// arvalid_use<=1;
			// arlen<=4'b0000;
		// end 
	// end
		
	
	
	//axi read apply module
	always@(posedge clk)
	begin
		if(inst_req & inst_rec & arready)//有效请求and前指到齐and外设可用
		begin
			araddr_v<=pc_1;// is new pc or before? perhaps late... 
			arvalid<=1;
			inst_rec<=0;
			arid<=0;
			arvalid_use<=1;
			arlen<=4'b0001;
		end 
		else if(data_r_req_1 & data_r_ok_1 & arready)//请求and前指到齐and外设可用
		begin
			araddr_v<=mem_data_addr_1;// 
			arvalid<=1;
			data_r_ok_1<=0;//?
			arid<=1;
			arvalid_use<=1;
			arlen<=4'b0000;
		end
		else if(data_r_req_2 & data_r_ok_2 & arready)//有效请求and前指到齐and外设可用
		begin
			if((mem_data_addr_2==mem_data_addr_1)&&data_w_req_1)
				begin
					data_r_req_2<=0;
					mem_forward<=1;
				end
			else
				begin
					araddr_v<=mem_data_addr_2;// 
					arvalid<=1;
					data_r_ok_2<=0;//?
					arid<=2;
					arvalid_use<=1;
					arlen<=4'b0000;
					mem_forward<=0;
				end
		end 	
		else if(arvalid)
			arvalid<=0;
	end
	//axi read apply end
	reg mem_forward;
	
	//axi read receive module
	//inst rec
	reg flag;
	reg [63:0]inst_2_if;
	reg [63:0]data_2_mem;
	always @ (posedge clk)//虚拟cache-指令对交替分�?
	begin
		if(rvalid==1&rid==0)
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
	//try merge up
	//data rec 
	always @ (posedge clk)
	begin
		if((rvalid==1)&&(rid==1))
		begin
			// mem_data_in_1 <= rdata;
			data_r_req_1 <= 0;
			data_2_mem[31:0]<=rdata;
			data_r_ok_1<=1;
		end 
		else if((rvalid==1)&&(rid==2))
		begin
			// mem_data_in_2 <= rdata;
			data_r_req_2 <= 0;
			data_2_mem[63:32]<=rdata;
			data_r_ok_2<=1;
		end
	end
	assign mem_data_in_1 = data_2_mem[31:0];
	assign mem_data_in_2 = mem_forward?mem_data_out_1:data_2_mem[63:32];
	
	assign if_inst_1 = inst_2_if[31:0];
	assign if_inst_2 = inst_2_if[63:32];
		
	
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
	always @(mem_load_en_1 or mem_load_en_2)
	begin
		if(mem_load_en_1)
			data_r_req_1<=1;
		if(mem_load_en_2)
			data_r_req_2<=1;

	end
	
	// assign delay_hard_data_r_req = data_r_req_1_p | data_r_req_2_p;
	
	// always @(posedge clk)
	// begin
		// if(data_r_req_1_p)
			// data_r_req_1<=1;
		// if(data_r_req_2_p)
			// data_r_req_2<=1;
	// end
	// reg data_r_req_1_p;
	// reg data_r_req_2_p;
	
	
	//
	// always@(posedge clk)
	// begin
		// if(arvalid)
		// begin
			// arvalid<=0;
		// end
	// end
	
	assign inst_req = inst_req_1 & inst_req_2;//必须12流水线同时请求时，才请求取指令对�?
	assign delay_soft_inst = inst_req_1 | inst_req_2;//任一流水线请求时，进行软暂停。只暂停pc的更新行为�?�其他状况不会保�?
	
	assign delay_hard_data_r_req = data_r_req_1 | data_r_req_2;
	
	
	
	
	initial
	begin
		flag = 1;
		arid=0;
		wid=0;
		// arlen=4'b1111;
		arlen=4'b0001;
		arsize=3'b010;
		awsize=3'b000;
		arburst=1'b1;
		awburst=1'b1;
		arlock=0;
		awlock=0;
		arcache=0;
		awcache=0;
		arprot=0;
		awprot=0;
		rready=1;
		wstrb=4'b1111;
		// inst_req_en=0;
		waitinst_1=0;
		waitinst_2=0;
		inst_rec=1;
		arvalid_use=0;
		inst_req_1=1;
		inst_req_2=1;
		data_r_ok_1=1;
		data_r_ok_2=1;
		
		data_r_req_1=0;
		data_r_req_2=0;
		// data_r_req_1_p=0;
		// data_r_req_2_p=0;
		
		
		data_w_req_1=0;
		data_w_req_2=0;
		data_w_ok_1=1;
		data_w_ok_2=1;
		
		mem_forward=0;
	end
	// always #500 arid=arid+1;
	
	wire if_delay;
	// wire if_delay;
	assign if_delay = delay_out_1 | delay_out_2;
	// assign if_delay_1 = delay | inst_req_1;
	// assign if_delay_2 = delay | inst_req_2;
	// assign if_delay_1 = delay;
	// assign if_delay_2 = delay;
	// assign waitinst = waitinst_1 | waitinst_2;
	
	
	//need data distributor divide instruction or data
	
	
	//axi write module here	
	wire mem_wr_en_1;
	wire mem_wr_en_2;
	reg data_w_ok_1;
	reg data_w_ok_2;
	reg data_w_req_1;
	reg data_w_req_2;
	wire [31:0]mem_data_out_1;
	wire [31:0]mem_data_out_2;
	
	//w req add

	always@(posedge clk)
	begin
		if(data_w_req_1 & data_w_ok_1 & data_w_ok_2 & awready)//请求and前指到齐and外设可用//�?要互斥！
		begin
			awaddr_v<=mem_data_addr_1;// 
			awvalid<=1;
			// wdata <= mem_data_out_1;
			// wvalid <=1;
			// wlast <=1;
			bready <=1;
			data_w_ok_1<=0;//?
			//
			awid<=0;
			awlen<=4'b0000;
		end
		else if(data_w_req_2 & data_w_ok_2 & data_w_ok_1 & awready)//有效请求and前指到齐and外设可用
		begin
			awaddr_v<=mem_data_addr_2;// 
			awvalid<=1;
			// wdata <= mem_data_out_2;
			// wvalid <=1;
			// wlast <=1;
			bready <=1;
			data_w_ok_2<=0;//?
			//
			awid<=0;
			awlen<=4'b0000;
		end 	
	end
	//w req data
	always@(posedge clk)
	begin
		if(awvalid==1&data_w_req_1)
		begin
			wdata <= mem_data_out_1;
			wvalid <=1;
			wlast <=1;
		end
		else if(awvalid==1&data_w_req_2)//有效请求and前指到齐and外设可用
		begin
			wdata <= mem_data_out_2;
			wvalid <=1;
			wlast <=1;
		end 	
	end
	
	//???修改下方 w rec
	always @ (posedge clk)
	begin
		if(wready==1 & data_w_req_1==1 & wlast==1)
		begin
			// wdata <= mem_data_out_1;
			data_w_req_1 <= 0;
			data_w_ok_1<=1;
			awvalid<=0;
			wlast<=0;
			wvalid<=0;
		end 
		else if(wready==1 & data_w_req_2==1 & wlast==1)
		begin
			// wdata <= mem_data_out_2;
			data_w_req_2 <= 0;
			data_w_ok_2<=1;
			awvalid<=0;
			wlast<=0;
			wvalid<=0;
		end
		
	end
	// 修改 
	// always @ (posedge clk)
	// begin
		// if(wready==1 & data_w_req_1)
		// begin
			// data_w_req_1 <= 0;
			// data_w_ok_1 <= 1;
		// end 
		// else if(wready==1 & data_w_req_2)
		// begin
			// data_w_req_2 <= 0;
			// data_w_ok_2 <= 1;
		// end
	// end
	//
	always @(mem_wr_en_1 or mem_wr_en_2)
	begin
		if(mem_wr_en_1)
			data_w_req_1<=1;
		if(mem_wr_en_2)
			data_w_req_2<=1;
	end
	
	//
	always@(posedge clk)
	begin
		if(awvalid)
		begin
			awvalid<=0;
		end
	end
	
	wire delay_hard_data_w_req;
	wire delay_hard_data_req;
	
	
	assign delay_hard_data_w_req = data_w_req_1 | data_w_req_2;
	assign delay_hard_data_req = delay_hard_data_r_req | delay_hard_data_w_req;

	
	//end here
	assign debug_wb_rf_wen_1 = {4{wb_reg_wr_1}};
	assign debug_wb_rf_wen_2 = {4{wb_reg_wr_2}};
	assign debug_wb_rf_wnum_1 = wb_res_des1;
	assign debug_wb_rf_wnum_2 = wb_res_des2;
	assign debug_wb_rf_wdata_1 = wb_reg_data_1;
	assign debug_wb_rf_wdata_2 = wb_reg_data_2;
	
endmodule
