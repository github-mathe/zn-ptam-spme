clear all; close all;

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(scriptDir);
addpath(genpath(fullfile(repoRoot, 'code')));
defaults = loadSimulationDefaults();

Crate = 1;
runName = 'default_cases';

caseOutput = runDefaultSimulationCase(repoRoot, Crate, runName, defaults);

fprintf('Single-case run completed successfully. Results written to %s\n', ...
    caseOutput.caseFolder);
