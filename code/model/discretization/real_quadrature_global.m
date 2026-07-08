function real_xq_global = real_quadrature_global(el,xq,grid)
%[ii,jj] = ndgrid(1,1:length(xq));
%real_xq_global = sparse(grid.number_of_elements,length(xq));
for k=grid.number_of_elements:-1:1
    if(el(k).active==1)
       real_xq_global(:,k) = real_quadrature_local(el(k),xq,grid);
    else
        real_xq_global(:,k)=NaN;
    end
end