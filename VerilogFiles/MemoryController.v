//Verilog HDL for "verilog_project_code", "MemoryController" "behavioral"


module MemoryController (clk, sram_we, sram_addr, sram_data_in, sram_data_out, rom_data, rom_oe, rom_ce, rom_addr,
core_we, core_sram_addr, core_rom_addr, core_sram_req, core_rom_req, core_write_data, core_op_done, core_sram_data, 
core_rom_data, IO_we, IO_addr, IO_req, IO_write_data, IO_data, EN, clr, IO_ready);

	input clk, clr;

	// SRAM
	output reg sram_we;
	output reg[18:0] sram_addr;
	input[7:0] sram_data_in;
	output reg[7:0] sram_data_out;
	output EN;
	//inout[7:0] sram_data;
	// Hold CE and OE low for SRAM

	// EPROM
	input[7:0] rom_data;
	output reg rom_oe;
	output reg rom_ce;
	output reg[17:0] rom_addr;

	// Core
	input core_we;
	input[18:0] core_sram_addr;
	input[17:0] core_rom_addr;
	input core_sram_req;
	input core_rom_req;
	input[7:0] core_write_data;
	output reg core_op_done;
	output reg[7:0] core_sram_data;
	output reg[7:0] core_rom_data;

	// I/O Stuff
	input IO_we;
	input[18:0] IO_addr;
	input IO_req;
	input[7:0] IO_write_data;
	output reg[7:0] IO_data;
	output reg IO_ready;
	
	//Other
	reg[1:0] sram_state;
	parameter IO = 0;
	parameter CORE = 1;
	parameter IDLE = 2;

	//assign sram_data_in = ~sram_we ? sram_state == IO ? IO_write_data : core_write_data : 8'bzzzzzzzz;

	assign EN = ~sram_we ? 1'b1 : 1'b0;


	always@(*) begin
		IO_data = 0;
		core_sram_data = 0;
		core_op_done = 0;
		IO_ready = 0;
		core_rom_data = rom_data;
		
		if(sram_we) begin // Not write
			if(sram_state == IO) begin
				IO_data = sram_data_in;
				IO_ready = 1;
			end
			else if(sram_state == CORE) begin
				core_sram_data = sram_data_in;
				core_op_done = 1;
			end
		end
		else begin
			if(sram_state == IO) begin
				//IO_data = sram_data_in;
				IO_ready = 1;
			end
			else if(sram_state == CORE) begin
				//core_sram_data = sram_data_in;
				core_op_done = 1;
			end
		end
	end

	always@(posedge clk or negedge clr) begin
		if(~clr) begin
			sram_state <= IDLE;
			rom_addr <= 0;
		end
		else begin
			if(core_rom_req) begin
				rom_ce <= 0;
				rom_oe <= 0;
				rom_addr <= core_rom_addr;
			end
			else begin
				rom_ce <= 1;
				rom_oe <= 1;
			end
		
			if(sram_state == IDLE) begin
				if(IO_req) begin
					sram_addr <= IO_addr;
					sram_we <= ~IO_we;
					sram_state <= IO;
					if(IO_we) begin
						sram_data_out <= IO_write_data;
					end
				end
				else if(core_sram_req) begin
					sram_addr <= core_sram_addr;
					sram_we <= ~core_we;
					sram_state <= CORE;
					if(core_we) begin
						sram_data_out <= core_write_data;
					end
				end
			end
			else begin
				if(IO_req) begin
					sram_addr <= IO_addr;
					sram_we <= ~IO_we;
					sram_state <= IO;
					if(IO_we) begin
						sram_data_out <= IO_write_data;
					end
				end
				else if(core_sram_req) begin
					sram_addr <= core_sram_addr;
					sram_we <= ~core_we;
					sram_state <= CORE;
					if(core_we) begin
						sram_data_out <= core_write_data;
					end
				end
				else begin
					sram_state <= IDLE;
				end
			end
		end
	end
endmodule