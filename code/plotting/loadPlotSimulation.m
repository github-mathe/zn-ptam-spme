function simData = loadPlotSimulation(simFolder, numOfStates, cSMax)
%LOADPLOTSIMULATION Load and preprocess simulation results for plotting.
%
% simData = loadPlotSimulation(simFolder, numOfStates, cSMax)
%
% Inputs
%   simFolder   - Folder containing one simulation CSV file, e.g. sim_10.csv
%   numOfStates - Number of representative states used for profile plots
%   cSMax       - Maximum solid concentration
%
% Output
%   simData     - Struct containing raw table and processed plotting fields

    arguments
        simFolder (1, :) char
        numOfStates (1, 1) double {mustBeInteger, mustBePositive}
        cSMax (1, 1) double {mustBePositive}
    end

    if numOfStates < 2
        error('loadPlotSimulation:TooFewStates', ...
            'numOfStates must be at least 2 because the profile plots require at least two sampled states.');
    end

    if ~isfolder(simFolder)
        error('loadPlotSimulation:MissingFolder', ...
            'Simulation folder does not exist: %s', simFolder);
    end

    simFiles = dir(fullfile(simFolder, 'sim_*.csv'));

    if isempty(simFiles)
        error('loadPlotSimulation:MissingSimulation', ...
            'No simulation file matching sim_*.csv found in: %s', simFolder);
    elseif numel(simFiles) > 1
        error('loadPlotSimulation:AmbiguousSimulation', ...
            'More than one sim_*.csv file found in: %s', simFolder);
    end

    simFile = fullfile(simFolder, simFiles(1).name);
    simTable = readtable(simFile);

    lenSim = height(simTable);

    if numOfStates > lenSim
        error('loadPlotSimulation:TooManyStates', ...
            'numOfStates = %d exceeds number of simulation rows = %d.', ...
            numOfStates, lenSim);
    end

    stateList = round(linspace(1, lenSim, numOfStates));

    csNames = startsWith(simTable.Properties.VariableNames, 'Cs_');
    ceNames = startsWith(simTable.Properties.VariableNames, 'Ce_');

    if ~any(csNames)
        error('loadPlotSimulation:MissingSolidProfiles', ...
            'No columns starting with Cs_ were found.');
    end

    if ~any(ceNames)
        error('loadPlotSimulation:MissingElectrolyteProfiles', ...
            'No columns starting with Ce_ were found.');
    end

    requiredVariables = { ...
        'cell_SOC', ...
        'Capacity', ...
        'Voltage_pos', ...
        'Css', ...
        'AvgCs', ...
        'AvgCe', ...
        'AvgCe_pos', ...
        'AvgCe_sep', ...
        'Time', ...
        'Etha_cathode', ...
        'Etha_anode', ...
        'delta_Phie'};

    missingVariables = setdiff(requiredVariables, simTable.Properties.VariableNames);

    if ~isempty(missingVariables)
        error('loadPlotSimulation:MissingVariables', ...
            'The simulation file is missing required variables: %s', ...
            strjoin(missingVariables, ', '));
    end

simData = struct();

    % Metadata
    simData.file = simFile;
    simData.table = simTable;
    simData.len = lenSim;
    simData.state_list = stateList;

    % Main scalar outputs
    simData.soc = simTable.cell_SOC .* 100;
    simData.cap = simTable.Capacity .* 1e6;
    simData.V = simTable.Voltage_pos;
    simData.time = simTable.Time;

    % Solid concentration
    simData.css = simTable.Css;
    simData.cs_avg = simTable.AvgCs;
    simData.cs = table2array(simTable(:, csNames));
    simData.cs_names = simTable.Properties.VariableNames(csNames);

    % Electrolyte concentration
    simData.ce_avg = simTable.AvgCe;
    simData.ce_avg_pos = simTable.AvgCe_pos;
    simData.ce_avg_sep = simTable.AvgCe_sep;
    simData.ce = table2array(simTable(:, ceNames));
    simData.ce_names = simTable.Properties.VariableNames(ceNames);

    % Representative states for profile plots
    simData.soc_list = simData.soc(stateList);
    simData.time_list = simData.time(stateList);

    simData.labels = strcat( ...
        "t = ", string(num2cell(round(simData.time_list))), ...
        "\newlineSOC = ", string(num2cell(round(simData.soc_list))) );

    % Voltage components
    simData.particle_overpotential = ...
        interp_ocp(simData.css ./ cSMax, 'soc2v') ...
        - interp_ocp(simData.cs_avg ./ cSMax, 'soc2v');

    simData.OCP_p = interp_ocp(simData.cs_avg ./ cSMax, 'soc2v');
    simData.etha_pos = simTable.Etha_cathode;
    simData.etha_neg = simTable.Etha_anode;
    simData.phie_cathode = simTable.delta_Phie - simData.etha_neg;

    simData.components = [ ...
        simData.OCP_p, ...
        simData.particle_overpotential, ...
        simData.etha_pos, ...
        simData.phie_cathode];

end
