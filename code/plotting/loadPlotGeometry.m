function [xr, xe, xe_sep, xe_pos] = loadPlotGeometry(geometryFile)
if ~isfile(geometryFile)
    error('loadPlotGeometry:MissingGeometry', 'Missing geometry file: %s', geometryFile);
end

geometry = load(geometryFile);

xr = geometry.cathode.sorted_dofs(:) * 1e6;
xe = geometry.electrolyte.sorted_dofs(:) * 1e6;
xe_sep = xe(1:geometry.electrolyte.Ns);
xe_pos = xe(geometry.electrolyte.Ns+1:end);
end