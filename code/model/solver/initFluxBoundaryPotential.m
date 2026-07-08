function [cathode, electrolyte] = initFluxBoundaryPotential(cathode, electrolyte, I, constants, reaction)
% initInitialConditions: Sets initial solid/electrolyte concentrations, fluxes and potential
% Inputs:
%   cathode, electrolyte - domain structs
%   I                    - current profile function handle I(t)
%   constants            - struct with R, T, F, etc.
%   soc_init             - initial SOC [0-1]
%   V_limit              - [Vmin, Vmax] for display/logging
%   reaction             - struct with stoichiometry info

    %% Constants
    F = constants.F;
    R = constants.R;
    T = constants.T;
    Brugg = electrolyte.Brugg;

    %% Reaction Parameters
    nu = reaction.nu;
    nu_cation = reaction.nu_cation;
    s_pos_cation = reaction.s_pos_cation;
    s_pos_anion = reaction.s_pos_anion;
    s_neg_cation = reaction.s_neg_cation;
    %s_neg_anion = reaction.s_neg_anion;
    n_pos_electron = reaction.n_pos_electron;
    n_neg_electron = reaction.n_neg_electron;
    z_cation = reaction.z_cation;

    L = cathode.L + electrolyte.L_sep;

    %% Fluxes (from current)
    cathode.i_n = @(t) -I(t) / cathode.a_s / cathode.L;
    cathode.j_n = @(t) -(s_pos_cation + s_pos_anion) / n_pos_electron * cathode.i_n(t) / F;
    cathode.rhs = @(t, x, c) zeros(size(x));
    cathode.boundary_end = @(t)-cathode.j_n(t);

    electrolyte.i_n_neg = @(t) I(t);
    electrolyte.i_n_sep = @(t) 0;
    electrolyte.i_n_pos = @(t) -I(t) / cathode.a_s / cathode.L;
    electrolyte.i_e_sep = @(t, x) I(t);
    electrolyte.i_e_pos = @(t, x) I(t) / cathode.L * (L - x);
    electrolyte.boundary_start = @(t) electrolyte.i_n_neg(t) / F / nu_cation * ...
        (s_neg_cation / n_neg_electron + electrolyte.t0_plus / z_cation);
    electrolyte.rhs_pos = @(t)  -electrolyte.i_n_pos(t) * cathode.a_s / F / nu_cation * ...
        (s_pos_cation / n_pos_electron + electrolyte.t0_plus / z_cation);
    electrolyte.rhs = @rhs;
    
    %% Electrolyte Potential
    TDF = electrolyte.TDF;
    electrolyte.phi_e = @(t, x, ce, dce) ...
        -nu * R * T / F / nu_cation * (s_neg_cation / n_neg_electron + electrolyte.t0_plus / z_cation) * ...
        (TDF) * (1 ./ ce) .* dce + ...
        ((x >= 0) & (x <= electrolyte.L_sep)) .* (-1 ./ electrolyte.sigma_e / electrolyte.epsilon_sep^Brugg) .* electrolyte.i_e_sep(t, x) + ...
        ((x > electrolyte.L_sep) & (x <= L)) .* (-1 ./ electrolyte.sigma_e / electrolyte.epsilon_pos^Brugg) .* electrolyte.i_e_pos(t, x);

    function out = rhs(t,x,c)
        for i=1:length(x)
            if x(i) < electrolyte.domain(2)
                out(i) = 0;
            elseif (x(i)>=electrolyte.domain(2) && x(i) <=electrolyte.domain(end))
                out(i) = electrolyte.rhs_pos(t);
            end
        end
        out=out';
    end
end