function [expData] = loadPlotExperiment(expFolder, expMode)
expData.soc = [];
expData.cap = [];
expData.V = [];

if isempty(expMode)
    candidatePatterns = {'charge_*C.csv', 'discharge_*C.csv'};
else
    candidatePatterns = {sprintf('%s_*C.csv', expMode)};
end

for k = 1:numel(candidatePatterns)
    candidateFiles = dir(fullfile(expFolder, candidatePatterns{k}));
    if isempty(candidateFiles)
        continue;
    end

    [~, order] = sort({candidateFiles.name});
    expFile = fullfile(expFolder, candidateFiles(order(1)).name);
    exp = readtable(expFile);

    expData.soc = exp.soc_cell .* 100;
    expData.cap = exp.C_A_h .* 1e6;
    expData.V = exp.Ewe_V;
    return;
end

warning('loadPlotExperiment:MissingExperiment', ...
    'No experimental file found in %s. Expected charge or discharge CSV.', expFolder);
end