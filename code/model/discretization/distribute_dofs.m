function [el, dof] = distribute_dofs(el, p, grid)

% Initialize nodes-to-DOF map
dof.coordinates = [];
%nodes_to_dof = zeros(grid.number_of_elements + 1);
dof.number_of_dofs = p * grid.number_of_active_elements + 1;
curr_dof = 1;

for i = grid.active_elements
    % Loop through each DOF (from 1 to p+1)
    for j = 1:p+1
        % Calculate position of the current DOF (from left to right)
        % Relative position between nodes n(1) and n(2)
        if j == 1
            % Left node (first DOF)
            pos = grid.coordinates(el(i).n(1));
        elseif j == p+1
            % Right node (last DOF)
            pos = grid.coordinates(el(i).n(2));
        else
            % Intermediate DOFs (use linear spacing)
            alpha = (j - 1) / p;
            pos = (1 - alpha) * grid.coordinates(el(i).n(1)) + alpha * grid.coordinates(el(i).n(2));
        end

        % Check if the DOF already exists
        existing_dof = find(abs(dof.coordinates - pos) < 1e-12, 1);

        if isempty(existing_dof)
            % New DOF - assign it
            dof.coordinates(curr_dof) = pos;
            el(i).dof(j) = curr_dof;
            curr_dof = curr_dof + 1;
        else
            % Existing DOF - reuse it
            el(i).dof(j) = existing_dof;
        end
    end
end

% Update the total number of DOFs
dof.number_of_dofs = curr_dof - 1;

end
