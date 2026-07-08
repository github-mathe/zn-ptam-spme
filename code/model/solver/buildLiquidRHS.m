function eq = buildLiquidRHS(eq)
% buildSolidRHS: Assemble RHS vector for the solid diffusion equation
% Inputs:
%   eq - struct with Geometry and cs_0
% Output:
%   RHS - vector
    wq = eq.Geometry.GaussQuadrature.wq;
    grid = eq.Geometry.grid;
    el = eq.Geometry.el;
    global_dof = eq.Geometry.global_dof;
    real_quad_global = eq.Geometry.real_quad_global;
    ref_shape_func = eq.Geometry.ref_shape_func;
    rhs_func = eq.rhs; 
    eq.FEM.RHS =@(t) compute_RHS(rhs_func, grid.active_elements, global_dof, el, ...
        ref_shape_func, real_quad_global, eq.ce_0, wq, t);
end