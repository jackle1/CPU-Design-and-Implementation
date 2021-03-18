module instruction_decoder(in, nsel, ALUop, sximm5, sximm8,
  shift, readnum, writenum, opcode, op, cond, sxim8);

  input [15:0] in;
  input [2:0] nsel;
  output [1:0] ALUop, shift;
  output [15:0] sximm8, sximm5;
  output [2:0] readnum, writenum, opcode, cond;
  output [1:0] op;
  output [8:0] sxim8;
  wire [2:0] readwrite;

  assign cond = in[10:8];
  assign sximm5 = {{11{in[4]}}, in[4:0]}; //sign extend in[4:0]
  assign sximm8 = {{8{in[7]}}, in[7:0]}; //sign extend in[7:0]
  assign sxim8 = {in[7], in[7:0]}; //sign extend in[7:0] to 9 bits long
  assign ALUop = (opcode == 3'b010 & op == 2'b10) ? 2'b00 : in[12:11]; //assign in[12:11] to ALUop
  assign shift = (in[15:13] !== 3'b100 & in[15:13] !== 3'b011 & in[15:13] !== 3'b001 & in[15:13] !== 3'b010) ? in[4:3] : 2'b00; //assign in[4:3] to shift
  Mux3 #(3) multiplex3(in[2:0], in[7:5], in[10:8], nsel, readwrite);   
  //multiplexer that chooses between Rd, Rn, and Rm based on nsel
  assign readnum = readwrite; //assign readnum and writenum with readwrite
  assign writenum = readwrite;
  assign opcode = in[15:13]; //assign in[15:13] to output opcode
  assign op = in[12:11]; //assign in[12:11] to output op
endmodule

module Mux3(a2,a1,a0,s,b);
  //multiplexer for three values
  parameter k = 1;
  input [k-1:0] a0, a1, a2;
  input [2:0] s;
  output [k-1:0] b;
 
  assign b = ({k{s[0]}} & a0) | ({k{s[1]}} & a1) | ({k{s[2]}} & a2);

endmodule

