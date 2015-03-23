function dOPS = starcal_checker(img,optpar,dateNtime,longlat,OPS)
% STARCAL_CHECKER - verify geometric calibration quality.
% 
% Calling:
%   starcal_checker(img,optpar,dateNtime,longlat,OPS)
%   dOPS = starcal_checker
% Input:
%   img       - image to display
%   optpar    - optical parameters used to calculate the image
%               positions of the stars, as obtained by STARCAL
%   dateNtime - [yyyy, mm, dd, HH, MM, ss] date and time of image
%               exposure 
%   longlat   - [longitude, latitude] of location where image was
%               taken, (degrees)
%   OPS       - options struct for controlling the displaying
%               default struct returned when function is called
%               with fewer than 4 input arguments. Fields are:
%               star_pl_cl = [1 .7 .5] Plot colour of stars [R,G,B]
%               star_pl_sz = 2;        Plot size of stars
%               star_max_mag = 5;      Max magnitude of stars to overplot
%               imageTheImage = false  Set to true to force
%               redisplaying of image
%               OPS.cax field can be created with a valid input to
%               CAXIS.

%   Copyright © 2013-07-23 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Make us a default options struct:
dOPS = staroverplot;
if nargin < 4
  % Then there are not enough input parameters to get the job
  % done, so just abort mission.
  return
end
if nargin > 4 && ~isempty(OPS)
  % Then we have an options struct input, so merge that one ontop
  % of the default struct - so that the input options take
  % precedence.
  dOPS = merge_structs(dOPS,OPS);
end

% load the star catalog, and extract the stars that are above the
% horizon: 
[possiblestars] = loadstars2(longlat,dateNtime(1:3),dateNtime(4:6));

% Display the inut image
imagesc(img),axis xy
if isfield(dOPS,'cax')
  caxis(dOPS.cax)
end

% Overplot stars with the optical parameter set
staroverplot(img,optpar,possiblestars,dOPS);
