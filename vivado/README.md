# Vivado Setup

Target: Xilinx ZedBoard / Zynq-7000
Original project tool: Vivado 2024.1

## Sources

Add all Verilog files under rtl/ to an RTL project.

## Required generated IP

The top-level design instantiates VIO instance vio_0 and ILA instance ila_0.

VIO expected outputs:
- probe_out0: 16-bit golden code
- probe_out1: 1-bit write strobe
- clock: clk

ILA expected probes: 15 probes corresponding to the probe0..probe14 connections in rtl/top.v, clocked by clk.

The original .xci IP files were not supplied, so they are intentionally omitted.

## Build

1. Create a Vivado RTL project for the ZedBoard device.
2. Add rtl/*.v.
3. Regenerate the VIO and ILA IP using the interfaces above.
4. Add the board XDC using the mappings in constraints/README.md.
5. Run synthesis.
6. Run implementation.
7. Review timing and DRC.
8. Generate the bitstream.
9. Program the board.
10. Use Hardware Manager for ILA/VIO.
