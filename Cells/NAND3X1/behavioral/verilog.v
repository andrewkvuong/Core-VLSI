//Verilog HDL for "Lib6710_02", "NAND3X1" "behavioral"


module NAND3X1 (Y, A, B, C );
	input A, B, C;
	output Y;

	nand _i0(Y, A, B, C);

   specify
     (A => Y) = (1.0, 1.0);
	 (B => Y) = (1.0, 1.0);
	 (C => Y) = (1.0, 1.0);
   endspecify

endmodule
