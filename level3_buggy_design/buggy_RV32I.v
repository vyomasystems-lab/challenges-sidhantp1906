module buggy_RV32I(
    input clk1,
    input clk2,
	 output reg [31:0]mem_wb_aluout
	 //output reg HALTED,TAKEN_BRANCH,
	 //output reg RR_ALU,RM_ALU,LOAD,STORE,BRANCH,HALT
    );


reg HALTED,TAKEN_BRANCH;
reg RR_ALU,RM_ALU,LOAD,STORE,BRANCH,HALT;
reg [31:0] pc,if_id_ir,if_id_npc;
reg [31:0] id_ex_ir,id_ex_npc,id_ex_a,id_ex_b,id_ex_imm;
reg [2:0] id_ex_type,ex_mem_type,mem_wb_type;
reg [31:0] ex_mem_ir,ex_mem_aluout,ex_mem_b,ex_mem_cond;
reg [31:0] mem_wb_ir/*,mem_wb_aluout*/,mem_wb_lmd;

reg [31:0]Reg[0:31];
reg [31:0]mem[0:1023];

reg [2:0]funct3_1;
reg [6:0]funct7_2,opcode,opcode_1,opcode_2;
reg [4:0]rd_3,rs1_1,rs2_1; 

parameter ADD=7'b0110011, SUB=7'b0110011, AND=7'b0110011, OR=7'b0110011, SLT=7'b0110011, MUL=7'b0110011, HLT=7'b0111111, LW=7'b0000011, SW=7'b0100011, ADDI=7'b0010011,SLTI=7'b0010011, BNE=7'b1100011, BEQ=7'b1100011;

    initial
		begin :map
		integer i;
		for(i=0;i<32;i=i+1)
		Reg[i] = i;
		
	    mem[0] = 32'h00308133; // add r2,r1,r3
      mem[1] = 32'h0073e3b3; // or r7,r7,r7 dummy instr to avoid data hazard 
      mem[2] = 32'h40308133; // sub r2,r1,r3 
      mem[3] = 32'h0073e3b3; // or r7,r7,r7 dummy instr to avoid data hazard 
      mem[4] = 32'h40308133; // sub r2,r1,r3
      mem[5] = 32'h00528213; // addi r4 r5,#5
      mem[6] = 32'h0083a303; // lw r6,8(r7)
      mem[7] = 32'h0073e3b3; // or r7,r7,r7 dummy instr to avoid data hazard
      mem[8] = 32'h023100b3; // mul r1,r2,r3
      mem[9] = 32'h0073e3b3; // or r7,r7,r7 dummy instr to avoid data hazard 
      mem[10] = 32'h40308133; // sub r2,r1,r3
      mem[11] = 32'h00528213; // addi r4 r5,#5
      mem[12] = 32'h0083a303; // lw r6,8(r7)
      mem[13] = 32'h0073e3b3; // or r7,r7,r7 dummy instr to avoid data hazard
      mem[14] = 32'h023100b3; // mul r1,r2,r3
      mem[15] = 32'h0073e3b3; // or r7,r7,r7 dummy instr to avoid data hazard
      mem[16] = 32'h0083a303; // lw r6,8(r7)	
		HALTED = 1; // Bug ** Halted is made intentionally high which makes processor to halt until idle condition********
		pc = 0;
		TAKEN_BRANCH = 0;
		end


always @(posedge clk1)   //if stage
begin : IF
if(HALTED == 0)
begin
if(((opcode == BEQ)&&(ex_mem_cond == 1'b1)) || ((opcode == BNE)&&(ex_mem_cond == 1'b0)))
begin
if_id_ir <= #2 mem[ex_mem_aluout];
//TAKEN_BRANCH <= #2 1'b1;
if_id_npc <= #2 ex_mem_aluout + 4;
pc <= #2 ex_mem_aluout +4;
end
else
begin
if_id_ir <= #2 mem[pc];
if_id_npc <= #2 pc /*+ 4*/; // Bug ** PC Does not increments by 4Bytes address results in single instruction execution***** 
pc <= #2 pc /*+ 4*/; // Bug ** PC Does not increments by 4Bytes address results in single instruction execution*****
end
opcode = if_id_ir[6:0];
end
end

