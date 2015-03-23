function [starpar] = updstrman(SkMp)
% UPDSTRMAN - 
%   

%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global bx by bxy
bxy = size(SkMp.img);
bx = bxy(1);
by = bxy(2);


figure( SkMp.figzoom )

%[x0,y0,button] = ginput(1);
[x0,y0] = ginput(1);

dl = SkMp.prefs.sz_z_r;

x0 = (x0);
y0 = (y0);

xmin = floor(min(max(x0-dl/2,1),by-dl));
xmax = floor(max(min(x0+dl/2,by),dl+1));
ymin = floor(min(max(y0-dl/2,1),bx-dl));
ymax = floor(max(min(y0+dl/2,bx),dl+1));

starmat = SkMp.img(ymin:ymax,xmin:xmax);
background = ( mean(starmat(1,:)) + mean(starmat(end,:)) + ...
	       mean(starmat(:,end)) + mean(starmat(:,1)) )/4;

starpar = [x0,y0,SkMp.img(floor(y0),floor(x0))-background,.5,0,.5];
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
