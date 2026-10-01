# Anti-Windup PID Controller (Fixed-Point, HDL Coder)

Fixed-point PID controller in MATLAB with output saturation and
anti-windup, with Verilog generated through MATLAB HDL Coder.

## Specs
- 16-bit I/O, 32-bit accumulator
- Output saturation with anti-windup to prevent integral buildup
  at the clamp limits
- HDL Coder target frequency: 100 MHz

## Design
- Number formats (signed): `error` and output `u` are 16-bit with 14
  fractional bits; `Kp` and `Kd/Ts` are 16-bit with 12 fractional
  bits; `Ki*Ts`, `uMax` and `uMin` are 16-bit with 14 fractional
  bits; the integrator and the P+I+D sum are 32-bit with 28
  fractional bits.
- Example configuration in `generate_verilog.m`: Kp = 1.0,
  Ki*Ts = 0.005, Kd/Ts = 0.01, output limits of +/-5.
- Anti-windup: when the summed output exceeds `uMax` or falls below
  `uMin`, `u` is clamped to the limit, the integral increment for
  that sample is reverted so the integrator does not keep growing
  while saturated, and the `saturated` flag is set.

## Repository layout
- `pid_controller_fixpt.m`: fixed-point controller
- `generate_verilog.m`: HDL Coder script that generates the Verilog
  (testbench generation is enabled in the config)
- `codegen/pid_controller_fixpt/hdlsrc/`: generated Verilog
  (`pid_controller_fixpt.v`), compile and synthesis scripts, and the
  HDL Coder HTML reports

## How to run
1. Open MATLAB with HDL Coder installed.
2. Run `generate_verilog.m`.
3. Generated files appear in `codegen/pid_controller_fixpt/hdlsrc/`.

## Results

### Generated hardware
From `resource_report.html` (HDL Coder, generated 2026-07-27):

| Resource | Count |
|---|---|
| Multipliers | 3 (two 16x16, one 16x17) |
| Adders / subtractors | 6 |
| Registers | 2 (one 16-bit, one 32-bit; 48 register bits) |
| Multiplexers | 15 |
| RAMs | 0 |
| I/O bits | 118 (100 in, 18 out) |

### Verification
- The HDL Code Generation Conformance Report
  (`pid_controller_fixpt_hdl_conformance_report.html`) reports no
  messages, warnings, or errors for the design.
- The 100 MHz figure is the HDL Coder target frequency. This
  repository does not include synthesis or timing results.
