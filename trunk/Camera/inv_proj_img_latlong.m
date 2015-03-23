function [Long,Lat,dh_final] = inv_proj_img_latlong(img_in,optmod,optpar,lat0,long0,alt0,alt,ze_max,options)
% INV_PROJ_IMG_LATLONG - calculate pixel-by-pixel Long-Lat coordinate for IMG_IN 
%   at altitude ALT. The image IMG_IN taken from LAT0, LONG0 at
%   an altitude ALT0 with a camera model OPTMOD and rotation and
%   optical transfer function caracterised by OPTPAR.
% 
% Callling:
%  [Long,Lat,dh_final] = inv_proj_img_latlong(IMG_IN,OPTMOD,OPTPAR,LAT0,LONG0,ALT0,ALT,ZE_MAX,options)
%
% Input:
%  
%  IMG_IN - Input image (double) grayscale or rgb
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
%  LAT0   - Latitude of camera (degrees)
%  LONG0  - Longitude of camera (degrees)
%  ALT0   - altitude of camera (km)
%  ALT    - altitude (km) coordinates of grid points to project image to
%  ZE_MAX - maximum zenith angle to use, optional - defaults to 85 deg
%  options - options for controlling fminsearchbnd, the fields
%            TolFun and TolX defaults to 0.001 if no other options
%            are given, this to speed up the running time - 
%  
%  The excecution time gets a bit longish (~40 minutes on a Vaio
%  1.7 GHz lap-top for a 512x512 image with 163366 pixels above
%  ZE_MAX), this is tenable for one-time efforts where a lat-long
%  grid is calculated once per altitude per season for a camera,
%  for other uses INV_PROJECT_IMG or INV_PROJ_IMG_LL that does
%  similar projections is recommended (the first to a plane
%  horizontal in the local Cartesian coordinate system centred at
%  LONG0, LAT0; and the second calculates the image intensities for
%  points on a regular LONG-LAT grid)
% 
% Example: 
%   optpar =  [-2.3603, 1.5209, 11.506, 64.502, 0.086649,-0.0025577, -0.0044151, 1, 1, 0];
%   optmod = 1;
%   lat0 = 63.154355;
%   long0 = 17.234802;
%   alt0 = 0.254;
%   alt = 110;
%   
%   %  For a grayscale image this is enough:
%   img_in = double(rgb2gray(imread('nlc214.jpg')));
%   [Long,Lat,dh_final] = inv_proj_img_latlong(img_in,optmod,optpar,lat0,long0,alt0,alt,ze_max)
%   pcolor(Long,Lat,img_in),shading flat
% 
%       See also INV_PROJ_IMG_LL, INV_PROJECT_IMG, INV_PROJECT_IMG_SURF, CAMERA_MODEL, CAMERA_INV_MODEL

%   Copyright � 2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


%% 0 Set the maximum zenith angle if needed
if nargin < 8 || isempty(ze_max)
  ze_max = 85;
end

fmsops = optimset('fminsearch');
fmsops.TolFun = 0.001;
fmsops.TolX = 0.001;
if nargin > 8
  fmsops = merge_structs(fmsops,options);
end

%% 1 Calculate the pixel coordinate grid
[px,py] = meshgrid(1:size(img_in,1),1:size(img_in,2));

%% 2 Calculate the line-of-sight vectors for all pixels:
epix = inv_project_LineOfSightVectors(px(:)',py(:)',img_in,[0,0,0],optmod,optpar,[0 0 1],100,eye(3));

%% 3 Get the sorted indices of the e_z components
[~,iS] = sort(epix(:,3),'descend');
%%
% That way we can start calculating the latitude-longitude
% coordinates of pixels from the one closest to zenith (which ought
% to be easy) and then continue over increasing zenith angles. That
% way the range to the desired altitude will vary slowly, thereby
% making the search for the right range shorter

%% 4 Initialise the output variables
%  with nans
Lat  = nan*py;
Long = nan*py;
dh0 = nan*py;
dh_final = nan*py;

%% 5 Start the grunt work:
%  We start with the pixel looking closes to vertical. For the
%  pixel looking into vertical everything should be
%  trivial. Lat-Long should not vary much from the camera position,
%  and the range to the desired altitude ought to be close to the
%  altitude.
h_target = alt;
range0 = alt;
r0 = [0,0,0];
n2do = sum(acos(epix(iS,3)) < ze_max*pi/180);
wbh = waitbar(0,'Please wait...');

OPS.tol = 0.001;
OPS.dx = 0.001;
OPS.maxitter = 1e3;

for i1 = 1:length(iS),
  
  if acos(epix(iS(i1),3)) < ze_max*pi/180
    
    %% Search for the range where the line-of-sight intersects ALT
    dh0(iS(i1)) = alt_error(range0,h_target,lat0,long0,alt0,r0,epix(iS(i1),:));
    [range,dh_final(iS(i1))] = fminsearchbnd(@(l) alt_error(l,h_target,lat0,long0,alt0,r0,epix(iS(i1),:)),range0,0,100*range0,fmsops);
    %% Calculate the corresponding longitude-latitude
    [Lat(iS(i1)),Long(iS(i1)),alt] = range2LongLatAlt(range,h_target,lat0,long0,alt0,r0,epix(iS(i1),:));
    %% Set RANGE0 for the next pixel to the current RANGE - since
    %  the pixels are sorted according to angle relative to zenith
    %  RANGE should increase steadily and slowly so this should be
    %  a good next start-guess.
    range0 = range;
    
  end
  if mod(i1,100) == 0
    waitbar(i1/n2do,wbh)
  end

end

close(wbh)

function [lat,long,alt] = range2LongLatAlt(range,h_target,lat0,long0,h0,r0,epix)

r = points_on_lines(r0,epix,range);
[long,lat,alt] = xyz_2_llh(lat0,long0,h0,r);

function dh2 = alt_error(range,h_target,lat0,long0,h0,r0,epix)

r = points_on_lines(r0,epix,range);
[long,lat,h] = xyz_2_llh(lat0,long0,h0,r);
dh2 = (h/1e3-h_target)^2;
