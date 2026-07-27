function [u, saturated] = pid_controller_fixpt(error, valid, Kp, Ki_Ts, Kd_Ts, uMax, uMin)
    %#codegen
    persistent integrator error_prev
    
    if isempty(integrator)
        integrator = fi(0, 1, 32, 28);
        error_prev = fi(0, 1, 16, 14);
    end
    
    u = fi(0, 1, 16, 14);
    saturated = false;
    
    if valid
        % Proportional
        prop = Kp * error;
        
        % Integral (cast result back to 32-bit)
        ki_prod = Ki_Ts * error;
        integrator = fi(integrator + ki_prod, 1, 32, 28);
        
        % Derivative
        deriv = Kd_Ts * (error - error_prev);
        error_prev = error;
        
        % Sum all components (cast to 32-bit)
        raw = fi(prop + integrator + deriv, 1, 32, 28);
        
        % Saturate with anti-windup
        if raw > uMax
            u = uMax;
            integrator = fi(integrator - ki_prod, 1, 32, 28);
            saturated = true;
        elseif raw < uMin
            u = uMin;
            integrator = fi(integrator - ki_prod, 1, 32, 28);
            saturated = true;
        else
            u = fi(raw, 1, 16, 14);
            saturated = false;
        end
    end
end