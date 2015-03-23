function Im_proj = inv_proj_img_ll(img_in,optmod,optpar,lat0,long0,alt0,lat,long,alt,ze_max)
% INV_PROJ_IMG_LL - map IMG_IN to a latitude-longitude grid LAT, LONG
%   at an altitude ALT. The image IMG_IN taken from LAT0, LONG0 at
%   an altitude ALT0 with a camera model OPTMOD and rotation and
%   optical transfer function caracterised by OPTPAR.
% 
% Callling:
%  Im_proj = inv_proj_img_ll(img_in,optmod,optpar,lat0,long0,alt0,lat,long,alt[,ze_max])
%
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
%   [long,lat] = meshgrid(16:.01:19,64:.01:67.5);
%   optpar =  [-2.3603, 1.5209, 11.506, 64.502, 0.086649,-0.0025577, -0.0044151, 1, 1, 0];
%   optmod = 1;
%   lat0 = 63.154355;
%   long0 = 17.234802;
%   alt0 = 0.254;
%   alt = 83;
%   
%   %  For a grayscale image this is enough:
%   img_in = double(rgb2gray(imread('nlc214.jpg')));
%   Im_proj = inv_proj_img_ll(img_in,optmod,optpar,lat0,long0,alt0,lat,long,alt);
%   pcolor(long,lat,Im_proj),shading flat
%   
%   % For a rgb image it is unfortunately needed to do:
%   img_in = double((imread('nlc214.jpg')));
%   Im_p(:,:,3) = inv_proj_img_ll(img_in(:,:,3),1,optpar,lat0,long0,alt0,lat,long,alt);
%   Im_p(:,:,2) = inv_proj_img_ll(img_in(:,:,2),1,optpar,lat0,long0,alt0,lat,long,alt);
%   Im_p(:,:,1) = inv_proj_img_ll(img_in(:,:,1),1,optpar,lat0,long0,alt0,lat,long,alt);
%   tcolor(long,lat,Im_p/256)

%       See also INV_PROJECT_IMG, INV_PROJECT_IMG_SURF, CAMERA_MODEL, CAMERA_INV_MODEL

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
ze_all = atan((Xs.^2+Ys.^2).^.5./Zs)*180/pi;

r = [0 0 0];

[Im_proj] = inv_project_img_surf(img_in,r,optmod,optpar,Xs,Ys,Zs,eye(3));
Im_proj(ze_all>ze_max|ze_all<0) = nan;
