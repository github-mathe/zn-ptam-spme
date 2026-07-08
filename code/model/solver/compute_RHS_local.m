function [RHS_local] = compute_RHS_local(ref_shape_function,F_local,wq,Jacobi)
arguments
    ref_shape_function {mustBeNumeric}
    F_local {mustBeNumeric,mustBeCompartibleSize(ref_shape_function,F_local)}
    wq double {mustBeCompartibleSize(ref_shape_function,wq)}
    Jacobi double {mustBePositive}
end
RHS_local = Jacobi*(wq'.*ref_shape_function)*F_local;
end
function mustBeCompartibleSize(a,b)
arguments
   a  
   b 
end
 if(size(a,2)~=size(b,1))
    msg = sprintf('Invalid argument at position %g. Arguments must have compatible sizes.',ref_shape_func);
    throwAsCaller(MException("MATLAB:mustHaveCompatibleSizes", msg));
 end
end