function saveFigureIfRequested(figHandle, options, fileName)
%SAVEFIGUREIFREQUESTED Save a figure when the plotting options request it.

    arguments
        figHandle
        options struct
        fileName (1, :) char
    end

    if ~isfield(options, 'saveFigures') || ~options.saveFigures
        return;
    end

    if ~isfield(options, 'figuresDir') || isempty(options.figuresDir)
        error('saveFigureIfRequested:MissingOutputDir', ...
            'options.figuresDir must be provided when saveFigures is true.');
    end

    saveCurrentFigure(figHandle, true, options.figuresDir, fileName);

end
