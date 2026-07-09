function saveCurrentFigure(figHandle, shouldSave, outputDir, baseName)
if ~shouldSave
    return;
end
if ~isfolder(outputDir)
    mkdir(outputDir);
end
exportgraphics(figHandle, fullfile(outputDir, [baseName '.png']),"Resolution",600);
exportgraphics(figHandle, fullfile(outputDir, [baseName '.pdf']),'ContentType','vector');
end