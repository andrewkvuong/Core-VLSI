module audioController(clk, clr, mem_data, addr, data, NC, gain, stop, req, data_ready, start, stopPos, done);
	input clk, clr;
	input[7:0] mem_data;
	output reg[18:0] addr;
	output reg data;
	output NC, gain, stop;
	output reg req;
	input data_ready;
	input start;
	input[18:0] stopPos;
	output reg done;
	
	assign NC = 0; // Chip on
	assign gain  = 0; // Gain to low
	assign stop = 0; // Leave on

	reg[18:0] currentPosition;
	reg[2:0] bitCounter;
	reg[6:0] counter;
	reg[7:0] data_saved;

	always@(*) begin
		req = 0;
		if(bitCounter == 0 && addr <= currentPosition)
			req = 1;
	end


	always@(posedge clk or negedge clr) begin
		if(~clr) begin
			counter <= 0;
			addr <= 0;
			bitCounter <= 0;
			currentPosition <= 0;
		end
		else if(start) begin
			addr <= 0;
			currentPosition <= stopPos;
			done <= 0;
		end
		else begin
			if(addr <= currentPosition) begin
				counter <= counter + 1'b1;
				if(data_ready) begin
					data_saved = mem_data;
				end
				if(counter == 78) begin
					data = data_saved[bitCounter];
					bitCounter <= bitCounter + 1'b1;
					if(bitCounter == 7) begin
						addr <= addr + 1'b1;
					end	
					counter <= 0;
				end
			end
			else
				done <= 1;
		end
	end
endmodule