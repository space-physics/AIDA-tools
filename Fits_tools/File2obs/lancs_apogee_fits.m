function [obs] = lancs_apogee_fits(img_head)
% LANCS_APOGEE_FITS parses an fits header for observation info
% such as exposure time, time and date of exposure et al.
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



obs.station = 11; % EISCAT is station 11 in the ALIS enumeration.
station = obs.station;
if obs.station == 0
  obs.longlat = [];
  obs.pos = [];
  obs.cmtr = [];
else
  obs.longlat = [sum(stationpos(station,5:7).*[1 1/60 1/3600])* ...
                 stationpos(station,8) ...
                 sum(stationpos(station,1:3).*[1 1/60 1/3600])* ...
                 stationpos(station,4)];
  obs.pos = obs.longlat;
  obs.cmtr = ktransf(1+3*(station-1):3*station,:);
end

filt_indx = fitsfindkey_strmhead(img_head,'FILTER');
if ~isempty(filt_indx)
  
  key_startstop = strfind(img_head(filt_indx,:),'''');
  key = ddeblank(img_head(filt_indx,key_startstop(1)+1:key_startstop(2)-1));
  
  if length(findstr(lower(key),'white'))
    obs.filter = 0;
  elseif length(findstr(lower(key),'green'))
    obs.filter = 5577;
  elseif length(findstr(lower(key),'blue'))
    obs.filter = 4278;
  elseif length(findstr(lower(key),'red'))
    obs.filter = 6300;
  elseif length(findstr(lower(key),'ir'))
    obs.filter = 7774;
  else
    disp('Warning, unknown filter:',key)
    disp('Expand the filters listed in LANCS_APOGEE_FITS.M')
  end

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
