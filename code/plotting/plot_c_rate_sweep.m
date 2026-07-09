clear all; close all;

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDir));

Crate = 1;
runName = 'default_cases';
saveFigures = true;
expMode = 'charge';
numOfStates = 5;

plotSavedCrateResults(repoRoot, Crate, runName, saveFigures, expMode, numOfStates);
