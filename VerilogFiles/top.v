//Verilog HDL for "verilog_project_code", "top" "behavioral"


module top (input clk,
			input clr,
			input[7:0] sram_data_in,
			input[7:0] rom_data,
			output sram_we,
			output[18:0] sram_addr,
			output[7:0] sram_data_out,
			output rom_oe,
			output rom_ce,
			output[17:0] rom_addr,
			output EN,
			output LED,
			output sram_oe,
			output sram_ce,
			output sram_NC,
			output rom_pgm,
			output audio_stop,
			output audio_gain,
			output audio_NC,
			output audio_data,
			input[7:0] buttons
			);


	assign sram_oe = 0; // Leave on
	assign sram_ce = 0; // Leave on
	assign sram_NC = 1; // Leave connected
	assign rom_pgm = 1; // Leave off. Want to do reads only.

	wire core_we, core_sram_req, core_rom_req, core_op_done;
	wire[18:0] core_sram_addr;
	wire[17:0] core_rom_addr;
	wire[7:0] core_write_data, core_sram_data, core_rom_data;

	wire IO_we, IO_req, IO_ready;
	wire[7:0] IO_data, IO_write_data;
	wire[18:0] IO_addr;

	wire[18:0] audio_addr;
	wire audio_req;
	wire start;
	wire[18:0] stopPos;
	wire audio_done;

	IOController _IOController(.clk(clk), 
							   .clr(clr), 
							   .mem_data(IO_data), 
							   .button(buttons), //  
							   .data_ready(IO_ready), 
							   .we(IO_we), 
							   .write_data(IO_write_data), 
							   .req(IO_req), 
							   .addr(IO_addr), 
							   .LED(LED),
							   .audio_req(audio_req),
							   .start(start),
							   .stopPos(stopPos),
								.audio_done(audio_done),
								.audio_addr(audio_addr));

	audioController _audioController(.clk(clk),
			.clr(clr),
			.mem_data(IO_data),
			.addr(audio_addr),//
			.data(audio_data), 
			.NC(audio_NC), 
			.gain(audio_gain), 
			.stop(audio_stop), 
			.req(audio_req), //
			.data_ready(IO_ready),
			.start(start), //
			.stopPos(stopPos), //
			.done(audio_done)); //

 MemoryController _MemoryController(.clk(clk), 
									.sram_we(sram_we), 
									.sram_addr(sram_addr), 
									.sram_data_in(sram_data_in), 
									.sram_data_out(sram_data_out), 
									.rom_data(rom_data), 
									.rom_oe(rom_oe), 
									.rom_ce(rom_ce), 
									.rom_addr(rom_addr),
									.core_we(core_we), 
									.core_sram_addr(core_sram_addr), 
									.core_rom_addr(core_rom_addr), 
									.core_sram_req(core_sram_req), 
									.core_rom_req(core_rom_req), 
									.core_write_data(core_write_data), 
									.core_op_done(core_op_done), 
									.core_sram_data(core_sram_data), 
									.core_rom_data(core_rom_data), 
									.IO_we(IO_we), 
									.IO_addr(IO_addr), 
									.IO_req(IO_req), 
									.IO_write_data(IO_write_data), 
									.IO_data(IO_data), 
									.IO_ready(IO_ready),
									.EN(EN), 
									.clr(clr));

	wire reg_write_enable;
	wire[3:0] reg_read_index_1, reg_read_index_2, reg_write_index;
	wire[18:0] reg_write_data, reg_read_data_1, reg_read_data_2;

	Core _Core(.clk(clk), 
			   .addr_to_sram(core_sram_addr),
			   .read_data_sram(core_sram_data),
 			   .write_data(core_write_data), 
               .write_enable(core_we), 
               .sram_req(core_sram_req), 
			   .rom_req(core_rom_req), 
			   .addr_rom(core_rom_addr), 
			   .read_data_rom(core_rom_data), 
			   .sram_op_done(core_op_done), 
			   .clr(clr), 
			   .reg_write_enable(reg_write_enable), 
			   .reg_read_index_1(reg_read_index_1), 
			   .reg_read_index_2(reg_read_index_2), 
			   .reg_write_index(reg_write_index), 
			   .reg_write_data(reg_write_data), 
			   .reg_read_data_1(reg_read_data_1), 
			   .reg_read_data_2(reg_read_data_2));

	Register_File _RegisterFile(.clk(clk),
		  					    .we(reg_write_enable),
		  					    .read_index_1(reg_read_index_1),
		  					    .read_index_2(reg_read_index_2),
		  					    .write_index(reg_write_index),
		  					    .write_data(reg_write_data),
		  					    .read_data_1(reg_read_data_1),
		  					    .read_data_2(reg_read_data_2));




endmodule
