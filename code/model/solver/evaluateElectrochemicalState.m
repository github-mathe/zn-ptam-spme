function state = evaluateElectrochemicalState(t, y, cathode, electrolyte, anode, reaction, constants)
% evaluateElectrochemicalState: computes voltage and electrochemical quantities from solution y
% Also logs results to a persistent cache for later retrieval

    [t_log, state_log] = ElectrochemCache('get');
    %Check if state at time t already logged
    idx = find(abs(t_log - t) < 1e-20, 1);
    if ~isempty(idx)
        state = state_log{idx};
        return;
    end
    % Unpack constants
    F = constants.F;
    R = constants.R;
    T = constants.T;

    % Split state vector
    N_DOF_cat = cathode.Geometry.dof.number_of_dofs;
    cs = y(1:N_DOF_cat); 
    ce = y(N_DOF_cat+1:end);

    % Key values
    state.css = cs(end);
    [state.ce_avg,state.ce_avg_sep,state.ce_avg_pos] = compute_avg_ce(electrolyte, ce);
    [~,~,state.sqrt_ce_avg_pos] = compute_avg_ce(electrolyte, sqrt(ce));
     
    % Exchange current densities
    electrodes = {'cathode', 'anode'};

    for i = 1:2
        name = electrodes{i};
        eq = eval(name);  % This gets either 'cathode' or 'anode' struct
        
        if (~isfield(eq, 'i0') || isempty(eq.i0)) || isfield(eq, 'k0')
            if strcmp(name, 'cathode')
                state.(name).i0 = reaction.n_pos_electron * F * eq.k0 * ...
                    sqrt((state.css ) * ...
                    (eq.cs_max - state.css))*state.sqrt_ce_avg_pos*sqrt(2);
                state.(name).k0 = eq.k0;
            elseif strcmp(name, 'anode')
                state.(name).i0 = reaction.n_neg_electron * F * eq.k0 * ...
                    (ce(1))^(1 - eq.alpha);  % Assuming ce(1) is electrolyte near anode
                state.(name).k0 = eq.k0;
            end
        elseif (isfield(eq, 'i0') && ~isempty(eq.i0)) || ~isfield(eq, 'k0')
            if strcmp(name, 'cathode')
                state.(name).k0 = eq.i0 / (reaction.n_pos_electron * F) / ...
                    (state.css)^(1 - eq.alpha)/state.sqrt_ce_avg_pos /sqrt(2)/ ...
                    (eq.cs_max - state.css)^eq.alpha;
            elseif strcmp(name, 'anode')
                state.(name).k0 = eq.i0 / (reaction.n_neg_electron * F) / ...
                    (ce(1))^(1 - eq.alpha);
            end
            state.(name).i0 = eq.i0;
        end
    end

    state.cathode.eta = 2 * R * T / F / reaction.n_pos_electron * asinh(cathode.i_n(t) / (2 * state.cathode.i0));
    state.anode.eta = 2 * R * T / F / reaction.n_neg_electron * asinh(electrolyte.i_n_neg(t) / (2 * state.anode.i0));
    state.delta_eta = state.cathode.eta - state.anode.eta;
    [elem_phi, ~] = compute_function_integral_elem(electrolyte, electrolyte.phi_e, t, ce);
    state.delta_phi_e = sum(elem_phi);

    state.OCP_pos = cathode.ocp_fun(state.css / cathode.cs_max);
    state.OCP_neg = -1.03;
    state.voltage = state.OCP_pos - state.OCP_neg + state.delta_eta + state.delta_phi_e;
    
 % Store in centralized cache
    ElectrochemCache('store', t, state);
end




