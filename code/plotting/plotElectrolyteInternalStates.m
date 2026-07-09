function figs = plotElectrolyteInternalStates(simData, geomData, Crate, options)
%PLOTELECTROLYTEINTERNALSTATES Plot electrolyte concentration internal states.
%
% figs = plotElectrolyteInternalStates(simData, geomData, Crate, options)
%
% Required simData fields:
%   simData.soc
%   simData.soc_list
%   simData.state_list
%   simData.ce
%   simData.ce_avg
%   simData.ce_avg_sep
%   simData.ce_avg_pos
%   simData.labels
%
% Required geomData fields:
%   geomData.xe
%   geomData.xe_sep
%   geomData.xe_pos

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

    if ~isfield(options, 'xLimitsSoc')
        options.xLimitsSoc = [-1, 101];
    end

    if ~isfield(options, 'xLimitsThickness')
        options.xLimitsThickness = [-1, 216];
    end

    if ~isfield(options, 'xTicksThickness')
        options.xTicksThickness = 0:50:200;
    end

    if ~isfield(options, 'profileYMax')
        options.profileYMax = 2010;
    end

    if ~isfield(options, 'scatterSize')
        options.scatterSize = 70;
    end

    if ~isfield(options, 'fileNameCeAvg')
        options.fileNameCeAvg = sprintf('ce_avg_vs_soc_%gC', Crate);
    end

    if ~isfield(options, 'fileNameCeProfiles')
        options.fileNameCeProfiles = sprintf('ce_profiles_%gC', Crate);
    end

    if ~isfield(options, 'fileNameCeEndCharge')
        options.fileNameCeEndCharge = sprintf('ce_end_charge_%gC', Crate);
    end

    % ---------- Validation ----------
    validateElectrolyteInputs(simData, geomData);

    figs = struct();

    xe = geomData.xe(:).';
    xe_sep = geomData.xe_sep(:).';
    xe_pos = geomData.xe_pos(:).';

    stateList = simData.state_list(:);
    socList = simData.soc_list(:);
    labels = simData.labels;

    ce = simData.ce;
    ceAvg = simData.ce_avg(:);
    ceAvgSep = simData.ce_avg_sep(:);
    ceAvgPos = simData.ce_avg_pos(:);

    % =====================================================================
    % 1. Average electrolyte concentration vs SOC
    % =====================================================================
    figs.ceAvgVsSoc = figure( ...
        options.figureBaseArgs{:}, ...
        'Units', 'centimeters', ...
        'Position', [0 0 12 8]);

    scatter( ...
        socList, ...
        ceAvg(stateList), ...
        options.scatterSize, ...
        'b', ...
        'filled', ...
        'MarkerEdgeColor', 'k');

    xlabel('SOC [%]');
    ylabel('Average Concentration c_{e,avg} [mol/m^3]');

    xlim(options.xLimitsSoc);
    ylim([min(ceAvg) - 10, max(ceAvg) + 10]);

    set(gca, ...
        'FontName', options.fontName, ...
        'FontSize', options.fontSize, ...
        'TickDir', 'in', ...
        'Box', 'on');

    saveFigureIfRequested( ...
        figs.ceAvgVsSoc, ...
        options, ...
        options.fileNameCeAvg);

    % =====================================================================
    % 2. Electrolyte concentration profiles
    % =====================================================================
    figs.ceProfiles = figure( ...
        options.figureBaseArgs{:}, ...
        'Units', 'centimeters', ...
        'Position', [0 0 14.3 8]);

    clf(figs.ceProfiles);
    hold on;

    plot( ...
        xe, ...
        ce(1, :), ...
        '-', ...
        'LineWidth', options.lwsim, ...
        'MarkerSize', 10);

    plot( ...
        xe, ...
        ce(stateList(2:end), :), ...
        options.lstProfiles, ...
        'LineWidth', options.lwsim);

    addSeparatorLine(xe_sep(end));

    xlabel('Thickness [\mum]');
    ylabel('Concentration c_e [mol/m^3]');

    ylim([min(ce(end, :)), options.profileYMax]);
    xlim(options.xLimitsThickness);
    xticks(options.xTicksThickness);

    colororder(options.colorList);
    colormap(options.colorList);

    legend(labels);
    legend show;
    legend( ...
        'Location', 'southoutside', ...
        'Orientation', 'horizontal', ...
        'FontWeight', 'bold', ...
        'IconColumnWidth', 10, ...
        'FontSize', options.fontSize, ...
        'Box', 'on');

    set(gcf, 'Renderer', 'painters');

    set(gca, ...
        'FontName', options.fontName, ...
        'FontSize', options.fontSize, ...
        'TickDir', 'in', ...
        'Box', 'on');

    saveFigureIfRequested( ...
        figs.ceProfiles, ...
        options, ...
        options.fileNameCeProfiles);

    % =====================================================================
    % 3. End-of-charge electrolyte profile and averages
    % =====================================================================
    figs.ceEndCharge = figure( ...
        options.figureBaseArgs{:}, ...
        'Units', 'centimeters', ...
        'Position', [0 0 14.3 8]);

    clf(figs.ceEndCharge);
    hold on;

    plot( ...
        xe, ...
        ce(end, :), ...
        '-', ...
        'LineWidth', 1.5, ...
        'Color', [0.5 0.5 0.5], ...
        'DisplayName', 'c_e');

    plot( ...
        xe_sep, ...
        ceAvgSep(end) .* ones(size(xe_sep)), ...
        '-', ...
        'LineWidth', options.lwsim, ...
        'Color', 'r', ...
        'DisplayName', 'Average c_{e,sep}');

    plot( ...
        xe_pos, ...
        ceAvgPos(end) .* ones(size(xe_pos)), ...
        '-', ...
        'LineWidth', options.lwsim, ...
        'Color', [1 0.6 0.6], ...
        'DisplayName', 'Average c_{e,pos}');

    plot( ...
        xe, ...
        ceAvg(end) .* ones(size(xe)), ...
        '--', ...
        'LineWidth', 2, ...
        'Color', [0.6 1 0.6], ...
        'DisplayName', 'Average c_e');

    addSeparatorLine(xe_sep(end));

    xlabel('Thickness [\mum]');
    ylabel(sprintf('Salt concentration c_e [mol/m^3]\n at the end of charge'));

    xlim(options.xLimitsThickness);
    xticks(options.xTicksThickness);

    legend show;
    legend( ...
        'Location', 'southoutside', ...
        'Orientation', 'horizontal', ...
        'FontWeight', 'bold', ...
        'IconColumnWidth', 10, ...
        'FontSize', options.fontSize, ...
        'Box', 'on');

    set(gcf, 'Renderer', 'painters');

    set(gca, ...
        'FontName', options.fontName, ...
        'FontSize', options.fontSize, ...
        'TickDir', 'in', ...
        'Box', 'on');

    saveFigureIfRequested( ...
        figs.ceEndCharge, ...
        options, ...
        options.fileNameCeEndCharge);

