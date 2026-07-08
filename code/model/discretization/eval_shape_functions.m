function [Phi,pvals] = eval_shape_functions(xq,p) 
% The shape functions can be defined in a Matlab function
% [ phi] = eval_shape_functions(xq,p) 

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
%--------------------------------------------------------------------%
pvals = linspace(0,1,p+1);
ref_xnodes = [0:1/p:1]'; 
for i=1:p+1
    pp = poly(ref_xnodes((1:p+1)~=i));
    pvals(i,:) = pp./polyval(pp,ref_xnodes(i));
    Phi(i,:) = polyval(pvals(i,:),xq);
end