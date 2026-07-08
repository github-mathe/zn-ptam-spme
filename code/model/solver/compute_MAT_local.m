function [A_local,B_local,C_local,D_local] = compute_MAT_local(ref_shape_function,ref_der_shape_function,coeff_local, wq, h)
arguments
    ref_shape_function {mustBeNumeric}
    ref_der_shape_function {mustBeNumeric}
    coeff_local {mustBeNumeric,mustBeCompartibleSize(ref_der_shape_function,coeff_local)}
    wq double {mustBeCompartibleSize(ref_der_shape_function,wq)}
    h double {mustBePositive}
end
A_local = h*wq'.*ref_shape_function*(coeff_local(:,1)'.*ref_shape_function)';
B_local = (1/h)*wq'.*ref_der_shape_function*(coeff_local(:,2)'.*ref_der_shape_function)';
C_local = wq'.*ref_shape_function*(coeff_local(:,3)'.*ref_der_shape_function)';
D_local = wq'.*ref_der_shape_function*(coeff_local(:,4)'.*ref_shape_function)';
end
function mustBeCompartibleSize(a,b)
arguments
   a  
   b 
end
 if(size(a,2)~=size(b,1))
    msg = sprintf('Invalid argument at position %g. Arguments must have compatible sizes.',ref_shape_function);
    throwAsCaller(MException("MATLAB:mustHaveCompatibleSizes", msg));
 end
end