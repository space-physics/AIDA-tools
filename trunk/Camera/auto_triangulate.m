function [X_out,Y_out,Z_out,CC,cc3d] = auto_triangulate(img1,r1,optmod1,optp1,img2,r2,optmod2,optp2,e_n,l_range,Xlim,Ylim,blksz,cm1,cm2)
% AUTO_TRIANGULATE - Automatic stareoscopic triangulation
%   
% Calling:
% [X_out,Y_out,Z_out,CC,cc3d] = auto_triangulate(img1,r1,optmod1,optp1,img2,r2,optmod2,optp2,e_n,l_range,Xlim,Ylim,blksz,cm1,cm2)
% 
% Input:
%  IMG1    - intensity image #1 taken from
%  R1      - Point in space of camera #1
%  OPTMOD1 - optical model of camera #1
%  OPTP1   - optical parameters for OPTMOD1
%  IMG2    - intensity image #2 taken from
%  R2      - Point in space of camera #2
%  OPTMOD2 - optical model of camera #2
%  OPTP2   - optical parameters for OPTMOD2
%  E_N     - normal direction of planes to project images onto
%  L_RANGE - lengths to planes to project images onto
%  XLIM    - west-east limits of region to resample image projection in
%  YLIM    - south-north limits of region to resample image projection in
%  BLKSZ   - size of blocks to calculate/comare image correlations on
%  CM1     - Correction matrix for rotation of camera #1
%  CM2     - Correction matrix for rotation of camera #2
%
% Output:
%   X_out - Best East distances.
%   Y_out - Best north distances.
%   Z_out - Best Altitudes.
%   CC    - Best correlation
%   CC3D  - 3D correlation
% 
% See also AUTO_P_TRIANG, AUTO_QUICKTRIANG


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if nargin > 13
  %[xx11,yy11,zz11] = inv_project_img(img1,r1,optmod1,optp1,e_n,l_range(1),cm1);
  %[xx1e,yy1e,zz1e] = inv_project_img(img1,r1,optmod1,optp1,e_n,l_range(end),cm1);
  [xx11,yy11] = inv_project_img(img1,r1,optmod1,optp1,e_n,l_range(1),cm1);
  [xx1e,yy1e] = inv_project_img(img1,r1,optmod1,optp1,e_n,l_range(end),cm1);
else
  %[xx11,yy11,zz11] = inv_project_img(img1,r1,optmod1,optp1,e_n,l_range(1));
  %[xx1e,yy1e,zz1e] = inv_project_img(img1,r1,optmod1,optp1,e_n,l_range(end));
  [xx11,yy11] = inv_project_img(img1,r1,optmod1,optp1,e_n,l_range(1));
  [xx1e,yy1e] = inv_project_img(img1,r1,optmod1,optp1,e_n,l_range(end));
end

if nargin > 14
  %[xx21,yy21,zz21] = inv_project_img(img2,r2,optmod2,optp2,e_n,l_range(1),cm2);
  %[xx2e,yy2e,zz2e] = inv_project_img(img2,r2,optmod2,optp2,e_n,l_range(end),cm2);
  [xx21,yy21] = inv_project_img(img2,r2,optmod2,optp2,e_n,l_range(1),cm2);
  [xx2e,yy2e] = inv_project_img(img2,r2,optmod2,optp2,e_n,l_range(end),cm2);
else
  %[xx21,yy21,zz21] = inv_project_img(img2,r2,optmod2,optp2,e_n,l_range(1));
  %[xx2e,yy2e,zz2e] = inv_project_img(img2,r2,optmod2,optp2,e_n,l_range(end));
  [xx21,yy21] = inv_project_img(img2,r2,optmod2,optp2,e_n,l_range(1));
  [xx2e,yy2e] = inv_project_img(img2,r2,optmod2,optp2,e_n,l_range(end));
end

X = min(Xlim(:)):2*(max(Xlim(:))-min(Xlim(:)))/mean(size(img1)):max(Xlim(:));
Y = min(Ylim(:)):2*(max(Ylim(:))-min(Ylim(:)))/mean(size(img1)):max(Ylim(:));
[X,Y] = meshgrid(X,Y);

ccm = -1*ones(size(blkproc2(X,Y,blksz,'corr_coef_cmt')));
Z_out = -1*ones(size(ccm));
for i = length(l_range):-1:1,
  
  xx1 = xx11 + (xx1e-xx11)*(l_range(i)-l_range(1))/(l_range(end)-l_range(1));
  yy1 = yy11 + (yy1e-yy11)*(l_range(i)-l_range(1))/(l_range(end)-l_range(1));
  %zz1 = zz11 + (zz1e-zz11)*(l_range(i)-l_range(1))/(l_range(end)-l_range(1));
  xx2 = xx21 + (xx2e-xx21)*(l_range(i)-l_range(1))/(l_range(end)-l_range(1));
  yy2 = yy21 + (yy2e-yy21)*(l_range(i)-l_range(1))/(l_range(end)-l_range(1));
  %zz2 = zz21 + (zz2e-zz21)*(l_range(i)-l_range(1))/(l_range(end)-l_range(1));
  
  C1 = griddata(xx1(:),yy1(:),img1(:),X,Y);
  I = find(~isfinite(C1(:)));
  C1(I) = randn(size(C1(I)));
  C2 = griddata(xx2(:),yy2(:),img2(:),X,Y);
  I = find(~isfinite(C2(:)));
  C2(I) = randn(size(C2(I)));
  
  CC = blkproc2(C1,C2,blksz,'corr_coef_cmt');
  
  I = find(CC(:)>ccm(:));
  Z_out(I) = l_range(i);
  ccm(I) = CC(I);
  cc3d(:,:,i) = CC;
  
end
X_out = X;
Y_out = Y;
CC = ccm;
