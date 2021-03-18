module regfile(data_in,writenum,write,readnum,clk,data_out);
input [15:0] data_in;
input [2:0] writenum, readnum;
input write, clk;
output [15:0] data_out;
wire [7:0] readOut, writeOut, load;
wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

Dec #(3,8) topD(writenum,writeOut); //instantiates a 3 to 8 decoder to determine which register to write to 
Dec #(3,8) bottomD(readnum,readOut); //instantiates a 3 to 8 deccoder to determine which register to read from

//determine which register to update
assign load = {(writeOut[7] & write), (writeOut[6] & write), (writeOut[5] & write), (writeOut[4] & write),
               (writeOut[3] & write), (writeOut[2] & write), (writeOut[1] & write), (writeOut[0] & write)};

//instantiate register R0
vDFFL Rout0(clk, load[0], data_in, R0);
//instantiate register R1
vDFFL Rout1(clk, load[1], data_in, R1);
//instantiate register R2
vDFFL Rout2(clk, load[2], data_in, R2);
//instantiate register R3
vDFFL Rout3(clk, load[3], data_in, R3);
//instantiate register R4
vDFFL Rout4(clk, load[4], data_in, R4);
//instantiate register R5
vDFFL Rout5(clk, load[5], data_in, R5);
//instantiate register R6
vDFFL Rout6(clk, load[6], data_in, R6);
//instantiate register R7
vDFFL Rout7(clk, load[7], data_in, R7);

//instantiate multiplexer to output value from selected register
Muxb8 #(16)return(R7, R6, R5, R4, R3, R2, R1, R0, readnum, data_out);
 
endmodule

//multibit decoder
module Dec(a,b);
   parameter n = 2;
   parameter m = 4;

   input [n-1:0] a;
   output [m-1:0] b;

   wire [m-1:0] b = 1 << a;
endmodule

//loaded register
module vDFFL(clk, load, in, out);
input clk;
input [15:0] in;
output [15:0] out;
wire [15:0] D; 
input load;

vDFF #(16) register(clk, D, out);

   assign D = load ?  in : out;

endmodule

//8-input multiplexer
module Mux8(a7,a6,a5,a4,a3,a2,a1,a0,s,b);

  parameter k = 1;
  input [k-1:0] a0, a1, a2, a3, a4, a5, a6, a7;
  input [7:0] s;
  output [k-1:0] b;
 
  assign b = ({k{s[0]}} & a0) | ({k{s[1]}} & a1) | ({k{s[2]}} & a2) | ({k{s[3]}} & a3) |
              ({k{s[4]}} & a4) | ({k{s[5]}} & a5) | ({k{s[6]}} & a6) | ({k{s[7]}} & a7) ;

endmodule

//8-input binary select multiplexer
module Muxb8(a7,a6,a5,a4,a3,a2,a1,a0,sb,b);
  parameter k = 1;
  input [k-1:0] a0, a1, a2, a3, a4, a5, a6, a7;
  input [2:0] sb;
  output [k-1:0] b;
  wire [7:0] s;

  Dec#(3,8) e(sb,s);
  Mux8 #(16) m(a7,a6,a5,a4,a3,a2,a1,a0,s,b);

endmodule

