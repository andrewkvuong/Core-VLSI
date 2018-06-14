//Verilog HDL for "Lib6710_02", "DFF" "behavioral"


module DFF ( Q, QB, CLK, CLRB, D );

  input CLK;
  output reg Q;
  input D;
  input CLRB;
  output reg QB;

  always @ (posedge CLK or negedge CLRB) begin
    if(~CLRB) begin
      Q = 0;
	  QB = 1;
    end
	else begin
    	Q = D;
    	QB = ~D;
	end
  end

endmodule
