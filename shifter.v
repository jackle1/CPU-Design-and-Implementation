module shifter(in,shift,sout);
  input [15:0] in;
  input [1:0] shift;
  output reg [15:0] sout;
  wire MSB;

  assign MSB = in[15];

  always @* begin // Cases for all the different shift inputs
  case (shift)
  2'b00: sout = in; // nothing
  2'b01: sout = {in[14:0], 1'b0} ; // Shift left
  2'b10: sout = {1'b0, in[15:1]} ; // Shift right MSB is 0
  2'b11: sout = {MSB, in[15:1]} ; // Shift right MSB is copied
  default: sout = 16'bxxxxxxxxxxxxxxxx ;
  endcase

end
endmodule
