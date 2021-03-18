module instruction_register(clk, in, load, out);
  input [15:0] in;
  input load, clk;
  output [15:0] out;

  vDFFLir irloaded(clk, load, in, out); //instantiating the loaded register
endmodule

module vDFFLir (clk, load, in, out); //code for a loaded register
input clk;
input [15:0] in;
output [15:0] out;
wire [15:0] D; 
input load;

vDFF #(16) register(clk, D, out);
assign D = load ?  in : out;
endmodule
