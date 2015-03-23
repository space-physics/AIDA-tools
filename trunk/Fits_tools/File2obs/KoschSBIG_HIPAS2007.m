function [obs] = KoschSBIG_HIPAS2007(img_head)
% LANCS_APOGEE_FITS parses an fits header for observation info
% such as exposure time, time and date of exposure et al.
% This has stuff hard-coded for a HIPAS-campaign
%
% Outdated! use: sbig2AIDAobs instead!
% 
% Calling:
%    [obs] = try_to_be_smart(img_head,ALIS_FITS)
% 
% INPUT: 
%   img_head - a FITS header, char array.
% 
% OUTPUT:
%    OBS the output is a struct with some relevant key parameters
%    such as camera rotation, exposure time, time and date of
%    exposure filter camera number, camera position.
% 
% 


%       Bjorn Gustavsson 2007-06-16
%       Copyright (c) 2001 by Bjorn Gustavsson

global FITS_HOME
persistent Station_names
persistent stationpos
persistent ktransf

load ktransf.dat
load stationpos.dat

FITS_HOME = which('inimg');
FITS_HOME = fileparts(FITS_HOME);


delimiters = [9:13 32];
delimiters = [delimiters,'~=+*/^()[]{}<>,;:'''];

obs.time = [];
obs.pos = [];
obs.station = [];
obs.alpha = [];
obs.beta = [];
obs.az = [];
obs.ze = [];
obs.camnr = [];
obs.exptime = [];
obs.filter = [];

H = img_head';

hindx = fitsfindinheader(img_head,'DATE-OBS');
if ~isempty(hindx)
  delimiters = [delimiters,'-T'];
  timestr = img_head(hindx,11:end);
  [year,timestr] = strtok(timestr,delimiters);
  [month,timestr] = strtok(timestr,delimiters);
  [day,timestr] = strtok(timestr,delimiters);
  [hour,timestr] = strtok(timestr,delimiters);
  [minute,timestr] = strtok(timestr,delimiters);
  %[sec,timestr] = strtok(timestr,delimiters);
  [sec] = strtok(timestr,delimiters);
  obs.time = [str2num(year) str2num(month) str2num(day) str2num(hour) str2num(minute) str2num(sec)];
  if length(obs.time) < 6
    hindx = fitsfindinheader(img_head,'TIME-OBS');
    timestr = img_head(hindx,11:end);
    [hour,timestr] = strtok(timestr,delimiters);
    [minute,timestr] = strtok(timestr,delimiters);
    %[sec,timestr] = strtok(timestr,delimiters);
    [sec] = strtok(timestr,delimiters);
    obs.time = [obs.time str2num(hour) str2num(minute) str2num(sec)];
  end
  
else
  
  % when everything else fails ask...
  datestr = 'Date of observation (YYYY , MM , DD)';
  timestr = 'Time of observation (UT) (HH , MM , SS.dd)';
  defll = {'1990 12 24','15  07  12'};
  title = 'OBSERVATION TIME?';
  lineNo=1;
  answer=inputdlg({datestr,timestr},title,lineNo,defll);
  %obs.time = [ str2num(char(answer{1})) str2num(char(answer{2}))];
  obs.time = [ str2num(answer{1}) str2num(answer{2})];
  
end
obs.time(end) = obs.time(end)-1;
% look for exposure time
%cmnrindx = findstr(H(:)','EXPTIME');
cmnrindx = fitsfindinheader(img_head,'EXPTIME');
if ~isempty(cmnrindx)
  
  %obs.exptime = str2num(strtok(H(cmnrindx+10:cmnrindx+79)));
  obs.exptime = str2num(strtok(img_head(cmnrindx,10:end)));
  
else
  
  cmnrindx = findstr(H(:)','EXPOSURE');
  if ~isempty(cmnrindx)
    obs.exptime = str2num(strtok(H(cmnrindx+10:cmnrindx+79)));
  else % Something missing badly!
    obs.exptime = -1;
    warning(['Missing exposure time in fits header (try_to_be_smart) for image at: ',num2str(obs.time,'%02d:%02d:%02d')])
  end
end  



obs.station = 450; % HIPAS is station 450 in the AIDA station enumeration.
station = obs.station;
obs.pos = [-146.842017 64.872];
obs.longlat = [-146.842017 64.872];
obs.cmtr = eye(3);

filt_indx = fitsfindkey_strmhead(img_head,'FILTER');
if ~isempty(filt_indx)
  
  [a1] = strfind(img_head(filt_indx,:),'=');
  obs.filter = str2num(img_head(filt_indx,a1+1:end));
  
end

temp_indx = fitsfindkey_strmhead(img_head,'CCD-TEMP');
if ~isempty(temp_indx)
  obs.ccdtemp = str2num(strtok(img_head(temp_indx,10:end)));
end
bz_indx = fitsfindkey_strmhead(img_head,'BZERO');
if ~isempty(temp_indx)
  obs.BZERO = str2num(strtok(img_head(bz_indx,10:end)));
end
bsc_indx = fitsfindkey_strmhead(img_head,'BSCALE');
if ~isempty(temp_indx)
  obs.bscale = str2num(strtok(img_head(bsc_indx,10:end)));
end

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
