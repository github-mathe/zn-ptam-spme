function [AVG_pos] = compute_avg_ce(eq,c)
    [int_c,~] = compute_elem_integral(eq,c);
    %func = @(t,x,c,dc) c;
    %[int_c1,global_grid_id1] = compute_function_integral_elem(eq,func,0,c);
    %AVG_sep=1/eq.L_sep * sum(int_c(1:eq.Nxs,1),1);
    AVG_pos = 1/(eq.domain(end)-eq.L_sep) * sum(int_c(eq.Nxs+1:end,1),1);
end