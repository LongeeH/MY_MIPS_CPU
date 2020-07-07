`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/02 18:02:45
// Design Name: 
// Module Name: mycpu_top
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

module mycpu_top(
	//global signal
	input  [5:0]  ext_int			,
    input         aclk 			,
    input  		  aresetn		,
    //read address channel
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [3 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock       ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //read data channel
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //write address channel
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [3 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //write data channel
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //write response channel
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready       ,
    //debug signal
    output  [31:0] debug_wb_pc_1,
    output  [3:0] debug_wb_rf_wen_1,
    output  [4:0] debug_wb_rf_wnum_1,
    output  [31:0] debug_wb_rf_wdata_1,
    output  [31:0] debug_wb_pc_2,
    output  [3:0] debug_wb_rf_wen_2,
    output  [4:0] debug_wb_rf_wnum_2,
    output  [31:0] debug_wb_rf_wdata_2

    );
    wire cpu_inst_req;
    wire [31:0] cpu_inst_addr;
    wire [31:0] cpu_inst_rdata;
    wire [31:0] cpu_inst_cache_rdata;
    wire [31:0] cpu_inst_uncache_rdata;
    wire [31:0] cpu_inst_wdata;
    wire cpu_inst_addr_ok;
    wire cpu_inst_data_ok;
    wire cpu_data_req;
    wire cpu_data_wr;
	wire [31:0] cpu_data_wdata;
	
    wire [3:0] cpu_data_wstrb;
    wire [31:0] cpu_data_addr;
    wire [2 :0] cpu_data_size;

    wire [31:0] cpu_data_rdata;
    wire [31:0] cpu_data_cache_rdata;
    wire [31:0] cpu_data_cache_wdata;
    wire [31:0] cpu_data_uncache_rdata;
    wire [31:0] cpu_data_uncache_wdata;
    wire cpu_data_addr_ok;
    wire cpu_data_data_ok;
    wire cache_req;
    wire [6 :0] cache_op;
    wire [31:0] cache_tag;    
    reg cache_op_r;
    



    exe_core core(
        .clk(aclk),
        .reset(aresetn),
        .int(ext_int),
        //test axi port here
        .arvalid(arvalid),
		.araddr(araddr),
		.arid(arid),
		.arlen(arlen),
		.arburst(arburst),
		.arlock(arlock),
		.arcache(arcache),
		.arprot(arprot),
		.arsize(arsize),
		
        .rvalid(rvalid),
        .rdata(rdata),
        .arready(arready),
		.rready(rready),
        
        
        
		//No function port (copied)
        .inst_req(cpu_inst_req),
        .inst_addr(cpu_inst_addr),
        .inst_rdata(cpu_inst_rdata),
        .inst_addr_ok(cpu_inst_addr_ok & inst_req_cango),
        .inst_data_ok(cpu_inst_data_ok),

        .data_req(cpu_data_req),
        .data_cache(),
        .data_wr(cpu_data_wr),
        .data_wstrb(cpu_data_wstrb),
        .data_addr(cpu_data_addr),
        .data_size(cpu_data_size),
        .data_wdata(cpu_data_wdata),
        .data_rdata(cpu_data_rdata),
        .data_addr_ok(cpu_data_addr_ok & data_req_cango),
        .data_data_ok(cpu_data_data_ok),
		
        .cache_req(cache_req),
        .cache_op(cache_op),
        .cache_tag(cache_tag),
        .cache_op_ok(cache_op_ok),
		
		//orignal debug signal
        //.debug_wb_pc(debug_wb_pc),
        //.debug_wb_rf_wen(debug_wb_rf_wen),
        //.debug_wb_rf_wnum(debug_wb_rf_wnum),
        //.debug_wb_rf_wdata(debug_wb_rf_wdata),
        //debug signal
        .debug_wb_pc_1(debug_wb_pc_1),
        .debug_wb_rf_wen_1(debug_wb_rf_wen_1),
        .debug_wb_rf_wnum_1(debug_wb_rf_wnum_1),
        .debug_wb_rf_wdata_1(debug_wb_rf_wdata_1),
        .debug_wb_pc_2(debug_wb_pc_2),
        .debug_wb_rf_wen_2(debug_wb_rf_wen_2),
        .debug_wb_rf_wnum_2(debug_wb_rf_wnum_2),
        .debug_wb_rf_wdata_2(debug_wb_rf_wdata_2)
    );
	
	
	
	
endmodule