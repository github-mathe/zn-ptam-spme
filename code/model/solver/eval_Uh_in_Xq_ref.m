function sol_local = eval_Uh_in_Xq_ref(dof_global,sol_global,ref_shape_func)
    arguments
        dof_global {mustBeInteger,mustBePositive} 
        sol_global {mustBeColumn}
        ref_shape_func {mustBeMatrix}
    end
    sol_local = ref_shape_func'*sol_global(dof_global);
end