module ALU(Ain,Bin,ALUop,out,status);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output reg [15:0] out;
  output reg [2:0] status;
  wire [15:0] s;
  wire ovf;

  AddSub #(16) U0 (Ain,Bin,1'b1,s,ovf);


  always @* begin //cases for each mathematical operation depending on ALUop
  case (ALUop)
  2'b00: {out,status} = {(Ain + Bin),3'bxxx} ; // Add
  2'b01: {out,status} = {s,(s == 16'b0000000000000000), s[15], ovf}; // Subtract
  2'b10: {out,status} = {(Ain & Bin),3'bxxx} ; // And
  2'b11: {out,status} = {~(Bin),3'bxxx} ; // Negate B
  default: out = 16'bxxxxxxxxxxxxxxxx ;
  endcase

end
endmodule



// multi-bit adder - behavioral
module Adder1(a,b,cin,cout,s) ;
  parameter n = 8 ;
  input [n-1:0] a, b ;
  input cin ;
  output [n-1:0] s ;
  output cout ;
  wire [n-1:0] s;
  wire cout ;

  assign {cout, s} = a + b + cin ;
endmodule 


// add a+b or subtract a-b, check for overflow
module AddSub(a,b,sub,s,ovf) ;
  parameter n = 8 ;
  input [n-1:0] a, b ;
  input sub ;           // subtract if sub=1, otherwise add
  output [n-1:0] s ;
  output ovf ;          // 1 if overflow
  wire c1, c2 ;         // carry out of last two bits
  wire ovf = c1 ^ c2 ;  // overflow if signs don't match

  // add non sign bits
  Adder1 #(n-1) ai(a[n-2:0],b[n-2:0]^{n-1{sub}},sub,c1,s[n-2:0]) ;
  // add sign bits
  Adder1 #(1)   as(a[n-1],b[n-1]^sub,c1,c2,s[n-1]) ;
endmodule


