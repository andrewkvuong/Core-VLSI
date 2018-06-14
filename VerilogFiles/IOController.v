
module IOController(clk, clr, mem_data, button, data_ready, we, write_data, req, addr, LED, audio_req, start, stopPos, audio_done, audio_addr);
	input clk, clr;
	input[7:0] mem_data;
	input[7:0] button;
	input data_ready;
	output reg we;
	output reg [7:0] write_data;
	output reg req;
	output reg[18:0] addr;
//	output audio_data, NC, gain, stop;
	output reg LED;	

	input audio_req;
	output reg start;
	output reg[18:0] stopPos;
	input audio_done;
	input[18:0] audio_addr;

	parameter BUTTON0 = 1;
	parameter BUTTON1 = 2;
	parameter BUTTON2 = 3;
	parameter BUTTON3 = 4;
	parameter BUTTON4 = 5;
	parameter BUTTON5 = 6;
	parameter BUTTON6 = 7;
	parameter BUTTON7 = 14;
	parameter WAITCORE = 8;
	parameter WAITPOSITION = 9;
	parameter GETPOSITION = 10;
	parameter STARTAUDIO = 11;
	parameter STARTAUDIO2 = 12;
	parameter WAITAUDIO = 13;

	reg[9:0] counter;
	reg[4:0] state;
	reg but8;

	always@(*) begin
		we  = 0;
		write_data = 0;
		addr = 0;
		req = 0;
		LED = 0;
		start = 0;
		case(state)
				BUTTON0:begin
					write_data = 8'd1; // Button 0
					we = 1;		
					req = 1;
				end
				BUTTON1:begin
					write_data = 8'd2; // Button 1
					we = 1;	
					req = 1;
				end
				BUTTON2:begin
					write_data = 8'd3; // Button 2
					we = 1;	
					req = 1;
				end
				BUTTON3:begin
					write_data = 8'd4; // Button 3
					we = 1;	
					req = 1;

				end
				BUTTON4:begin
					write_data = 8'd5; // Button 4
					we = 1;	
					req = 1;

				end
				BUTTON5:begin
					write_data = 8'd6; // Reset
					we = 1;	
					req = 1;

				end
				BUTTON6:begin
					write_data = 8'd7; // PLAY
					we = 1;
					req = 1;
				end
				BUTTON7:begin
					if(but8 == 1) begin
						write_data = 8'd0;
					end
					else
						write_data = 8'd1;
					addr = 2;
					we = 1;
					req = 1;
				end
				WAITPOSITION: begin
					// DO NOTHING
				end
				GETPOSITION:begin
					req = 1;
					addr = 1;
				end
				STARTAUDIO: begin
					start = 1;
				end
				WAITAUDIO: begin
					req = audio_req;
					addr = audio_addr;
				end
				WAITCORE: begin
					LED = 1;
					if(counter == 0) begin
						req = 1;
					end
				end
		endcase
	end

	always@(posedge clk or negedge clr) begin
		if(~clr) begin
			state <= 0;
			counter <= 0;
		end
		else begin
			case(state)
				0: begin
					if(button[0]) begin
						state <= BUTTON0;
					end
					else if(button[1]) begin
						state <= BUTTON1;
					end
					else if(button[2]) begin
						state <= BUTTON2;
					end
					else if(button[3]) begin
						state <= BUTTON3;
					end
						else if(button[4]) begin
						state <= BUTTON4;
					end
					else if(button[5]) begin // RESET BUTTON
						state <= BUTTON5;
					end
					else if(button[6]) begin // START BUTTON
						state <= BUTTON6;
					end
					else if(button[7]) begin
						state <= BUTTON7;
					end
				end
				BUTTON0:begin
					state <= WAITCORE;	
				end
				BUTTON1:begin
					state <= WAITCORE;	
				end
				BUTTON2:begin
					state <= WAITCORE;	
				end
				BUTTON3:begin
					state <= WAITCORE;	
				end
				BUTTON4:begin
					state <= WAITCORE;	
				end
				BUTTON5:begin
					state <= WAITCORE;	
				end
				BUTTON6:begin
					state <= GETPOSITION;
					counter <= 0;
				end
				BUTTON7: begin
					state <= 0;
				end
				WAITPOSITION: begin
					counter <= counter + 1'b1;
					if(counter == 100) begin
						state <= GETPOSITION;
					end
				end
				GETPOSITION:begin
					state <= STARTAUDIO;
				end
				STARTAUDIO: begin
					state <= WAITAUDIO;
					stopPos <= mem_data * 16000; // Core offset * size of sample 
				end
				WAITAUDIO: begin
					if(audio_done)
						state <= 0;
				end
				WAITCORE:begin
					counter <= counter + 1'b1;
					if(mem_data == 0) begin
						state <= 0;
					end
				end
			endcase

		end

	end

	// State 1: Button Pressed
	// State 2: Check the button
	// If write audio/clear audio - set button flag and turn LED on. Go to wait state.
	// If play audio - set flag to tell core audio is playing, turn ON LED
	// State WAIT CORE: Periodically check memory until core completes. Go back
	// to state 1 if core completes.
	// State WAIT AUDIO: Wait until audio says that it is done.
endmodule