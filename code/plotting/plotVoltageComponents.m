function fig = plotVoltageComponents(simData, Crate, options)
%PLOTVOLTAGECOMPONENTS Plot stacked voltage decomposition.
%
% Required simData fields:
%   simData.cap
%   simData.V
%   simData.components

    arguments
        simData struct
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

    if ~isfield(options, 'position')
        options.position = [0 0 14.3 8];
    end

    if ~isfield(options, 'fileName')
        options.fileName = sprintf('voltage_components_%gC', Crate);
    end

    if ~isfield(options, 'componentColors')
        options.componentColors = [ ...
            0.98 0.71 0.38;
            0.55 0.78 0.47;
            0.95 0.52 0.52;
            0.70 0.58 0.82];
    end

    if ~isfield(options, 'fontName')
        options.fontName = 'Arial';
    end

    if ~isfield(options, 'fontSize')
        options.fontSize = 10;
    end

    if ~isfield(options, 'legendLocation')
        options.legendLocation = 'northwest';
    end

    if ~isfield(options, 'xLabel')
        options.xLabel = 'Capacity [\muAh]';
    end

    if ~isfield(options, 'yLabel')
        options.yLabel = 'Voltage [V]';
    end

    if ~isfield(options, 'voltageLineStyle')
        options.voltageLineStyle = 'k--';
    end

    if ~isfield(options, 'voltageLineWidth')
        options.voltageLineWidth = 1.5;
    end

    if ~isfield(options, 'vMaxLineStyle')
        options.vMaxLineStyle = 'k-';
    end

    if ~isfield(options, 'vMaxLineWidth')
        options.vMaxLineWidth = 1;
    end

    % ---------- Validation ----------
    validateVoltageComponentsInput(simData, options);

    cap = simData.cap(:);
    V = simData.V(:);
    components = simData.components;

    if size(components, 1) ~= numel(cap)
        error('plotVoltageComponents:InvalidComponentSize', ...
            'simData.components must have the same number of rows as simData.cap.');
    end


    % ---------- Plot ----------
    fig = figure( ...
        options.figureBaseArgs{:}, ...
        'Units', 'centimeters', ...
        'Position', options.position, ...
        'Color', 'w');

    clf(fig);
    hold on;

    cumulativeComponents = cumsum(components, 2);
    previous = zeros(size(cap));

    for k = 1:size(components, 2)
        bottom = previous;
        top = cumulativeComponents(:, k);

        fill( ...
            [cap; flipud(cap)], ...
            [top; flipud(bottom)], ...
            options.componentColors(k, :), ...
            'EdgeColor', 'none');

        previous = cumulativeComponents(:, k);
    end

    Vmax = max(V);

    plot(cap, V, options.voltageLineStyle, ...
        'LineWidth', options.voltageLineWidth);

    plot([cap(1), cap(end)], [Vmax, Vmax], options.vMaxLineStyle, ...
        'LineWidth', options.vMaxLineWidth);

    ylim([min(V) - 0.02, Vmax + 0.02]);
    xlim([min(cap) - 0.001, max(cap) + 0.001]);

    xlabel(options.xLabel);
    ylabel(options.yLabel);

    box on;

    set(gca, ...
        'Layer', 'top', ...
        'FontName', options.fontName, ...
        'FontSize', options.fontSize, ...
        'TickDir', 'in');

    legend({ ...
        'OCP', ...
        'Particle conc. overpotential', ...
        'Reaction overpotential in pos. electrode', ...
        'Overpotential and ohmic loss in electrolyte', ...
        'Voltage'}, ...
        'Location', options.legendLocation);

    saveFigureIfRequested(fig, options, options.fileName);

end


function validateVoltageComponentsInput(simData, options)

    requiredFields = {'cap', 'V', 'components'};

    for k = 1:numel(requiredFields)
        fieldName = requiredFields{k};

        if ~isfield(simData, fieldName)
            error('plotVoltageComponents:MissingField', ...
                'simData is missing required field "%s".', fieldName);
        end

        if isempty(simData.(fieldName))
            error('plotVoltageComponents:EmptyField', ...
                'simData.%s is empty.', fieldName);
        end
    end

    if numel(simData.cap) ~= numel(simData.V)
        error('plotVoltageComponents:InconsistentLength', ...
            'simData.cap and simData.V must have the same number of elements.');
    end

    if size(simData.components, 2) ~= 4
        error('plotVoltageComponents:InvalidComponentNumber', ...
            'Expected simData.components to contain exactly 4 columns.');
    end

    if size(options.componentColors, 1) < size(simData.components, 2)
        error('plotVoltageComponents:NotEnoughColors', ...
            'options.componentColors must contain at least %d rows.', ...
            size(simData.components, 2));
    end

    if size(options.componentColors, 2) ~= 3
        error('plotVoltageComponents:InvalidColorMatrix', ...
            'options.componentColors must be an N-by-3 RGB matrix.');
    end

end
