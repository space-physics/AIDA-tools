function [atten_matr] = atm_attenuation(imgsize,optpar,optmod,wavelength,airpressure)
% atm_attenuation - Atmospheric attenuation
%
% Calling:
% [atten_mtr] = atm_attenuation(imgsize,optpar,optmod,wavelength)

%   Copyright © 1999 by Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global bx by

bxy = imgsize;
bx = bxy(2);
by = bxy(1);

if 4270 < wavelength || wavelength < 8480
  atten_matr = 1;
  warning(['Wavelength outside range for atmospheric ttenuation: ',num2str(wavelength)])
  return
end

%TBR?: dmax = 0;

v = 1:by;
u = 1:bx;
[u,v] = meshgrid(u,v);
if optmod < 0
  [rmat] = camera_rot(optpar.rot(1),optpar.rot(2),optpar.rot(3));
else
  [rmat] = camera_rot(optpar(3),optpar(4),optpar(5));
end
[fi,taeta] = camera_invmodel(u(:),v(:),optpar,optmod,imgsize);
fi = -fi;
epix = [-sin(taeta).*sin(fi), sin(taeta).*cos(fi), cos(taeta)];
epix = rmat*epix';

zenith = zeros(imgsize);
zenith(:) = acos(epix(3,:));

Opt_d =      [.236 .116 .081 .080];
Wavelength = [4270 5577 6300 8480];

opt_d = interp1(Wavelength,Opt_d,wavelength);

atten_matr = exp(-airpressure*opt_d./cos(zenith));
