function [grid,el] = create_grid_1D(a,b,num_ref)

%INPUT: Interval [a,b], number of refinments numref
%OUTPUT: Grid after num_ref global refinement steps
%   coordinates .......... coordinates of the nodes in the order of creating
%   active_elements....... indices of the active elements 
%   number_of_active_elements
%   number_of_elements ... number of all active and inactive elements
%   level ................ maximum of refinnig levels of all elements
%   pairs ................ pairings of all elements with the same parent
%
% 
% The elements are structured as follws:
%   id ................ unique index
%   h ................. width of the element
%   n = [n(1),n(2)] ... node indices matching to the coordinates in
%                       grid.coordinates
%   active ............ true if element is active, false if it is inactive
%   level ............. level of refinement
%   children .......... indices of elements created from this element
%   parent ............ index of creating elements
%   refining .......... flag to mark element to be refined
%   coarsening ........ flag to mark element to be coarsened

% create an initial grid and el

grid.coordinates(1) = a;
grid.coordinates(2) = b;

nE = 1;
el(1).id = 1;
el(1).h = abs(a-b);
el(1).n(1) = 1;
el(1).n(2) = 2;
el(1).active = true;
el(1).level = 1;
el(1).children = [];
el(1).parent = [];
el(1).refining = false;
el(1).coarsening = false;

admissible_pairs = [];

for ref = 1:num_ref
    % loop over all active elements
    for k = 2^(ref-1):2^(ref)-1

        el(k).active = false;           % set parent element as inactive

        % Add new coordinate
        grid.coordinates(k+2) = (grid.coordinates(el(k).n(1))+grid.coordinates(el(k).n(2)))/2;


        % create first child
        el(2*k).active = true;
        el(2*k).level = ref + 1;
        el(2*k).n(1) = el(k).n(1);
        el(2*k).n(2) = k+2;
        el(2*k).h = abs(grid.coordinates(el(2*k).n(1))- grid.coordinates(el(2*k).n(2)));
        el(2*k).id = 2*k;
        el(2*k).refining = false;
        el(2*k).coarsening = false;
        
        
        % create second child
        el(2*k+1).active = true;
        el(2*k+1).level = ref + 1;
        el(2*k+1).n(1) = k+2;
        el(2*k+1).n(2) = el(k).n(2);
        el(2*k+1).h = abs(grid.coordinates(el(2*k+1).n(1))- grid.coordinates(el(2*k+1).n(2)));
        el(2*k+1).id = 2*k+1;
        el(2*k+1).refining = false;
        el(2*k+1).coarsening = false;
        
        % generate admissible pairs
        pair = [2*k,2*k+1];             
       
        % connect parent element with children  
        el(k).children = [2*k, 2*k+1];
        el(2*k).parent = k;
        el(2*k+1).parent = k;
        
        nE = nE + 1;

        admissible_pairs = [admissible_pairs; pair];
    end 
end

% update grid
grid.active_elements = 2^(num_ref):2^(num_ref+1)-1;
grid.number_of_active_elements = nE;
grid.number_of_elements = length(el);
grid.level = num_ref;
grid.pairs = admissible_pairs;


end