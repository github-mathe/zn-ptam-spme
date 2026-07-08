function [eq] = buildLiquidMatrices(eq)
%% Coefficients of the weak formulation %%
% <a*u_t,phi> + <b*du_x,dphi_x> + <c*du_x,phi> + <d*u,phi> 
% a = coeff1
% b = coeff2
% c = coeff3
% d = coeff4
p = eq.fem_p;
wq = eq.Geometry.GaussQuadrature.wq;
grid = eq.Geometry.grid;
el = eq.Geometry.el;
global_dof = eq.Geometry.global_dof;
real_quad_global = eq.Geometry.real_quad_global;
ref_shape_func = eq.Geometry.ref_shape_func;
ref_der_shape_func = eq.Geometry.ref_der_shape_func;  
coeff = @(t,x,u)[coeff1(x),coeff2(x), zeros(size(x)), zeros(size(x))];
[A,B,C,D] = compute_MAT(coeff,grid.active_elements,global_dof,el,ref_shape_func,ref_der_shape_func,real_quad_global,eq.ce_0,wq,0);
eq.FEM.MasseMatrix = A;
eq.FEM.SystemMatrix = B+C+D;
function out = coeff1(x)
    for i=1:length(x)
        if (x(i) < eq.domain(2))
            out(i) = eq.epsilon_sep ;
        elseif(x(i)>=eq.domain(2)&&x(i) <=eq.domain(end))
            out(i) = eq.epsilon_pos;
        end
    end
out=out';
end
function out = coeff2(x)
for i=1:length(x)
    if (x(i) < eq.domain(2))
        out(i) = eq.D_e_sep;
    elseif(x(i)>=eq.domain(2) && x(i) <=eq.domain(end))
        out(i) = eq.D_e_cat;
    end
end
out=out';
end
end

