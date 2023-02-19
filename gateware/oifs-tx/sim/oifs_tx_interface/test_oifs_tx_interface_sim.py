"""



"""

import logging
import os

import cocotb_test.simulator

import cocotb
from cocotb.log import SimLog
from cocotb.triggers import RisingEdge, Timer


class TB:
    def __init__(self, dut, speed=1000e6):
        self.dut = dut

        self.log = SimLog("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        dut.i_clk.setimmediatevalue(0)
        dut.i_arst.setimmediatevalue(0)

        cocotb.start_soon(self._run_clk())

    async def init(self):

        for k in range(3):
            await RisingEdge(self.dut.i_clk)

        self.dut.i_arst.value = 1

        for k in range(2):
            await RisingEdge(self.dut.i_clk)

        self.dut.i_arst.value = 0

    async def _run_clk(self):
        t = Timer(5, 'ns')
        while True:
            self.dut.i_clk.value = 1
            await t
            self.dut.i_clk.value = 0
            await t

@cocotb.test()
async def run_simple_test(dut):

    tb = TB(dut)

    await tb.init()

    tb.log.info("test oifs tx interface")

    # assum FSCTS
    dut.i_fscts.value = 1

    for k in range(1):
        await RisingEdge(dut.i_clk)

    # try to send data 0xAA from channel 0
    dut.i_data.value = 0xAA
    dut.i_channel.value = 0
    dut.i_valid.value = 1
    await RisingEdge(dut.i_clk)
    dut.i_data.value = 0x00
    dut.i_valid.value = 0

    await RisingEdge(dut.o_ready)

    for k in range(4):
        await RisingEdge(dut.i_clk)

    # try to send data 0x55 from channel 1
    dut.i_data.value = 0x55
    dut.i_channel.value = 1
    dut.i_valid.value = 1
    await RisingEdge(dut.i_clk)
    dut.i_data.value = 0x00
    dut.i_valid.value = 0

    await RisingEdge(dut.o_ready)

    for k in range(10):
        await RisingEdge(dut.i_clk)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))


def test_adc_interface(request):
    dut = "opto_tx_interface"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    # parameters['A'] = val

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    sim_build = os.path.join(tests_dir, "sim_build",
                             request.node.name.replace('[', '-').replace(']', ''))

    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
    )
