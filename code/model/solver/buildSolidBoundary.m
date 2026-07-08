function boundaryFunc = buildSolidBoundary(eq)
% buildSolidBoundary: Returns a dynamic boundary condition function
% Inputs:
%   eq - struct with .fem_p, .N, .domain, .j_n(t)
% Output:
%   boundaryFunc - function handle @(t, c)

    p = eq.fem_p;
    N = eq.N;
    boundaryFunc = @(t, c) [zeros(p * N, 1); eq.boundary_end(t)*eq.domain(end)^2];
end
