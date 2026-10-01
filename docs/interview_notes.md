# Interview Notes

## 30 seconds

I built a 4-digit digital combination lock in Verilog on a Xilinx ZedBoard. The Enter button is synchronized and debounced, the four switch inputs are synchronized and restricted to decimal digits 0-9, and valid digits are accumulated in a 16-bit shift register. A five-state FSM compares the completed code with a VIO-programmable golden code. A correct code produces a 2-second UNLOCK state and green LED; an incorrect code produces a 5-second LOCKOUT state and red LED. ILA and VIO were used for hardware debugging.

## 3-5 minute flow

1. 100 MHz system clock.
2. tick_gen generates a 1 ms enable after 100,000 clock cycles.
3. BTN0 passes through a two-flop synchronizer and about 20 ms debounce.
4. The debouncer generates a one-clock enter_pulse.
5. SW[3:0] passes through a two-flop synchronizer.
6. Only 0-9 are accepted; 10-15 are rejected.
7. Each accepted digit shifts into a 16-bit register.
8. FSM progresses IDLE -> INPUT -> CHECK.
9. The 16-bit code is compared with the golden code.
10. Match -> UNLOCK timer -> green LED for 2 seconds.
11. Mismatch -> LOCKOUT timer -> red LED for 5 seconds.
12. Inputs are gated during UNLOCK/LOCKOUT.
13. The entered code is cleared when the terminal state completes.
14. VIO updates the golden code in IDLE; ILA exposes internal debug signals.

## Hardware mapping

Registers/state/counters map to flip-flops; FSM decode, comparators and control map primarily to LUT logic; counter arithmetic can use FPGA carry chains; the 16-bit entered code does not need BRAM or DSP slices.

## Key interview topics

Synchronization vs debouncing; clock-enable tick generation; FSM state transitions; shift-register behavior; setup/hold and WNS/TNS; LUT/FF/BRAM/DSP mapping; ILA/VIO; debug-IP resource overhead; reset strategy; timer/state-boundary corner cases.
