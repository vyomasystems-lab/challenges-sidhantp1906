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
- Memory location accessed is 0x00000000 which has 0x00308133 i.e., add r2,r1,r3.
- Expected output mem_wb_aluout is 4.
- Observed output mem_wb_aluout is 2.
This shows that observed output does not matches with expected output hence possible **bug** found.
##### Test Case 2
##### Test Case3
#### Bugs Found
#### Debug Information
#### Verification Stractegy
#### Is The Verification Complete?
