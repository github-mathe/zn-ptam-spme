function [num_map] = renumbering(coordinates)

[~,I] = sort(coordinates);

for i = 1:length(I)

    num_map(I(i)) = i;

end

end