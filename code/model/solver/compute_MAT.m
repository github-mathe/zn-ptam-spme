function [A,B,C,D] = compute_MAT(COEFF,active_elem,global_dof,el,ref_shape_func,ref_der_shape_func,real_xq,u_old,wq,t)
        idx=[];
        dataA=[];
        dataB=[];
dataC=[];
dataD=dataC;
        for k=length(active_elem):-1:1
            global_dof_elem = global_dof(el(active_elem(k)).dof);
            u_old_local = eval_Uh_in_Xq_ref(global_dof_elem,u_old,ref_shape_func);
            COEFF_local=COEFF(t,real_xq(:,active_elem(k)),u_old_local);
            [A_loc,B_loc,C_loc,D_loc] = compute_MAT_local(ref_shape_func,ref_der_shape_func,COEFF_local,wq,el(active_elem(k)).h);
            [ii,jj] = ndgrid(global_dof_elem);
            idx =[idx; ii(:) jj(:) ];
            dataA = [dataA;A_loc(:)];
            dataB = [dataB;B_loc(:)];
            dataC = [dataC;C_loc(:)];
            dataD = [dataD;D_loc(:)];
        end
        A = accumarray(idx,dataA);
        B = accumarray(idx,dataB);
        C = accumarray(idx,dataC);
        D = accumarray(idx,dataD); 
end