always @(posedge clk2)  // id stage
begin : ID
if(HALTED == 0)
begin 
if(rs1_1 == 5'b00000)
id_ex_a <= 0;
else
id_ex_a <= #2 Reg[rs1_1];

if(rs2_1 == 5'b00000)
id_ex_b <= 0;
else
id_ex_b <= #2 Reg[rs2_1];

id_ex_npc <= #2 if_id_npc;
id_ex_ir <= #2 if_id_ir;
id_ex_imm <= #2 {{20{if_id_ir[31]}},{if_id_ir[31:20]}};

opcode_1 <= id_ex_ir[6:0];
funct3_1 <= id_ex_ir[14:12];
rs1_1 <= id_ex_ir[19:15];
rs2_1 <= id_ex_ir[24:20];

case(funct3_1)
3'b000:begin
case(opcode_1)
ADD,SUB,MUL: id_ex_type <= #2 RR_ALU;
ADDI : id_ex_type <= #2 RM_ALU;
BEQ: id_ex_type <= #2 BRANCH;
endcase
end

3'b110:begin
case(opcode_1)
OR:id_ex_type <= #2 RR_ALU;
endcase
end

3'b111:begin
case(opcode_1)
AND:id_ex_type <= #2 RR_ALU;
endcase
end

3'b010:begin
case(opcode_1)
SLT : id_ex_type <= #2 RR_ALU;
SLTI : id_ex_type <= #2 RM_ALU;
LW : id_ex_type <= #2 LOAD;
SW : id_ex_type <= #2 STORE;
endcase
end

3'b001:begin
case(opcode_1)
BNE: begin
	TAKEN_BRANCH <= #2 1'b1;
	id_ex_type <= #2 BRANCH;
end
HLT : id_ex_type <= #2 HALT;
endcase
end

default :begin
	TAKEN_BRANCH <= #2 1'b0;
	id_ex_type <= #2 HALT;
 end
endcase
end
end

always @(posedge clk1) //ex stage
begin : EX
if(HALTED == 0)
begin 
ex_mem_type <= #2 id_ex_type;
ex_mem_ir <= #2 id_ex_ir;
//TAKEN_BRANCH <= #2 1'b0;
opcode_2 <= ex_mem_ir[6:0];
funct7_2 <= ex_mem_ir[31:25];

case(id_ex_type)
RR_ALU: begin

case(funct7_2)

7'b0000000:begin
case(opcode_2)
ADD: ex_mem_aluout <= #2 id_ex_a ^ id_ex_b; // Bug ** This Additon operation but now it does XOR operation ********
AND: ex_mem_aluout <= #2 id_ex_a & id_ex_b;
OR : ex_mem_aluout <= #2 id_ex_a | id_ex_b;
SLT: ex_mem_aluout <= #2 id_ex_a < id_ex_b;
default: ex_mem_aluout <= #2 32'h00000000;
endcase
end
 
 7'b0100000:begin
 case(opcode_2)
 SUB: ex_mem_aluout <= #2 id_ex_a - id_ex_b;
 default: ex_mem_aluout <= #2 32'h00000000;
endcase
end

  7'b0000001:begin
 case(opcode_2)
 MUL: ex_mem_aluout <= #2 id_ex_a * id_ex_b;
 default: ex_mem_aluout <= #2 32'h00000000;
endcase
end
default: ex_mem_aluout <= #2 32'h00000000;
endcase
end

RM_ALU: begin
case(opcode_2)
ADDI: ex_mem_aluout <= #2 id_ex_a + id_ex_imm;
SLTI: ex_mem_aluout <= #2 id_ex_a < id_ex_imm;
default: ex_mem_aluout <= #2 32'h00000000;
endcase
end

LOAD,STORE: 
begin
ex_mem_aluout <= #2 id_ex_a + id_ex_imm;
ex_mem_b <= #2 id_ex_b;
end

BRANCH: begin
ex_mem_aluout <= #2 id_ex_npc + id_ex_imm;
ex_mem_cond <= #2 (id_ex_a == 0);
end
endcase
end
end

always @(posedge clk2) //mem stage
begin : MEM
if(HALTED == 0)
begin 
mem_wb_type = ex_mem_type;
mem_wb_ir <= #2 ex_mem_ir;

case(ex_mem_type)
RR_ALU,RM_ALU: 
mem_wb_aluout <= #2 ex_mem_aluout;

LOAD: mem_wb_lmd <= #2 mem[mem_wb_aluout];

STORE:begin
if(TAKEN_BRANCH == 0)
mem[ex_mem_aluout] <= #2 ex_mem_b;
end
endcase
end
end

always @(posedge clk1) //wb stage
begin : WB
rd_3 <= mem_wb_ir[11:7];
if(TAKEN_BRANCH == 0)
case (mem_wb_type)
RR_ALU: Reg[rd_3] <= #2 mem_wb_aluout;
RM_ALU: Reg[rd_3] <= #2 mem_wb_aluout;
LOAD: Reg[rd_3] <= #2 mem_wb_lmd;
HALT: HALTED <= #2 1'b1;
endcase
end

endmodule