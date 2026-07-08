function [intF,global_grid_id] = compute_function_integral_elem(eq,f,t,c)
    grid=eq.Geometry.grid;
    el=eq.Geometry.el;
    global_dof=eq.Geometry.global_dof;
    p=eq.fem_p;
    intF=zeros(grid.number_of_active_elements,1);
    global_grid_id=intF;
    ref_shape_func=eq.Geometry.ref_shape_func;
    ref_der_shape_func = eq.Geometry.ref_der_shape_func;
    real_quad_global = eq.Geometry.real_quad_global;
    wq=eq.Geometry.GaussQuadrature.wq;
for elem=grid.active_elements
    local_dof=el(elem).dof;
    elem_global_dof = global_dof(local_dof);
    global_gridId = (elem_global_dof(end)-1)/(p);
    c_loc     = ref_shape_func'*c(elem_global_dof);
    c_der_loc = ref_der_shape_func'*c(elem_global_dof);
    xq_loc = real_quad_global(:,elem);
    f_loc = arrayfun(@(row) f(t,xq_loc(row),c_loc(row),c_der_loc(row)/el(elem).h),(1:size(xq_loc,1))');
    intF(global_gridId,1) = wq'*f_loc*el(elem).h;
    global_grid_id(global_gridId,1) = elem;
end
end