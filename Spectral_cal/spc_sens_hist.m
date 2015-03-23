function [N_all,nP_all,Chi2_all] = spc_sens_hist(I_img,I_star,filter_in,filter2wl_order,hist_range)
% SPC_SENS_HIST - make histogram with parametrisation and uncertainty
% of the sensitivity, from star-in-image-intensity I_IMG and
% star-enrgy-flux-from-catalog I_star, FILTER_IN should contain the
% filter identity as given from QWE, and hist_range should be the
% range over which to calculate the histogram.
% 
% See also HIST, SPC_SORT_OUT_THE_BAD_ONES,  SPEC_CAL_BAD_INTENS
%
% Calling:
%  [N_all,nP_all,Chi2_all] = spc_sens_hist(I_img,I_star,filter_in,hist_range)
% 

%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% I1 = [];
N_all = [];
nP_all = [];

filters = filter2wl_order;

for ii = 1:length(filters),
  
  disp([ii filters(ii)])
  for jj = 1:size(I_star,1),
    
    if ~isempty(I_img{jj,ii})
      I1 = I_img{jj,ii}/I_star(jj,ii);
      %n1(jj) = length(i_f);
      [N_all{ii}(jj,:),X1] = hist(I1,hist_range);
      [nP_all{ii}(jj,:),Chi2_all{ii}(jj)] = hfitg(I1,length(hist_range),min(hist_range),max(hist_range));
    end
    
  end
  
  par(1)=median(nP_all{ii}(isfinite(nP_all{ii}(:,1)),1));
  par(2)=median(nP_all{ii}(isfinite(nP_all{ii}(:,1)),2));
  par(3)=max(sum(N_all{ii}(:,1:end-1)));
  plot(hist_range(1:end-1),sum(N_all{ii}(:,1:end-1)))
  hold on
  plot([par(1) par(1)],[0 par(3)],'r')
  [nP_all{ii}(jj+1,:),Chi2_all{ii}(jj+1)]=chisq_min(par,hist_range(1:end-1),sum(N_all{ii}(:,1:end-1)));
  if ii < length(filters)
    pause(3)
  end
  hold off
  
% $$$   varargout(1+(ii-1)*3) = {N_all};
% $$$   varargout(2+(ii-1)*3) = {nP_all};
% $$$   varargout(3+(ii-1)*3) = {Chi2_all};

end
