module datapath(clk,readnum, vsel, loada, loadb, shift, 
asel, bsel, ALUop, loadc, loads, writenum, write, PC, mdata, sximm8, sximm5, datapath_out, Z, N, V);
  input [1:0] shift, ALUop;
  input [2:0] readnum, writenum;
  input [3:0] vsel;
  input loada, loadb, asel, bsel, loadc, loads, write, clk;
  input [8:0] PC;
  input [15:0] mdata, sximm8, sximm5;
  output [15:0] datapath_out;
  wire [2:0] status_out;
  wire [2:0] status;
  output Z,N,V;

  wire [15:0] data_in, data_out, Ain, Bin, out, sout, in, aout;


  Mux4 #(16) mux1(mdata, sximm8, {7'b0, PC+1'b1}, datapath_out, vsel, data_in); 
  //chooses between mdata, sximm8, 7'b0, PC}, and datapath_out depending on the value of vsel
  regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);
  //instantiates the regfile module
  vDFFL regA(clk, loada, data_out, aout);
  //loaded register for the A value
  vDFFL regB(clk, loadb, data_out, in);
  //loaded register for the B value
  Muxb2 #(16) muxA(16'b0, aout, asel, Ain);
  //multiplexer that chooses A value or 0
  shifter shifted(in, shift, sout);
  //instantiates the shifter module and shifts B value
  Muxb2 #(16) muxB(sximm5, sout, bsel, Bin);
  //multiplexer that chooses between sximm5 and the shifter output
  ALU math(Ain, Bin, ALUop, out, status);
  //instantiates the ALU module and does math on A and B
  vDFFL regC(clk, loadc, out, datapath_out);
  //loaded register that stores the output of the ALU
  vDFFLstatus regstatus(clk, loads, status, status_out);
  //loaded register that stores if the value of ALU is 0, signed, or overflowed

  assign {Z,N,V} = status_out; //assigns each bit of status to Z,N, and V
endmodule


module Mux4(a3,a2,a1,a0,s,b); //multiplexer for 4 values
  parameter k = 1;
  input [k-1:0] a0, a1, a2, a3;
  input [3:0] s;
  output [k-1:0] b;
 
  assign b = ({k{s[0]}} & a0) | ({k{s[1]}} & a1) | ({k{s[2]}} & a2) | ({k{s[3]}} & a3);
endmodule

module Muxb4(a3,a2,a1,a0,sb,b); //multiplexer that decodes binary to onehot for 4 inputs
  parameter k = 1;
  input [k-1:0] a0, a1, a2, a3;
  input [2:0] sb;
  output [k-1:0] b;
  wire [3:0] s;

  Dec #(2,4) e(sb,s);
  Mux4 #(16) m(a3,a2,a1,a0,s,b);
endmodule

module Mux2(a1,a0,s,b); //multiplexer for 2 values
  parameter k = 1;
  input [k-1:0] a0, a1;
  input [1:0] s;
  output [k-1:0] b;
 
  assign b = ({k{s[0]}} & a0) | ({k{s[1]}} & a1);
endmodule

module Muxb2(a1,a0,sb,b); //multiplexer that decodes binary to onehot for 2 inputs
  parameter k = 1;
  input [k-1:0] a0, a1;
  input sb;
  output [k-1:0] b;
  wire [1:0] s;

  Dec2 #(1,2) f(sb,s);
  Mux2 #(16) m(a1,a0,s,b);
endmodule

module vDFFLstatus(clk, load, in, out); //module for the status 3-bit loaded register
input clk;
input [2:0] in;
output [2:0] out;
wire [2:0] D; 
input load;

vDFF #(3) register(clk, D, out);
   assign D = load ?  in : out;
endmodule

module Dec2(a,b); //decoder
   parameter n = 2;
   parameter m = 4;

   input [n-1:0] a;
   output [m-1:0] b;

   wire [m-1:0] b = 1 << a;
endmodule