# FPGA Digital Combination Lock

A 4-digit digital combination lock implemented in Verilog HDL for the Xilinx ZedBoard (Zynq-7000).

## Overview

The user enters four decimal digits using SW[3:0], confirming each digit with BTN0. The Enter button is synchronized and debounced, the switch value is synchronized and validated, and each accepted digit is stored in a 16-bit shift register. A five-state FSM compares the completed code with a VIO-programmable golden code.

Correct code -> 2-second UNLOCK -> green LED.

Incorrect code -> 5-second LOCKOUT -> red LED.

ILA is used for hardware observation and VIO is used to update the golden code during testing.

## Architecture

100 MHz clock
  |
  +--> reset synchronizer --> rst_sync
  +--> tick_gen --> 1 ms ms_tick
  +--> debounce_enter <-- BTN0 --> enter_pulse
                              |
                              v
                        sync_switches <-- SW[3:0]
                              |
                              +--> digit / digit_valid
                                           |
                                           v
                                       fsm_lock
                                      /         \
                                 UNLOCK       LOCKOUT
                                  2 sec         5 sec
                                    |             |
                               green LED      red LED

VIO --> golden code
ILA <-- internal debug signals

## RTL

- rtl/top.v : top-level integration
- rtl/tick_gen.v : 1 ms timing tick
- rtl/debounce_enter.v : Enter button synchronization and debounce
- rtl/sync_switches.v : switch synchronization and 0-9 validation
- rtl/shift_reg.v : four-digit 16-bit shift register
- rtl/fsm_lock.v : main FSM, golden-code register, LED control, timer control
- rtl/timer.v : parameterized millisecond timer
- rtl/LockVIO.v : wrapper for Vivado VIO IP

## FSM

IDLE -> INPUT -> CHECK -> UNLOCK -> IDLE

IDLE -> INPUT -> CHECK -> LOCKOUT -> IDLE

## Timing

- System clock: 100 MHz
- Clock period: 10 ns
- 1 ms tick: 100,000 clock cycles
- Debounce target: 20 ms
- Unlock duration: 2000 ms
- Lockout duration: 5000 ms

The 1 ms signal is a clock-enable pulse, not a separate clock domain.

## Board mapping from the project report

- 100 MHz clock: Y9
- BTN1 reset: R18
- BTN0 enter: T18
- Switches: F21, H22, G22, F22
- Unlock LED: U14
- Lockout LED: U19

The original XDC source was not supplied with the RTL, so an authoritative XDC is not invented in this repository.

## Implementation results from the project report / latest implementation shown

- LUT: 1905
- LUTRAM: 216
- FF: 3171
- BRAM: 2.50
- I/O: 9
- BUFG: 2
- WNS: +26.989 ns
- TNS: 0 ns
- Failing endpoints: 0
- Estimated on-chip power: 0.108 W (Vivado estimate, low confidence)

The implementation contains ILA/VIO debug infrastructure, so the reported utilization is not representative of the functional lock logic alone.

## Verification

A focused fsm_lock simulation testbench is included in sim/. The original report also describes reset, correct code, incorrect code, input-during-lockout, and input-during-unlock test scenarios.

## Vivado IP

The generated VIO and ILA IP source files were not provided with the RTL. See vivado/README.md for the expected interfaces and setup.

## RTL review fixes included

- debounce_enter now generates a true one-clock enter_pulse
- sync_switches consumes the one-clock pulse directly
- clear_shift is combinational in fsm_lock to avoid the previous extra-cycle clear delay
- unused timer start_prev was removed
- state and golden-code debug outputs directly expose the internal registers
