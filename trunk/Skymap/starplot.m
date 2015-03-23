function [pstarsout] = starplot(pstars,SkMp)
% STARPLOT plots the skymap.
% Used in the starcalibration program.
% 
% Calling:
% [pstarsout] = starplot(pstars,SkMp)


%       Bjorn Gustavsson 7-9-97
%	Copyright � 1997 by Bjorn Gustavsson

global bx by bxy

Lb = [395.3125
      400.0000
      411.9792
      439.0625
      450.0000
      460.9375
      489.0625
      512.3762
      535.6436];
eye_b = [0.0212
         0.0377
         0.1274
         0.9552
         0.9835
         0.9316
         0.3042
         0.0896
         0.0071];
Lg = [423.9583
      470.8333
      495.3125
      517.8218
      544.0594
      578.4946
      600.0000
      630.0971
      658.3333];
eye_g = [0.0118
         0.0967
         0.2241
         0.4764
         0.6627
         0.4481
         0.2476
         0.0377
         0.0047];
Lr = [405.7292
      439.0625
      467.7083
      500.4950
      534.6535
      565.0538
      587.0968
      618.4466
      641.2621
      671.6667
      701.6667];
eye_r = [0.0142
         0.0401
         0.0189
         0.1014
         0.3632
         0.5212
         0.5637
         0.3986
         0.1863
         0.0472
         0.0047];



fig = SkMp.figsky;
ssc = SkMp.prefs.pl_sz_st/10;
% selectedstar = SkMp.selectedstar;

if isempty(SkMp.img)
  clf
  
  x = ssc*180/pi*.5*cos(0:2*pi/8:2*pi);
  y = ssc*180/pi*.5*sin(0:2*pi/8:2*pi);
  sz = size(pstars);
  figure(fig)
  hold off
  plot(180/pi*max(pstars(:,6))*[1 -1],'w.','markersize',.1)
  hold on
  plot(180/pi*max(pstars(:,6))*[1 -1],[0 0],'w.','markersize',.1)
  ax = axis;
  axis(ax)
  axis off
  
  hold on
  
  for i = sz(1):-1:1,
    
    px = ( .05 - .05*pstars(i,4)/9 )*x + 180/pi*pstars(i,6)*cos(-pstars(i,5));
    py = ( .05 - .05*pstars(i,4)/9 )*y + 180/pi*pstars(i,6)*sin(-pstars(i,5));
    f_h = fill(px,py,SkMp.prefs.pl_cl_st);
    i_s = find([SkMp.star_list.Bright_Star_Nr]==pstars(i,8));
    if SkMp.star_list(i_s).spectra == 1
      set(f_h,'facecolor',SkMp.star_list(i_s).rgb)
    end
  end
  pstarsout = 1;
  
else
  cax = caxis;
  if ( cax(1) == 0 && cax(2) == 1 )
    cax = [ min(SkMp.img(:)) max(SkMp.img(:))];
  end
  clf
  
  if SkMp.optmod < 0
    [e1,e2,e3] = camera_base(SkMp.optpar.rot(1),SkMp.optpar.rot(2),SkMp.optpar.rot(3));
  else
    if length(SkMp.optpar) > 9
      [e1,e2,e3] = camera_base(SkMp.optpar(3),SkMp.optpar(4),SkMp.optpar(5),SkMp.optpar(10));
    else
      [e1,e2,e3] = camera_base(SkMp.optpar(3),SkMp.optpar(4),SkMp.optpar(5));
    end
  end
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
  
  x = ssc*cos(0:2*pi/8:2*pi);
  y = ssc*sin(0:2*pi/8:2*pi);
  sz = max(size(ua));
  imagesc(SkMp.img),axis xy
  caxis(cax)
  hold on
  
  figure(fig)
  for i = sz(1):-1:1,
    px = .5*( 10 - intens(i) )*x + ua(i);
    py = .5*( 10 - intens(i) )*y + wa(i);
    if isfield(SkMp,'selectedstar') && SkMp.selectedstar(3) == pstars(i,3)
      line(px,py,'color',SkMp.prefs.pl_cl_slst)
    else
      line(px,py,'color',SkMp.prefs.pl_cl_st)
    end
  end
  zoom on
  hold off
  
end
