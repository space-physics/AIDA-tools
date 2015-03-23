function [u,v] = ASK_get_fieldline(x0,y0,z,az,el,optpar,imsiz,r_Camera,varargin)
% ASK_GET_FIELDLINE - get magnetic field-line projection onto an image.
%
% Calling:
%   [u,v] = ASK_get_fieldline(x0,y0,z,az,el,dphi,optpar,imsiz,l,r_camera)
% Input:
%  x0
%  y0
%   z
%  az         - azimuth angle of radar beam - clock-wise from
%               north, DEGREES! If left empty the default magnetic
%               zenith directions at Ramfjord and ESR is used.
%  el         - elevation angle of radar beam, DEGREES! If left
%               empty the default magnetic zenith directions at
%               Ramfjord and ESR is used.
%  optpar     - optical parameters of camera - is obtained with: ASK_get_ask_cnv
%  imsiz      - size (pixels) of image to calculate beam projection onto. 
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


% Overwrite the default values if input is given.
if ~isempty(az)
  azi = az*pi/180;
end
if ~isempty(el)
  ele = el*pi/180;
end

if nargin < 8 || isempty(r_Camera)
  r_Camera = [0,0,0];
end

% field-line direction
e_COB = [cos(ele)*sin(azi), cos(ele)*cos(azi), sin(ele)];


% vector to point at altitude l along e_COB
r0 = points_on_line([x0,y0,0],e_COB',z'/e_COB(3));
% Calculate image coordinates of r0:
[u,v] = project_point(r_Camera,optpar,r0,eye(3),imsiz);

