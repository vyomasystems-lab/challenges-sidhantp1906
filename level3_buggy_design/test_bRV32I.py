import os
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
@cocotb.test()
async def test_bRV32I(dut):
    """Test for RV32I"""
    cocotb.log.info('##### CTB: Testing For ADD R2,R1,R3 ########')
    clock = Clock(dut.clk1, 10, units="us")  # Create a 10us period clock on port clk1
    cocotb.start_soon(clock.start()) 

    await Timer(5,units = 'us') # To phase shift clk2 by 180 degree

    clock = Clock(dut.clk2, 10, units="us")  # Create a 10us period clock on port clk2 
    cocotb.start_soon(clock.start()) 

    await Timer(30,units = 'us')
    await RisingEdge(dut.clk1)

    dut._log.info("AluOut = %d" %dut.mem_wb_aluout.value)
    assert dut.mem_wb_aluout.value == 4, "Test Failed :Got {out} expected 4".format(out=int(dut.mem_wb_aluout.value))
      
@cocotb.test()
async def test_bRV32I_1(dut):
    """Test for RV32I"""
    cocotb.log.info('##### CTB: Testing For SUB R2,R1,R3 ########')
    clock = Clock(dut.clk1, 10, units="us")  # Create a 10us period clock on port clk1
    cocotb.start_soon(clock.start()) 

    await Timer(5,units = 'us') # To phase shift clk2 by 180 degree

    clock = Clock(dut.clk2, 10, units="us")  # Create a 10us period clock on port clk2 
    cocotb.start_soon(clock.start()) 

    await Timer(5,units = 'us')
    await RisingEdge(dut.clk1)
    
    dut._log.info("AluOut = %d" %dut.mem_wb_aluout.value)
    assert hex(dut.mem_wb_aluout.value) == hex(4294967294), "Test Failed :Got {out} expected fffffffe".format(out=hex(dut.mem_wb_aluout.value))
      
@cocotb.test()
async def test_bRV32I_2(dut):
    """Test for RV32I"""
    cocotb.log.info('##### CTB: Testing For MUL R1,R2,R3 ########')
    clock = Clock(dut.clk1, 10, units="us")  # Create a 10us period clock on port clk1
    cocotb.start_soon(clock.start()) 

    await Timer(5,units = 'us') # To phase shift clk2 by 180 degree

    clock = Clock(dut.clk2, 10, units="us")  # Create a 10us period clock on port clk2 
    cocotb.start_soon(clock.start()) 

    await Timer(5,units = 'us')
    await RisingEdge(dut.clk1)
    
    dut._log.info("AluOut = %d" %dut.mem_wb_aluout.value)
    assert hex(dut.mem_wb_aluout.value) == hex(12), "Test Failed :Got {out} expected 0xc".format(out=hex(dut.mem_wb_aluout.value))
