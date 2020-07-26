`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/21 08:21:58
// Design Name: 
// Module Name: CP0
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




module CP0(
	input clk,
	input reset,
	input [5:0] hard_int_wire,
	input cp0_w_en_1,//HIGH effective
	input cp0_w_en_2,//HIGH effective
	input [4:0] cp0_r_addr_1,
	input [4:0] cp0_r_addr_2,
	input [4:0] cp0_w_addr_1,
	input [4:0] cp0_w_addr_2,
	input [31:0] cp0_w_data_1,
	input [31:0] cp0_w_data_2,
	input [15:0] cp0_int_contr_word_1,
	input [15:0] cp0_int_contr_word_2,
	// input [31:0] exceptionFlag,//final exception!!!!!!! 0 addrException in IF, 1?unknown instruction, 2 overflow, 3 break, 4 syscall, 5 addrException when read data in MA, 6 ERET, 7 addrException when write data in MA,the others bits is reservation
	input [31:0] PC_1,// this exceptionPC have been chosen from pc and pc-4
	input [31:0] PC_2,// this exceptionPC have been chosen from pc and pc-4
	// input isDelay,
	input [31:0] orginalVritualAddrT_1,
	input [31:0] orginalVritualAddrT_2,
	input  branch_1,
	
	output reg [31:0] cp0_r_data_1,
	output reg [31:0] cp0_r_data_2,
	output reg EXL,
	output reg [31:0] EPC_o,
	output reg softWareInt,
	output cp0_intexp_1,
	output cp0_intexp_2,
	output cp0_cln_1,
	output cp0_cln_2
);
    reg conflict12;
    reg [31:0] BadVAddr;
	reg [31:0] Count;
	reg [31:0] Status;
	reg [31:0] Cause;
	reg [31:0] Compare;
    reg [31:0] EPC;
    reg [31:0] pcForSoftwareInt;
	reg [31:0] exceptionFlag;
	reg [31:0] exceptionPC;
	reg [31:0] orginalVritualAddrT;
	// wire [31:0] exceptionFlag_2;
    reg isDelay;
	//现在int和mem信号同步，下一周期处理中断同时进行跳转准备；
	//如若放到下一个always中，则必然中断寄存器处理结束后才开始跳转准备。
	//必须要立刻给出，否则mem2无法及时清零
	// assign cp0_int_1 = cp0_int_contr_word_1[15];
	// assign cp0_int_2 = cp0_int_contr_word_2[15];
	reg cp0_int_1;
	reg cp0_int_2;
	reg cp0_exp_1;
	reg cp0_exp_2;
	reg cp0_cln_1;
	reg cp0_cln_2;
	reg cause_change_last;
	
	wire cp0_info_des_1;
	wire cp0_info_des_2;
	wire cp0_intexp_1;
	wire cp0_intexp_2;
	assign cp0_info_des_1 = cp0_cln_1;//碰巧一样转换
	assign cp0_info_des_2 = cp0_cln_2;
	assign cp0_intexp_1=cp0_exp_1||cp0_int_1;
	assign cp0_intexp_2=cp0_exp_2||cp0_int_2;
	
	always@(*)//中断信号检测器
	begin
		// if(cp0_int_contr_word_1[15]||cp0_int_contr_word_2[15])
		// begin
			case(cp0_int_contr_word_1[7:0])
				8'b00000001,8'b00000010,8'b00000100,8'b00001000,8'b00010000,8'b00100000,8'b10000000:begin//int occur ,8'b00000100
					cp0_exp_1 <= 1'b1;
					cp0_cln_1<=1'b1;
				end
				8'b01000000:begin//eret
					cp0_exp_1<=1'b0;
					cp0_cln_1<=1'b1;
				end
				8'b00000000:begin
					cp0_exp_1 <= 1'b0;
					cp0_cln_1<=1'b0;
				end
				default:begin
					cp0_exp_1 <= 1'b0;
					cp0_cln_1<=1'b0;
				end
			endcase
			if(!branch_1)
			begin
				case(cp0_int_contr_word_2[7:0])
					8'b00000001,8'b00000010,8'b00000100,8'b00001000,8'b00010000,8'b00100000,8'b10000000:begin//int occur,8'b00000100
						cp0_exp_2 <= 1'b1;
						cp0_cln_2<=1'b1;
					end
					8'b01000000:begin//eret
						cp0_exp_2<=1'b0;
						cp0_cln_2<=1'b1;
					end
					8'b00000000:begin
						cp0_exp_2 <= 1'b0;
						cp0_cln_2<=1'b0;
					end
					default:begin
						cp0_exp_2 <= 1'b0;
						cp0_cln_2<=1'b0;
					end
				endcase	
			end
	end
	
	
	//solve conflict
	always@(*)//中断信息选择器
	begin
		// case({cp0_int_contr_word_1[15],cp0_int_contr_word_2[15]})
		case({cp0_info_des_1,cp0_info_des_2})
		2'b10,2'b11:begin
			isDelay = cp0_int_contr_word_1[9];
			exceptionFlag = {24'b0,cp0_int_contr_word_1[7:0]};
			exceptionPC = (cp0_int_contr_word_1[9]==1'b1)?PC_1-4:PC_1;
			orginalVritualAddrT = orginalVritualAddrT_1;
		end
		2'b01:begin
			isDelay = cp0_int_contr_word_2[9];
			exceptionFlag = {24'b0,cp0_int_contr_word_2[7:0]};
			exceptionPC = (cp0_int_contr_word_2[9]==1'b1)?PC_2-4:PC_2;
			orginalVritualAddrT = orginalVritualAddrT_2;
		end
		2'b00:begin
			isDelay = 1'bZ;
			exceptionFlag[7:0] = 8'bZ;
			exceptionPC = 32'bZ;
			orginalVritualAddrT = 32'bZ;
		end
		default:begin
			conflict12 = 1;
		end	
		endcase
	end
	
	// assign isDelay = cp0_int_contr_word[8];
	// assign exceptionFlag[7:0] = cp0_int_contr_word_1[7:0]:cp0_int_contr_word_2[7:0];
	
    always @ (posedge clk)//中断信息处理器*****
    begin
        if(reset == 0)
        begin
            BadVAddr <= 31'h0000_0000;
            Count <= 31'h0000_0000;
            Status <= 31'h0040_0000;    //Status = 0000 0000 0100 0000 1111 1111 0000 0000
            Cause <= 31'h0000_0000;
            EPC <= 31'h0000_0000;
			Compare <= 31'h0000_0000;
			EXL <= 1'b0;
			pcForSoftwareInt <= 32'h0000_0000;
		end
		else
		begin
            Count <= Count + 1 ;
            Cause[15:10] <= hard_int_wire;
            EXL <= Status[1];
            EPC_o <= EPC;
            pcForSoftwareInt <= exceptionPC + 4; //for software hard_int_wire exp
			if(Compare != 31'h0000_0000 && Compare == Count)
			begin
				Cause[1] <= 1'b1;
			end
            else
            begin
                // hold the timer interrupt, until compare's value have been changed
            end
            
            if(hard_int_wire != 6'b000000 && Status[1] == 1'b0)//outint and exl//hard ward int?
            begin
                EPC <= exceptionPC;
                Cause[31] <= isDelay;//bd
                Cause[6:2] <= 5'b00000;//not any int code
                Status[1] <= 1'b1;//exl
				cp0_int_1<=1'b1;
				cp0_int_2<=1'b1;
            end
            else if((Status[1] == 1'b0) && ((Cause[9] == 1'b1 && Status[9] == 1'b1) || (Cause[8] == 1'b1 && Status[8] == 1'b1)))//soft ok &sofe int &exl
            begin
                // exp <= pcForSoftwareInt;
                EPC <= cause_change_last?(PC_2+4):(PC_1+4);
                // Cause[31] <= isDelay;
                Cause[31] <= cause_change_last?cp0_int_contr_word_2[9]:cp0_int_contr_word_1[9];
                Status[1] <= 1'b1;
                Cause[6:2] <= 5'b00000; 
				cp0_int_1<=!cause_change_last;
				cp0_cln_1<=!cause_change_last;
				cp0_int_2<=cause_change_last;
				cp0_cln_1<=cause_change_last;
            end         
            else if((((exceptionFlag > 32'h0000_0000) && (exceptionFlag < 32'h0000_0040)) || (exceptionFlag == 32'h0000_0080)) && (Status[1] == 0))
			//have exception
            begin
                case(exceptionFlag)
					32'h0000_0020,32'h0000_0080:begin//addr exp                    
						BadVAddr <= orginalVritualAddrT;
					end
					32'h0000_0001:begin                    
						BadVAddr <= exceptionPC;
					end
					default:begin              
					end
                endcase
                EPC <= exceptionPC;
                Cause[31] <= isDelay;
                Status[1] <= 1'b1;
                case(exceptionFlag[7:0])
					8'b00000001,8'b00100000:begin//addr if 0r ma r                    
						Cause[6:2] <= 5'b00100;
					end
					8'b00000010:begin//unknown inst                    
						Cause[6:2] <= 5'b01010;
					end
					8'b00000100:begin//ov                    
						Cause[6:2] <= 5'b01100;
					end
					8'b00001000:begin//break                    
						Cause[6:2] <= 5'b01001;
					end
					8'b00010000:begin//syscall                    
						Cause[6:2] <= 5'b01000;//sys
						// cp0_int_occur<=1;
					end
					8'b10000000:begin//addr w                    
						Cause[6:2] <= 5'b00101;
					end
					default:;
                endcase
            end
            else if(exceptionFlag == 32'h0000_0040)//eret
            begin
				// cp0_int_occur<=0;
                Status[1] <= 1'b0;
            end
			else
			begin
				cp0_int_1<=1'b0;
				cp0_int_2<=1'b0;
			end

            

		end
	end
	//write
	always@(*)begin
		if(cp0_w_en_1&&!cp0_int_2&&cp0_w_addr_1!=cp0_w_addr_2)//change cp0 reg force? && other line not int
			begin
                case (cp0_w_addr_1)
                // `CP0CountAddr: 
				5'b01001:
                    begin
                        Count <= cp0_w_data_1;
                    end
                // `CP0StatusAddr: 
				5'b01100:
                    begin
                        Status[15:8] <= cp0_w_data_1[15:8];//block int
                        Status[1:0] <= cp0_w_data_1[1:0];
                    end
                // `CP0CauseAddr: 
				5'b01101:
                    begin
                        Cause[9:8] <= cp0_w_data_1[9:8];
						cause_change_last<=1'b0;
                    end
                // `CP0expAddr: 
				5'b01110:
                    begin
                        EPC[31:0] <= cp0_w_data_1[31:0];
                    end
                // `CP0CompareAddr: 
				5'b01011:
                    begin
                        Compare <= cp0_w_data_1;
                        Cause[1] <= 1'b0;
                    end
                default:
                    begin
                        //do nothing
                    end
				endcase
			end
		if(cp0_w_en_2&&!cp0_int_1)//change cp0 status force?
			begin
                case (cp0_w_addr_2)
                // `CP0CountAddr: 
				5'b01001:
                    begin
                        Count <= cp0_w_data_2;
                    end
                // `CP0StatusAddr: 
				5'b01100:
                    begin
                        Status[15:8] <= cp0_w_data_2[15:8];//block int
                        Status[1:0] <= cp0_w_data_2[1:0];
                    end
                // `CP0CauseAddr: 
				5'b01101:
                    begin
                        Cause[9:8] <= cp0_w_data_2[9:8];
						cause_change_last<=1'b1;
                    end
                // `CP0expAddr: 
				5'b01110:
                    begin
                        EPC[31:0] <= cp0_w_data_2[31:0];
                    end
                // `CP0CompareAddr: 
				5'b01011:
                    begin
                        Compare <= cp0_w_data_2;
                        Cause[1] <= 1'b0;
                    end
                default:
                    begin
                        //do nothing
                    end
				endcase
			end
		else
			begin
			
			end			
	end
	
	// The logic of read reg from cp0
	always @ (*) begin
		if(reset == 0)
		begin
			cp0_r_data_1 <= 31'h0000_0000;
		end
		else
		begin
            case (cp0_r_addr_1)
				// `CP0BadVAddrAddr: //5'b01000
				5'b01000:begin
					cp0_r_data_1 <= BadVAddr;
				end
				// `CP0CountAddr: 
				5'b01001:begin
					cp0_r_data_1 <= Count;
				end
				// `CP0StatusAddr:
				5'b01100:begin
					cp0_r_data_1 <= Status;
				end
				// `CP0CauseAddr: 
				5'b01101:begin
					cp0_r_data_1 <= Cause;
				end
				// `CP0expAddr: 
				5'b01110:begin
					cp0_r_data_1 <= EPC;
				end
				// `CP0CompareAddr: 
				5'b01011:begin
					cp0_r_data_1 <= Compare;
				end	
				default:begin
					cp0_r_data_1 <= 31'h0000_0000;
				end			
            endcase		
		end
		
		if(reset == 0)
		begin
			cp0_r_data_2 <= 31'h0000_0000;
		end
		else
		begin
            case (cp0_r_addr_2)
				// `CP0BadVAddrAddr: //5'b01000
				5'b01000:begin
					cp0_r_data_2 <= BadVAddr;
				end
				// `CP0CountAddr: 
				5'b01001:begin
						cp0_r_data_2 <= Count;
				end
				// `CP0StatusAddr:
				5'b01100:begin
						cp0_r_data_2 <= Status;
				end
				// `CP0CauseAddr: 
				5'b01101:begin
						cp0_r_data_2 <= Cause;
				end
				// `CP0expAddr: 
				5'b01110:begin
						cp0_r_data_2 <= EPC;
				end
				// `CP0CompareAddr: 
				5'b01011:begin
						cp0_r_data_2 <= Compare;
				end	
				default:begin
						cp0_r_data_2 <= 31'h0000_0000;
                end			
            endcase		
		end
	end
	
	
	//softWare hard_int_wire
	always @ (*)
	begin
        if((Status[1] == 1'b0) && ((Cause[9] == 1'b1 && Status[9] == 1'b1) || (Cause[8] == 1'b1 && Status[8] == 1'b1)))
        begin
            softWareInt <= 1'b1;
        end
        else
        begin
            softWareInt <= 1'b0;
        end   
	end
	
endmodule