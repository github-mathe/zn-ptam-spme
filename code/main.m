clear all; close all;

crates = [1,2,5,10,20,50,100];
soc_inits = [0.000014355627617533,...
    3.05339246153066E-05,...
    9.61858235395057E-05,...
    0.000173140556902034,...
    0.000510415415779126,...
    0.00347608787119108,...
    0.000114834185742365];


scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(scriptDir);
resultsRoot = fullfile(repoRoot, 'results');
addpath(genpath(fullfile(repoRoot, 'code')));
paramFolder = fullfile(repoRoot, 'code', 'model', 'parameters', 'data');
constants = getConstants();
process = -1;
T_end = 36000;
dt = 1;
fem_opts = struct( ...
            'fem_p_cathode', 7, ...
            'fem_q_cathode', 8, ...
            'fem_ref_cathode',7, ...
            ...
            'fem_p_electrolyte', 3, ...
            'fem_q_electrolyte', 4, ...
            'fem_ref_electrolyte',4 ...
            );
[cathode, anode, electrolyte, reaction, ~] = initParams(paramFolder);
[cathode, electrolyte] = setupDiscretization(cathode, electrolyte, fem_opts);

V_limit = [cathode.ocp_fun(cathode.x0), cathode.ocp_fun(cathode.x1)];
Q_oneC = cathode.Q_th / cathode.A;

for p = 3:4
    Crate = crates(p);
    soc_init = soc_inits(p);
    i_C = process * Crate * Q_oneC;
    current = @(t) (t > 0 && t < T_end + 1) * i_C + (t == 0) * 0;

    modelParam = struct();
    modelParam.I_fun = current;
    modelParam.tspan = 0:dt:T_end;
    modelParam.soc_init = soc_init;
    modelParam.process = process;
    modelParam.V_limit = V_limit(2);

    [T, Y, results, cathode, electrolyte, anode] = runSPMe(cathode, electrolyte, anode, reaction, constants, modelParam);

    saveSimulationResults(resultsRoot, Crate, results, cathode, anode, electrolyte)

    clear results T Y
    fprintf('Completed C-rate %g\n', Crate);
end
