function N = spc_sens_pdf(I_img,I_star,filter_in,filter2wl_order,hist_range)
% SPC_SENS_PDF - Estimate PDF of the sensitivity, from
% star-in-image-intensity I_IMG and star-enrgy-flux-from-catalog
% I_star, FILTER_IN should contain the
% filter identity as given from QWE, and hist_range should be the
% range over which to calculate the histogram.
% 
% See also HIST, SPC_SORT_OUT_THE_BAD_ONES,  SPEC_CAL_BAD_INTENS
%
% Calling:
%  N1 = spc_sens_hist(I_img,I_star,filter_in,hist_range)
% 


%   Copyright © 2008 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later



filters = filter2wl_order;

% disp([jj])
for ii = 1:length(filters),
  
  N1 = [];

  disp([ii filters(ii)])
  for jj = 1:size(I_star,1),
    
    %TBR?: I1 = [];
    if ~isempty(I_img{jj,ii})
      %disp([ii I_star(jj,ii)])
      %I1 = [I_img{jj,ii}/I_star(jj,ii)];
      
      I1 = I_img{jj,ii}/I_star(jj,ii);
      if numel(I1) > 1
        [N1(jj,:)] = ksdensity(I1,hist_range);
      end
      
    end
    
  end
  
  N{ii} = N1;
  
end
