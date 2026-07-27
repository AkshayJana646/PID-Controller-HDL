clear all;
close all;
clc;

fprintf('Generating PID Verilog...\n\n');

%% Configure
cfg = coder.config('hdl');
cfg.TargetLanguage = 'Verilog';
cfg.TargetFrequency = 100;
cfg.AdaptivePipelining = false;
cfg.DistributedPipelining = false;
cfg.GenerateHDLCode = true;
cfg.GenerateHDLTestBench = true;

fprintf('Config set\n');

%% Create prototypes (fixed-point inputs)
error_proto = fi(0, 1, 16, 14);
valid_proto = true;
Kp_proto = fi(1.0, 1, 16, 12);
Ki_Ts_proto = fi(0.005, 1, 16, 14);
Kd_Ts_proto = fi(0.01, 1, 16, 12);
uMax_proto = fi(5, 1, 16, 14);
uMin_proto = fi(-5, 1, 16, 14);

fprintf('Prototypes created\n');
fprintf('  Kp = 1.0\n');
fprintf('  Ki*Ts = 0.005\n');
fprintf('  Kd/Ts = 0.01\n\n');

%% Generate
fprintf('Generating HDL...\n');

codegen -config cfg pid_controller_fixpt ...
    -args {error_proto, valid_proto, Kp_proto, Ki_Ts_proto, Kd_Ts_proto, uMax_proto, uMin_proto}

fprintf('\n✓ SUCCESS\n\n');
fprintf('Verilog generated:\n');
fprintf('  File: codegen/pid_controller_fixpt/pid_controller_fixpt.v\n');
fprintf('  Report: codegen/pid_controller_fixpt/pid_controller_fixpt_report.html\n');