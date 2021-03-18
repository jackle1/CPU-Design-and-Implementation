module cpu(clk,reset,load,read_data,out,N,V,Z, mem_cmd, mem_addr, light);
  input clk, reset, load;
  input [15:0] read_data;
  output [15:0] out;
  output N, V, Z, light;
  output [1:0] mem_cmd;
  output [8:0] mem_addr;

  wire [15:0] irout, sximm5, sximm8;
  wire [2:0] nsel, readnum, writenum, opcode, cond, branch;
  wire [1:0] ALUop, shift, op;
  wire [3:0] vsel;
  wire loada, loadb, asel, bsel, loadc, loads, write, reset_pc, load_pc, load_da, load_ir, addr_sel;
  wire [8:0] next_pc, pc_in, da_out, new_pc, int_pc, pc_rd, sxim8, PC;


  instruction_register IR(clk, read_data, load_ir, irout);
  instruction_decoder ID(irout, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, opcode, op, cond, sxim8);
  datapath DP(clk, readnum, vsel, loada, loadb, shift, 
  asel, bsel, ALUop, loadc, loads, writenum, write, PC, read_data, sximm8, sximm5, out, Z, N, V);
  FSM FSM(clk, reset, opcode, op, nsel, loada, loadb, asel, bsel, vsel, loadc, loads, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd, cond, branch, Z, N, V, light);
  vDFFLPC programCounter(clk, load_pc, new_pc, PC);
  vDFFLDA dataAddress(clk, load_addr, out[8:0], da_out);
  Mux3 #(9) muxPC((int_pc + sxim8), pc_rd, next_pc, branch, new_pc);

   assign pc_rd = out[8:0];
   assign int_pc = next_pc == 9'b0 ? 9'd1 : pc_in;
   assign pc_in = PC + 1;
   assign next_pc = reset_pc ? 9'b0 : pc_in;


   assign mem_addr = addr_sel ? PC : da_out;

endmodule




module vDFFLPC(clk, load, in, out); //module for the 9-bit PC loaded register
   input clk;
   input [8:0] in;
   output [8:0] out;
   wire [8:0] D; 
   input load;

   vDFF #(9) register(clk, D, out);
      assign D = load ?  in : out;
endmodule

module vDFFLDA(clk, load, in, out); //module for the 9-bit DA loaded register
   input clk;
   input [8:0] in;
   output [8:0] out;
   wire [8:0] D; 
   input load;

   vDFF #(9) register(clk, D, out);
      assign D = load ?  in : out;
endmodule

