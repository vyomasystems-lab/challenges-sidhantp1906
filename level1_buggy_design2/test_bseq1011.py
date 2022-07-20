import os
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

@cocotb.test()
async def test_bseq(dut):
    """Test for seq detection """

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

    assert dut.seq_seen.value == 1, "Test Failed: sequence should be 1011 hence output = {seen}".format(seen=int(dut.seq_seen.value))

@cocotb.test()
async def test_bseq1(dut):
    """Test for seq detection """

    clock = Clock(dut.clk, 10, units="us")  # Create a 10us period clock on port clk
    cocotb.start_soon(clock.start())        # Start the clock

    # reset
    dut.reset.value = 1
    await FallingEdge(dut.clk)  
    dut.reset.value = 0
    await FallingEdge(dut.clk)

    cocotb.log.info('#### CTB: Develop your test here! ######')
    dut.inp_bit.value = 0
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")

    assert dut.seq_seen.value == 1, "Test Failed: sequence should be 1011 hence output = {seen}".format(seen=int(dut.seq_seen.value))

@cocotb.test()
async def test_bseq2(dut):
    """Test for seq detection """

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
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")
    dut.inp_bit.value = 1
    await Timer(10, units = "us")

    assert dut.seq_seen.value == 1, "Test Failed: sequence should be 1011 hence output = {seen}".format(seen=int(dut.seq_seen.value))