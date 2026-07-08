function [eq] = buildSolidMatrices(eq)
%addpath Grid_1D/
%addpath Grid_1D/Grid_1D/
% buildSolidMatrices: Assemble mass and system matrices for the solid domain
% Inputs:
%   eq - struct with Geometry, material coefficients, cs_0, etc.
% Outputs:
%   FEM - struct with fields: MasseMatrix, SystemMatrix
p = eq.fem_p;
wq = eq.Geometry.GaussQuadrature.wq;
grid = eq.Geometry.grid;
el = eq.Geometry.el;
global_dof = eq.Geometry.global_dof;
real_quad_global = eq.Geometry.real_quad_global;
ref_shape_func = eq.Geometry.ref_shape_func;
ref_der_shape_func = eq.Geometry.ref_der_shape_func;

%% Coefficients of the weak formulation %%
% <a*u_t,phi> + <b*du_x,dphi_x> + <c*du_x,phi> + <d*u,dphi> 
% a = coeff1
% b = coeff2
% c = coeff3
% d = coeff4
% eq.FEM.RHS = compute_RHS(@rhs ...
%                                  ,grid.active_elements ...
%                                  ,global_dof ...
%                                  ,el ...
%                                  ,ref_shape_func ...
%                                  ,real_quad_global ...
%                                  ,eq.cs_0 ...
%                                  ,wq ...
%                                  ,0);
coeff = @(t,x,u)[x.^2, x.^2.*eq.D_s, zeros(size(x)), zeros(size(x))];
[A,B,C,D] = compute_MAT(coeff,grid.active_elements,global_dof,el,ref_shape_func,ref_der_shape_func,real_quad_global,eq.cs_0,wq,0);
eq.FEM.MasseMatrix = A;
eq.FEM.SystemMatrix = B+C+D;
% eq.FEM.Boundary =@(t,c) [ zeros(p*eq.N,1); -eq.j_n(t)*eq.domain(end)^2];  
% eq.odefun = @odefun;
% %% RHS %%
% function out = rhs(t,x,c)
%     out = zeros(size(x));
% end

    %eq.FEM.Boundary =@(t,c) [ zeros(p*eq.N,1); eq.j_n(t)*eq.domain(end)^2]; %+ eq.D_s_eff*c(end)/eq.domain(end)];
    % define ODE function M*dcdt = F(c,t)
% function dMcdt = odefun(t,c)
%    dMcdt = - eq.FEM.SystemMatrix*c + eq.FEM.RHS + eq.FEM.Boundary(t,c); 
% end
end

