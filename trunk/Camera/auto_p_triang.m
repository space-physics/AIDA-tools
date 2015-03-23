function [xtr,ytr,ztr,tu1,tv1,tu2,tv2] = auto_p_triang(img1,r1,optp1,img2,r2,optp2,checktmp,cm1,cm2)
% AUTO_P_TRIANG - triangulation of 3D positions of imaged objects
% in 2 images (IMG1 and IMG2) from different
% locations (R1 and R2). The optical transfer function are
% described by optical model OPTP1(9) and OPTP2(9) with respective
% parameters OPTP1 and OPTP2
% CHECKTMP == 0 avoids the useful feasibility check of the result
% during the work process. CM1 and CM2 are optional correction
% matrices to transform the coordinate systems of the cameras.
%
% Calling:
% [xtr,ytr,ztr,tu1,tv1,tu2,tv2] = AUTO_P_TRIANG(img1,r1,optp1,img2,r2,optp2,cm1,cm2)
% 
% Input:
%  img1  - Image 1 to use to identify common points.
%  r1    - 1x3 array of coordinates for camera 1
%  optp1 - is a vector caracterising the optical
%          transfer function, or an OPTPAR struct, with fields:
%          sinzecosaz, sinzesinaz, u, v that define the horizontal
%          components of a pixel l-o-s, and the pixel coordinates
%          for the corresponding horizontal l-o-s components,
%          respectively, and optionally a field rot (when used a
%          vector with 3 Tait-Bryant rotaion angles)
%  img2  - Image 2 to use to identify common points.
%  r2    - 1x3 array of coordinates for camera 2
%  optp2 - is a vector caracterising the optical
%          transfer function, or an OPTPAR struct, with fields:
%          sinzecosaz, sinzesinaz, u, v that define the horizontal
%          components of a pixel l-o-s, and the pixel coordinates
%          for the corresponding horizontal l-o-s components,
%          respectively, and optionally a field rot (when used a
%          vector with 3 Tait-Bryant rotaion angles)
%  cm1   - additional rotation matrix, allowing correcting between
%          local coordinate system 1 and the common coordinates
%  cm2   - additional rotation matrix, allowing correcting between
%          local coordinate system 2 and the common coordinates
% 
% Output:
%   XTR - "East" direction of identified points
%   YTR - "North" direction of identified  points
%   ZTR - "Altitude" direction of identified points
%   TU1 - Horisontal image1 coordinate of identified points
%   TV1 - Vertical image1 coordinate of identified points
%   TU2 - Horisontal image2 coordinate of identified points
%   TV2 - Vertical image2 coordinate of identified points
%
% See also TRIANGULATE, AOTO_TRIANGULATE


%   Copyright � 2001 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


fig1 = gcf;
if ( checktmp )
  figtmp = figure('menubar','none','position',[600 300 500 500]);
end

bxy1 = size(img1);
bx1 = bxy1(1);
by1 = bxy1(2);

bxy2 = size(img2);
bx2 = bxy2(1);
by2 = bxy2(2);

if isstruct(optp1)
  rot1 = camera_rot(optp1.rot(1),optp1.rot(2),optp1.rot(3));
  optmod1 = optp1.mod;
else
  rot1 = camera_rot(optp1(3),optp1(4),optp1(5));
  optmod1 = optp1(9);
end
if (nargin>7)
  rot1 = cm1*rot1;
end

if isstruct(optp2)
  rot2 = camera_rot(optp2.rot(1),optp2.rot(2),optp2.rot(3));
  optmod2 = optp2.mod;
else
  rot2 = camera_rot(optp2(3),optp2(4),optp2(5));
  optmod2 = optp2(9);
end
if (nargin>8)
  rot2 = cm2*rot2;
end

if ( checktmp )
  figure(fig1)
  clf
  imagesc(img1),axis xy
  hold on
  fig2 = figure('menubar','none','position',[10 300 500 500]);
  imagesc(img2),axis xy
  hold on
end
i = 1;
% £££ button = 1;

[imax,I] = max(img1);
[imax,J] = max(imax);
x1 = J;
y1 = I(J);

[imax,I] = max(img2);
[imax,J] = max(imax);
x2 = J;
y2 = I(J);


if ( checktmp )
  figure(figtmp);
end

[fi,taeta] = camera_invmodel(x1,y1,optp1,optmod1,[by1 bx1]);
fi = -fi;
epix = [-sin(taeta).*sin(fi); sin(taeta).*cos(fi); cos(taeta)];
epix = rot1*epix;
e1 = epix';

[fi,taeta] = camera_invmodel(x2,y2,optp2,optmod2,[by2 bx2]);
fi = -fi;
epixf = [-sin(taeta).*sin(fi); sin(taeta).*cos(fi); cos(taeta)];
epix = rot2*epixf;
e2 = epix';

% direct algebra inversion!!!
rhs = [dot(r2,e1)-dot(r1,e1) dot(r2,e2)-dot(r1,e2)];
M = [1 -dot(e1,e2);dot(e1,e2) -1];
% This is what we calculate below: lmatr = (inv(M)*rhs')';
lmatr = (M\rhs')';

minlength = diff2_ps_on_ls(lmatr,r1,e1,r2,e2);

% temporary plot for control of triangulation result ^
% ---------------------------------------------------|
if ( checktmp )
  figure(figtmp);
  hold on
  plot3(r1(1),r1(2),r1(3),'r+')
  plot3(r2(1),r2(2),r2(3),'r+')
  xp(1) = r1(1);
  yp(1) = r1(2);
  zp(1) = r1(3);
  qw = lmatr(1)*e1;
  xp(2) = r1(1)+qw(1);
  yp(2) = r1(2)+qw(2);
  zp(2) = r1(3)+qw(3);
  plot3(xp,yp,zp,'g')
  xp(1) = r2(1);
  yp(1) = r2(2);
  zp(1) = r2(3);
  qw = lmatr(2)*e2;
  xp(2) = r2(1)+qw(1);
  yp(2) = r2(2)+qw(2);
  zp(2) = r2(3)+qw(3);
  plot3(xp,yp,zp,'b')
  
  rmin = .5*(r1+lmatr(1)*e1+r2+lmatr(2)*e2);
  plot3(rmin(1),rmin(2),rmin(3),'k*')
  disp('  lmin')
  disp(lmatr)
  drawnow
  view(30,30)
  grid on
  rotate3d on
  xlabel('    i       minlength')
  disp([ i       minlength])
  qwas = gca;
  set(qwas,'Projection','perspective');
  %-------------------------------------------------V
else
  rmin = .5*(r1+lmatr(1)*e1+r2+lmatr(2)*e2);
end % if ( checktmp )

xtr(i) = rmin(1);
ytr(i) = rmin(2);
ztr(i) = rmin(3);
tu1(i) = x1;
tv1(i) = y1;
tu2(i) = x2;
tv2(i) = y2;

if ( checktmp )
  figure(fig2)
  hold on
  plot(x2,y2,'w+')
  
  figure(fig1)
  plot(x1,y1,'w+')
  pause(5)
  
  close(figtmp)
  close(fig2)
  hold off
  
end
