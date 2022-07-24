# challenges-sidhantp1906
## MUX Design Verification
### Table of Content
- [Abstract](####Abstract)
- [Verification Environment](####Verification%20Environment)
- [Test Scenario](####Test%20Scenario)
- [Bugs Found](####Bugs%20Found)
- [Debug Information](####Debug%20Information)
- [Verification Strategy](####Verification%20Stractegy)
- [Is The Verification Complete?](####Is%20The%20Verification%20Complete?)
#### Abstract
This is 31-1 Mux design which works on the basis of selection line as a 5 -bit control input. If sel is 0 then input 0 is passed. 
#### Verification Environment
The verification environment is setup using [Vyoma's UpTickPro](https://vyomasystems.com) provided for the hackathon.

<img src="https://user-images.githubusercontent.com/60102705/180488717-b51b86b1-741e-4da8-9350-320dd270bfcf.png" style=" width:640px ; height:360px "  >

The [CoCoTb](https://www.cocotb.org/) based Python test is developed as explained. The test_MUX drives inputs to the Design Under Test  (MUX) which takes in 5-bit select line *sel* and 2-bit 31 inputs *inp0..inp30* and gives 2-bit output *out*. Below is the code for driving inputs.
```
 dut.sel.value = 0
 dut.inp0.value = 0
 dut.inp1.value = 1
 await Timer(2,units = 'us')
```
Below is the assertion code which when not satisfied causes error.
```
assert dut.out.value == dut.inp0.value, "Test Failed :Got {out} expected {in0}".format(out=int(dut.out.value), in0=int(dut.inp0.value))
```
#### Test Scenario
##### Test Case 1
```
 dut.sel.value = 0
 dut.inp0.value = 0
 dut.inp1.value = 1
 await Timer(2,units = 'us')
 assert dut.out.value == dut.inp0.value, "Test Failed :Got {out} expected {in0}".format(out=int(dut.out.value), in0=int(dut.inp0.value))
```
##### Test Case 2
```
 dut.sel.value = 1
 dut.inp0.value = 0
 dut.inp1.value = 1
 await Timer(2,units = 'us')
 assert dut.out.value == dut.inp1.value, "Test Failed :Got {out} expected {in1}".format(out=int(dut.out.value), in1=int(dut.inp1.value))
```
#### Bugs Found
```
case(sel)
      5'b00000: out = inp1; //=======> Bug ** It should be inp0 not inp1****** 
      5'b00001: out = inp0;  //=======> Bug ** It should be inp1 not inp0****** 
```
To overcome above bug we have to replace with below code:
```
case(sel)
      5'b00000: out = inp0; 
      5'b00001: out = inp1; 
```
#### Debug Information
Designed is corrected as per the bugs observed.Below is the log for corrected design.
```
  2000.00ns INFO     test_bmux passed
  2000.00ns INFO     running test_bmux1 (2/2)
  4000.00ns INFO     test_bmux1 passed
  4000.00ns INFO     **************************************************************************************
                     ** TEST                          STATUS  SIM TIME (ns)  REAL TIME (s)  RATIO (ns/s) **
                     **************************************************************************************
                     ** test_bmux.test_bmux            PASS        2000.00           0.00    3102297.41  **
                     ** test_bmux.test_bmux1           PASS        2000.00           0.00    8701879.87  **
                     **************************************************************************************
                     ** TESTS=2 PASS=2 FAIL=0 SKIP=0               4000.00           0.01     524616.15  **
                     **************************************************************************************
                     
```
#### Verification Stractegy
To check the correctnes design based on selection line and output observed so changed the inputs of first to line to check whether output is getting same as selects line selects the input so when slect line is 0 then inp0 is tranfered as inp0 is inp1 in buggy design then inp1 is transfered hence make output assertion fail. It is same for the case when select line is 1. 
<img src="https://user-images.githubusercontent.com/60102705/180633799-f881eb9f-ce4f-45d2-92b3-daf1b73d8eb8.png" style=" width:640px ; height:360px "  >

#### Is The Verification Complete?
```YES```, As presented above shows the verification strategies of design and how to overcome the issue.


## Sequence 1011 Detector Design Verification
### Table of Content
- [Abstract](####Abstract)
- [Verification Environment](####Verification%20Environment)
- [Test Scenario](####Test%20Scenario)
- [Bugs Found](####Bugs%20Found)
- [Debug Information](####Debug%20Information)
- [Verification Strategy](####Verification%20Stractegy)
- [Is The Verification Complete?](####Is%20The%20Verification%20Complete?)

#### Abstract
This is design of non-overlapping sequence detector which detects the input stream of *1011*. When stream 1011 is detected then output *seq_seen* is made high. This is design in moore machine FSM style.
#### Verification Environment
The verification environment is setup using [Vyoma's UpTickPro](https://vyomasystems.com) provided for the hackathon.

<img src="https://user-images.githubusercontent.com/60102705/180488717-b51b86b1-741e-4da8-9350-320dd270bfcf.png" style=" width:640px ; height:360px "  >

The [CoCoTb](https://www.cocotb.org/) based Python test is developed as explained. The test_seq_detect_1011 drives inputs to the Design Under Test  (seq_detect_1011) which takes in 1-bit input *inp_bit* and *clk , reset* as synchronus inputs and gives 1-bit output *seq_seen*. Below is the code for driving inputs.
```
clock = Clock(dut.clk, 10, units="us")  # Create a 10us period clock on port clk
    cocotb.start_soon(clock.start())        # Start the clock

    # reset
    dut.reset.value = 1
    await FallingEdge(dut.clk)  
    dut.reset.value = 0
    await FallingEdge(dut.clk)

    cocotb.log.info('#### CTB: Develop your test here! ######')
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 0
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
```
For assertion refer below code:
```
assert dut.seq_seen.value == 1, "Test Failed sequence should be 1011 hence output = {seen}".format(seen=int(dut.seq_seen.value))
```
#### Test Scenario
##### Test Case 1
```
    dut.inp_bit.value = 0
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
```
##### Test Case 2
```
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
```
##### Test Case 3
```
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 0
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
```
#### Bugs Found
##### Bug 1
The expected traversal of states is ```SEQ_1=>SEQ_10=>SEQ_101=>SEQ_1011``` but here when input 1 is read at first edge of *clk* according to rule it should go to *SEQ_10* state but it goes to *SEQ_101*.
```
SEQ_1:
      begin
        if(inp_bit == 1)
          next_state = IDLE;
        else
          next_state = SEQ_101; //=========>bug ** it should go to seq10 but it goes to seq101 ***********
      end
```
To correct above replace ```next_s = SEQ_101``` with ```next_s = SEQ_10```.
##### Bug 1
Here when input 0 is read at second edge of *clk* according to rule it should go to *SEQ_101* state but it goes to *SEQ_10* hence remains in state *SEQ_10* itself forever.
```
SEQ_10:
      begin
        if(inp_bit == 1)
          next_state = SEQ_10; //=========>bug ** it should go to seq101 but it goes to seq10 ***********
        else
          next_state = IDLE;
      end
```
To correct above replace ```next_s = SEQ_10``` with ```next_s = SEQ_101```.
#### Debug Information 
#### Verification Strategy
#### Is The Verification Complete?
```YES```, As presented above shows the verification strategies of design and how to overcome the issue.

## RISC-V RV32I Design Verification
### Table of Content
- [Abstract](####Abstract)
- [Verification Environment](####Verification%20Environment)
- [Test Scenario](####Test%20Scenario)
- [Bugs Found](####Bugs%20Found)
- [Debug Information](####Debug%20Information)
- [Verification Strategy](####Verification%20Stractegy)
- [Is The Verification Complete?](####Is%20The%20Verification%20Complete?)
#### Abstract
This Readme presents the verification of RISCV-RV32I which is 32-bit processor core implemented using 5-stage pipelining. Five stage pipelining enables faster execution of instructions using pre-fetch and branching operation. It has ROM inside which stores the instructions which has to be executed sequentially in a pipeline architecture. This design is implemented using Verilog-2003 and simulated using Icarus-Verilog and GTK-Wave. This design will be verified using python based
verification methodology CoCoTb.

#### Verification Environment
The verification environment is setup using [Vyoma's UpTickPro](https://vyomasystems.com) provided for the hackathon.

<img src="https://user-images.githubusercontent.com/60102705/180488717-b51b86b1-741e-4da8-9350-320dd270bfcf.png" style=" width:640px ; height:360px "  >

The [CoCoTb](https://www.cocotb.org/) based Python test is developed as explained. The test_RV32I drives inputs to the Design Under Test  (RV32I) which takes in 2 clock as inputs *clk1* and *clk2* and gives 32-bit output *mem_wb_aluout*.

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
Thank You
Sidhant Priyadarshi
```
