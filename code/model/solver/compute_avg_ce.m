function [avgce,AVG_sep,AVG_pos] = compute_avg_ce(eq,c)
    [int_c,~] = compute_elem_integral(eq,c);
    AVG_sep = (1/eq.L_sep)*sum(int_c(1:eq.Nxs,1),1);
    AVG_pos = 1/(eq.domain(end)-eq.L_sep) * sum(int_c(eq.Nxs+1:end,1),1);
    avgce = ((eq.domain(end)-eq.L_sep)*AVG_pos+eq.L_sep*AVG_sep)/eq.domain(end);
end