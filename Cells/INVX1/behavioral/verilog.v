//Verilog HDL for "Lib6710_02", "INV2X1" "behavioral"


module INVX1 ( Y, A );

  input A;
  output Y;

  assign Y = ~A;
  specify
    (A => Y) = (1.0, 1.0);
  endspecify

endmodule
