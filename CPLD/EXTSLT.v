`timescale 1ns / 1ps


//////////////////////////////////////////////////////////////////////////////////
// Company: illegal function call
// Engineer: @v9938
// 
// Create Date:    05/12/2022 
// Design Name: EXTPAND SLT (4 SLOT Version)
// Module Name:    EXT_SLT4
// Project Name: EXT_SLT4
// Target Devices: XC9536XL
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision 1.0 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module EXT_SLT(
	input SLT_CLOCK,				//from MSX Slot
	input SLT_RESETn,				//from MSX Slot
	input SLT_SLTSL,				//from MSX Slot
	input SLT_WEn,					//from MSX Slot
	input SLT_RDn,					//from MSX Slot
    input [15:0] SLT_A,				//from MSX Slot
    inout [7:0] SLT_D,				//from MSX Slot
    output SLT_BUSDIR,				//To MSX Slot
    inout [3:0] EXTSLT				//To EXT Slot
    );

//	Address Decoder==========================
// Enable EXTSLT
//     FFFFh: page0/1/2/3h
//

	wire ExtsltSel;
	wire Page0Sel,Page1Sel,Page2Sel,Page3Sel;

	assign ExtsltSel			= ((SLT_A[15:0]==16'hFFFF) & (SLT_SLTSL == 1'b0));
	assign Page0Sel				= (SLT_A[15:14]==2'b00);
	assign Page1Sel				= (SLT_A[15:14]==2'b01);
	assign Page2Sel				= (SLT_A[15:14]==2'b10);
	assign Page3Sel				= (SLT_A[15:14]==2'b11);

//	ExtSlt register write control==========================
	reg [7:0] ExtsltReg;

	always @(negedge SLT_CLOCK or negedge SLT_RESETn) begin
		if (!SLT_RESETn) begin
			ExtsltReg[7:0] 	<= 8'h00;
		end
		else begin
			if ((SLT_WEn == 1'b0) & (ExtsltSel == 1'b1)) ExtsltReg[7:0] 	<= SLT_D[7:0];
		end
	end
//	ExtSlt register read control==========================
	wire [7:0] intSLT_D;
	wire SltRead;

	assign SltRead	= ExtsltSel &  ~SLT_RDn;
	assign intSLT_D[7:0] = (SltRead) ? ~ExtsltReg[7:0]: 8'b1111_1111;

	//BUS Driver
	assign SLT_D[7] = (intSLT_D[7]==1'b0) ? 1'b0 : 1'bz;
	assign SLT_D[6] = (intSLT_D[6]==1'b0) ? 1'b0 : 1'bz;
	assign SLT_D[5] = (intSLT_D[5]==1'b0) ? 1'b0 : 1'bz;
	assign SLT_D[4] = (intSLT_D[4]==1'b0) ? 1'b0 : 1'bz;
	assign SLT_D[3] = (intSLT_D[3]==1'b0) ? 1'b0 : 1'bz;
	assign SLT_D[2] = (intSLT_D[2]==1'b0) ? 1'b0 : 1'bz;
	assign SLT_D[1] = (intSLT_D[1]==1'b0) ? 1'b0 : 1'bz;
	assign SLT_D[0] = (intSLT_D[0]==1'b0) ? 1'b0 : 1'bz;

//	Make EXTSLT ==========================
	wire [1:0] ExtsltNum;
	wire [3:0] intEXTSLT;

	//Select bit
	assign ExtsltNum[1:0] 	= 	(Page0Sel == 1'b1 ) ? ExtsltReg[1:0] :
								(Page1Sel == 1'b1 ) ? ExtsltReg[3:2] :
								(Page2Sel == 1'b1 ) ? ExtsltReg[5:4] : ExtsltReg[7:6];
	//Bit Decode
	assign intEXTSLT[3:0]	=	((SLT_SLTSL == 1'b0) & (SLT_A[15:0]!=16'hFFFF) & ExtsltNum[1:0]==2'b00) ? 4'b1110 :
								((SLT_SLTSL == 1'b0) & (SLT_A[15:0]!=16'hFFFF) & ExtsltNum[1:0]==2'b01) ? 4'b1101 :
								((SLT_SLTSL == 1'b0) & (SLT_A[15:0]!=16'hFFFF) & ExtsltNum[1:0]==2'b10) ? 4'b1011 :
								((SLT_SLTSL == 1'b0) & (SLT_A[15:0]!=16'hFFFF) & ExtsltNum[1:0]==2'b11) ? 4'b0111 : 4'b1111;
	
	//BUS Driver
	assign EXTSLT[3] = ((intEXTSLT[3] & EXTSLT[3]) == 0)? intEXTSLT[3] : 1'bz;
	assign EXTSLT[2] = ((intEXTSLT[2] & EXTSLT[2]) == 0)? intEXTSLT[2] : 1'bz;
	assign EXTSLT[1] = ((intEXTSLT[1] & EXTSLT[1]) == 0)? intEXTSLT[1] : 1'bz;
	assign EXTSLT[0] = ((intEXTSLT[0] & EXTSLT[0]) == 0)? intEXTSLT[0] : 1'bz;

	//BUS DIR
	assign SLT_BUSDIR = SLT_RDn | SLT_SLTSL;

endmodule
