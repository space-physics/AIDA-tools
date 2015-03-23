function imthumbScaler(N)
% IMTHUMBSCALER - colormap scaling and clipping callback-function 
%  IMTHUMBSCALER handles the callback handling intensity mapping
%  and clipping for imthumb.
%  

%   Copyright © 20140123 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

UD = get(gcf,'userdata');

switch N
 case 1
  % Set CLIMS to [min(Im(:)), max(Im(:))]
  caxis(minmax(UD.xHist))
 case 2
  % These are histogram clipping at various levels
  caxis(minmaxIalpha(UD.xHist,UD.imHist,0.999))
 case 3
  caxis(minmaxIalpha(UD.xHist,UD.imHist,0.99))
 case 4
  caxis(minmaxIalpha(UD.xHist,UD.imHist,0.97))
 case 5
  caxis(minmaxIalpha(UD.xHist,UD.imHist,0.95))
 case 6
  caxis(minmaxIalpha(UD.xHist,UD.imHist,0.90))
 case 7
  % LINEAR-scaling
  % (RE-)set the colormap of current figure to a default colourmap,
  % that for example should be set to gray(/bone) in
  % im(/aida)thumbImTool.m 
  colormap(UD.cmap)
 case 8
  % SQRT-scaling
  % Square root re-mapping of current colormap (should be very
  % equal to brighten 0.5)
  cmp = colormap;
  % colormap(interp1(1:length(cmp),cmp,([1:length(cmp)]/length(cmp)).^0.5*length(cmp)));
  colormap(interp1(linspace(0,1,length(cmp)),cmp,linspace(0,1,length(cmp)).^0.5))
 case 9
  % LOG-scaling
  % Logarithmic rescaling of current colormap.
  cmp = colormap;
  % colormap(interp1(1:length(cmp),cmp,1+(log([1:length(cmp)])/log(length(cmp)))*(length(cmp)-1)));
  colormap(interp1(linspace(0,1,length(cmp)),cmp,log(1:length(cmp))/log(length(cmp))));
 case 10
  % Histogram-equalization scaling
  % Histogram equalization by modifying the colormap.
  if length(UD.imsz) < 3 % Pointless if the image is an RGB-image
    cmp = colormap;
    % iH = [0;UD.imHist(:)];
    % Normalised Cumulative intensity Histogram:
    NCiH = cumsum([0;UD.imHist(:)])/sum(UD.imHist(:));
    % But with an added leading zero...
    xH = UD.xHist; % Centre of the histogram bins, will now be one
                   % shorter than NCiH
    % Attempt to shift from bin-centres to bin edges
    % by shifting everything by half the gradient:
    DxH = diff(xH); 
    xH = [xH(1)-DxH(1)/2;xH(1:end-1)+DxH/2;xH(end)+DxH(end)/2];
    % This should map the colourmap to achieve histogram equalization.
    % The inner interpolation is just to resample the cumulative
    % histogram to the same length as the colormap in CMP
    colormap(interp1(linspace(0,1,length(cmp)),...
                     cmp,...
                     interp1((xH-xH(1))/(xH(end)-xH(1)),...
                             NCiH,...
                             linspace(0,1,length(cmp)))));
  end
 case 11
  % Brighten the colour map
  brighten(0.1)
 case 12
  % unBrighten - darken the colour map
  brighten(-0.1)
 otherwise
end


function mM = minmax(X)
% MINMAX - min and max value of matrix
%   
mM = [min(X(:)) max(X(:))];


function minMaxLims = minmaxIalpha(X,I,Alpha)
% MINMAXIALPHA - alpha-histogram-clipping 
%   

alpha = (1-Alpha)/2;

ch = cumsum(I)/sum(I);

i_cut = find(alpha(1) <= ch & ch <= 1-alpha(end));

minMaxLims = X(i_cut([1 end]));

