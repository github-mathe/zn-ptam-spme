function [Phi,pvals_der] = eval_derivative_shape_functions(xq,p) 
% The shape functions can be defined in a Matlab function
% [ Phi] = eval_shape_functions(xq,p) ,
% where p = 1 renders the linear basis function, p = 2 the quadratic basis funct
% ion, and
% p = 3 the cubic basis function values. For example, with p = 2 the outputs are
% Phi(1) , Ph(2) , Phi(3) , three basis function values,
% dpsi(1) , dpsi(2) , dpsi(3) , three derivative values.
% The Matlab subroutine is as follows.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% Function ‘‘eval_shape_functions’’ evaluates the values of the basis functions
%
% and their derivatives at a point xq. %
% %
% p: The basis function. p=2, linear, p=3, quadratic, p=3, cubic. %
% xq: The point where the base function is evaluated. %
% Output: %
% phi: The value of the base function at xi. %
% dphi: The derivative of the base function at xi. %
%--------------------------------------------------------------------%
[~,pvals] = eval_shape_functions(xq,p); 
for i=1:p+1
    pvals_der(i,:) = polyder(pvals(i,:));
    Phi(i,:) = polyval(pvals_der(i,:),xq);
end