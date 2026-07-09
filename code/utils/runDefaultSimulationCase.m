function caseOutput = runDefaultSimulationCase(repoRoot, Crate, runName, defaults)
%RUNDEFAULTSIMULATIONCASE Run one default simulation case and save outputs.

    arguments
        repoRoot (1, :) char
        Crate (1, 1) double
        runName (1, :) char
        defaults struct
    end

    resultsRoot = fullfile(repoRoot, 'results');
    paramFolder = fullfile(repoRoot, 'code', 'model', 'parameters', 'data');
    runRoot = getResultsRunRoot(resultsRoot, runName);
    caseInfo = getDefaultSimulationCase(Crate, defaults);

    constants = getConstants();
    [cathode, anode, electrolyte, reaction, ~] = initParams(paramFolder);
    [cathode, electrolyte] = setupDiscretization(cathode, electrolyte, defaults.fem_opts);

    V_limit = [cathode.ocp_fun(cathode.x0), cathode.ocp_fun(cathode.x1)];
    Q_oneC = cathode.Q_th / cathode.A;
    i_C = defaults.process * Crate * Q_oneC;
    current = buildConstantCurrentProfile(i_C, defaults.T_end);

    modelParam = struct();
    modelParam.I_fun = current;
    modelParam.tspan = 0:defaults.dt:defaults.T_end;
    modelParam.soc_init = caseInfo.soc_init;
    modelParam.process = defaults.process;
    modelParam.V_limit = V_limit(2);

    [~, ~, results, cathode, electrolyte, anode] = runSPMe( ...
        cathode, electrolyte, anode, reaction, constants, modelParam);

    saveSimulationResults(runRoot, Crate, results, cathode, anode, electrolyte);

    caseOutput = struct();
    caseOutput.runName = runName;
    caseOutput.runRoot = runRoot;
    caseOutput.Crate = Crate;
    caseOutput.caseFolder = fullfile(runRoot, sprintf('Crate_%g', Crate));
    caseOutput.caseInfo = caseInfo;

end
