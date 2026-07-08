function [el,grid] = add_new_point(el,grid,point)
    elemIdx=[];
    dist = abs(point - [grid.coordinates]);
    [~,minIdx] = min(dist);
    grid.coordinates(minIdx) = point;
    elemIdx=[find(cellfun(@(m)ismember(minIdx,m),{el.n}) & [el.active]==1),elemIdx];
    % change the h - distance in elements where the coordinates were
    % changed
    for elemID = elemIdx
        el(elemID).h = abs(grid.coordinates(el(elemID).n(1)) - grid.coordinates(el(elemID).n(2)));
    end
end