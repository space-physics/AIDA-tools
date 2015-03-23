function img_out = imgs_edge_tap(img_in,psfsz)
% imgs_edge_tap - Edge tapering, "extrapolating" version
%   This version of edge-tapering interpolates one dimension at a
%   time from the last pixel to the first pixel in PSFSZ steps.
% 
% CALLING:
% img_out = imgs_edge_tap(img_in,psf)
% 
% INPUT:
%   IMG_IN - 2-D intensity image (double)
% 
% See also EDGE_TAPER


%   Copyright © 20050115 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if length(size(img_in)) == 2
  
  right_edge = [img_in(:,[end end]) img_in(:,[1 1])];
  R_edge = interp1([0 1 psfsz(2)+[0 1]],right_edge',1:psfsz(2),'pchip');
  img_out = [img_in,R_edge'];
  
  top_edge = [img_out([end end],:);img_out([1 1],:)];
  T_edge = interp1([0 1 psfsz(1)+[0 1]],top_edge,1:psfsz(1),'pchip');
  img_out = [img_out;T_edge];
  
end
