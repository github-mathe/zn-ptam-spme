function [value, isterminal, direction] = voltageEvent(t, y, cathode, electrolyte, anode, reaction, constants, V_limit,process)
% voltageEvent: triggers when voltage reaches the lower cutoff limit
% Inputs:
%   t           - current time
%   y           - current state [cs; ce]
%   cathode     - cathode struct with ocp_fun and i_n(t)
%   electrolyte - electrolyte struct with i_n_neg(t) and phi_e
%   anode       - anode struct
%   reaction    - reaction parameters (stoichiometry, alpha)
%   constants   - constants like F, R, T
%   V_limit     - [V_min, V_max]
    
    % Event 2: any of first N_DOF_cat becomes <= tol_positive
    % We want event when min(y(1:N_DOF_cat)) - tol_positive == 0 (i.e. <= tol)
    val_dof = min(y(1:cathode.Geometry.dof.number_of_dofs));
    val_css = min(cathode.cs_max-y(cathode.Geometry.dof.number_of_dofs));
if val_css<=0 || val_dof<=0
    value = -1;
else
    state = evaluateElectrochemicalState(t, y, cathode, electrolyte, anode, reaction, constants);
    if isnan(state.voltage)
        value=-1;
    else
        value = process*((state.voltage-1.03)-V_limit) ;
    end
end
    isterminal = 1;                      % stop the solver
    direction = -1;                      % only trigger when voltage is decreasing
end
