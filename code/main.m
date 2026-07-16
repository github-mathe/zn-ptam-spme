clear all; close all;

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(scriptDir);
addpath(genpath(fullfile(repoRoot, 'code')));
defaults = loadSimulationDefaults();

% User input
workflow = 'single_case'; % 'single_case' or 'sweep'
Crate = 10;
selectedIdx = 4:numel(defaults.crates);
autoPlot = true;
saveFigures = true;
expMode = 'charge';
numOfStates = 5;

defaultRunName = 'default_cases';

switch workflow
    case 'single_case'
        cratesToRun = getDefaultSimulationCase(Crate, defaults).Crate;
    case 'sweep'
        cratesToRun = defaults.crates(selectedIdx);
    otherwise
        error('main:UnknownWorkflow', ...
            'workflow must be ''single_case'' or ''sweep''.');
end

for crateValue = cratesToRun
    caseOutput = runDefaultSimulationCase(repoRoot, crateValue, defaultRunName, defaults);
    fprintf('Completed C-rate %g\n', caseOutput.Crate);

    if autoPlot
        plotSavedCrateResults( ...
            repoRoot, ...
            caseOutput.Crate, ...
            defaultRunName, ...
            saveFigures, ...
            expMode, ...
            numOfStates);
    end

    fprintf('===============================\n');
end
