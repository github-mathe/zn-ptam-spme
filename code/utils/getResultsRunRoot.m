function runRoot = getResultsRunRoot(resultsRoot, runName)
%GETRESULTSRUNROOT Build the root output folder for a named run workflow.

    arguments
        resultsRoot (1, :) char
        runName (1, :) char
    end

    runRoot = fullfile(resultsRoot, runName);

end
