# Anti-Windup PID Controller (Fixed-Point, HDL Coder)

Fixed-point PID controller in MATLAB with output saturation and
anti-windup, with Verilog and a testbench generated through
MATLAB HDL Coder.

## Specs
- 16-bit I/O, 32-bit accumulator
- Output saturation with anti-windup to prevent integral buildup
  at the clamp limits
- HDL Coder target frequency: 100 MHz

## Repository layout
- `pid_controller_fixpt.m`: fixed-point controller
- `generate_verilog.m`: HDL Coder script that generates Verilog
  and the testbench
- `codegen/pid_controller_fixpt/hdlsrc/`: generated Verilog and
  testbench
- `reports/`: HDL Coder generated reports

## How to run
1. Open MATLAB with HDL Coder installed.
2. Run `generate_verilog.m`.
3. Generated files appear in `codegen/pid_controller_fixpt/hdlsrc/`.

## Results
[Plot showing the output with and without anti-windup, with a
one-line explanation of what it shows]

[Note on how you verified the Verilog, e.g. HDL Coder testbench
results]
