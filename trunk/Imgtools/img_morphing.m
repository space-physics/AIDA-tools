function Iout = img_morphing(Iin,morphVector,delta)
% IMG_MORPHING - Intensity and spatial morphing of image
%   
% Calling:
%   Iout = img_morphing(Iin,morphVector,delta)
% Input:
%  Iin         - Image to be transformed.
%  morphVector - Spatial-n-intensity transformation vector. The
%                components are ordered [x,y,Iscale], where x and y
%                are the displacements of the n-by-n pixels
%                meshgrid(linspace(1,size(I1,2),n),linspace(1,size(I1,2),n))
%                in I1, that is I1 will be spatiall;y wrapped
%                according to: interp2(I1,X,Y) where X and Y is
%                created as interp2(xP0,yP0,xP,1:size(I1,2),[1:size(I1,1)]','*linear');
%                respectively. Iscale is produced the same way.
%  delta       - (Fractional) length of the morphing transform to
%                do. Usefull for making morphing interpolation,
%                when the morphVector is produced for a start and a
%                stop image and one wants an estimate of an image
%                in the interval inbetween. Could also be used for
%                morphing extrapolation...
%
% SEE also: errFcnAuroralFlow, img_optflow, parsOnrefinedGrid4AF     

%   Copyright © 20110830 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

nPoints = (length(morphVector)/3)^(1/2);

xP0 = linspace(1,size(Iin,2),nPoints);
yP0 = linspace(1,size(Iin,1),nPoints);
[xP0,yP0] = meshgrid(xP0,yP0);

vP0 = [xP0(:)',yP0(:)',ones(size(xP0(:)'))];
vPdelta = vP0' + delta*(morphVector - vP0');

efAFops = errFcnAuroralFlow;
efAFops.outputType = 2;

Iout = errFcnAuroralFlow(vPdelta,1:length(vPdelta),vPdelta, ...
                              Iin,Iin,nPoints,efAFops);

