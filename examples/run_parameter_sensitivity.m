clear all; close all;

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(scriptDir);
addpath(genpath(fullfile(repoRoot, 'code')));
defaults = loadSimulationDefaults();

Crate = 1;
caseInfo = getDefaultSimulationCase(Crate, defaults);
runName = fullfile('parameter_sensitivity', 'cathode_D_s');
scaleFactors = [0.5, 1.0, 2.0];

resultsRoot = fullfile(repoRoot, 'results');
paramFolder = fullfile(repoRoot, 'code', 'model', 'parameters', 'data');
runRoot = getResultsRunRoot(resultsRoot, runName);

for scaleFactor = scaleFactors
    constants = getConstants();
    [cathode, anode, electrolyte, reaction, ~] = initParams(paramFolder);
    cathode.D_s = cathode.D_s * scaleFactor;
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

    sensitivityRoot = fullfile(runRoot, sprintf('scale_%g', scaleFactor));
    saveSimulationResults(sensitivityRoot, Crate, results, cathode, anode, electrolyte);

    fprintf('Completed sensitivity run for D_s scale %g\n', scaleFactor);
end
