function SphDist = ASK_sph_dist(ra1,decl1,ra2,decl2)
% ASK_SPH_DIST -  Calculating angle between two points on a sphere. 
% the inputs and outputs are in radians
% dec1 and dec2 are like latitudes, and ra1 and ra2 are like longitudes
% Works for arrays, if all inputs correspond.
%
% Calling:
%   SphDist = ASK_sph_dist(ra1,decl1,ra2,decl2)
% Input:
%   ra1   - Rect ascension 1
%   decl1 - Declination 1
%   ra2   - Rect ascension 2
%   decl2 - Declination 2
% Output:
%   SphDist - great circle angle between the two points


% Written to replicate functionality of sph_dist.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies

e1 = [sin(ra1).*sin(decl1),cos(ra1).*sin(decl1),cos(decl1)];
e2 = [sin(ra2).*sin(decl2),cos(ra2).*sin(decl2),cos(decl2)];
SphDist = atan2(norm(cross(e1,e2)),dot(e1,e2));
