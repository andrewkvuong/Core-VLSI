//Verilog HDL for "Lib6710_xx", "NAND2X1" "behavioral"


module NAND2X1 ( Y, A, B );

  input A;
  output Y;
  input B;

  nand _i0(Y, A, B);

  specify
    (A => Y) = (1.0, 1.0);
	(B => Y) = (1.0, 1.0);
  endspecify

endmodule
