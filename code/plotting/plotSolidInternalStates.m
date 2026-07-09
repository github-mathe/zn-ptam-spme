function figs = plotSolidInternalStates(simData, geomData, Crate, options)
%PLOTSOLIDINTERNALSTATES Plot solid concentration internal states.
%
% Required simData fields:
%   simData.soc_list
%   simData.state_list
%   simData.cs_avg
%   simData.cs
%   simData.labels
%
% Required geomData fields:
%   geomData.xr

    arguments
        simData struct
        geomData struct
        Crate (1, 1) double
        options struct = struct()
    end

    % ---------- Defaults ----------
    if ~isfield(options, 'saveFigures')
        options.saveFigures = false;
    end

    if ~isfield(options, 'figuresDir')
        options.figuresDir = pwd;
    end

    if ~isfield(options, 'figureBaseArgs')
        options.figureBaseArgs = {};
    end

    if ~isfield(options, 'fontName')
        options.fontName = 'Arial';
    end

    if ~isfield(options, 'fontSize')
        options.fontSize = 10;
    end

    if ~isfield(options, 'lwsim')
        options.lwsim = 1.5;
    end

    if ~isfield(options, 'lstProfiles')
        options.lstProfiles = '-';
    end

    if ~isfield(options, 'colorList')
        options.colorList = lines(numel(simData.state_list));
    end

    if ~isfield(options, 'scatterSize')
        options.scatterSize = 70;
    end

    if ~isfield(options, 'socLimits')
        options.socLimits = [-1, 101];
    end

    if ~isfield(options, 'radiusLimits')
        options.radiusLimits = [-0.1, 10.1];
    end

    if ~isfield(options, 'radiusTicks')
        options.radiusTicks = 0:1:10;
    end

    if ~isfield(options, 'csProfileLimits')
        options.csProfileLimits = [-400, 5000];
    end

    if ~isfield(options, 'fileNameCsAvg')
        options.fileNameCsAvg = sprintf('cs_avg_vs_soc_%gC', Crate);
    end

    if ~isfield(options, 'fileNameCsProfiles')
        options.fileNameCsProfiles = sprintf('cs_profiles_%gC', Crate);
    end

    % ---------- Validation ----------
    validateSolidInputs(simData, geomData);

    figs = struct();

    xr = geomData.xr(:).';
    stateList = simData.state_list(:);
    socList = simData.soc_list(:);
    csAvg = simData.cs_avg(:);
    cs = simData.cs;
    labels = simData.labels;

    % =====================================================================
    % 1. Average solid concentration vs SOC
    % =====================================================================
    figs.csAvgVsSoc = figure( ...
        options.figureBaseArgs{:}, ...
        'Units', 'centimeters', ...
        'Position', [0 0 12 8]);

    scatter( ...
        socList, ...
        csAvg(stateList), ...
        options.scatterSize, ...
        'r', ...
        'filled', ...
        'MarkerEdgeColor', 'k');

    xlabel('SOC [%]');
    ylabel('Average Concentration c_{s,avg} [mol/m^3]');

    xlim(options.socLimits);

    set(gca, ...
        'FontName', options.fontName, ...
        'FontSize', options.fontSize, ...
        'TickDir', 'in', ...
        'Box', 'on');

    saveFigureIfRequested( ...
        figs.csAvgVsSoc, ...
        options, ...
        options.fileNameCsAvg);

    % =====================================================================
    % 2. Radial solid concentration profiles
    % =====================================================================
    figs.csProfiles = figure( ...
        'PaperUnits', 'centimeters', ...
        'Units', 'centimeters', ...
        'Position', [0 0 14.3 8], ...
        options.figureBaseArgs{:});

    clf(figs.csProfiles);
    hold on;

    plot( ...
        xr, ...
        cs(1, :), ...
        '-', ...
        'LineWidth', options.lwsim);

    plot( ...
        xr, ...
        cs(stateList(2:end), :), ...
        options.lstProfiles, ...
        'LineWidth', options.lwsim);

    ylim(options.csProfileLimits);
    xlim(options.radiusLimits);
    xticks(options.radiusTicks);

    xlabel('Radius [\mum]');
    ylabel({'Concentration c_s [mol/m^3]'});

    colororder(options.colorList);

    legend(labels);
    legend( ...
        'Location', 'southoutside', ...
        'Orientation', 'horizontal', ...
        'FontName', options.fontName, ...
        'FontWeight', 'bold', ...
        'FontSize', options.fontSize, ...
        'IconColumnWidth', 10, ...
        'Box', 'on');

    set(gcf, 'Renderer', 'painters');

    set(gca, ...
        'FontName', options.fontName, ...
        'FontSize', options.fontSize, ...
        'TickDir', 'in', ...
        'Box', 'on');

    saveFigureIfRequested( ...
        figs.csProfiles, ...
        options, ...
        options.fileNameCsProfiles);

end


function validateSolidInputs(simData, geomData)

    requiredSimFields = { ...
        'soc_list', ...
        'state_list', ...
        'cs_avg', ...
        'cs', ...
        'labels'};

    for k = 1:numel(requiredSimFields)
        fieldName = requiredSimFields{k};

        if ~isfield(simData, fieldName)
            error('plotSolidInternalStates:MissingSimField', ...
                'simData is missing required field "%s".', fieldName);
        end

        if isempty(simData.(fieldName))
            error('plotSolidInternalStates:EmptySimField', ...
                'simData.%s is empty.', fieldName);
        end
    end

    if ~isfield(geomData, 'xr')
        error('plotSolidInternalStates:MissingGeomField', ...
            'geomData is missing required field "xr".');
    end

    if isempty(geomData.xr)
        error('plotSolidInternalStates:EmptyGeomField', ...
            'geomData.xr is empty.');
    end

    nTime = size(simData.cs, 1);
    nRadius = size(simData.cs, 2);

    if numel(geomData.xr) ~= nRadius
        error('plotSolidInternalStates:InvalidXrLength', ...
            'numel(geomData.xr) must equal size(simData.cs, 2).');
    end

    if numel(simData.cs_avg) ~= nTime
        error('plotSolidInternalStates:InvalidCsAvgLength', ...
            'numel(simData.cs_avg) must equal size(simData.cs, 1).');
    end

    if any(simData.state_list < 1) || any(simData.state_list > nTime)
        error('plotSolidInternalStates:InvalidStateList', ...
            'simData.state_list contains indices outside the valid time range.');
    end

    if numel(simData.soc_list) ~= numel(simData.state_list)
        error('plotSolidInternalStates:InvalidSocListLength', ...
            'simData.soc_list must have the same length as simData.state_list.');
    end

end
