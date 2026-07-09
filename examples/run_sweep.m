clear all; close all;

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(scriptDir);
addpath(genpath(fullfile(repoRoot, 'code')));
defaults = loadSimulationDefaults();

selectedIdx = 1:numel(defaults.crates);
runName = 'default_cases';

for crateValue = defaults.crates(selectedIdx)
    caseOutput = runDefaultSimulationCase(repoRoot, crateValue, runName, defaults);
    fprintf('Completed C-rate %g. Results written to %s\n', ...
        caseOutput.Crate, caseOutput.caseFolder);
end
