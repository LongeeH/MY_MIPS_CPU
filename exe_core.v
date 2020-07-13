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
	wire [31:0]jr_data;//‰∏âÊ?ÅÈó®
	wire jr_data_ok;//‰∏âÊ?ÅÈó®
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
	wire [31:0]mem_hilo_1;
	wire [31:0]mem_hilo_2;
	wire [1:0]exe_wr_hilo_1;
	wire [1:0]exe_wr_hilo_2;
	//MEM-WB
	wire [31:0]mem_res_1;
	wire [31:0]mem_res_2;
	wire [31:0]mem_contr_word_1;
	wire [31:0]mem_contr_word_2;
	wire [31:0]wb_hilo_data_1;
	wire [31:0]wb_hilo_data_2;
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
		.delay_hard(if_delay),
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
		.delay_hard(if_delay|delay_mix),
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
		.mem_hilo_res_1(mem_2id_hilo_1),.mem_hilo_res_2(mem_2id_hilo_2),.delay_mix(delay_mix),.delay_in(delay_out_2),
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
		.mem_hilo_res_1(mem_2id_hilo_1),.mem_hilo_res_2(mem_2id_hilo_2),.delay_in(delay_out_1),
         //output
        .branch(branch_2),.j(j_2),.jr(jr_2),.jr_data(jr_data),.jr_data_ok(jr_data_ok),.delay_out(delay_out_2),.delay_mix(delay_mix),.id_contr_word(id_contr_word_2),.id_int_contr_word(id_int_contr_word_2),.exe_pc(exe_pc_2),
		.reg_esa(reg_esa_2),.reg_esb(reg_esb_2),.immed(immed_2),.id_des(id_des_2),.self_des(self_des),.self_hilo(self_hilo),
		.id_wr_hilo(id_wr_hilo_2),.RSO(RSO_2),.RTO(RTO_2)
	);
	
    EXE exe1(
		.clk(clk),
		.reset(reset),
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
		.mem_hilo(mem_hilo_1),
		.alu_2id_res(alu_res_1),
		.alu_2id_hilo(alu_2id_hilo_1)
	);
	EXE exe2(
		.clk(clk),
		.reset(reset),
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
		.mem_hilo(mem_hilo_2),
		.alu_2id_res(alu_res_2),
		.alu_2id_hilo(alu_2id_hilo_2)
	);
	
    MEM mem1(
		.clk(clk),
		.reset(reset),
		.exe_contr_word(exe_contr_word_1),
		.exe_int_contr_word(exe_int_contr_word_1),
		.exe_res(exe_res1),
		.mem_data_in(),
		.mem_cp0_data_in(),
		.mem_hilo_data(mem_hilo_1),
		.mem_data(mem_data_1),
		.mem_pc(mem_pc_1),
		.exe_des(exe_des_1),
		.exe_wr_hilo(exe_wr_hilo_1),
		.mem_tran_data_addr(),
		.mem_sorl(),
		.mem_wr(),
		.mem_rd_cp0_reg(),
		.mem_wr_cp0_reg(),
		.mem_tlb_op_en(),
		.mem_data_addr(),
		.mem_data_out(),
		.mem_int_contr(),
		.mem_cp0_reg_index(),
		.mem_tlb_op(),
		.mem_res(mem_res_1),
		.mem_contr_word(mem_contr_word_1),
		.wb_hilo_data(wb_hilo_data_1),
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
		.exe_contr_word(exe_contr_word_2),
		.exe_int_contr_word(exe_int_contr_word_2),
		.exe_res(exe_res2),
		.mem_data_in(),
		.mem_cp0_data_in(),
		.mem_hilo_data(mem_hilo_2),
		.mem_data(mem_data_2),
		.mem_pc(mem_pc_2),
		.exe_des(exe_des_2),
		.exe_wr_hilo(exe_wr_hilo_2),
		.mem_tran_data_addr(),
		.mem_sorl(),
		.mem_wr(),
		.mem_rd_cp0_reg(),
		.mem_wr_cp0_reg(),
		.mem_tlb_op_en(),
		.mem_data_addr(),
		.mem_data_out(),
		.mem_int_contr(),
		.mem_cp0_reg_index(),
		.mem_tlb_op(),
		.mem_res(mem_res_2),
		.mem_contr_word(mem_contr_word_2),
		.wb_hilo_data(wb_hilo_data_2),
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
		.wb_hilo_data(wb_hilo_data_1),
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
		.wb_hilo_data(wb_hilo_data_1),
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
	wire delay_soft;
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
	
	assign if_inst_1 = inst_2_if[31:0];
	assign if_inst_2 = inst_2_if[63:32];
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
	assign delay_soft_inst = inst_req_1 | inst_req_2;
	
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

	
	wire if_delay;
	// wire if_delay;
	assign if_delay = delay_out_1 | delay_out_2;
	// assign if_delay_1 = delay | inst_req_1;
	// assign if_delay_2 = delay | inst_req_2;
	// assign if_delay_1 = delay;
	// assign if_delay_2 = delay;
	// assign waitinst = waitinst_1 | waitinst_2;
	
	
	//need data distributor divide instruction or data
	
	
	
	//end here
	assign debug_wb_rf_wen_1 = {4{wb_reg_wr_1}};
	assign debug_wb_rf_wen_2 = {4{wb_reg_wr_2}};
	assign debug_wb_rf_wnum_1 = wb_res_des1;
	assign debug_wb_rf_wnum_2 = wb_res_des2;
	assign debug_wb_rf_wdata_1 = wb_reg_data_1;
	assign debug_wb_rf_wdata_2 = wb_reg_data_2;
	
endmodule
