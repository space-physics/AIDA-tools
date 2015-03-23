function [staz,stze,stind,stmagn] = findneareststarxy(x0,y0,SkMp)
% FINDNEARESTSTARXY - find the star among PSTARS closest to X0, Y0
% in the sky. FIG is a handle to the figure where the result is
% plotted.
% 
% Calling:
%  [staz,stze,stind,stmagn] = findneareststar(x0,y0,pstars,fig)
% Input:
%  x0 - horizontal position of star
%  y0 - vertical position of star
%  SkMp - starcal struct

%   Copyright ©  1997 by Bjorn Gustavsson <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global bxy bx by
fig = SkMp.figsky;
set(fig,'pointer','watch')

if SkMp.optmod < 0
  [e1,e2,e3] = camera_base(SkMp.optpar.rot(1),SkMp.optpar.rot(2),SkMp.optpar.rot(3));
else
  if length(SkMp.optpar) > 9
    [e1,e2,e3] = camera_base(SkMp.optpar(3),SkMp.optpar(4),SkMp.optpar(5),SkMp.optpar(10));
  else
    [e1,e2,e3] = camera_base(SkMp.optpar(3),SkMp.optpar(4),SkMp.optpar(5));
  end
end
SkMp.e1 = e1;
SkMp.e2 = e2;
SkMp.e3 = e3;

pstars = SkMp.plottstars;

bxy = size(SkMp.img);
bx = bxy(2);
by = bxy(1);

az = pstars(:,1);
ze = pstars(:,2);

[u,w] = camera_model(az',ze',e1,e2,e3,SkMp.optpar,SkMp.optmod,size(SkMp.img));

diff = (u-x0).^2 + (w-y0).^2;
[mindiff,minindex] = min(diff);

staz = pstars(minindex,1);
stze = pstars(minindex,2);
stind = pstars(minindex,3);
stmagn = pstars(minindex,4);

figure(fig)
hold on
SkMp.last_pH = plot(u(minindex),w(minindex),...
                    [SkMp.prefs.cl_st_pt,'h'],...
                    'markersize',SkMp.prefs.sz_st_pt);
hold off
zoom on
set(fig,'pointer','arrow')
title('')
