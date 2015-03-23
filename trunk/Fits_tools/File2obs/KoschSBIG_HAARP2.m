function [obs] = KoschSBIG_HAARP2(img_struct)
% KoschSBIG_HAARP2 extracts observation info from SBIG header-struct 
% as returned from SBIG.M
% such as exposure time, time and date of exposure et al.
% This version is hard-coded for a HAARP-campaign.
%
% Outdated! use: sbig2AIDAobs instead!
% 
% Calling:
%    [obs] = try_to_be_smart(img_struct)
% 
% INPUT: 
%   img_head - a sbig9 meta-data struct as returned from sbig.
% 
% OUTPUT:
%    OBS the output is a struct with some relevant key parameters
%    such as camera rotation, exposure time, time and date of
%    exposure filter camera number, camera position.

%       Bjorn Gustavsson 2007-06-16
%       Copyright (c) 2001 by Bjorn Gustavsson

global FITS_HOME

FITS_HOME = which('inimg');
FITS_HOME = fileparts(FITS_HOME);

obs.time = [];
obs.pos = [];
obs.longlat = [];
obs.xyz = [];
obs.station = [];
obs.alpha = [];
obs.beta = [];
obs.az = [];
obs.ze = [];
obs.camnr = [];
obs.exptime = [];
obs.filter = [];

o_date = sscanf(img_struct.date,'%f/%f/%f')';
o_time = sscanf(img_struct.time,'%f:%f:%f')';
obs.time = [o_date([3 1 2]),o_time];
if obs.time(1) < 80
  obs.time(1) = 2000 + obs.time(1);
elseif obs.time(1) < 1900
  obs.time(1) = 1900 + obs.time(1);
end
obs.exptime = str2num(img_struct.exposure);

obs.station = 0; % HAARP is station 401 in the AIDA-tools station enumeration.
obs.longlat = [-146.842017 64.872];
obs.pos = [-146.842017 64.872];
obs.cmtr = eye(3);
obs.xyz = [0,0,0];

switch lower(img_struct.filter)
 case 'red'
  obs.filter = 6300;
 case 'green'
  obs.filter = 5577;
 case 'blue'
  obs.filter = 4278;
 otherwise
  obs.filter = nan;
end


obs.ccdtemp = str2num(img_struct.temperature);

obs.BZERO = 0;
obs.bscale = 1;


% Some functions related to the geometric calibrations benefits
% from getting azimuth and zenith (or alpha and beta) angles. But
% as none is in the header it is just to set them all to 0.
obs.az = 0;
obs.ze = 0;
obs.alpha = 0;
obs.beta = 0;
% Some image correction/pre-processing steps require information
% about which ccd it is - ALIS bias correction and bad-pixel fixing
% have images and maps for bias and bad pixels. As long as the
% camnr doesnt match it should be OK.
obs.camnr = -12;

function outstr = ddeblank(in_str)
% DDEBLANK - 
%   

outstr = fliplr(deblank(fliplr(deblank(in_str))));
