
`timescale 1ns / 100ps

// Code write by V9938

module sim_top();
parameter CYC = 145;
reg 		SLT_CLOCK;
reg 		SLT_RESETn;
reg 		SLT_SLTSL;
reg			SLT_WEn;
reg			SLT_RDn;
reg [15:0]	SLT_A;
reg [7:0]	SLT_D;
wire [7:0] SLT_D_w;
reg [7:0]	SLT_Dx;


wire [1:0]	EXTSLT;
wire		SLT_BUSDIR;

// -----------------------------------------------------------------
task write_task; // writeタスク (addr,data)
input [15:0] addr_task;
input [7:0] data_task;
begin
	#(CYC+25)		SLT_A = addr_task;	//170
	#(CYC+10-25)	SLT_SLTSL = 1'b0;	//130+170 =300
					SLT_RDn = 1'b1;
	#(55)			SLT_D = data_task;	//355=145+210
	#(80+CYC-5)		SLT_WEn = 1'b0;		

	#(CYC+5)		$display("Write Data[%4h]=%2h ====================",SLT_A,SLT_D);
					$display("EXTSLT=%2b",EXTSLT);
	#(CYC-25)		SLT_WEn = 1'b1;
	#(25+10)		SLT_SLTSL = 1'b1;
	#(CYC-10)		SLT_D = 8'bzzzz_zzzz;
	#(CYC);
end
endtask

task read_task; // readタスク (addr)
input [15:0] addr_task;
begin
	#(CYC+25)		SLT_A = addr_task;	//170
	#(CYC+10-25)	SLT_SLTSL = 1'b0;	//130+170 =300
					SLT_WEn = 1'b1;
					SLT_RDn = 1'b0;
	#(55+80+CYC*2)	$display("Read Data[%4h]=%2h ====================",SLT_A,SLT_D);
					$display("EXTSLT=%2b",EXTSLT);
	#(CYC-25)		SLT_RDn = 1'b1;
	#(25+10)		SLT_SLTSL = 1'b1;
	#(CYC-10)		SLT_D = 8'bzzzz_zzzz;
	#(CYC);
end
endtask
// -----------------------------------------------------------------

initial	begin
	#40 SLT_CLOCK = 1'b1;

	forever begin
		#(CYC) SLT_CLOCK = ~SLT_CLOCK;
	end
	
end
initial begin
	SLT_RESETn = 1'bz;
	#(CYC)	SLT_RESETn = 1'b0;
	#(CYC*2)	SLT_RESETn = 1'b1;
end

initial begin
	#(CYC*5) ;
	write_task (16'hFFFF,8'h00);
	read_task (16'hFFFF);
	write_task (16'hFFFF,8'b00_00_00_01);
	read_task (16'hFFFF);
	read_task (16'h0000);
	read_task (16'h4000);
	read_task (16'h8000);
	read_task (16'hc000);

	write_task (16'hFFFF,8'b00_00_01_01);
	read_task (16'hFFFF);
	read_task (16'h0000);
	read_task (16'h4000);
	read_task (16'h8000);
	read_task (16'hc000);

	write_task (16'hFFFF,8'b00_01_01_01);
	read_task (16'hFFFF);
	read_task (16'h0000);
	read_task (16'h4000);
	read_task (16'h8000);
	read_task (16'hc000);

	write_task (16'hFFFF,8'b01_01_01_01);
	read_task (16'hFFFF);
	read_task (16'h0000);
	read_task (16'h4000);
	read_task (16'h8000);
	read_task (16'hc000);


	$finish;

end


assign SLT_D_w = SLT_D;

// Instantiate the module
EXT_SLT instance_name (
    .SLT_CLOCK(SLT_CLOCK), 
    .SLT_RESETn(SLT_RESETn), 
    .SLT_SLTSL(SLT_SLTSL), 
    .SLT_WEn(SLT_WEn), 
    .SLT_RDn(SLT_RDn), 
    .SLT_A(SLT_A), 
    .SLT_D(SLT_D_w), 
    .EXTBUSDIR(2'b11),
    .SLT_BUSDIR(STL_BUSDIR),
    .EXTSLT(EXTSLT)
    );


endmodule
