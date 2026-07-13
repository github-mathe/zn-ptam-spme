function eq = getGeometry(eq)
    x_start = eq.domain(1);
    x_end = eq.domain(end);
    num_ref = eq.fem_ref;
    [xq,wq] = gaussLegendre(eq.fem_q,0,1);
    
    % generate grid and elements 
    [grid, el] = create_grid_1D(x_start,x_end,num_ref);
    if length(eq.domain)==3
        point = eq.domain(1)+eq.domain(2);
        [el,grid]=add_new_point(el,grid,point);
        sort_grid=sort(grid.coordinates);
        eq.Nxs = numel(find(sort_grid<=point))-1;   
        eq.Nxp = grid.number_of_active_elements - eq.Nxs;
    end
   
    % distribute degrees of freedom 
    [el,dof] = distribute_dofs(el,eq.fem_p,grid);
    eq.N = grid.number_of_active_elements;
    eq.Geometry.sorted_dofs = sort(dof.coordinates); 
    eq.Geometry.el = el;
    eq.Geometry.dof = dof;
    eq.Geometry.grid = grid;
    eq.Geometry.GaussQuadrature.xq = xq;
    eq.Geometry.GaussQuadrature.wq = wq;
    eq.Geometry.global_dof = renumbering(dof.coordinates);
    eq.Geometry.ref_shape_func = eval_shape_functions(xq,eq.fem_p);
    eq.Geometry.ref_der_shape_func=eval_derivative_shape_functions(xq,eq.fem_p);
    eq.Geometry.real_quad_global = real_quadrature_global(el,xq,grid);
end