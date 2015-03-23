function [Z_out,CC,cc3d] = auto_quicktriang(img1,r1,optmod1,optp1,img2,r2,optmod2,optp2,X,Y,Z,blksz,cm1,cm2)
% AUTO_QUICKTRIANG - Automatic triangulation of structured surfaces
% 
% Calling
% [Z_out,CC,cc3d] = auto_quicktriang(img1,r1,optmod1,optp1,img2,r2,optmod2,optp2,X,Y,Z,blksz,cm1,cm2)
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
%  X       - 3-D block of east-coordinates to project images on 
%  Y       - 3-D block of north-coordinates to project images on 
%  Z       - 3-D block of up-coordinates to project images on 
%  BLKSZ   - size of blocks to calculate/comare image correlations on
%  CM1     - Correction matrix for rotation of camera #1
%  CM2     - Correction matrix for rotation of camera #2
%
% Output:
%   Z_out - Best Altitudes.
%   CC    - Best correlation
%   CC3D  - 3D correlation
% 
% See also AUTO_P_TRIANG AUTO_TRIANGULATE

%   Copyright � 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin > 13 && all(size(cm1)==[3 3])
  Cm1 = cm1;
else
  Cm1 = eye(3);
end

if nargin > 14 && all(size(cm1)==[3 3])
  Cm2 = cm2;
else
  Cm2 = eye(3);
end

ccm = -10*ones(size(blkproc2(X(:,:,1),Y(:,:,1),blksz,'corr_coef_cmt')));
Z_out = -10*ones(size(ccm));
for i1 = size(Z,3):-1:1,
  
  r(:,1) = reshape(X(:,:,i1),[numel(X(:,:,i1)) 1]);
  r(:,2) = reshape(Y(:,:,i1),[numel(X(:,:,i1)) 1]);
  r(:,3) = reshape(Z(:,:,i1),[numel(X(:,:,i1)) 1]);
  
  u1 = X(:,:,i1);
  v1 = Y(:,:,i1);
  if optmod1 > 0
    [u1(:),v1(:)] = project_point(r1,[optp1(1:8) optmod1 0],r',Cm1);
  else
    [u1(:),v1(:)] = project_point(r1,optp1,r',Cm1);
  end
  u2 = X(:,:,i1);
  v2 = Y(:,:,i1);
  if optmod2 > 0
    [u2(:),v2(:)] = project_point(r2,[optp2(1:8) optmod2 0],r',Cm2);
  else
    [u2(:),v2(:)] = project_point(r2,optp2,r',Cm2);
  end

  C1 = interp2(img1,u1,v1);
  C2 = interp2(img2,u2,v2);
  
  subplot(1,3,1)
  pcolor(squeeze(X(:,:,1)),squeeze(Y(:,:,1)),C1),shading flat
  hold on
  contour(squeeze(X(1,:,1)),squeeze(Y(:,1,1)),wiener2(C2),'k')
  hold off
  subplot(1,3,2)
  pcolor(squeeze(X(:,:,1)),squeeze(Y(:,:,1)),C2),shading flat
  hold on
  contour(squeeze(X(:,:,1)),squeeze(Y(:,:,1)),wiener2(C1),'k')
  title(num2str(Z(1,1,i1)))
  hold off
  subplot(1,3,3)
  I = find(~isfinite(C1(:)));
  C1(I) = randn(size(C1(I)));
  I = find(~isfinite(C2(:)));
  C2(I) = randn(size(C2(I)));
  pcolor(squeeze(X(:,:,1)),squeeze(Y(:,:,1)),...
         (C2-conv2(C2,ones(50)/50^2,'same')).*...
         (C1-conv2(C1,ones(50)/50^2,'same'))),shading flat%./...
  
  td(i1) = sum(sum(abs(C2/max(max(wiener2(C2)))-C1/max(max(wiener2(C1))))));
  drawnow
  CC = blkproc2(C1,C2,blksz,'corr_coef_cmt');
  
  I = find(CC(:)>ccm(:));
  Z_out(I) = Z(1,1,i1);
  ccm(I) = CC(I);
  cc3d(:,:,i1) = CC;
  
end
CC = ccm;
clf
plot(td,unique(Z(:)))
