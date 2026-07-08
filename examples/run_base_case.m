clear all; close all;

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(scriptDir);
addpath(genpath(fullfile(repoRoot, 'code')));

% Nominal case settings
Crate = 1;
soc_init = 0.000014355627617533;
process = -1;
T_end = 36000;
dt = 1;

resultsRoot = fullfile(repoRoot, 'results');
simfolder = fullfile(resultsRoot, 'base');
paramFolder = fullfile(repoRoot, 'code', 'model', 'parameters', 'data');

constants = getConstants();
[cathode, anode, electrolyte, reaction, ~] = initParams(paramFolder);

V_limit = [cathode.ocp_fun(cathode.x0), cathode.ocp_fun(cathode.x1)];
Q_oneC = cathode.Q_th / cathode.A;
i_C = process * Crate * Q_oneC;
current = @(t) (t > 0 && t < T_end + 1) * i_C + (t == 0) * 0;

fem_opts = struct( ...
    'fem_p_cathode', 7, ...
    'fem_q_cathode', 8, ...
    'fem_ref_cathode', 7, ...
    'fem_p_electrolyte', 3, ...
    'fem_q_electrolyte', 4, ...
    'fem_ref_electrolyte', 4 ...
    );
[cathode, electrolyte] = setupDiscretization(cathode, electrolyte, fem_opts);

modelParam = struct();
modelParam.I_fun = current;
modelParam.tspan = 0:dt:T_end;
modelParam.soc_init = soc_init;
modelParam.process = process;
modelParam.V_limit = V_limit(2);

[T, Y, results, cathode, electrolyte, anode] = runSPMe( ...
    cathode, electrolyte, anode, reaction, constants, modelParam);

saveSimulationResults(simfolder, Crate, results, cathode, anode, electrolyte);

disp('Base case completed successfully.');