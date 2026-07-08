function [cathode, electrolyte] = setupDiscretization(cathode, electrolyte, fem_opts)
% setupDiscretization: Applies FEM discretization settings and computes geometry
%   Inputs:
%   cathode     - struct for cathode domain
%   electrolyte - struct for electrolyte domain
%   fem_opts    - struct with fields:
%                   .fem_p_cathode, .fem_q_cathode, .fem_ref_cathode
%                   .fem_p_electrolyte, .fem_q_electrolyte, .fem_ref_electrolyte
%   Outputs:
%   cathode     - updated with discretization and geometry
%   electrolyte - updated likewise

    % Set cathode FEM settings
    cathode.fem_p   = fem_opts.fem_p_cathode;
    cathode.fem_q   = fem_opts.fem_q_cathode;
    cathode.fem_ref = fem_opts.fem_ref_cathode;

    % Set electrolyte FEM settings
    electrolyte.fem_p   = fem_opts.fem_p_electrolyte;
    electrolyte.fem_q   = fem_opts.fem_q_electrolyte;
    electrolyte.fem_ref = fem_opts.fem_ref_electrolyte;

    % Compute geometry
    cathode = getGeometry(cathode);
    electrolyte = getGeometry(electrolyte);
end
