function RoundMask = ASK_roundmask( sx,sy, xc, yc, r )
% ASK_ROUNDMASK - "circular" mask with ones in image sized [sy,sx]
%   
% Calling:
%   RoundMask = ASK_roundmask( sx,sy, xc, yc, r )
% Input:
%  sx - horizontal image size
%  sy - vertical image size
%  xc - centre of circle horizontaly 
%  yc - centre of circle vertically 
%  r  - radius of circle.
% Output:
%  RoundMask - array [SY x SX] with ones in all pixels inside
%              circle, zeros outside

% Modified from roundmask.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies

[ix,iy] = meshgrid(1:sy,1:sx);
RoundMask = double( (ix-xc).^2 + (iy-yc).^2 < r.^2);
