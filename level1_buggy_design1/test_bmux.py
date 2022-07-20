import cocotb
from cocotb.triggers import Timer
import random
@cocotb.test()
async def test_bmux(dut):
    """Test for mux2"""
    cocotb.log.info('##### CTB: Develop your test here ########')
    dut.sel.value = 0
    dut.inp0.value = 0
    dut.inp1.value = 1
    await Timer(2,units = 'us')
    #dut._log.info(f'In={dut.in0.value:05}  sel={dut.sel.value:05} DUT={int(dut.out.value):05}')
    assert dut.out.value == dut.inp0.value, "Test Failed :Got {out} expected {in0}".format(out=int(dut.out.value), in0=int(dut.inp0.value))
        
@cocotb.test()
async def test_bmux1(dut):
    dut.sel.value = 1
    dut.inp0.value = 0
    dut.inp1.value = 1
    await Timer(2,units = 'us')
    #dut._log.info(f'In={dut.in1.value:05}  sel={dut.sel.value:05} DUT={int(dut.out.value):05}')
    assert dut.out.value == dut.inp1.value, "Test Failed :Got {out} expected {in1}".format(out=int(dut.out.value), in1=int(dut.inp1.value))