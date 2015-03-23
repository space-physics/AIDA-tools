function [obs] = try_to_be_smart(img_head,ALIS_FITS,PO)
% TRY_TO_BE_SMART parses an (ALIS) fits header for observation info
% such as exposure time, time and date of exposure et al.
% 
% INPUT: 
%   img_head - a FITS header, char array.
%   ALIS_FITS - bolean, 1 if the header follow "any" fits
%   standard... 
% 
% OUTPUT:
%    OBS the output is a struct with some relevant key parameters
%    such as camera rotation, exposure time, time and date of
%    exposure filter camera number, camera position.
% 
% Calling:
%   obs = try_to_be_smart(img_head)
%   obs = try_to_be_smart(img_head,ALIS_FITS)
% Input:
%   img_head - image header, string array
% Output:
%   obs - obs struct with fields for various meta-data, fields
%         needed are:
%         obs.time    - [yyyy mm dd HH MM ss.ddd]
%         obs.pos     - [depreciated]
%         obs.longlat - [longitude, latitude] (degrees)
%         obs.station - Station number, in ALIS, Miracle and
%                       HAARPOON stations have a designated number
%         obs.alpha   - rotation around east-west axis.
%         obs.beta    - rotation around north-south axis.
%         obs.az      - Azimuth rotation angle, clock-wise from
%                       north (degrees)
%         obs.ze      - Zenith rotation angle (degrees)
%         obs.camnr   - ALIS has cameras numbered (for bad-pixel
%                       maps and intensity calibration and such)
%         obs.exptime - exposure time (s)
%         obs.filter  - Filter, emission wavelength (�, or nm)
% 
% Some of these are needed for different purposes, time, pos (and
% to some extent az & ze) are needed for running the STARCAL
% geometric calibrations.


%   Copyright � 20050804 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global FITS_HOME
persistent Station_names

% The logic here is that with ALIS-images there is a known, and
% somewhat meandering evolution, of the meta-data evolution so to
% handle that the second input argument, ALIS_FITS, should be set
% to 1. If there is 
if nargin < 2
  ALIS_FITS = 0;
end
% To make it convenient to both get STARCAL to query for
% observation time and location and all other functions not to
% bother with that (e.g. keogram and time-series stuff where
% multiple images are read) the default setting of SKIP-DIALOGS
% will be 1 (skip the dialogs and just get on with it) but if there
% is a field 'skip_dialogs' in the submitted 3rd input argument
% then that value will be used. In STARCAL PO.skip_dialogs is set
% to 0 - in order to do the geometric star-calibration time and
% location is critically needed...
if nargin > 2
  skip_dialogs = PO.skip_dialogs;
else
  skip_dialogs = 1;
end
if isempty(Station_names)
  Station_names = textread('station.name','%s','delimiter','\n','whitespace','');
end

FITS_HOME = which('inimg');
FITS_HOME = fileparts(FITS_HOME);


delimiters = [9:13 32];
delimiters = [delimiters,'~=+*/^()[]{}<>,;:'''];

% Initiate the OBS struct with all the meta-data fields needed.
obs.time = [];
obs.pos = [];
obs.longlat = [];
obs.station = [];
obs.alpha = [];
obs.beta = [];
obs.az = [];
obs.ze = [];
obs.camnr = [];
obs.exptime = [];
obs.filter = [];

H = img_head';

% This is the date the ALIS station #1 was moved from Swedish
% Institute of Space Physics to the Knutstorp building:
To_Knutstorp_time = [1999 8 1 0 0 0];

%Determination of date and time of observation
% 1 Look for standard (post 1998 something )time key-word
% 'DATE-OBS' 
hindx = fitsfindinheader(img_head,'DATE-OBS');

if ~isempty(hindx)
  delimiters = [delimiters,'-T'];
  timestr = img_head(hindx,11:end);
  [year,timestr] = strtok(timestr,delimiters);
  [month,timestr] = strtok(timestr,delimiters);
  [day,timestr] = strtok(timestr,delimiters);
  [hour,timestr] = strtok(timestr,delimiters);
  [minute,timestr] = strtok(timestr,delimiters);
  [sec] = strtok(timestr,delimiters);
  obs.time = [str2num(year) str2num(month) str2num(day) str2num(hour) str2num(minute) str2num(sec)];
  if length(obs.time) < 6
    hindx = fitsfindinheader(img_head,'TIME-OBS');
    timestr = img_head(hindx,11:end);
    [hour,timestr] = strtok(timestr,delimiters);
    [minute,timestr] = strtok(timestr,delimiters);
    [sec] = strtok(timestr,delimiters);
    obs.time = [obs.time str2num(hour) str2num(minute) str2num(sec)];
  end
  
