function ph = ASK_plot_fieldline(x0,y0,z,az,el,optpar,imsiz,r_Camera,varargin)
% ASK_PLOT_FIELDLINE - plot magnetic field-line projection onto an image.
%
% Calling:
%   ph = ASK_plot_fieldline(x0,y0,z,az,el,dphi,optpar,imsiz,l,r_camera)
% Input:
%  x0         - East footpoint of magnetic field-line (km), scalar
%  y0         - North footpoint of magnetic field-line (km), scalar
%   z         - Altitudes along field-line to plot, (km), [nH x 1]
%  az         - azimuth angle of field-line - clock-wise from
%               north, DEGREES!
%  el         - elevation angle of radar beam, DEGREES!
%  optpar     - optical parameters of camera - is obtained with
%               ASK_get_cnv if OPTPAR is empty.
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
azi = az*pi/180;
ele = el*pi/180;

if isempty(optpar)
  optpar = [ASK_get_cnv, 11, 0];
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

ph = plot(u,v,varargin{:});
