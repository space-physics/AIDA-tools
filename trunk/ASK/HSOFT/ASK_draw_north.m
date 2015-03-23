function ph = ASK_draw_north(optpar,imsiz,ArrowLength,Colour,ArrowWidth,Start_uv,EastOrNorthOrUp)
% ASK_DRAW_NORTH -  Draws the north direction on an image, from the centre.
%   
% Callling:
%   ph = ASK_draw_north(optpar,imsiz,ArrowLength,Colour,ArrowWidth,Start_uv,EastInstead)
% Input:
%  optpar      - Optical parameter vector/struct, See documentation
%                for AIDA-tools for details.
%  imsiz       - image size [sy, sx] (pixels)
%  ArrowLength - arrow length, in fractions of a full image size (default: 0.45)
%  Colour      - Colour of arrow, either an RGB triplet [0.9 0, 0.4]
%                of a matlab colour identifying char (any of 'krgbcmyw')
%  ArrowWidth  - line-width of arrow (default: 0.5)
%  Start_uv    - Displacement from image center, in fraction of
%                image size, should be 2-element array with values
%                between -0.5 and 0.5
%  EastOrNorthOrUp - if 1 then an arrow in the east direction will be
%                    plotted if 2 then an arrow in the north
%                    direction and if 3 then an arrow in the vertical
%                    direction will be plotted. Default is north if
%                    no EastOrNorthOrUp is given.

% Done to losely mimic draw_north.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies


if nargin < 3 | isempty(ArrowLength)
  ArrowLength = 0.25*mean(imsiz); % fraction of image side length
end
if nargin < 4 | isempty(Colour)
  Colour = 'w'; % white as default colour.
end
if nargin < 5 | isempty(ArrowWidth)
  ArrowWidth = 0.5; % default width of arrow
end
if nargin < 6 | isempty(Start_uv)
  Start_uv = [0,0]+imsiz/2; % ofsett from centre.
end

% Get the optical transfer function identifier
if isstruct(optpar)
  optmod = optpar.mod;
else
  optmod = optpar(9);
end

% Starting point of arrow
uC = Start_uv(1);
vC = Start_uv(2);

%% % Arbitrary point on line-of-sight in direction of [uC,vC] pixels field-of-view
%% [xC,yC,zC] = inv_project_points(uC,vC,ones(imsiz),[0,0,0],optmod,optpar,[0 0 1],500);
%% rC = [xC,yC,zC];
%% There is something dodgy about that above. Cant figure out why.
% This below is exactly what it does:
[fi,taeta] = camera_invmodel(uC,vC,optpar,optmod,imsiz);
epix = [sin(taeta).*sin(fi); sin(taeta).*cos(fi); cos(taeta)];
% Rotate/Transform them with the rotation matrix:
%epix = epix';

rC = epix*500;
% take a point displaced in desired direction
if  nargin > 6 && EastOrNorthOrUp == 1
  rA = rC+[3;0;0];%[xC+3,yC,zC];
elseif nargin > 6 && EastOrNorthOrUp == 3
  rA = rC+[0;0;30];%[xC,yC+3,zC];
else
  rA = rC+[0;3;0];%[xC,yC+3,zC];
end
% Calculate the pixel coordinate of that point.
[uA,vA] = project_point([0,0,0],optpar,rA,eye(3),imsiz);
% Subtract and normalize to unit vector.
eA = [uA,vA] - [uC,vC];
eA = eA/norm(eA);

HoldIsOn = ishold;
hold on

% Draw the arrow
ph = arrow([uC,vC],[uC,vC]+ArrowLength*eA,...
           'facecolor',Colour,'Edgecolor',Colour,'width',ArrowWidth);

if ~HoldIsOn
  hold off
end
