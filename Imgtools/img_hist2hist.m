function out_img = img_hist2hist(in_img,hist_out)
% img_hist2hist - histogram transformation. 
%    IMG_IN should be a double array.
%   
%   J = IMG_HISTEQ(I,HIST_OUT) transforms the double array I,
%   returning in J an array with a histogram roughly matching
%   HIST_OUT. 
%   NO checks or tests


%   Copyright © 20130323 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


%% If we only have one input argument then error out, need a
%  histogram to map the input values to...
if nargin ~= 2
  error('img_hist2hist takes 2 arguments')
end

out_img = in_img;
%% If the input values are all equal then just give up and return
%  them...
if max(out_img(:))==min(out_img(:))
  warning('img_hist2hist: All values in input identical.')
  return
end

%% Get the size of the out-put histogram...
sz_h = size(hist_out);
if sz_h(1) > sz_h(2)
  % and make sure that it becomes a row-matrix
  hist_out = hist_out.';
  sz_h = size(hist_out);
end

%% Number of bins in output histogram
nH = max(sz_h);

[qa,qs] = hist(in_img(:),nH);

qs = [min(in_img(:)) qs(1:end-1)/2+qs(2:end)/2 max(in_img(:))];

out_img(:) = interp1(qs,...
                     [0 cumsum(qa)/sum(qa)],...
                     in_img(:),...
                     'pchip','extrap');

if min(sz_h) == 1
  
  out_img(:) = interp1(linspace(0,1,nH+1),...
                       [0 cumsum(hist_out)/sum(hist_out)],...
                       out_img(:),...
                       'pchip','extrap');
  out_img = min(in_img(:)) + (max(in_img(:)) - min(in_img(:))) * out_img;
  
else
  
  Xout = unique([0 cumsum(hist_out(2,:))/sum(hist_out(2,:))]);
  Yout = linspace(0,1,length(Xout));
  out_img(:) = interp1(Xout,...
                       Yout,...
                       out_img(:),...
                       'pchip','extrap');
  out_img = hist_out(1,1) + (hist_out(1,end) - hist_out(1,1)) * out_img;
  
end
