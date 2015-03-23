function [ph] = spc_sens_distr(I_img,img_times,I_star,filter_in,filter2wl_order,plot_stars,pl_clrs)
% SPC_SENS_DISTR - scatter plot camera sensitivity estimates.
% From star-in-image-intensity I_IMG and
% star-enrgy-flux-from-catalog I_star, FILTER_IN should contain the
% filter identity as given from QWE, and hist_range should be the
% range over which to calculate the histogram.
% 
% See also HIST, SPC_SORT_OUT_THE_BAD_ONES,  SPEC_CAL_BAD_INTENS
%
% Calling:
%  [N1,N1p,Chi2_1,N2,N2p,Chi2_2,...] = spc_sens_distr(I_img,I_star,filter_in,hist_range)
% 

%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% I1 = [];
% I2 = [];
% I3 = [];
% N1 = [];
% N2 = [];
% N3 = [];
% nP1 = [];
% nP2 = [];
% nP3 = [];

filters = filter2wl_order;
clf
pl_mrkr = ['.';'d';'*';'h';'p';'s'];

for ii = 1:length(filters),
  
  for jj = plot_stars(ii,:),
    
    i_f = find(filter_in(jj,:)== filters(ii));
    if ~isempty(i_f)
      I1 = I_img(jj,i_f)/I_star(jj,ii);
      subplot(length(filters),1,ii)
      hold on
      ph(ii,jj) = plot(img_times(jj,i_f),I1,[pl_mrkr(mod(jj,6)+1),pl_clrs(mod(jj,6)+1)]);
      timetick
    end
    
  end
  
end

