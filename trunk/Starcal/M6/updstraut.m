function [starpar] = updstraut(SkMp)
% UPDSTRAUT - fit image location size and intensity of star.
%   

%   Copyright © 1997 Bjorn Gustavsson<bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global bxy bx by

bxy = size(SkMp.img);
bx = bxy(1);
by = bxy(2);

figure( SkMp.figzoom )

[x0,y0,button] = ginput(1);
dl = SkMp.prefs.sz_z_r;

x0 = floor(x0);
y0 = floor(y0);

xmin = floor(min(max(x0-dl/2,1),by-dl));
xmax = floor(max(min(x0+dl/2,by),dl+1));
ymin = floor(min(max(y0-dl/2,1),bx-dl));
ymax = floor(max(min(y0+dl/2,bx),dl+1));

set(SkMp.figzoom,'pointer','watch')
starmat = SkMp.img(ymin:ymax,xmin:xmax);
startvec = [x0,y0,SkMp.img(y0,x0),1,.01,1];

starpar = fminsearch('stardiff',...
		     startvec,[0,5e-2,0,0,0,0,0,0,0,0,0,0,0,2000],[],...
		     xmin,xmax,ymin,ymax,starmat);

set(SkMp.figzoom,'pointer','arrow')

fynd = starint(starpar,xmin,xmax,ymin,ymax);

hold off
if ( max(max(starmat)) - min(min(starmat)) > eps )
  
  contour(xmin:xmax,ymin:ymax,starmat,8,'b')
  
end
hold on
if ( max(max(fynd)) - min(min(fynd)) > eps )
  
  contour(xmin:xmax,ymin:ymax,fynd,8,'r')
  
end
hold off
