function fig = plotExpSimXY(expData, simData, Crate, xField, yField, options)
%PLOTEXPSIMXY Plot experimental and simulated data against a common x-y pair.
%
% fig = plotExpSimXY(expData, simData, Crate, xField, yField, options)
%
% Example:
%   plotExpSimXY(expData, simData, Crate, 'cap', 'V', options)
%   plotExpSimXY(expData, simData, Crate, 'soc', 'V', options)

    arguments
        expData struct
        simData struct
        Crate (1, 1) double
        xField (1, :) char
        yField (1, :) char
        options struct = struct()
    end

    % ---------- Defaults ----------
    if ~isfield(options, 'saveFigures')
        options.saveFigures = false;
    end

    if ~isfield(options, 'figuresDir')
        options.figuresDir = pwd;
    end

    if ~isfield(options, 'xLabel')
        options.xLabel = xField;
    end

    if ~isfield(options, 'yLabel')
        options.yLabel = yField;
    end

    if ~isfield(options, 'xLimits')
        options.xLimits = [];
    end

    if ~isfield(options, 'yLimits')
        options.yLimits = [];
    end

    if ~isfield(options, 'legendLocation')
        options.legendLocation = 'south';
    end

    if ~isfield(options, 'fileName')
        options.fileName = sprintf('%s_vs_%s_%gC', yField, xField, Crate);
    end

    if ~isfield(options, 'color')
        options.color = lines(1);
    end

    if ~isfield(options, 'lstexp')
        options.lstexp = '-';
    end

    if ~isfield(options, 'lstsim')
        options.lstsim = '--';
    end

    if ~isfield(options, 'lwexp')
        options.lwexp = 3;
    end

    if ~isfield(options, 'lwsim')
        options.lwsim = 3;
    end

    if ~isfield(options, 'figureBaseArgs')
        options.figureBaseArgs = {};
    end

    if ~isfield(options, 'position')
        options.position = [0 0 12 8];
    end

    if ~isfield(options, 'fontName')
        options.fontName = 'Arial';
    end

    if ~isfield(options, 'fontSize')
        options.fontSize = 10;
    end

    % ---------- Validate simulation data ----------
    validateXYData(simData, 'simData', xField, yField);

    % ---------- Check experimental data ----------
    hasExperiment = ...
        isfield(expData, xField) && ...
        isfield(expData, yField) && ...
        ~isempty(expData.(xField)) && ...
        ~isempty(expData.(yField));

    if hasExperiment
        validateXYData(expData, 'expData', xField, yField);
    end

    % ---------- Plot ----------
    fig = figure( ...
        options.figureBaseArgs{:}, ...
        'Units', 'centimeters', ...
        'Position', options.position);

    hold on;

    if hasExperiment
        plot( ...
            expData.(xField), ...
            expData.(yField), ...
            options.lstexp, ...
            'Color', options.color, ...
            'LineWidth', options.lwexp, ...
            'DisplayName', sprintf('Experiment %gC', Crate));
    end

    plot( ...
        simData.(xField), ...
        simData.(yField), ...
        options.lstsim, ...
        'Color', options.color, ...
        'LineWidth', options.lwsim, ...
        'DisplayName', sprintf('SPMe %gC', Crate));

    xlabel(options.xLabel);
    ylabel(options.yLabel);

    legend('Location', options.legendLocation);

    set(gca, ...
        'FontName', options.fontName, ...
        'FontSize', options.fontSize, ...
        'TickDir', 'in', ...
        'Box', 'on');

    if ~isempty(options.xLimits)
        xlim(options.xLimits);
    end

    if ~isempty(options.yLimits)
        ylim(options.yLimits);
    end

    saveFigureIfRequested(fig, options, options.fileName);

end


function validateXYData(data, dataName, xField, yField)
%VALIDATEXYDATA Validate that data contains compatible x/y fields.

    if ~isfield(data, xField)
        error('plotExpSimXY:MissingXField', ...
            '%s is missing required x-field "%s".', dataName, xField);
    end

    if ~isfield(data, yField)
        error('plotExpSimXY:MissingYField', ...
            '%s is missing required y-field "%s".', dataName, yField);
    end

    if isempty(data.(xField))
        error('plotExpSimXY:EmptyXField', ...
            '%s.%s is empty.', dataName, xField);
    end

    if isempty(data.(yField))
        error('plotExpSimXY:EmptyYField', ...
            '%s.%s is empty.', dataName, yField);
    end

    if numel(data.(xField)) ~= numel(data.(yField))
        error('plotExpSimXY:InconsistentLengths', ...
            '%s.%s and %s.%s must have the same number of elements.', ...
            dataName, xField, dataName, yField);
    end

end
