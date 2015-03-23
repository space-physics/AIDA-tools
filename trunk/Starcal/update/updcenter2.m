function updcenter2(SkMp)
% UPDCENTER2 - 
%   

%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global bxy bx by

bxy = size(SkMp.img);
bx = bxy(1);
by = bxy(2);

figure( SkMp.figzoom )

dl = SkMp.prefs.sz_z_r;

%[x0,y0,button] = ginput(1);
[x0,y0] = ginput(1);

xmin = floor(min(max(x0-dl/2,1),by-dl));
xmax = floor(max(min(x0+dl/2,by),dl+1));
ymin = floor(min(max(y0-dl/2,1),bx-dl));
ymax = floor(max(min(y0+dl/2,bx),dl+1));

imagesc(xmin:xmax,ymin:ymax,SkMp.img(ymin:ymax,xmin:xmax)),
axis xy
% cval = caxis;
