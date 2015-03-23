function [lat0,long0,alt0] = trace_line_to_EARTHsurf(x0,y0,z0,dx,dy,dz)
% TRACE_LINE_TO_EARTHSURF - from point [x0,y0,z0] in direction [dx,dy,dz]
%   to the earth surface
% 
% Calling:
%  [lat0,long0,alt0] = trace_line_to_EARTHsurf(x0,y0,z0,dx,dy,dz)
% Input:
%   x0 - Earth centred x coordinate of point (km)
%   y0 - Earth centred y coordinate of point (km)
%   z0 - Earth centred z coordinate of point (km)
%   dx - x-component of unit vector of line
%   dy - y-component of unit vector of line
%   dz - z-component of unit vector of line
% Output:
%   lat0  - latitude of line interseection with earth surface (deg)
%   long0 - longitude of line interseection with earth surface (deg)
%   alt0  - altitude of line interseection with earth surface (km)

%   Copyright © 20121208 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% If called as trace_line_to_EARTHsurf(x0,y0,z0,dx,dy,dz)
if nargin > 4
  % then merge the line-of-sight components
  e_los = [dx,dy,dz];
else
  e_los = dx;
end

e_los = e_los/norm(e_los);
r0 = [x0,y0,z0];

[l_opt,fv_opt,exit_flag] = fminsearch(@(l) altitude_error(r0,e_los,l),1)



[long0,lat0,alt0] = pos_on_ground(r0,e_los,l_opt)



function err = altitude_error(r0,e_los,l)
% ALTITUDE_ERROR - 
%   

r = point_on_line(r0,e_los,l);

[long,lat,h] = r_2_llh(r);
err = h.^2;

function [long,lat,alt] = pos_on_ground(r0,e_los,l_opt)

r = point_on_line(r0,e_los,l_opt);
[latitude, longitude, altitude] = ecef2geo(r,1)
[long,lat,alt] = r_2_llh(r)
