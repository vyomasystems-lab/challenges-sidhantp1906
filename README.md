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

The [CoCoTb](https://www.cocotb.org/) based Python test is developed as explained. The test drives inputs to the Design Under Test (adder module here) which takes in 4-bit inputs *a* and *b* and gives 5-bit output *sum*

The values are assigned to the input port using 
```
dut.a.value = 7
dut.b.value = 5
```

The assert statement is used for comparing the adder's outut to the expected value.

The following error is seen:
```
assert dut.sum.value == A+B, "Adder result is incorrect: {A} + {B} != {SUM}, expected value={EXP}".format(
                     AssertionError: Adder result is incorrect: 7 + 5 != 2, expected value=12
```

#### Test Scenario
#### Bugs Found
#### Debug Information
#### Verification Stractegy
#### Is The Verification Complete?
