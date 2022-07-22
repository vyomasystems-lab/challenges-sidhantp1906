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

This shows that observed output does not matches with expected output hence possible **bug** found.
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
ADD: ex_mem_aluout <= #2 id_ex_a ^ id_ex_b; //============>Bug ** This should be Additon operation but it does XOR operation ********
AND: ex_mem_aluout <= #2 id_ex_a & id_ex_b;
OR : ex_mem_aluout <= #2 id_ex_a | id_ex_b;
SLT: ex_mem_aluout <= #2 id_ex_a < id_ex_b;
default: ex_mem_aluout <= #2 32'h00000000;
endcase
end
```
Need to replace ```^``` operator with ```+``` operator.

##### Test Case 2
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
##### Test Case 3
```
begin
if_id_ir <= #2 mem[pc];
if_id_npc <= #2 pc; //============> Bug ** PC Does not increments by 4Bytes address results in single instruction execution***** 
pc <= #2 pc; //============> Bug ** PC Does not increments by 4Bytes address results in single instruction execution*****
end
```
This is pre-fetch condition where instructions are fetched from code memory every clock cycle to improve speed but here due to **bug** that is pc is not increamented it leads to single instruction execution that is '''add  r2,r1,r3'''.
To avoid this replace with below code.

```
begin
if_id_ir <= #2 mem[pc];
if_id_npc <= #2 pc + 4;
pc <= #2 pc + 4; 
end
```

#### Debug Information
Updating the design and re-running the test makes the test pass.

<img src="https://user-images.githubusercontent.com/60102705/180498543-155cc545-d287-4503-859c-0afcbf812b96.png" style=" width:640px ; height:360px "  >

The updated design is checked in as RV32I.v
#### Verification Stractegy
- RISC-V RV32I Design which is implemented by [Sidhant Priyadarshi](https://github.com/sidhantp1906/RV32I) (i.e.,Me) works for very few of the instructions like add, sub, div, load, store, etc needs to be verified for its working. So, forced the instructions in code memory for 17 locations and initialized the pc to 0x0 to start the fetch from 0x0th location and registers values with values of index ```i.e., R0=0,R1=1,..r31=31``` which first executes ```add r2,r1,r3``` instruction which adds content of *r1* and *r3* ```r1+r3``` and then stores the data back to register *r2*, To execute and write back the data to destination register *r3* it takes 5 clock cycles but this design has two clock with 180 Degree of phase shift hence data is written back to *r3* at 4th clock cycle of *clk1*. Then the second instruction is fetched at second cycle of *clk1* and executed at 5th edge of *clk1* which is 
```sub r1,r2,r3``` which writes back to *r1* the value ```r2-r3``` that is *-2(0xfffffffe 2's complement)* but here the value of *r2* does not changes due to 
```add r2,r1,r3``` because when second instruction is in execution stage the first instruction was in memory stage. Then the third instruction is executed which is 
```mul r1,r2,r3``` which is fetched at third cycle of *clk1* and written back at 6th edge of *clk1* and value stored in *r1* will be *12* because when it is in execution stage then first instruction is in write back stage where the *r2* value is updated with *r1+r3* hence multiplicatoin of ```r2*r3``` gives *12*.

- To verify the above functionality, Forced the initial values as discussed above and then generated *clk1 and clk2* with phase difference of 180 Degree and 10us period and after *30us* of delay at *positive edge of clk1* assertion is made to check whether *mem_wb_aluout* equals to *4* or not. If it is not equal it will generate thr failure report with correct value displaying.
- Again need to check the second instruction execution after *5us* if not equals to expected value then gives assertion error.
- After *5us* last instruction is asserted.
- Below image represents the failure of first test case. This is *buggy* assertion where i need to check the correctness of *ADD* operation and *WriteBack* stage whether design is able to perform all the five pipeline stage ```fetch=>decode=>execute=>memory=>writeback``` or not so if add instruction is *corrupted* and stores the *buggy* value in *r2* then is should affect ```mul r1,r2,r3``` also. As seen below it corrupts the design as expected. 

<img src="https://user-images.githubusercontent.com/60102705/180502265-f643cc3b-35ac-4bea-aa58-2da7716b2a7c.png" style=" width:540px ; height:360px "  >

- Below image represents the failure of second test case. This insertion checks whether if *HALT* is made high then design stops working or not.

<img src="https://user-images.githubusercontent.com/60102705/180504113-312695df-2f42-4012-b8e0-1baceecebd3f.png" style=" width:540px ; height:360px "  >

- Below image represents the failure of third test case. This checks the pre-fetch working of design that is when there is stuck at fault in *PC(Program Counter)* then it is stucked at present location or not so here *PC* value is not incremented due to *buggy design* then it is stucked at location *0x00000000* itself and perform only first instruction and keeps the *mem_wb_aluout* value constant to *4*.

<img src="https://user-images.githubusercontent.com/60102705/180504853-fefa0f6d-4608-44ac-97c7-e67c9f66a5a5.png" style=" width:540px ; height:360px "  >

#### Is The Verification Complete?

```YES``` , As [Debug Information](https://github.com/vyomasystems-lab/challenges-sidhantp1906/blob/master/README.md#debug-information) shows the correctness of design after **BUGS** identified and corrected which were very important to check the functionality of **RISC-V RV32I**. Thanks to 
[Vyoma's UpTickPro](https://vyomasystems.com) for providing such an *interesting* environment to perform fucntional verification of design based on python library called [CoCoTb](https://www.cocotb.org/) and also special thanks to [VSD](https://www.vlsisystemdesign.com/) for creating such an *amazing* hackathons which enables students like me to learn explore more.                                                                                                                                
```
**Thank You**
**Sidhant Priyadarshi**
```
