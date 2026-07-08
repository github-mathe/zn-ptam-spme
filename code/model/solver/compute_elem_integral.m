function [int_sol,global_grid_id] = compute_elem_integral(eq,sol)
    grid=eq.Geometry.grid;
    el=eq.Geometry.el;
    global_dof=eq.Geometry.global_dof;
    p=eq.fem_p;
    int_sol=zeros(grid.number_of_active_elements,1);
    global_grid_id=int_sol;
    ref_shape_func=eq.Geometry.ref_shape_func;
    wq=eq.Geometry.GaussQuadrature.wq;
for elem=grid.active_elements
    local_dof=el(elem).dof;
    elem_global_dof = global_dof(local_dof);
    global_gridId = (elem_global_dof(end)-1)/(p);
    int_sol(global_gridId,1) = wq'*(ref_shape_func'*sol(elem_global_dof))*el(elem).h;
    global_grid_id(global_gridId,1) = elem;
end
end