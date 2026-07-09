function params = loadPlotParameters(paramFolder)
%LOADPLOTPARAMETERS Load plotting-relevant parameters from a cell parameter CSV.
%
% params = loadPlotParameters(paramFolder)
%
% The function searches paramFolder for exactly one file ending with
% "cellParams.csv", then reads the required plotting/model parameters.
%
% Required symbols:
%   x0_p
%   x1_p
%   Q_th
%   c_s_max_p

    arguments
        paramFolder (1, :) char
    end

    if ~isfolder(paramFolder)
        error('loadPlotParameters:MissingFolder', ...
            'Parameter folder does not exist: %s', paramFolder);
    end

    csvFiles = dir(fullfile(paramFolder, '*cellParams.csv'));

    if isempty(csvFiles)
        error('loadPlotParameters:MissingParameterFile', ...
            'No file ending with cellParams.csv found in: %s', paramFolder);
    end

    if numel(csvFiles) > 1
        fileNames = string({csvFiles.name});

        error('loadPlotParameters:AmbiguousParameterFile', ...
            ['More than one file ending with cellParams.csv found in: %s\n' ...
             'Matching files:\n%s'], ...
            paramFolder, strjoin(fileNames, newline));
    end

    paramFile = fullfile(csvFiles(1).folder, csvFiles(1).name);

    parameterTable = readtable(paramFile);

    requiredColumns = {'Symbol', 'Value'};

    for k = 1:numel(requiredColumns)
        if ~ismember(requiredColumns{k}, parameterTable.Properties.VariableNames)
            error('loadPlotParameters:MissingColumn', ...
                'Parameter table is missing required column "%s".', ...
                requiredColumns{k});
        end
    end

    params = struct();

    params.file = paramFile;
    params.folder = paramFolder;

    params.x0_p = getParameterValue(parameterTable, 'x0_p');
    params.x1_p = getParameterValue(parameterTable, 'x1_p');
    params.Q_th_Ah = getParameterValue(parameterTable, 'Q_th');
    params.cs_max_p = getParameterValue(parameterTable, 'c_s_max_p');

    % Capacity used in plots is in microampere-hours.
    params.max_cap_uAh = params.Q_th_Ah * 1e6;

end


function value = getParameterValue(parameterTable, symbol)

    idx = string(parameterTable.Symbol) == string(symbol);

    if ~any(idx)
        error('loadPlotParameters:MissingSymbol', ...
            'Required parameter "%s" was not found.', symbol);
    end

    if nnz(idx) > 1
        error('loadPlotParameters:DuplicateSymbol', ...
            'Parameter "%s" appears more than once.', symbol);
    end

    value = parameterTable.Value(idx);

end