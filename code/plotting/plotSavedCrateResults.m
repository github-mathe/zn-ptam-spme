function capError = plotSavedCrateResults(repoRoot, Crate, runName, saveFigures, expMode, numOfStates)
%PLOTSAVEDCRATERESULTS Plot saved results for one C-rate and one run group.

    arguments
        repoRoot (1, :) char
        Crate (1, 1) double
        runName (1, :) char = 'default_cases'
        saveFigures (1, 1) logical = true
        expMode (1, :) char = 'charge'
        numOfStates (1, 1) double {mustBeInteger, mustBePositive} = 5
    end

    addpath(genpath(fullfile(repoRoot, 'code')));
    paramFolder = fullfile(repoRoot, 'code', 'model', 'parameters', 'data');
    defaults = loadSimulationDefaults();
    caseInfo = getDefaultSimulationCase(Crate, defaults);
    params = loadPlotParameters(paramFolder);
    maxCap = params.max_cap_uAh;
    csMax = params.cs_max_p;

    resultsRoot = fullfile(repoRoot, 'results');
    runRoot = getResultsRunRoot(resultsRoot, runName);
    processedRoot = fullfile(repoRoot, 'data', 'processed');
    figuresDir = fullfile(runRoot, 'figures', sprintf('Crate_%g', Crate));
    figureVisibility = 'off';
    figureBaseArgs = {'Visible', figureVisibility, 'PaperPositionMode', 'auto'};

    if saveFigures && ~isfolder(figuresDir)
        mkdir(figuresDir);
    end

    simFolder = fullfile(runRoot, sprintf('Crate_%g', Crate));
    geometryFile = fullfile(simFolder, 'Geometry_cell.mat');
    [xr, xe, xe_sep, xe_pos] = loadPlotGeometry(geometryFile);

    expFolder = fullfile(processedRoot, sprintf('%g', Crate));
    expData = loadPlotExperiment(expFolder, expMode);
    simData = loadPlotSimulation(simFolder, numOfStates, csMax);

    fprintf('Plots for %gC\n', Crate);

    lwsim = 3;
    lstexp = '-';
    colorList = winter(numOfStates);
    colorList(1,:) = [0, 0, 0];
    crateColors = lines(numel(defaults.crates));
    baseOptions = struct( ...
        'saveFigures', saveFigures, ...
        'figuresDir', figuresDir, ...
        'figureBaseArgs', {figureBaseArgs});
    optionsExpSim = baseOptions;
    optionsExpSim.color = crateColors(caseInfo.index, :);

    optionsCap = optionsExpSim;
    optionsCap.xLimits = [-1, maxCap];
    optionsCap.xLabel = 'Capacity [\muAh]';
    optionsCap.yLabel = 'Voltage [V]';
    optionsCap.fileName = sprintf('voltage_vs_capacity_%gC', Crate);
    plotExpSimXY(expData, simData, Crate, 'cap', 'V', optionsCap);

    optionsSoc = optionsExpSim;
    optionsSoc.xLimits = [-1, 101];
    optionsSoc.xLabel = 'SOC [%]';
    optionsSoc.yLabel = 'Voltage [V]';
    optionsSoc.fileName = sprintf('voltage_vs_soc_%gC', Crate);
    plotExpSimXY(expData, simData, Crate, 'soc', 'V', optionsSoc);

    optionsComponents = baseOptions;
    optionsComponents.fileName = sprintf('voltage_components_%gC', Crate);
    plotVoltageComponents(simData, Crate, optionsComponents);

    geomData = struct();
    geomData.xe = xe;
    geomData.xe_sep = xe_sep;
    geomData.xe_pos = xe_pos;

    optionsElectrolyte = baseOptions;
    optionsElectrolyte.lwsim = lwsim;
    optionsElectrolyte.lstProfiles = lstexp;
    optionsElectrolyte.colorList = colorList;
    plotElectrolyteInternalStates(simData, geomData, Crate, optionsElectrolyte);

    geomData.xr = xr;
    optionsSolid = baseOptions;
    optionsSolid.lwsim = lwsim;
    optionsSolid.lstProfiles = lstexp;
    optionsSolid.colorList = colorList;
    plotSolidInternalStates(simData, geomData, Crate, optionsSolid);

    capError = computeCapacityRelativeError(expData, simData);
    fprintf('Relative capacity error: %.2f%%\n', capError.rel_error_percent);

end
