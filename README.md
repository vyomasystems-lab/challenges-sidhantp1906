# challenges-sidhantp1906
## RISC-V RV32I Design Verification
### Table of Content
- [Abstract](####Abstract)
- [Verification Environment](####Verification%20Environment)
- [Verification Strategy](####Verification%20Stractegy)
- [Test Scenario](####Test%20Scenario)
- [Bugs Found](####Bugs%20Found)
- [Debug Information](####Debug%20Information)
- [Verification Strategy](####Verification%20Stractegy)
- [Is The Verification Complete?](####Is%20The%20Verification%20Complete?)
#### Abstract
This Document presents the verification of RISCV-RV32I which is 32-bit processor core implemented using 5-stage pipelining. Five stage pipelining enables faster execution of instructions using pre-fetch and branching operation. It has ROM inside which stores the instructions which has to be executed sequentially in a pipeline architecture. This design is implemented using Verilog-2003 and simulated using Icarus-Verilog and GTK-Wave. This design will be verified using python based
verification methodology CoCoTb.

#### Verification Environment
The verification environment is setup using [Vyoma's UpTickPro](https://vyomasystems.com) provided for the hackathon.

<img src="https://user-images.githubusercontent.com/60102705/180488717-b51b86b1-741e-4da8-9350-320dd270bfcf.png" style=" width:640px ; height:360px "  >

The [CoCoTb](https://www.cocotb.org/) based Python test is developed as explained. The test_RV32I drives inputs to the Design Under Test  (RV32I) which takes in 2 clock aa inputs *clk1* and *clk2* and gives 32-bit output *mem_wb_aluout*.

The values are assigned to the input port using 
```
clock = Clock(dut.clk1, 10, units="us")  # Create a 10us period clock on port clk1
    cocotb.start_soon(clock.start()) 

    await Timer(5,units = 'us') # To phase shift clk2 by 180 degree

    clock = Clock(dut.clk2, 10, units="us")  # Create a 10us period clock on port clk2 
    cocotb.start_soon(clock.start()) 

    await Timer(30,units = 'us') # Wait for the output to propogate
    await RisingEdge(dut.clk1) # Wait for the next positive edge of clock1
```

The assert statement is used for comparing the adder's outut to the expected value.

The following error is seen:
```
assert dut.mem_wb_aluout.value == 4, "Test Failed :Got {out} expected 4".format(out=int(dut.mem_wb_aluout.value))
```

#### Test Scenario
##### Test Case 1
- PC Value is 0x00000000.
- Memory location fetched is 0x00000000 which has 0x00308133 i.e., add r2,r1,r3.
- Expected output mem_wb_aluout is 4.
- Observed output mem_wb_aluout is 2.        
                                                                                                                           
This shows that observed output does not matches with expected output hence possible **bug** found.
                                                                                                                                                                      
- PC Value is 0x00000004.
- Memory location fetched is 0x00000004 which has 0x40308133 i.e., sub r2,r1,r3 .
- Expected output mem_wb_aluout is -2.
- Observed output mem_wb_aluout is -2.    
                                                                                                                             
This shows that observed output matches with expected output hence **No bug** found
                                                                                                                                                                       
- PC Value is 0x00000008.
- Memory location fetched is 0x00000008 which has 0x023100b3 i.e., mul r1,r2,r3 .
- Expected output mem_wb_aluout is 12. ```As R2 becomes 4 after first addition instruction```
- Observed output mem_wb_aluout is 6. ```As R2 becomes 2 after first buggy addition instruction```                                                                         

This shows that observed output does not matches with expected output hence possible **bug** found                                                                                                                                                                      
##### Test Case 2
- PC Value is 0x00000000.
- Memory location fetched is 0x00000000 which has 0x00308133 i.e., add r2,r1,r3.
- Expected output mem_wb_aluout is 4.
- Observed output mem_wb_aluout is 0.                                                                                                                                   
- This shows that observed output does not matches with expected output hence possible **bug** found.
##### Test Case3
- PC Value is 0x00000000.
- Memory location fetched is 0x00000000 which has 0x00308133 i.e., add r2,r1,r3.
- Expected output mem_wb_aluout is 4.
- Observed output mem_wb_aluout is 4.        
                                                                                                                           
This shows that observed output matches with expected output hence **No bug** found.
                                                                                                                                                                      
- PC Value is 0x00000000.
- Memory location fetched is 0x00000000 which has 0x00308133 i.e., add r2,r1,r3.
- Expected output mem_wb_aluout is -2.
- Observed output mem_wb_aluout is 4.    
                                                                                                                             
This shows that observed output does not matches with expected output hence **bug** found
                                                                                                                                                                       
- PC Value is 0x00000000.
- Memory location fetched is 0x00000000 which has 0x00308133 i.e., add r2,r1,r3.
- Expected output mem_wb_aluout is 12. ```As R2 becomes 4 after first addition instruction```
- Observed output mem_wb_aluout is 4.                                                                       

This shows that observed output does not matches with expected output hence possible **bug** found          
#### Bugs Found
##### Test Case 1
```
7'b0000000:begin
case(opcode_2)
ADD: ex_mem_aluout <= #2 id_ex_a ^ id_ex_b; // Bug ** This should be Additon operation but it does XOR operation ********
AND: ex_mem_aluout <= #2 id_ex_a & id_ex_b;
OR : ex_mem_aluout <= #2 id_ex_a | id_ex_b;
SLT: ex_mem_aluout <= #2 id_ex_a < id_ex_b;
default: ex_mem_aluout <= #2 32'h00000000;
endcase
end
```
Need to replace ```^``` operator with ```+``` operator.

##### Test Case 3
```
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
		HALTED = 1; //============> Bug ** Halted is made intentionally high which makes processor to halt until idle condition********
		pc = 0;
		TAKEN_BRANCH = 0;
		end
```
- Halt is raised high initialy due to interrupts which causes exception instruction and leds to processor to hold mode until idle condition arrives again.              - To make processor to start replace ```HALTED = 1``` with ```HALTED = 0```. 
#### Debug Information
#### Verification Stractegy
#### Is The Verification Complete?
