function out_img = img_histeq(in_img,hist_lim)
% img_histeq - histogram equalisation. 
%    IMG_IN should be a double array. When HIST_LIM is an integer
%    IMG_HISTEQ makes IMG_IN to have a uniform histogram
%   
%   J = IMG_HISTEQ(I,N) transforms the double array I, returning
%   in J an array with a roughly flat histogram with N bins.
%   NO checks or tests


%   Copyright © 20050109 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin == 1
  hist_lim = 100;
end

out_img = in_img;
if max(out_img(:))==min(out_img(:))
  return
end
[qa,qs] = hist(in_img(:),hist_lim);

qs = [min(in_img(:)) qs(1:end-1)/2+qs(2:end)/2 max(in_img(:))];


out_img(:) = interp1(qs,...
                     min(in_img(:))+(max(in_img(:))-min(in_img(:)))*[0 cumsum(qa)/sum(qa)],...
                     in_img(:),...
                     'pchip','extrap');
