function [d,o,h] = read_pric_jpg(filename)
% read_pric_jpg - reads PRIC jpg images
% Calling:
%   [h,d] = read_pric_jpg(filename)
% Input:
%   filename - filename either a string with name of file (either
%              relative of full path to file) or a struct from the
%              'dir' command (then care have to be taken that the
%              filename.name points to the file i.e. give the full path)
% Output:
%   d - data, [NxN] sized double array
%   o - observation details (time, filter, station position,
%       exposure time, camera and station number)
%       structure
%   h - header containing the metadata for png files (to be implemented)
%
%% adapted by Laureline Sangalli Feb '10


if isstruct(filename)
  filename=filename.name;
end 

% Just read the image with matlab's image-reading function.
d = imread(filename);
d = double(d);

% This is adapted from the read_MIRACLE_acs function, there they
% use information about the image exposure stored in the file-name.
[p,fn,ext] = fileparts(filename); % Extract file-name

%array [yyyy,mo,dd,hh,mm,ss.ms];
y=str2num(fn(4:5)); % Year of observation

if y >= 90
  y = 1900+y;
else
  y = 2000+y;
end
mo = str2num(fn(6:7)); % Month of observation

if length(fn) == 25
  
  h = [];
  % Set the date-and-time field of the obs struct
  o.time = [y,mo,str2num(fn(8:9)),str2num(fn(11:12)),...
            str2num(fn(13:14)),str2num(fn(15:16))];
  % Searh for filter information:
  flt = str2num(fn(18:20));
  if isempty(flt)
    o.filter = 0;
  else
    % And set it if found.
    o.filter = flt;
  end
  % Set exposure time
  o.exptime = str2num(fn(22:25));
  
elseif length(fn) == 27
  
  h = []; % for now
  %HUOM! png files have ms too!!
  o.time = [y,mo,str2num(fn(8:9)),str2num(fn(11:12)),...
            str2num(fn(13:14)),str2num(fn(15:16))+str2num(fn(17:18))/100];
  flt = str2num(fn(20:22));
  if isempty(flt)
    o.filter = 0;
  else
    o.filter = flt;
  end
  o.exptime = str2num(fn(24:27));
  
else
  disp('something is wrong with the image file');
end

% below is the field for station name set.


%station and camera number - for now both numbers are the same
%NB:KIL location changed fall 2009 -> station number changes from 740 to 741
stn_name = {'SOD','MUO','ABK','KIL1','KIL2','KEV','LYR','NAL'};
stn_num = [710,720,730,740,741,750,760,770];
sn = fn(1:3);
if strcmp(sn,'KIL') && y == 2009 && mo < 6 % sn == 'KIL' & y == 2009 & mo < 6
  sn = 'KIL1';
elseif strcmp(sn,'KIL') && y ==2009 && mo > 8 % sn == 'KIL' & y ==2009 & mo > 8
  sn = 'KIL2';
end
isn = strcmp(sn,stn_name);
o.station = stn_num(isn);
o.camnr = stn_num(isn); 

% Below here are the fields for station position set.
% Here you should, for now set both o.pos and o.longlat, o.pos was
% previously used for both longitude and latitude and for
% horizontal coordinates for distances between ALIS and MIRACLE
% station. This led to several errors, so now o.pos is being phased
% out and will be obsoleted. o.longlat will eventually replace. For
% the horizontal position there will be a new field o.xyz.
if exist('AIDA_tools/.data/miraclepos.dat','file') == 2
  % Here you can hard-code the positions for your imager for now.
  load AIDA_tools/.data/miraclepos.dat
  o.longlat = miraclepos(isn,2:3);
  o.pos = miraclepos(isn,2:3);
  
else 
 disp('you did something stupid and put miraclepos.dat somewhere else. Please move it back to AIDA_tools/.data/ or modify AIDA_tools/Fit_tools/read_miracle_asc.m accordingly');
end  

o.beta = [];
o.alfa = [];
% You could put the actual values of magnetic zenith in here as well.
o.az = 0;
o.ze = 0;

