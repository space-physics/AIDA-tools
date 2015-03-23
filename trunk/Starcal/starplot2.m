function [pstarsout] = starplot2(pstars,SkMp)
% STARPLOT2 plots the skymap.
% Used in the starcalibration program.
% 
% Calling:
% [pstarsout] = starplot2(pstars,SkMp)



%   Copyright � 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global bx by bxy
fig = SkMp.figsky;

str_col = SkMp.prefs.pl_cl_st;
str_siz = SkMp.prefs.pl_sz_st/10;

cax = caxis;
if ( cax(1) == 0 && cax(2) == 1 )
  cax = [ min(SkMp.img(:)) max(SkMp.img(:))];
end
clf

if SkMp.optmod < 0
  if isfield(optpar,'rot')
    [e1,e2,e3] = camera_base(kMp.optpar.rot(1),SkMp.optpar.rot(2),SkMp.optpar.rot(3));
  else
    [e1,e2,e3] = camera_base(0,0,0);
  end
else
  if length(SkMp.optpar) > 9
    [e1,e2,e3] = camera_base(SkMp.optpar(3),SkMp.optpar(4),SkMp.optpar(5),SkMp.optpar(10));
  else
    [e1,e2,e3] = camera_base(SkMp.optpar(3),SkMp.optpar(4),SkMp.optpar(5));
  end
end
e1 = SkMp.e1;
e2 = SkMp.e2;
e3 = SkMp.e3;
bxy = size(SkMp.img);
bx = bxy(2);
by = bxy(1);

figure(fig);
az = pstars(:,1);
ze = pstars(:,2);

[u,w] = camera_model(az',ze',e1,e2,e3,SkMp.optpar,SkMp.optmod,size(SkMp.img));
indx = find(inimage(u,w,bx,by));
ua = u;
wa = w;
pstarsout = pstars;
intens = pstars(:,4);
min(intens);
max(intens);

x = cos(0:2*pi/8:2*pi);
y = sin(0:2*pi/8:2*pi);
sz = max(size(ua));
imagesc(SkMp.img),axis xy
caxis(cax)
hold on

figure(fig)
for i1 = sz(1):-1:1,
  
  px = str_siz*( 5 - intens(i1)*.5 )*x + ua(i1);
  py = str_siz*( 5 - intens(i1)*.5 )*y + wa(i1);
  if isfield(SkMp,'selectedstar') && SkMp.selectedstar(3) == pstars(i1,3)
    line(px,py,'color',SkMp.prefs.pl_cl_slst)
  else
    line(px,py,'color',str_col)
  end
  % Test the above for now... 
  % previous version: line(px,py,'color',str_col)
  
end
hold off
zoom on
