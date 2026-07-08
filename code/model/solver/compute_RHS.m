function RHS = compute_RHS(f,active_elem,global_dof,el,ref_shape_func,real_xq,u,wq,t)
        idx = global_dof([el(active_elem).dof])';
        for k=length(active_elem):-1:1
            global_dof_elem = global_dof(el(active_elem(k)).dof);
            u_local = eval_Uh_in_Xq_ref(global_dof_elem,u,ref_shape_func);
            F_local=f(t,real_xq(:,active_elem(k)),u_local);
            data(:,k) = compute_RHS_local(ref_shape_func,F_local,wq,el(active_elem(k)).h);
        end
        data=data(:);
        RHS=accumarray(idx,data);
end

         