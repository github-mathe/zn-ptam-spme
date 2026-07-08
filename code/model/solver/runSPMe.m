function [T,Y,results, cathode, electrolyte, anode] = runSPMe(cathode, electrolyte, anode, reaction, constants, modelParams)
% runSPMePhase: Runs a single SPMe simulation phase from a given initial state and current profile.
% Inputs:
%   initialState - vector [cs; ce]
%   cathode, electrolyte, anode - domain structs
%   reaction, constants         - system-wide parameters
%   modelParams - struct with fields:
%       .I_fun     - current function handle @(t)
%       .tspan     - time vector
%       .M         - mass matrix
%       .odefun    - system function @(t,y)
%       .V_limit   - [Vmin Vmax]
% Output:
%   model.results, model.cathode, model.anode, model.electrolyte

    ElectrochemCache('clear')
    [cathode,electrolyte] = initFluxBoundaryPotential(cathode,electrolyte,modelParams.I_fun,constants,reaction);
    t_init = modelParams.tspan(1);
    
    % Set initial state
    if isfield(modelParams, "soc_init") && ~isempty(modelParams.soc_init)
        [cathode, electrolyte,anode] = initInitialConditions(t_init,cathode, electrolyte,anode, reaction, constants,modelParams.soc_init);
    else
        [cathode, electrolyte,anode] = initInitialConditions(t_init,cathode, electrolyte,anode, reaction, constants);
    end
   
    % Assemble system
    cathode = buildSolidMatrices(cathode);
    cathode = buildSolidRHS(cathode);
    electrolyte = buildLiquidMatrices(electrolyte);
    electrolyte = buildLiquidRHS(electrolyte);
    cathode.FEM.Boundary = buildSolidBoundary(cathode);
    electrolyte.FEM.Boundary = buildLiquidBoundary(electrolyte);

    % Logging Info
    disp('Initial Conditions:');
    fprintf('  Normalized Solid Concentration on the Interface (Cathode): %.4f\n', cathode.soc);
    fprintf('  Electrolyte Concentration: %.3f kmol/m^3\n', electrolyte.ce_init / 1e3);
    fprintf('  Temperature: %.2f K\n', constants.T);
    disp(' ');
    N_DOF_cat = cathode.Geometry.dof.number_of_dofs;
    
    % define odeset
    MassCoupled = blkdiag(cathode.FEM.MasseMatrix, electrolyte.FEM.MasseMatrix);
    maxMass = max(MassCoupled,[],2);
    MassCoupled=MassCoupled./maxMass;
    y0 = [cathode.cs_0; electrolyte.ce_0];
    
    % Solve with event handling (if cutoff provided)
    if isfield(modelParams, 'V_limit') && ~isempty(modelParams.V_limit)
        options = odeset('Mass', MassCoupled, ...
                         'Events', @(t,y) voltageEvent(t, y, cathode, electrolyte, anode, reaction, constants, modelParams.V_limit,modelParams.process) ...
                         );
    fprintf('Voltage limit: %.3f V\n', modelParams.V_limit);
    else
        options = odeset('Mass', MassCoupled,'RelTol',1e-6,'MaxStep',.1);
    end

   [T,Y] = ode15s(@(t, y) odefun(t, y), modelParams.tspan, y0, options);

    % 1) Check number of time points / rows (failed if <= 2)
    if numel(T) <= 2 || size(Y,1) <= 2
        error('ODE solver failed or made no progress: only %d time points returned.', numel(T));
    end
    
    % 2) Check for NaN/Inf in solution
    if any(isnan(Y(:))) || any(isinf(Y(:)))
        error('ODE solver produced NaN or Inf in the solution.');
    end
    
    % 3) Optional: check if solution is trivial (all values unchanged)
    if all( Y(1,:) == Y(end,:) )
        error('ODE solution did not change from initial condition — solver likely failed.');
    end
    % Postprocess results
   [results, cathode, electrolyte, anode] = computePostProcessing(T, Y, cathode, electrolyte, anode, reaction, constants);

    function dydt = odefun(t, y)
    % odefun: Combined ODE function for solid and electrolyte domains
    % Inputs:
    %   t     - current time
    %   y     - combined state vector [c_s; c_e]
    %   model - struct containing equation handles and system sizes
    % Output:
    %   dydt  - combined time derivative vector [dc_s/dt; dc_e/dt]
    % Combine
    y1 = y(1:N_DOF_cat,1);
    y2 = y(1+N_DOF_cat:end,1);
    dydt1 = (- cathode.FEM.SystemMatrix*y1 + cathode.FEM.RHS + cathode.FEM.Boundary(t,y1));
    dydt2 = - electrolyte.FEM.SystemMatrix*y2 + electrolyte.FEM.RHS(t) + electrolyte.FEM.Boundary(t,y2);
    dydt = [dydt1;dydt2]./maxMass;
    end
end
