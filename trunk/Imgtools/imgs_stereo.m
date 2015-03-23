function [X,Y,Z,U1,V1,U2,V2,minL] = imgs_stereo(file1,PO1,optp1,r1,file2,PO2,optp2,r2,corr1,corr2,OPS)
% imgs_stereo - Triangulate from 2 series of images
%   
% Calling:
% [X,Y,Z,U1,V1,U2,V2,minL] = imgs_stereo(file1,PO1,optp1,r1,file2,PO2,optp2,r2,corr1,corr2,OPS)
% 
%   INPUT parameters: 
%   FILES1 - char array of image files, full or relative path, readable 
%   PO1    - image pre_proc_ops for images in FILES1, see TYPICAL_PRE_PROC_OPS
%   OPTP1  - should be an array with optical parameters for images in FILES1 see CAMERA,
%   R1     - location of camera 1 (1x3) or (3x1)
%   FILES2 - char array of image files,
%   PO2    - image pre_proc_ops for images in FILES2,
%   OPTP2  - should be an array with optical parameters for images in FILES2 see CAMERA,
%   R2     - location of camera 2, (station 2, second observation point) (1x3) or (3x1)
%   CORR1  - correction matrix for rotations in camera 1
%   (difference in coordinate system between R1 and R2)
%   CORR2  - correction matrix for rotations in camera 2
%   (difference in coordinate system between R1 and R2, curvature
%   of earth or whatever)
%  
%   OUTPUT parameters: 
%   X    - "East" distance of points identified (Cell array)
%   Y    - "North" distance of points identified (Cell array)
%   Z    - "Altitude" of points identified (Cell array)
%   U1   - cell array of horisontal coordinate of identified points in images1
%   V1   - cell array of vertical coordinate of identified points in images1
%   U2   - cell array of horisontal coordinate of identified points in images2
%   V2   - cell array of vertical coordinate of identified points in images2
%          size U1 = [size(file1,1) 1], size(U1{i}) varying
%   MINL - Minimum distance between lines-of-sight of identified
%          points 
%   OPS - Options structure, currently OPS.chectmp, if 1 extra plot
%         for control of the triangulation result
%   
%   Very little or no argument checking is preformed
%
% See also: TRIANGULATE


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


%global bxy bx by


if nargin == 0
  % if no input return OPS as first outarg
  X.checktmp = 0;
  X.epipolar_lines = 1;
  X.epipolar_range = [80,20,500];
  X.SubplotsNotFigs = 1;
  return
end

if all(size(corr1)) ~= 3
  corr1 = eye(3);
end
if all(size(corr2)) ~= 3
  corr2 = eye(3);
end

for i = 1:size(file1,1),
  
  %[img1,h1,o1] = inimg(file1(i,:),PO1);
  %[img2,h2,o2] = inimg(file2(i,:),PO2);
  [img1] = inimg(file1(i,:),PO1);
  [img2] = inimg(file2(i,:),PO2);
  
  %% ATTEMPTED: fix the calling of TRIANGULATE to conform with:
  PO1.optpar = optp1;
  PO2.optpar = optp2;
  [xtr,ytr,ztr,u1,v1,u2,v2,minl] = triangulate(img1,r1,...
                                               img2,r2,...
                                               corr1,corr2,[PO1,PO2],OPS);
  % Maybe it is that simple...
  % ...but lets keep the old version for now
  %[xtr,ytr,ztr,u1,v1,u2,v2,minl] = triangulate(img1,r1,optp1,...
  %                                             img2,r2,optp2,...
  %                                             OPS.checktmp,corr1,corr2);
  X{i} = xtr;
  Y{i} = ytr;
  Z{i} = ztr;
  U1{i} = u1;
  V1{i} = v1;
  U2{i} = u2;
  V2{i} = v2;
  minL{i} = minl;
  
end
