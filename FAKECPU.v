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

module FAKECPU(
	//global signal
	input  [5:0]  ext_int			,
    input         aclk 			,
    input  		  aresetn		,
    //read address channel
    output reg[3 :0] arid         ,
    output reg[31:0] araddr       ,
    output reg[3 :0] arlen        ,
    output reg[2 :0] arsize       ,
    output reg[1 :0] arburst      ,
    output reg[1 :0] arlock       ,
    output reg[3 :0] arcache      ,
    output reg[2 :0] arprot       ,
    output   reg     arvalid      ,
    input         arready      ,
    //read data channel
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output     reg   rready       ,
    //write address channel
    output reg [3 :0] awid         ,
    output reg[31:0] awaddr       ,
    output reg[3 :0] awlen        ,
    output reg[2 :0] awsize       ,
    output reg[1 :0] awburst      ,
    output reg[1 :0] awlock       ,
    output reg[3 :0] awcache      ,
    output reg[2 :0] awprot       ,
    output reg       awvalid      ,
    input         awready      ,
    //write data channel
    output reg[3 :0] wid          ,
    output reg[31:0] wdata        ,
    output reg[3 :0] wstrb        ,
    output  reg     wlast        ,
    output        wvalid       ,
    input         wready       ,
    //write response channel
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input        bvalid       ,
    output    reg    bready       ,
    //debug signal
    output  reg[31:0] debug_wb_pc_1,
    output  reg[3:0] debug_wb_rf_wen_1,
    output  reg[4:0] debug_wb_rf_wnum_1,
    output  reg[31:0] debug_wb_rf_wdata_1,
    output  reg[31:0] debug_wb_pc_2,
    output  reg[3:0] debug_wb_rf_wen_2,
    output  reg[4:0] debug_wb_rf_wnum_2,
    output  reg[31:0] debug_wb_rf_wdata_2

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
    //
	
	reg [31:0]araddr_v;
	reg [31:0]awaddr_v;
//	assign araddr[28:0]=araddr_v[28:0];
//	assign araddr[31:29]=(araddr_v[31:30]==2'b10)?3'b000:araddr_v[31:29];
	// assign araddr[31:29]=araddr_v[31:29];
//	assign awaddr[28:0]=awaddr_v[28:0];
//	assign awaddr[31:29]=(awaddr_v[31:30]==2'b10)?3'b000:awaddr_v[31:29];	
	// assign awaddr[31:29]=awaddr_v[31:29];	

	initial
	begin
		arid=0;
		// arlen=4'b1111;
		arlen=4'b0000;
		arsize=3'b010;
		arburst=1'b1;
		arlock=0;
		arcache=0;
		arprot=0;
		rready=1;
		// inst_req_en=0;
		cnt =0;
	end
	reg cnt;
	always@(posedge aclk)
	begin
		if(!cnt)
		begin
			arvalid<=1;
			araddr<=32'h1faf_f02c;
			cnt<=1;
		end
		else
		begin
			arvalid<=1;
			araddr<=32'h1faf_f02c;
		end
		
	end
		
		
	always@(posedge aclk)
	begin
		if(arvalid)
			arvalid<=0;
	end
	
	
	
	
endmodule