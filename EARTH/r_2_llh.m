function [long,lat,h] = r_2_llh(r)
% R_2LLH transforms R in an earth centred horizontal system (GEO)
% to ( LONG, LAT, H ).
%    
% Calling:
% [long,lat,h] = r_2_llh(r)
% 
% Input R - [Nx3] array with positions in a permuted earth centered
% system, with e_z  poiting at (0 E,0 N), e_x pointing at (90 E, 0 N) 
% See also LATLONGH_2_R


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


try 
  % disp(size(r))
  if min(size(r))~=1
    % disp('a')
    [lat, long, h] = ecef2geo(r(:,[3 1 2])*1000);
    % disp('a')
  else
    % disp('b')
    [lat, long, h] = ecef2geo(r([3 1 2])*1000);
    % disp('b')
  end
catch
  r_earth = 6378.137;
  f = 1/298.257;
  e = (2*f-f*f)^.5;
  
  if min(size(r)==1)
    
    long = atan2(r(1),r(3));
    lat = atan(r(2)./((r(1)^2+r(3)^2)^.5/(1-e^2)));
    h = ( r(1)^2 + r(2)^2/(1-e^2)^2 + r(3)^2 )^.5 - r_earth;
    
  else
    
    long = atan2(r(:,1),r(:,3));
    lat = atan(r(:,2)./((r(:,1).^2+r(:,3).^2).^.5/(1-e^2)));
    h = ( r(:,1).^2 + r(:,2).^2/(1-e^2).^2 + r(:,3).^2 ).^.5 - r_earth;
    
  end
  warning('Using low precision Teoid')
  dbstack
end


