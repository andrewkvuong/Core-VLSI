//Verilog HDL for "Lib6710_02", "OR2X1" "behavioral"


module OR2X1 (Y, A, B );
	input A, B;
	output Y;

	or _i0(Y, A, B);
	
   specify
     (A => Y) = (1.0, 1.0);
     (B => Y) = (1.0, 1.0);
   endspecify
	

endmodule
