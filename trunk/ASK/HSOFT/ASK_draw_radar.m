function [varargout] = ASK_draw_radar(radar_site,az,el,dphi,optpar,imsiz,l,r_Camera,varargin)
% ASK_DRAW_RADAR - plot the radar beam onto an image. 
%
% Calling:
%   ph = ASK_draw_radar(radar_site,az,el,dphi,optpar,imsiz,l,r_camera)
%   [u,v] = ASK_draw_radar(radar_site,az,el,dphi,optpar,imsiz,l,r_camera)
%   [u,v,ph] = ASK_draw_radar(radar_site,az,el,dphi,optpar,imsiz,l,r_camera)
% Input:
%  radar_site - Name of radar size [ 'T' | 'E' ] for which default
%               beam parameters exists
%  az         - azimuth angle of radar beam - clock-wise from
%               north, DEGREES!
%  el         - elevation angle of radar beam, DEGREES!
%  dphi       - Half wifdth of radar beam, DEGREES!
%  optpar     - optical parameters of camera
%  imsiz      - size (pixels) of image to calculate beam projection onto. 
%  l          - altitude of beam pattern to project - for off-site
%               located cameras (km)
%  r_camera   - camera location relative to radar site [East, North Above](km)
%               Optional, if left out, will be set to [0,0,0]
%               (colocated with radar)
% Output:
%  ph - handle to plotted beam-projection, as returned from PLOT
%  u  - horizontal image coordinates of beam-projection
%  v  - vertical image coordinates of beam-projection
%
% When the function is called with 1 or 3 outputs, the projection
% will be plotted, if function is called with 2 output parameters
% only the image coordinates of the projection is returned.
%
% If the default beam-directions is to be plotted, AZ, EL, DPHI can
% be set to empty (== []).

% Modified from draw_radar.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies


[u0,v0,r,u,v,dr] = ASK_get_radar(radar_site,az,el,dphi,optpar,imsiz,l,r_Camera,varargin);
if nargout ~= 2
  isHoldOn = ishold;
  hold on
  ph = plot(u,v,varargin{:});
  if ~isHoldOn
    hold off
  end
end
if nargout == 1
  varargout{1} = ph;
elseif nargout == 2
  varargout{1} = u;
  varargout{2} = v;
elseif nargout == 3
  varargout{1} = u;
  varargout{2} = v;
  varargout{3} = ph;
end
