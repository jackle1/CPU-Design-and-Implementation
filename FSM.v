`define RST 5'b00000
`define IF1 5'b00001
`define IF2 5'b00010
`define UpdatePC 5'b00011
`define Decode 5'b00100
`define GetA 5'b00101
`define GetB 5'b00111
`define ADDANDMVN 5'b01000 
`define CMP 5'b01001
`define WriteReg 5'b01010
`define WriteImm 5'b01011
`define GetC 5'b01100
`define LDRSTR 5'b01101
`define GetRd 5'b01110
`define GetData 5'b01111
`define WriteMem 5'b10000
`define SelectAddr 5'b10001
`define WriteRegFromMem 5'b10010
`define Halt 5'b10011
`define LoadC 5'b10100
`define BL 5'b10101
`define GetR7 5'b10110
`define Buffer 5'b10111
`define LoadCandWrite 5'b11000
`define BLX 5'b11001
`define MREAD 2'b11
`define MNONE 2'b00
`define MWRITE 2'b10

module FSM(clk, reset, opcode, op, nsel, loada, loadb, asel, bsel, vsel, loadc, loads, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd, cond, branch, Z, N, V, light);
   input reset, clk, Z, N, V;
   input [2:0] opcode, cond;
   input [1:0] op;
   output reg loada, loadb, loadc, asel, bsel, loads, write, addr_sel, load_pc, reset_pc, load_ir, load_addr, light;
   output reg [1:0] mem_cmd; 
   output reg [2:0] nsel, branch;
   output reg [3:0] vsel;

   reg [4:0] n_state, present_state;
   wire [4:0] r_state; 

   always @(posedge clk)
       present_state <= r_state;

   assign r_state = reset ? `RST : n_state;


    always @(*) begin

      if (opcode == 3'b001 & op == 2'b00 & cond == 3'b000)
         branch = 3'b100;
      else if (opcode == 3'b001 & op == 2'b00 & cond == 3'b001 & Z== 1'b1)
         branch = 3'b100;
      else if (opcode == 3'b001 & op == 2'b00 & cond == 3'b010 & Z == 1'b0) 
         branch = 3'b100;
      else if (opcode == 3'b001 & op == 2'b00 & cond == 3'b011 & N !== V)
         branch = 3'b100;
      else if (opcode == 3'b001 & op == 2'b00 & cond == 3'b001 & (N !== V | Z == 1'b1))
         branch = 3'b100;
      else if (opcode == 3'b010 & op == 2'b11 & cond == 3'b111)
         branch = 3'b100;
      else if (opcode == 3'b010 & (op == 2'b00 | op == 2'b10) & (cond == 3'b000 | cond == 3'b111))
         branch = 3'b010;    
      else
         branch = 3'b001;
      

      if (present_state == `Halt)
         light = 1'b1;
      else 
         light = 1'b0;

       casex({present_state, reset, opcode, op})
          {`RST,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`IF1, 19'b0_0_0_0_xxx_xxxx_0_0_0_1_1_0_0_0,`MNONE};
          {`IF1,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`IF2, 19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_1_0,`MREAD};
          {`IF2,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`Buffer,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_1_1_0,`MREAD};
          {`Buffer,6'bx01010}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`BLX,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`Buffer,6'bx01011}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`BL,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`Buffer,6'bx01000}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetR7,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`BLX,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetR7,19'b0_0_0_0_001_0010_0_0_0_0_0_0_0_0,`MNONE};
          {`GetR7,6'bx01000}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetC,19'b0_1_0_0_010_0010_0_0_0_0_0_0_0_0,`MNONE};
          {`GetC,6'bx01000}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`UpdatePC,19'b0_0_1_0_xxx_xxxx_1_0_0_0_0_0_0_0,`MNONE};
          {`Buffer,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`UpdatePC, 19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`BL,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`UpdatePC,19'b0_0_0_0_001_0010_0_0_1_0_0_0_0_0,`MNONE};
          {`GetR7,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`LoadCandWrite,19'b0_1_0_0_010_0010_0_0_0_0_0_0_0_0,`MNONE};
          {`LoadCandWrite,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`UpdatePC,19'b0_0_1_0_001_0010_1_0_1_0_0_0_0_0,`MNONE};
          {`UpdatePC,6'bx010xx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`IF1,19'b0_0_0_0_xxx_xxxx_0_0_0_0_1_0_0_0,`MNONE};
          {`UpdatePC,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`Decode, 19'b0_0_0_0_xxx_xxxx_0_0_0_0_1_0_0_0,`MNONE};
          {`Decode,6'bx11010}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`WriteImm, 19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE}; 
          {`WriteImm,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`IF1, 19'b0_0_0_0_001_0100_0_0_1_0_0_0_0_0,`MNONE};
          {`Decode,6'bx111xx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`Halt,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`Halt,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`Halt,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`Decode,6'bx01100}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetA,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`Decode,6'bx10000}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetA,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`Decode,6'bx0101x}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`IF1,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`Decode,6'bx001xx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`IF1,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`Decode,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetB,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`GetB,6'bx11000}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetC,19'b0_1_0_0_100_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`GetC,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`WriteReg,19'b0_0_1_0_xxx_xxxx_1_0_0_0_0_0_0_0,`MNONE};
          {`GetB,6'bx10111}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetC,19'b0_1_0_0_100_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`GetB,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetA,19'b0_1_0_0_100_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`GetA,6'bxxxx01}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`CMP,19'b1_0_0_0_001_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`GetA,6'bx101xx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`ADDANDMVN,19'b1_0_0_0_001_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`GetA,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`LDRSTR,19'b1_0_0_0_001_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`LDRSTR,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetData,19'b0_0_1_0_xxx_xxxx_0_1_0_0_0_0_0_0,`MNONE};
          {`GetData,6'bx100xx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`GetRd,19'b0_0_0_0_xxx_xxxx_0_1_0_0_0_0_0_1,`MNONE};
          {`GetData,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`SelectAddr,19'b0_0_0_0_xxx_xxxx_0_1_0_0_0_0_0_1,`MNONE};
          {`GetRd,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`LoadC,19'b0_1_0_0_010_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`LoadC,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`SelectAddr,19'b0_0_1_0_xxx_xxxx_1_0_0_0_0_0_0_0,`MNONE};
	  {`SelectAddr,6'bx100xx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`WriteMem,19'b0_0_0_0_xxx_xxxx_0_1_0_0_0_0_0_0,`MNONE};
          {`WriteMem,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`IF1,19'b0_0_0_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MWRITE};
          {`SelectAddr,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`WriteRegFromMem,19'b0_0_0_0_xxx_xxxx_0_1_0_0_0_0_0_0,`MNONE};
          {`WriteRegFromMem,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`IF1,19'b0_0_0_0_010_1000_0_1_1_0_0_0_0_0,`MREAD};
          {`CMP,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`IF1, 19'b0_0_0_1_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`ADDANDMVN,6'bxxxxxx}: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`WriteReg, 19'b0_0_1_0_xxx_xxxx_0_0_0_0_0_0_0_0,`MNONE};
          {`WriteReg,6'bxxxxxx} : {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {`IF1, 19'b0_0_0_0_010_0001_0_0_1_0_0_0_0_0,`MNONE};
          default: {n_state, loada, loadb, loadc, loads, nsel, vsel, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr, mem_cmd} = {26'bxxxxx_x_x_x_x_xxx_xxxx_x_x_x_x_x_x_x_x_xx}; 
        endcase
     end
endmodule

