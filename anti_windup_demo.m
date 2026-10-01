%% anti_windup_demo.m
% Compares pid_controller_fixpt (with anti-windup) against the same
% controller with the integrator revert removed, driving a simple
% first-order plant through output saturation.
%
% Scenario
%   - Output limits are +/-1 (uMax, uMin).
%   - Setpoint is 1.5 for the first 600 samples, which the limited output
%     cannot reach, so the error persists and the integrator can wind up.
%   - At sample 600 the setpoint drops to 0.5, which is reachable.
%   - Without anti-windup the stored integral keeps the output pinned at
%     the limit long after the setpoint drops. With anti-windup the
%     output leaves saturation right away.
%
% Run from the repository root. Saves anti_windup_response.png.

clear; close all; clc;

%% Parameters (demo values; generate_verilog.m uses Ki_Ts = 0.005)
N        = 1500;       % samples
kStep    = 600;        % setpoint drop at this sample
rHigh    = 1.5;        % unreachable setpoint
rLow     = 0.5;        % reachable setpoint
plantA   = 0.05;       % first-order plant: y = y + plantA*(u - y)

Kp    = fi(1.0,  1, 16, 12);
Ki_Ts = fi(0.02, 1, 16, 14);
Kd_Ts = fi(0.01, 1, 16, 12);
uMax  = fi( 1,   1, 16, 14);
uMin  = fi(-1,   1, 16, 14);
valid = true;

r       = [rHigh*ones(1,kStep), rLow*ones(1,N-kStep)];
y_aw    = zeros(1,N);  u_aw  = zeros(1,N);  sat_aw  = false(1,N);
y_noaw  = zeros(1,N);  u_noaw = zeros(1,N); sat_noaw = false(1,N);

%% Case 1: pid_controller_fixpt (with anti-windup)
clear pid_controller_fixpt          % reset persistent state
y = 0;
for k = 1:N
    e = fi(r(k) - y, 1, 16, 14);
    [u, s] = pid_controller_fixpt(e, valid, Kp, Ki_Ts, Kd_Ts, uMax, uMin);
    y = y + plantA*(double(u) - y);
    y_aw(k) = y;  u_aw(k) = double(u);  sat_aw(k) = s;
end

%% Case 2: same controller without the integrator revert
st = struct('integ', fi(0,1,32,28), 'prev', fi(0,1,16,14));
y = 0;
for k = 1:N
    e = fi(r(k) - y, 1, 16, 14);
    [u, s, st] = pid_no_antiwindup(e, Kp, Ki_Ts, Kd_Ts, uMax, uMin, st);
    y = y + plantA*(double(u) - y);
    y_noaw(k) = y;  u_noaw(k) = double(u);  sat_noaw(k) = s;
end

%% Report
postAW   = sum(sat_aw(kStep+1:end));
postNoAW = sum(sat_noaw(kStep+1:end));
fprintf('Saturated samples after the setpoint drop (sample %d):\n', kStep);
fprintf('  with anti-windup   : %d\n', postAW);
fprintf('  without anti-windup: %d\n', postNoAW);

%% Plot
fig = figure('Position', [100 100 900 650], 'Color', 'w');
t = 1:N;

subplot(2,1,1);
plot(t, r, 'k--', 'LineWidth', 1.2); hold on;
plot(t, y_noaw, 'r',  'LineWidth', 1.5);
plot(t, y_aw,   'b',  'LineWidth', 1.5);
xline(kStep, ':', 'setpoint drop');
ylabel('Plant output y'); grid on;
legend('Setpoint', 'No anti-windup', 'With anti-windup', 'Location', 'east');
title('Anti-windup comparison: fixed-point PID, output limits \pm1');

subplot(2,1,2);
plot(t, u_noaw, 'r', 'LineWidth', 1.5); hold on;
plot(t, u_aw,   'b', 'LineWidth', 1.5);
yline(double(uMax), 'k:'); yline(double(uMin), 'k:');
xline(kStep, ':');
xlabel('Sample'); ylabel('Controller output u'); grid on;
legend('No anti-windup', 'With anti-windup', 'Location', 'east');
ylim([-1.3 1.3]);

exportgraphics(fig, 'anti_windup_response.png', 'Resolution', 200);
fprintf('Saved anti_windup_response.png\n');

%% Local function: pid_controller_fixpt without the integrator revert
function [u, saturated, st] = pid_no_antiwindup(err, Kp, Ki_Ts, Kd_Ts, uMax, uMin, st)
    prop    = Kp * err;
    ki_prod = Ki_Ts * err;
    st.integ = fi(st.integ + ki_prod, 1, 32, 28);
    deriv   = Kd_Ts * (err - st.prev);
    st.prev = err;
    raw = fi(prop + st.integ + deriv, 1, 32, 28);
    if raw > uMax
        u = uMax;  saturated = true;
    elseif raw < uMin
        u = uMin;  saturated = true;
    else
        u = fi(raw, 1, 16, 14);  saturated = false;
    end
end
