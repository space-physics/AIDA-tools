function [u0,v0,r,u,v,dr] = ASK_get_radar(radar_site,az,el,dphi,optpar,imsiz,l,r_Camera,varargin)
% ASK_GET_RADAR - get image coordinates of the radar beam.
%
% Calling:
%   [u0,v0,r,u,v,dr] = ASK_get_radar(radar_site,az,el,dphi,optpar,imsiz,l,r_camera)
% Input:
%  radar_site - Name of radar size [ 'T' | 'E' ] for which default
%               beam parameters exists
%  az         - azimuth angle of radar beam - clock-wise from
%               north, DEGREES! If left empty the default magnetic
%               zenith directions at Ramfjord and ESR is used.
%  el         - elevation angle of radar beam, DEGREES! If left
%               empty the default magnetic zenith directions at
%               Ramfjord and ESR is used.
%  dphi       - Half wifdth of radar beam, DEGREES! If left
%               empty the default magnetic zenith directions at
%               Ramfjord and ESR is used.
%  optpar     - optical parameters of camera - is obtained with: ASK_get_ask_cnv
%  imsiz      - size (pixels) of image to calculate beam projection onto. 
%  l          - altitude of beam pattern to project - for off-site
%               located cameras (km)
%  r_Camera   - camera location relative to radar site [East, North Above](km)
%               Optional, if left out, will be set to [0,0,0]
%               (colocated with radar)
% Output:
%  u0 - horizontal image coordinate of radar beam center 
%  v0 - vertical image coordinate of radar beam center 
%  r  - approximate radar beam radius in image
%  u  - horizontal image coordinates of beam-projection
%  v  - vertical image coordinates of beam-projection
%  dr - standard deviation of ( (u-u0).^2 + (v-v0).^2 ).^0.5
%
% If the default beam-directions is to be used, AZ, EL, DPHI can
% be set to empty (== []).

% Modified from draw_radar.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies


% Seems unused: global vs
% Seems unused: global cnv


switch radar_site(1)
 case 'T' % Tromso
  
  dPhi = 0.3*pi/180;   %  Half beam width (radius)
  azi = 185.02*pi/180; %  Azimuth, radians
  ele = 77.5*pi/180;   %  Elevation, radians
  
 case 'E' % ESR
  
  dPhi = 0.45*pi/180; % Half beam width (radius)
  azi = 181.0*pi/180; % Azimuth, radians
  ele = 81.6*pi/180;  % Elevation, radians

 otherwise
  % No settings known...
end

% Overwrite the default values if input is given.
if ~isempty(az)
  azi = az*pi/180;
end
if ~isempty(el)
  ele = el*pi/180;
end
if ~isempty(dphi)
  dPhi = dphi*pi/180;
end
if nargin < 7 || isempty(l)
  l = 100;
end
if nargin < 8 || isempty(r_Camera)
  r_Camera = [0,0,0];
end

% Center-of-Beam direction
e_COB = [cos(ele)*sin(azi), cos(ele)*cos(azi), sin(ele)];
% Arbitrary direction perpendicular to e_COB.
e_perpR = cross(e_COB,[0,1,0]);
% [0 1 0] is a horizontal direction if radar beam points there no
% ionspheric data will be available anyways

% Rotation matrix around that vector
rMtr = rot_around_v(e_perpR,dPhi);

% Line-of-sight unit vector
e_3dB = (rMtr * e_COB')';

% Pre-allocate r
r = zeros(181,3);

% vector to point at altitude l along e_COB
r0 = point_on_line([0,0,0],e_COB,l/e_COB(3));
% Calculate image coordinates of r0:
[u0,v0] = project_point(r_Camera,optpar,r0',eye(3),imsiz);


% vector to point at altitude l in direction e_3dB
r(1,:) = point_on_line([0,0,0],e_3dB,l/e_3dB(3));

for i1 = 1:180,
  % Rotate around the clock, in 2 degree steps
  dPhi = i1*2*pi/180;
  rMtr = rot_around_v(e_COB,dPhi); % Rotation matrix around the Center-of-Beam direction
  e_3dBp = (rMtr * e_3dB')';       % Rotate the edge-vector
  % And fill up r
  r(i1+1,:) = point_on_line([0,0,0],e_3dBp,l/e_3dB(3));
  
end

% Calculate image coordinates of r:
[u,v] = project_point(r_Camera,optpar,r',eye(3),imsiz);

if exist('nanmean','file')
  r = nanmean( ( (u-u0).^2 + (v-v0).^2 ).^(1/2) );
  dr = nanstd( ( (u-u0).^2 + (v-v0).^2 ).^(1/2) );
else
  r = mean( ( (u-u0).^2 + (v-v0).^2 ).^(1/2) );
  dr = std( ( (u-u0).^2 + (v-v0).^2 ).^(1/2) );
end

