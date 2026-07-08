function [cathode, electrolyte,anode] = initInitialConditions(t_init,cathode, electrolyte,anode, reaction, constants, soc_init)
% initInitialConditions: Sets initial solid/electrolyte concentrations
% Inputs:
%   cathode, electrolyte - domain structs
%   soc_init             - initial SOC [0-1] or [] if cs_init is provided directly
    
    %% Solid concentration in cathode
    if exist('soc_init', 'var') && ~isempty(soc_init)
        cathode.soc = (soc_init * (cathode.x1 - cathode.x0) + cathode.x0);
        cathode.cs_0 = cathode.soc * ones(cathode.fem_p * cathode.N + 1, 1) * cathode.cs_max;
    elseif isfield(cathode, "cs_init") && ~isempty(cathode.cs_init)
        cathode.cs_0 = cathode.cs_init;
        cathode.soc = cathode.cs_init(end,1)/cathode.cs_max;
    else
        error('Initial condition for solid concentration missing: provide soc_init or cathode.cs_init.');
    end

    %% Electrolyte Initial Concentration
    if isfield(electrolyte, "ce_init_vec") && ~isempty(electrolyte.ce_init_vec)
        electrolyte.ce_0 = electrolyte.ce_init_vec;
    else
        electrolyte.ce_init = electrolyte.c_ref*(1-(soc_init*cathode.Q_th*3600/(cathode.A*2*constants.F*electrolyte.c_ref*(electrolyte.L_sep*electrolyte.epsilon_sep + cathode.L*electrolyte.epsilon_pos))));
        electrolyte.ce_0 = electrolyte.ce_init * ones(electrolyte.fem_p * electrolyte.N + 1, 1);
    end
    state = evaluateElectrochemicalState(t_init, [cathode.cs_0;electrolyte.ce_0], cathode, electrolyte, anode, reaction, constants);
    cathode.InitState.css=state.css;
    electrolyte.InitState.ce_avg = state.ce_avg;
    cathode.k0=state.cathode.k0;
    anode.k0 =state.anode.k0;
    cathode.InitState.i0 = state.cathode.i0;
    cathode.InitState.molar_flux(1,1) = cathode.i_n(t_init)/constants.F;
    cathode.InitState.eta = state.cathode.eta ;
    anode.InitState.i0 = state.anode.i0;
    anode.InitState.eta = state.anode.eta ;
    anode.InitState.molar_flux(1,1) = electrolyte.i_n_neg(t_init)/constants.F;
    electrolyte.InitState.delta_phi_e = state.delta_phi_e ;
    cathode.InitState.OCP = state.OCP_pos;
    anode.InitState.OCP = state.OCP_neg ;
end
