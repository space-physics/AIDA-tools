function [LongI,LatI] = inv_proj_img_ll2(img_in,optmod,optpar,lat0,long0,alt0,lat,long,alt,ze_max)
% INV_PROJ_IMG_LL - map IMG_IN to a latitude-longitude grid LAT, LONG
%   at an altitude ALT. The image IMG_IN taken from LAT0, LONG0 at
%   an altitude ALT0 with a camera model OPTMOD and rotation and
%   optical transfer function caracterised by OPTPAR.
% 
% Callling:
%  [LongI,LatI] = inv_proj_img_ll2(img_in,optmod,optpar,lat0,long0,alt0,lat,long,alt[,ze_max])
% Input:
%  
%  img_in - Input image (double) grayscale or rgb
%  OPTMOD - is the optical model/transfer function to use:
%           1 - f*tan(theta),
%           2 - f*sin(alfa*theta),
%           3 - f(alfa*theta + (1-alfa)*tan(theta))
%           4 - f*theta 5 - f*tan(alfa*theta)
%           5 - f*tan(alfa*theta)
%          -1 - non-parametric, unrotated from zenith, with look-up
%               tables,
%          -2 - non-parametric, rotated from zenith, with look-up
%               tables,
%  OPTPAR - is a vector caracterising the optical
%           transfer function, or an OPTPAR struct, with fields:
%           sinzecosaz, sinzesinaz, u, v that define the horizontal
%           components of a pixel l-o-s, and the pixel coordinates
%           for the corresponding horizontal l-o-s components,
%           respectively, and optionally a field rot (when used a
%           vector with 3 Tait-Bryant rotaion angles)
%  lat0   - Latitude of camera (degrees)
%  long0  - Longitude of camera (degrees)
%  alt0   - altitude of camera (km)
%  lat    - latitude (degrees) coordinates of grid points to project image to
%  long   - longitude (degrees) coordinates of grid points to project image to
%  alt    - altitude (km) coordinates of grid points to project image to
%  ze_max - maximum zenith angle to use, optional - defaults to 85 deg
% 
% Example: 
%   [LongG,LatG] = meshgrid(linspace(6.2,35.5,600),linspace(63.8,74.2,600));                                   
%   optpar = [0.97899 -0.97941 -0.55363 -1.1863 -7.8519 -0.019269 -0.033697 0.32993 2 0]
%   [LongN,LatN] = inv_proj_img_ll2(ones([512,512]),optpar(9),optpar,69.02,20.87,0.123,LatG,LongG,110,82);       
%   pcolor(LongN,LatN,img_in),shading flat
%   
%   See also INV_PROJECT_IMG, INV_PROJECT_IMG_SURF, CAMERA_MODEL, CAMERA_INV_MODEL

%   Copyright � 2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if nargin < 10 || isempty(ze_max)
  ze_max = 85;
end
Xs = lat;
Ys = lat;
Zs = lat;
if alt0 > 8 % alt0 should be in km into latlong_2_xyz, if alt0 is larger than 8 its unit isn't km.
  alt0 = alt0/1e3;
end
[r_out] = latlongh_2_xyz(lat0,long0,alt0,lat(:),long(:),alt);
%[Xs(:),Ys(:),Zs(:)] = makenlcpos(lat0,long0,alt0,lat(:),long(:),alt);
Xs(:) = r_out(1,:);
Ys(:) = r_out(2,:);
Zs(:) = r_out(3,:);

r = [0 0 0];

% Calculate image coordinates for points on the surface [X,Y,Z]
[uL,vL] = project_point(r,optpar,[Xs(:),Ys(:),Zs(:)]',eye(3),size(img_in));

ui = 1:size(img_in,2);
vi = 1:size(img_in,1);
[ui,vi] = meshgrid(ui,vi);

LongI = griddata(uL(:),vL(:),long(:),ui,vi,'cubic');
LatI  = griddata(uL(:),vL(:),lat(:), ui,vi,'cubic');

%ze_all = atan((Xs.^2+Ys.^2).^.5./Zs)*180/pi;
[az_all,ze_all] = inv_project_directions(ui(:)',vi(:)',img_in,[0,0,0],optmod,optpar,[0 0 1],10,eye(3));

LongI(ze_all(:)>ze_max|ze_all(:)<0) = nan;
LatI(ze_all(:)>ze_max|ze_all(:)<0) = nan;