else
  
  % Didn't find 'DATE-OBS' keyword now looking for old nonstandard
  % time keyword used by 'ALIS' pre 1998 something...
  hindx = findstr(H(:)','ALIS-UTC');
  if ~isempty(hindx)
    timestr = H(hindx+11:hindx+79);
    [gps_class,timestr] = strtok(timestr,':');
    [year,timestr] = strtok(timestr,delimiters);
    [month,timestr] = strtok(timestr,delimiters);
    [day,timestr] = strtok(timestr,delimiters);
    [hour,timestr] = strtok(timestr,delimiters);
    [minute,timestr] = strtok(timestr,delimiters);
    [sec] = strtok(timestr,delimiters);
    obs.time = [1900+str2num(year) str2num(month) str2num(day) str2num(hour) str2num(minute) str2num(sec)];
    
  else
    % when everything else fails ask...
    datestr = 'Date of observation (YYYY , MM , DD)';
    timestr = 'Time of observation (UT) (HH , MM , SS.dd)';
    defll = {'1990 12 24','15  07  12'};
    title = 'OBSERVATION TIME?';
    lineNo=1;
    if skip_dialogs == 0
      answer=inputdlg({datestr,timestr},title,lineNo,defll);
      obs.time = [ str2num(answer{1}) str2num(answer{2})];
    else
      obs.time = (datevec(now,'yyyy mm dd HH MM SS'));
    end
  end
  
end

% look for exposure time
cmnrindx = fitsfindinheader(img_head,'EXPTIME');
if ~isempty(cmnrindx)
  
  obs.exptime = str2num(strtok(img_head(cmnrindx,10:end)));
  
else
  % or the old version
  cmnrindx = findstr(H(:)','ALIS-EXP');
  if ~isempty(cmnrindx)
    obs.exptime = str2num(strtok(H(cmnrindx+10:cmnrindx+79)))/1000;
  else
    cmnrindx = findstr(H(:)','EXPOSURE');
    if ~isempty(cmnrindx)
      obs.exptime = str2num(strtok(H(cmnrindx+10:cmnrindx+79)));
    else % Something missing badly!
      obs.exptime = -1;
      warning(['Missing exposure time in fits header (try_to_be_smart) for image at: ',num2str(obs.time,'%02d:%02d:%02d')]);
    end
  end  
end


hindx = fitsfindinheader(img_head,'ALISSTD');
%TBR:? alis_header_version = [];
if ~isempty(hindx)
  alis_header_version = str2num(strtok(img_head(hindx,11:end)));
else
  hindx = fitsfindinheader(img_head,'MIMASTD');
  alis_header_version = [];
  if ~isempty(hindx)
    alis_header_version = str2num(strtok(img_head(hindx,11:end)));
  end
  
end

if alis_header_version >= 5
% $$$   [FITS_HOME,'header_v5_2_obs.txt']
  VersionParserFile = ['header_v',num2str(alis_header_version),'_obs.txt'];
  fp = fopen(fullfile(FITS_HOME,VersionParserFile),'r');
  if fp == -1
    fp = fopen([FITS_HOME,'header_v5_2_obs.txt'],'r');
  end
  while ~feof(fp)
    curr_line = fgetl(fp);
    if ischar(curr_line)
      [fieldname,curr_line] = strtok(curr_line,':');
      [field_fits_key,curr_line] = strtok(curr_line(2:end),'=');
      [key_Evalue_string,curr_line] = strtok(curr_line(2:end),' ');
      hindx = fitsfindkey_strmhead(img_head,ddeblank(field_fits_key));
      
      if ~isempty(hindx)
        key_val = eval(key_Evalue_string);
        obs.(fieldname) = key_val;% obs = setfield(obs,fieldname,key_val);
      else
        %  obs = setfield(obs,fieldname,0);%%% Fixa fixen senare...
        obs.(fieldname) = 0;%%% Fixa fixen senare...
        warning('MATLAB:try_to_be_smart',['missing header info for?: ',fieldname]);
      end
    end
  end
  switch obs.site(1)
   case 'K' % Knutstorp
    obs.station = 7;
   case 'O' % Optics Lab IRF
    obs.station = 1;
   case 'Q' % Calibration Img
    obs.station = 1;
   case 'M' % Merasjarvi
    obs.station = 2;
   case 'S' % Silkimuotka
    obs.station = 3;
   case 'T' % Tjautjas
    obs.station = 4;
   case 'A' % Abisko
    obs.station = 5;
   case 'N' % Nikkaluokta
    obs.station = 6;
   case 'B' % SkiBotn (Bus)
    obs.station = 10;
   case 'R' % Ramfjord
    obs.station = 11;
   case 'L' % Longyearbyen
    obs.station = 12;
   otherwise
    % do nothing
  end
  fclose(fp);
  [stnnr] = fix_stationpos(obs);
  
else
  
  %determination of observation site (long,lat)
  if ALIS_FITS
    
    load ktransf.dat
    
    hindx = findstr(H(:)','ALIS-STN');
    if isempty(hindx)
      obs.station = 0; % Dont know for now.
    else
      station = sscanf(strtok(H(hindx+9:hindx+79),delimiters),'%d');
      obs.station = station;
      if ( obs.station == 1 ) && ...
            ( date2juldate(obs.time) >  date2juldate(To_Knutstorp_time) )
        obs.station = 7;
      end
    end
  else
    stn_found = 0;
    hindx = findstr(H(:)','ORIGIN'); 
   if ~isempty(hindx)
      station = strtok(H(hindx+11:hindx+79),[9:13 32]);
      station = strmatch(station(1:5),Station_names);
      if ~isempty(station)
        stn_found = 1;
      end
    end
    if ~stn_found % if everything else fails ask
      latstr = 'Latitude of observation site (+ north)';
      longstr = 'Longitude of observation site (+ east)';
      defll = {'0','0'};
      title = 'Position of observation site?';
      lineNo = 1;
      if skip_dialogs == 0
        answer = inputdlg({latstr,longstr},title,lineNo,defll);
        pos = [sscanf(answer{2},'%f') sscanf(answer{1},'%f')];
        obs.longlat = pos;
        obs.pos = obs.longlat;
      else
        obs.longlat = [0,0];
        obs.pos = obs.longlat;
      end
    end
    
  end
  
  % looking for something like camera rotation
  %AZIMUTH =              346.007 / POSITIVE EAST (CW)                             
  %ZEANGLE =               36.995 / ZENITH ANGLE 90 DEG - ELEV                     
  %POSALFA =                 -413 / ALFA AXIS (COUNTS)                             
  %POSBETA =                -1429 / BETA AXIS (COUNTS)                             
  alfaindx = findstr(H(:)','POSALFA');
  if ~isempty(alfaindx)
    
    alpha = sscanf(H(alfaindx+11:alfaindx+79),'%d');
    betaindx = findstr(H(:)','POSBETA');
    beta = sscanf(H(betaindx+11:betaindx+79),'%d');
    obs.alpha = rem(alpha,360);
    obs.beta = rem(beta,360);
    
  end
  
  azindx = findstr(H(:)','AZIMUTH');
  if ~isempty(azindx)
    
    azimuth = sscanf(H(azindx+11:azindx+79),'%f');
    obs.az = azimuth;
  end
  zeindx = findstr(H(:)','ZEANGLE');
  if ~isempty(zeindx)
    
    zenith = sscanf(H(zeindx+11:zeindx+79),'%f');
    obs.ze = zenith;
  end
  
  if isempty(azindx)
    % if nothing found this far - look for the old version.
    pindx = findstr(H(:)','ALIS-POS');
    if ~isempty(pindx)
      pstr = H(pindx:pindx+79);
      [q,pstr] = strtok(H(pindx-5:pindx+79-6));
      [q,pstr] = strtok(pstr,delimiters);
      [q,pstr] = strtok(pstr,delimiters);
      az = str2num(q);
      if isempty(az) % we really should not end up here
        az = 0;
      end
      [q,pstr] = strtok(pstr,delimiters);
      [q,pstr] = strtok(pstr,delimiters);
      ze = str2num(q);
      if isempty(ze) % we really should not end up here
        ze = 0;
      end
      obs.az = az;
      obs.ze = ze;
    else
      obs.az = 0;
      obs.ze = 0;
      % disp(['No alisposinfo for stn: ',num2str(obs.station),', at: ',num2str(obs.time,'%02d')])
    end
  end
  
  obs.camnr = 0; % unknown
                 % look for camera number...
  cmnrindx = findstr(H(:)','ALIS-CCD');
  if ~isempty(cmnrindx)
    
    obs.camnr = str2num(strtok(H(cmnrindx+10:cmnrindx+79)));
    if isempty(obs.camnr)
      qwe = H(cmnrindx+10:cmnrindx+79);
      aqsd = regexp(qwe,'/[\d]/');
      obs.camnr = str2num(qwe(aqsd(1)+1));
    end
  else
    % or the old version
    cmnrindx = findstr(H(:)','ALIS-CAM');
    if ~isempty(cmnrindx)
      if ~isempty(findstr(H(cmnrindx:cmnrindx+79-6),'0'))
        obs.camnr = 0;
      elseif ~isempty(findstr(H(cmnrindx:cmnrindx+79-6),'1'))
        obs.camnr = 1;
      elseif ~isempty(findstr(H(cmnrindx:cmnrindx+79-6),'2'))
        obs.camnr = 2;
      elseif ~isempty(findstr(H(cmnrindx:cmnrindx+79-6),'3'))
        obs.camnr = 3;
      elseif ~isempty(findstr(H(cmnrindx:cmnrindx+79-6),'4'))
        obs.camnr = 4;
      elseif ~isempty(findstr(H(cmnrindx:cmnrindx+79-6),'5'))
        obs.camnr = 5;
      elseif ~isempty(findstr(H(cmnrindx:cmnrindx+79-6),'6'))
        obs.camnr = 6;
      elseif ~isempty(findstr(H(cmnrindx:cmnrindx+79-6),'7'))
        obs.camnr = 7;
      end
    else
      cmnrindx = fitsfindkey_strmhead(img_head,'INSTRUME');
      if ~isempty(cmnrindx)
        obs.camnr = str2num(strtok(fliplr(img_head(cmnrindx,12:end)),' abcdefghijklmnopqrstuvwxyz'''));
      end
    end
    
  end
  
  
  cmnrindx = findstr(H(:)','FILTER  =');
  if ~isempty(cmnrindx)
    
    [q,w] = strtok(H(cmnrindx:cmnrindx+79-6));
    if ~isempty(findstr(lower(w),'white'))
      obs.filter = 0;
    elseif ~isempty(findstr(lower(w),'none'))
      obs.filter = 0;
    elseif ~isempty(findstr(lower(w),'redbg'))
      obs.filter = 632;
    else
      [w,q] = strtok(w,delimiters);
      obs.filter = str2num(w);
    end
  end
end


%function [stnnr,pos,cmtr] = fix_stationpos(obs)
function [stnnr] = fix_stationpos(obs)
% FIX_STATIONPOS - 
%   

To_Knutstorp_time = [2000 8 1 0 0 0];

if ( obs.station == 1 ) && ...
      ( date2juldate(obs.time) >  date2juldate(To_Knutstorp_time) )
  stnnr = 7;
else
  stnnr = obs.station;
end

if ~isempty(obs.site)
  switch obs.site(1)
   case 'K' % Knutstorp
    stnnr = 7;
   case 'O' % Optics lab IRF Kiruna
    stnnr = 1;
   case 'M' % Merasjarvi
    stnnr = 2;
   case 'S' % Silkimuotka
    stnnr = 3;
   case 'T' % Tjautjas
    stnnr = 4;
   case 'A' % Abisko
    stnnr = 5;
   case 'N' % Nikkaloukta
    stnnr = 6;
   case 'B' % Bus guess that it is in Skibotn
    stnnr = 10;
   case 'R' % Ramfjord
    stnnr = 11;
   otherwise
    stnnr = 0;
  end

end

if obs.station == 0
  pos = [];
  cmtr = [];
  stnnr = [];
else
  station = obs.station;
  station = stnnr;
end

function outstr = ddeblank(in_str)
% DDEBLANK - 
%   

outstr = strtrim(in_str);

function stn_nr = header2stnnr_v5(header_line)
% HEADER2STNNR - 
%   


%' /etc/aniara/mima6 ' / name of instrument
%4 debug?: header_line;
nums = '1234567890';
for i1 = 1:10,
  isnum = findstr(nums(i1),header_line);
  if ~isempty(isnum)
    break
  end
end
stn_nr = i1;

function site = header2site_v5(header_line)
% HEADER2SITE_V5 - 
%   


[site] = ddeblank(strtok(header_line,''''));
