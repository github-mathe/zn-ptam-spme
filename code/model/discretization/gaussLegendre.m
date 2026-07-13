function [x, w] = gaussLegendre(N, a, b)
%GAUSSLEGENDRE Gauss-Legendre nodes and weights on [a,b].

    arguments
        N (1,1) double {mustBeInteger, mustBePositive}
        a (1,1) double
        b (1,1) double
    end

    if b <= a
        error('gaussLegendre:InvalidInterval', ...
              'The upper endpoint must be greater than the lower endpoint.');
    end

    k = (1:N-1)';
    beta = k ./ sqrt(4*k.^2 - 1);

    J = diag(beta, 1) + diag(beta, -1);
    [V, D] = eig(J, 'vector');

    [t, order] = sort(D);
    V = V(:, order);

    % Nodes and weights on [-1,1]
    weightsCanonical = 2 * (V(1, :).').^2;

    % Map to [a,b]
    x = ((b-a) * t + (a+b)) / 2;
    w = (b-a) * weightsCanonical / 2;
end