end


function addSeparatorLine(xSepEnd)

    xSep = xline(xSepEnd, 'LineWidth', 3);
    xSep.Label = 'L_{sep}';
    xSep.LabelHorizontalAlignment = "center";
    xSep.LabelVerticalAlignment = 'middle';
    xSep.LineStyle = '--';
    xSep.HandleVisibility = "off";

end


function validateElectrolyteInputs(simData, geomData)

    requiredSimFields = { ...
        'soc_list', ...
        'state_list', ...
        'ce', ...
        'ce_avg', ...
        'ce_avg_sep', ...
        'ce_avg_pos', ...
        'labels'};

    for k = 1:numel(requiredSimFields)
        fieldName = requiredSimFields{k};

        if ~isfield(simData, fieldName)
            error('plotElectrolyteInternalStates:MissingSimField', ...
                'simData is missing required field "%s".', fieldName);
        end

        if isempty(simData.(fieldName))
            error('plotElectrolyteInternalStates:EmptySimField', ...
                'simData.%s is empty.', fieldName);
        end
    end

    requiredGeomFields = {'xe', 'xe_sep', 'xe_pos'};

    for k = 1:numel(requiredGeomFields)
        fieldName = requiredGeomFields{k};

        if ~isfield(geomData, fieldName)
            error('plotElectrolyteInternalStates:MissingGeomField', ...
                'geomData is missing required field "%s".', fieldName);
        end

        if isempty(geomData.(fieldName))
            error('plotElectrolyteInternalStates:EmptyGeomField', ...
                'geomData.%s is empty.', fieldName);
        end
    end

    nTime = size(simData.ce, 1);
    nSpace = size(simData.ce, 2);

    if numel(geomData.xe) ~= nSpace
        error('plotElectrolyteInternalStates:InvalidXeLength', ...
            'numel(geomData.xe) must equal size(simData.ce, 2).');
    end

    if numel(simData.ce_avg) ~= nTime
        error('plotElectrolyteInternalStates:InvalidCeAvgLength', ...
            'numel(simData.ce_avg) must equal size(simData.ce, 1).');
    end

    if numel(simData.ce_avg_sep) ~= nTime
        error('plotElectrolyteInternalStates:InvalidCeAvgSepLength', ...
            'numel(simData.ce_avg_sep) must equal size(simData.ce, 1).');
    end

    if numel(simData.ce_avg_pos) ~= nTime
        error('plotElectrolyteInternalStates:InvalidCeAvgPosLength', ...
            'numel(simData.ce_avg_pos) must equal size(simData.ce, 1).');
    end

    if any(simData.state_list < 1) || any(simData.state_list > nTime)
        error('plotElectrolyteInternalStates:InvalidStateList', ...
            'simData.state_list contains indices outside the valid time range.');
    end

end
