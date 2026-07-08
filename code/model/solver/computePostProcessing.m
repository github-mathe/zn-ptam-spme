function [results, cathode, electrolyte, anode] = computePostProcessing(tvec, Y, cathode, electrolyte, anode, reaction, constants)
% computePostProcessing: Calculates voltage and related outputs from solution
% Inputs:
%   tvec            - time vector
%   Y               - solution matrix [cs; ce]
%   cathode         - cathode struct with geometry and solution
%   electrolyte     - electrolyte struct with geometry and solution
%   anode           - anode struct
%   reaction        - reaction parameter struct
%   constants       - struct with F, R, Temperature
%   t_log       - vector of logged times (optional)
%   state_log   - cell array of logged states (optional)
% Output:
%   results     - struct with computed values (Voltage, eta, i0, etc.)
%   cathode     - updated with solution
%   electrolyte - updated with solution
%   anode       - updated with i0 and eta
if isfield(cathode,'Matlab') && isfield(electrolyte,'Matlab')
    cathode=rmfield(cathode,'Matlab');
    electrolyte=rmfield(electrolyte,'Matlab');
end
    N_time = length(tvec);
    N_DOF_cat = cathode.Geometry.dof.number_of_dofs;
    cs_all = Y(:, 1:N_DOF_cat);
    ce_all = Y(:, N_DOF_cat+1:end);

    % Store solutions
    results.cs_all = cs_all;
    results.ce_all = ce_all;
    results.T = tvec;
    % Preallocate result fields
    results.Voltage = zeros(N_time, 1);
    results.OCP_pos = zeros(N_time, 1);
    results.OCP_neg = zeros(N_time, 1);  % assumed zero
    results.eta_cathode = zeros(N_time, 1);
    results.eta_anode = zeros(N_time, 1);
    results.delta_eta = zeros(N_time, 1);
    results.delta_phi_e = zeros(N_time, 1);
    results.i0_cathode = zeros(N_time, 1);
    results.i0_anode = zeros(N_time, 1);
    results.css = zeros(N_time, 1);
    results.ce_avg = zeros(N_time, 1);
    results.cell_SOC = zeros(N_time,1);
    results.k0_cathode = [cathode.k0;zeros(N_time-1, 1)];
    results.k0_anode = [anode.k0;zeros(N_time-1, 1)];
    results.css(1)         = cathode.InitState.css;
    results.ce_avg(1)      = electrolyte.InitState.ce_avg;
    results.i0_cathode(1)  = cathode.InitState.i0;
    results.i0_anode(1)    = anode.InitState.i0;
    results.eta_cathode(1) = cathode.InitState.eta;
    results.eta_anode(1)   = anode.InitState.eta;
    results.delta_eta(1)   = cathode.InitState.eta-anode.InitState.eta;
    results.delta_phi_e(1) = electrolyte.InitState.delta_phi_e;
    results.OCP_pos(1)     = cathode.InitState.OCP;
    results.OCP_neg(1)     = anode.InitState.OCP;
    results.Voltage(1)     = cathode.InitState.OCP - anode.InitState.OCP + electrolyte.InitState.delta_phi_e + cathode.InitState.eta-anode.InitState.eta;
    results.cell_SOC(1,1)  = (cathode.soc- cathode.x0)/(cathode.x1-cathode.x0);
    results.AvgCs(1,1)     = cathode.InitState.css;
    results.j_cathode(1, 1) = cathode.j_n(0);
    results.j_anode(1, 1) = electrolyte.i_n_neg(0)/constants.F;
    results.Q(1, 1) = results.AvgCs(1, 1) * constants.F * cathode.L * cathode.epsilon_s*cathode.A /3600;
    
    for n = 2:N_time
        y_vec = Y(n, :)';
        state = evaluateElectrochemicalState(tvec(n), y_vec, cathode, electrolyte, anode, reaction, constants);
        results.css(n)         = state.css;
        results.ce_avg(n)      = state.ce_avg;
        results.i0_cathode(n)  = state.cathode.i0;
        results.i0_anode(n)    = state.anode.i0;
        results.eta_cathode(n) = state.cathode.eta;
        results.eta_anode(n)   = state.anode.eta;
        results.delta_eta(n)   = state.delta_eta;
        results.delta_phi_e(n) = state.delta_phi_e;
        results.OCP_pos(n)     = state.OCP_pos;
        results.OCP_neg(n)     = state.OCP_neg;
        results.Voltage(n)     = state.voltage;
        results.j_cathode(n,1) = cathode.j_n(tvec(n));
        results.j_anode(n,1) = electrolyte.i_n_neg(tvec(n))/constants.F;
        results.AvgCs(n,1) = cathode.InitState.css- 3*cathode.j_n(tvec(n)).*tvec(n)/cathode.R_end;
        results.Q(n,1) = (results.AvgCs(n,1)-results.AvgCs(1,1)) * constants.F * cathode.L * cathode.epsilon_s*cathode.A/3600;
        results.k0_cathode(n,1) = state.cathode.k0;
        results.k0_anode(n,1) = state.anode.k0;
        results.cell_SOC(n,1)    = (results.AvgCs(n,1)/cathode.cs_max - cathode.x0)/(cathode.x1-cathode.x0);
    end
end
