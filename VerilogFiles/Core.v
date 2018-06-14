module Core (clk, addr_to_sram, read_data_sram, write_data, write_enable, sram_req, rom_req, addr_rom, read_data_rom, sram_op_done, clr, reg_write_enable, reg_read_index_1, reg_read_index_2, reg_write_index, reg_write_data, reg_read_data_1, reg_read_data_2);

	input clk, clr, sram_op_done; // clk: Clock, sram_op_done: Checks if access to SRAM completed successfully
	output reg[18:0] addr_to_sram;
	output reg[17:0] addr_rom; // addr_to_sram: Address to access SRAM, addr_rom: Address to access ROM
	input[7:0] read_data_sram, read_data_rom; // read_data_sram: Data returned from SRAM from read, read_data_rom: Data returned from ROM from read
	output reg write_enable, sram_req, rom_req; // write_enable and sram_request signals for accesses to SRAM
	output reg[7:0] write_data; // Write data to write to SRAM

	output reg reg_write_enable;
	output reg[3:0] reg_read_index_1, reg_read_index_2, reg_write_index;
	output reg[18:0] reg_write_data;
	input[18:0] reg_read_data_1, reg_read_data_2;

	parameter ADD = 5'b00000;
	parameter SUB = 5'b00001;
	parameter CMP = 5'b00010;
	parameter AND = 5'b00011;
	parameter OR = 5'b00100;
	parameter XOR = 5'b00101;
	parameter MOV = 5'b00110;
	parameter BLT = 5'b00111;
	parameter BLTE = 5'b01000;
	parameter LOAD = 5'b01001;
	parameter STORE = 5'b01010;
	parameter JR = 5'b01011;
	parameter BE = 5'b01100;
	parameter BNE = 5'b01101;
	parameter SHIFTLI = 5'b01110;
	parameter SHIFTRI = 5'b01111;
	parameter INC = 5'b11111;
	parameter ADDI = 5'b10000;
	parameter SUBI = 5'b10001;
	parameter CMPI = 5'b10010;
	parameter ANDI = 5'b10011;
	parameter ORI = 5'b10100;
	parameter XORI = 5'b10101;
	parameter MOVI = 5'b10110;
	parameter LOADI = 5'b10111;
	parameter STOREI = 5'b11000;
	parameter JA = 5'b11001;
	parameter BEI = 5'b11010;
	parameter BNEI = 5'b11011;
	parameter BLTI = 5'b11100;
	parameter BLTEI = 5'b11101;
	parameter JS = 5'b11110;	
	
	parameter FETCH1 = 0;
	parameter DECODE1 = 1;
	parameter FETCH2 = 2;
	parameter DECODE2 = 3;
	parameter FETCH3 = 15;
	parameter DECODE3 = 16;
	parameter FETCH4 = 17;
	parameter DECODE4 = 18;
	parameter OPERATION = 4;
	parameter BRANCH = 5;
	parameter LOADSTATE = 6;
	parameter STORESTATE = 7;
	parameter I_OPERATION = 8;
	parameter I_BRANCH = 9;
	parameter I_LOAD = 10;
	parameter I_STORE = 11;
	parameter I_STORE2 = 19;
	parameter LOADSTATE2 = 12;
	parameter I_LOAD2 = 13;
	parameter STORESTATE2 = 14;


	reg[4:0] state;// = FETCH1;
	
	reg[17:0] PC;// = 20'd0;
	reg neg_flag;// = 0;
	reg zero_flag;// = 0;
	
	reg[4:0] OPCODE;// = 0;  
	reg[19:0] immd;// = 0;

	reg load_sram;// = 0;

	always @ (*) begin
	// These values are never getting used with my logic
		addr_rom = 19'd0;
		sram_req = 1'b0;
		write_enable = 0;
		reg_write_data = 0;
		write_data = 0;
		reg_write_enable = 0;
		rom_req = 0;
		addr_to_sram = 0;
			if(state == FETCH1) begin
				rom_req = 1'b1;
				addr_rom = PC;
			end
			else if(state == DECODE1) begin
				// DO NOTHING
			end
			else if(state == FETCH2) begin
				rom_req = 1;
				addr_rom = PC;
			end
			else if(state == DECODE2) begin
				// DO NOTHING
			end
			if(state == FETCH3) begin
				rom_req = 1;
				addr_rom = PC;
			end
			else if(state == DECODE3) begin
				// DO NOTHING
			end
			else if(state == FETCH4) begin
				rom_req = 1;
				addr_rom = PC;
			end
			else if(state == DECODE4) begin
				// DO NOTHING
			end
			else if(state == OPERATION) begin
				reg_write_enable = 1'b1;
				case(OPCODE)
					ADD: begin
							reg_write_data = reg_read_data_1 + reg_read_data_2;
					end
					SUB: begin
							reg_write_data = reg_read_data_1 - reg_read_data_2;
					end
					CMP: begin
							reg_write_data = reg_read_data_1 - reg_read_data_2;
					end
					AND: begin
							reg_write_data = reg_read_data_1 & reg_read_data_2;
					end
					OR: begin
							reg_write_data = reg_read_data_1 | reg_read_data_2;
					end
					XOR: begin
							reg_write_data = reg_read_data_1 ^ reg_read_data_2;
					end
					MOV: begin
							reg_write_data = reg_read_data_2;
					end
					SHIFTLI: begin
							reg_write_data = reg_read_data_1 << reg_read_index_2;
					end
					SHIFTRI: begin
							reg_write_data = reg_read_data_1 >> reg_read_index_2;
					end
					INC: begin
							reg_write_data = reg_read_data_1 + 1'b1;
					end
				endcase
				if(OPCODE == CMP) begin
					reg_write_enable = 1'b0;
				end
			end
			else if(state == I_BRANCH) begin
				if(OPCODE == JS) begin
						reg_write_data = PC; // PC was incremented in FETCH
						reg_write_enable = 1;
				end
			end
			// IF ADDR IS GREATER THAN 0x10, GO TO ROM OTHERWISE GO TO SRAM 
			else if(state == LOADSTATE) begin
				if(reg_read_data_2 <= 20'hF)
					sram_req = 1'b1;
				else
					rom_req = 1;
				addr_to_sram = {reg_read_data_2}; // Get addr from reg 2
				addr_rom = {reg_read_data_2};
			end
			else if(state == LOADSTATE2) begin
				reg_write_data = load_sram ? read_data_sram : read_data_rom; // Place data into reg 1 
				reg_write_enable = 1;
			end
			else if(state == I_LOAD) begin
				if(immd <= 20'hF)
					sram_req = 1'b1;
				else
					rom_req = 1;
				addr_to_sram = {immd};
				addr_rom = {immd};
			end
			else if(state == I_LOAD2) begin
				reg_write_data = load_sram ? read_data_sram : read_data_rom; // Place data into reg 1 
				reg_write_enable = 1;
			end
			else if(state == STORESTATE) begin
				sram_req = 1'b1;
				write_enable = 1;
				addr_to_sram = {reg_read_data_2};
				write_data = reg_read_data_1[7:0];
			end 
			else if(state == I_STORE) begin
				sram_req = 1'b1;
				addr_to_sram = {immd};
				write_data = reg_read_data_1[7:0];
				write_enable = 1;
			end
			else if(state == I_OPERATION) begin
				reg_write_enable = 1'b1;
				case(OPCODE)
					ADDI: begin
							reg_write_data = reg_read_data_1 + immd;
					end
					SUBI:begin
							reg_write_data = reg_read_data_1 - immd;
					end
					CMPI: begin
							reg_write_data = reg_read_data_1 - immd;
					end
					ANDI: begin
							reg_write_data = reg_read_data_1 & immd;
					end
					ORI: begin
							reg_write_data = reg_read_data_1 | immd;
					end
					XORI: begin
							reg_write_data = reg_read_data_1 ^ immd;
					end
					MOVI: begin
							reg_write_data = immd;
					end
				endcase
				if(OPCODE == CMPI) begin
					reg_write_enable = 1'b0;
				end
			end
	end

	always @ (posedge clk or negedge clr) begin
			if(~clr) begin
				state <= FETCH1;
				PC <= 0;
			end
			else if(state == FETCH1) begin
				state <= DECODE1;
				PC <= PC + 1'b1;
			end
			else if(state == DECODE1) begin
				OPCODE <= read_data_rom[7:3];
				state <= FETCH2;
			end
			else if(state == FETCH2) begin
				state <= DECODE2;
				PC <= PC + 1'b1;
			end
			else if(state == DECODE2) begin
					reg_read_index_1 <= read_data_rom[7:4];	
					reg_read_index_2 <= read_data_rom[3:0];
					reg_write_index <= read_data_rom[7:4];
					immd[19:16] <= read_data_rom[3:0];
					if(OPCODE == INC || OPCODE <= MOV || OPCODE == SHIFTLI || OPCODE == SHIFTRI) begin
						state <= OPERATION;
					end
					else if(OPCODE[4] == 1'b1) begin
						state <= FETCH3;
					end
					else if(OPCODE == LOAD) begin
						state <= LOADSTATE;
					end
					else if(OPCODE == STORE) begin
						state <= STORESTATE;
					end
					else begin
						state <= BRANCH;
					end
			end
			else if(state == FETCH3) begin
				state <= DECODE3;
				PC <= PC + 1'b1;
			end
			else if(state == DECODE3) begin
				state <= FETCH4;
				immd[15:8] <= read_data_rom;
			end
			else if(state == FETCH4) begin
				state <= DECODE4;
				PC <= PC + 1'b1;
			end
			else if(state == DECODE4) begin
				immd[7:0] <= read_data_rom;
				if(OPCODE <= MOVI) 
					state <= I_OPERATION;
				else if(OPCODE == LOADI)
					state <= I_LOAD;
				else if(OPCODE == STOREI)
					state <= I_STORE;
				else begin
					if(OPCODE == JS) 
						reg_write_index <= 4'd3;
					state <= I_BRANCH;
				end
			end
			else if(state == OPERATION || state == I_OPERATION) begin
				if(reg_write_data == 0) begin
					zero_flag <= 1; 
				end
				else begin
					zero_flag <= 0;
				end
				
				if(reg_write_data[18] == 1'b1) begin
					neg_flag <= 1;
				end
				else begin
					neg_flag <= 0;
				end
				state <= FETCH1;
			end
			else if(state == BRANCH) begin
				case(OPCODE)
					BLT: begin
						if(neg_flag) 
							PC <= reg_read_data_1;
					end
					BLTE: begin
						if(neg_flag || zero_flag) 
							PC <= reg_read_data_1;
					end
					JR: begin
						PC <= reg_read_data_1;
					end
					BE: begin
						if(zero_flag)
							PC <= reg_read_data_1;
					end
					BNE: begin
						if(!zero_flag) 
							PC <= reg_read_data_1;
					end
				endcase
				state <= FETCH1;
			end 
			else if(state == I_BRANCH) begin
				case(OPCODE)
					BLTI: begin
						if(neg_flag) 
							PC <= immd;
					end
					BLTEI: begin
						if(neg_flag || zero_flag) 
							PC <= immd;
					end
					JA: begin
						PC <= immd;
					end
					JS: begin
						PC <= immd;
					end
					BEI: begin
						if(zero_flag)
							PC <= immd;
					end
					BNEI: begin
						if(!zero_flag) 
							PC <= immd;
					end
				endcase
				state <= FETCH1;
			end
			else if(state == STORESTATE) begin
				state <= STORESTATE2;
			end
			else if(state == STORESTATE2) begin
				if(sram_op_done)
					state <= FETCH1;
				else
					state <= STORESTATE;
			end
			else if(state == I_STORE) begin
				state <= I_STORE2;
			end
			else if(state == I_STORE2) begin
				if(sram_op_done)
					state <= FETCH1;
				else
					state <= I_STORE;
			end
			else if(state == LOADSTATE) begin
				if(reg_read_data_2 <= 20'hF)
					load_sram <= 1'b1;
				else 
					load_sram <= 1'b0;
				state <= LOADSTATE2;
			end
			else if(state == LOADSTATE2) begin
				if((sram_op_done && load_sram) || ~load_sram)
					state <= FETCH1;
				else 
					state <= LOADSTATE;
			end
			else if(state == I_LOAD) begin
				if(immd <= 20'hF)
					load_sram <= 1'b1;
				else
					load_sram <= 1'b0;
				state <= I_LOAD2;
			end
			else if(state == I_LOAD2) begin
				if((sram_op_done && load_sram) || ~load_sram)
					state <= FETCH1;
				else
					state <= I_LOAD;
			end
	end
endmodule
