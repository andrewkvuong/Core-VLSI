//Verilog HDL for "CAD5_new", "MUX2X1" "behavioral"


module MUX2X1 ( Y, A, B, S );

  input A;
  input S;
  output reg Y;
  input B;
	always @(A or B or S)
	  begin
		if(S==1)
			Y =A;
		else Y = B;
	end
endmodule
