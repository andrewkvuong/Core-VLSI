//Verilog HDL for "Lib6710_02", "NOR2X1" "behavioral"


module NOR2X1 ( F, A, B );

  input A;
  output F;
  input B;

  nor _i0(F, A, B);

  specify
    (A => F) = (1.0, 1.0);
    (B => F) = (1.0, 1.0);
  endspecify

endmodule
