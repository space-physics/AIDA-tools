function info = fits_header2infostruct(img_head,filename2parseheader,PO)
% FITS_HEADER2INFOSTRUCT - parse fits header, make struct of meta-data 
% needed fields
%
% Calling:
%  INFO = fits_header2infostruct(HEADER,filename2parseheader)
% Input:
%  HEADER - Fits header - string array [(n*32) x 80] as returned
%           from fits_header
%  FILENAME2PARSEHEADER - filename of file containing information
%           about how to parse header for necessary information,
%           see header_v5_2_obs.txt for example
% Output:
%  INFO - struct with fields: naxis - number of axis in data block,
%         nx - [1 x naxis] array with data block sizes, bitpix -
%         fits bitpix key describing number of bits per pixel, and
%         data format.


%   Copyright � 20100615 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

FITS_HOME = which('inimg');
FITS_HOME = fileparts(FITS_HOME);

for i1 = size(img_head,1):-1:1,
  key{i1} = sscanf(img_head(i1,:),'%8s=',1);
  keyval{i1} = deblank(img_head(i1,10:end));
end

Naxis=sscanf(keyval{fitsfindkey(key,'NAXIS')},'%d');
info.naxis = Naxis;
for i1 = 1:Naxis,
  info.nx(i1) = sscanf(keyval{fitsfindkey(key,['NAXIS',num2str(i1)])},'%d');
end

info.bitpix=sscanf(keyval{fitsfindkey(key,'BITPIX')},'%d');

if nargin == 1
  return;
end


fid = fopen(fullfile(FITS_HOME,filename2parseheader),'r');
if fid == -1
  disp(['Could not open the Meta-data parsing-rules file: ',filename2parseheader])
else
  
  while ~feof(fid)
    curr_line = fgetl(fid);
    if ischar(curr_line)
      [fieldname,curr_line] = strtok(curr_line,':');
      [field_fits_key,curr_line] = strtok(curr_line(2:end),'=');
      [key_Evalue_string,curr_line] = strtok(curr_line(2:end),' ');
      if strcmp(ddeblank(field_fits_key),'EMPTY')
        hindx = 1;
      else
        hindx = fitsfindkey_strmhead(img_head,ddeblank(field_fits_key));
      end
      
      if ~isempty(hindx)
        key_val = eval(key_Evalue_string);
        info = setfield(info,fieldname,key_val);
      else
        info = setfield(info,fieldname,0);%%% Fixa fixen senare...
        warning('MATLAB:fits_header2infostruct',['missing header info for?: ',fieldname]);
      end
    end
  end
  if isfield(info,'site') && ( ~isfield(info,'station') || ...
                             isempty(info.station) )
    switch info.site(1)
     case 'K'
      info.station = 7;
     case 'O'
      info.station = 1;
     case 'M'
      info.station = 2;
     case 'S'
      info.station = 3;
     case 'T'
      info.station = 4;
     case 'A'
      info.station = 5;
     case 'N'
      info.station = 6;
     case 'B'
      info.station = 10;
     case 'R'
      info.station = 11;
     case 'L'
      info.station = 12;
     otherwise
      % do nothing
    end
  end
  fclose(fid);
  [stnnr] = fix_stationpos(info);
  
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
   case 'K' % nutstorp
    stnnr = 7;
   case 'O' % Optics lab IRF Kiruna
    stnnr = 1;
   case 'M' % erasjarvi
    stnnr = 2;
   case 'S' % ilkimuotka
    stnnr = 3;
   case 'T' % jautjas
    stnnr = 4;
   case 'A' % bisko
    stnnr = 5;
   case 'N' % ikkaloukta
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
header_line;
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

