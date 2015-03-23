function [d,o,h] = read_miracle_asc(filename,PREPRO_OPS)
% READ_miracle_asc - reads MIRACLE ASC jpg or png images
% Calling:
%   [h,d] = read_miracle_asc(filename)
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
%   h - header containing the metadata for png files 
%
%% adapted by Laureline Sangalli Feb '10
%% modified by mv jun '10


if isstruct(filename)
  filename=filename.name;
end 


d = imread(filename);
d = double(d);

% colour pngs are weird
sd=size(d);
if length(sd) >2
  if sd(3) > 1 && sd(1) == sd(2) 
    %% averaging the 3 color channels for KEV and MUO color jpg
    d=mean(d,3); 
  elseif sd(3) > 1 && sd(1) ~= sd(2)
    %binning png to make it square
    d=d(:,1:2:sd(2),:)+d(:,2:2:sd(2),:); 
    %averaging the 3 color channels
    d=mean(d,3); 
  end
end

%%%%%%%%%%%% BEWARE %%%%%%%%%%%%%%%%%%%%%%%%%
%%% for SOD emccd images with traditional readout
if PREPRO_OPS.SODemccd_flag == 1;
  d=fliplr(d);
  disp('REMEMBER IMAGE IS FLIPPED L-R !!!!! FOR EMCCD TRAD MODE');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[p,fn,ext] = fileparts(filename);
header = [];
if strcmpi(ext,'.png')
  h1 = imfinfo(filename);
  h = h1.OtherText;
  
  %Build struct header.keyword='value' (NB: strings)
  %In this way sorting and searching can be avoided.
  if ~isempty(h)
    vals={h{:,2}};
    keywords={h{:,1}};
    %workaround: no "operators" or brackets allowed in struct field names
    keywords=strrep(keywords,'(','');
    keywords=strrep(keywords,')','');
    keywords=strrep(keywords,'-','');
    header=cell2struct(vals,keywords,2);
    %o.png_header = header;
    
    %%Time: array [yyyy,mo,dd,hh,mm,ss.ms], average of start and stop times
    %[myear, mmonth, mday, mhour, mmin, msec] = parse_png_time([header.Date, header.TimeStart1]);  
    %start = datenum(myear, mmonth, mday, mhour, mmin, msec);
    %if ~isempty(str2num(header.TimeStop2))
    %	[myear, mmonth, mday, mhour, mmin, msec] = parse_png_time([header.Date, header.TimeStop2]);  
    %else
    %	[myear, mmonth, mday, mhour, mmin, msec] = parse_png_time([header.Date, header.TimeStop1]);
    %end
    %stop = datenum(myear, mmonth, mday, mhour, mmin, msec);
    %o.time = datestr(datenum(mean([start stop])));
    %%remember, brackets were stripped, so it's Filternm, not Filter(nm)
    %o.filter=header.Filternm; 
    %
    %%Exposure time, from string (n*BaseExp)
    %%Likewise Exposures, not Exposure(s)
    %o.exptime=eval(header.Exposures); 
  end
end

%array [yyyy,mo,dd,hh,mm,ss.ms];
y=str2num(fn(4:5));
if y >= 90 
  y = 1900+y;
else
  y = 2000+y;
end
mo = str2num(fn(6:7));

if length(fn) == 25
  
  h = [];
  o.time = [y,mo,str2num(fn(8:9)),str2num(fn(11:12)),...
            str2num(fn(13:14)),str2num(fn(15:16))];
  flt = str2num(fn(18:20));
  if isempty(flt)
    o.filter = 0;
  else
    o.filter = flt;
  end
  o.exptime = str2num(fn(22:25));
  
elseif length(fn) == 27
   h = header; % for now
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

%station and camera number - for now both numbers are the same
%NB:KIL location changed fall 2009 -> station number changes from 740 to 741
stn_name = {'SOD','MUO','ABK','KIL1','KIL2','KEV','LYR','NAL'};
stn_num = [710,720,730,740,741,750,760,770];
sn = fn(1:3);
% if sn == 'KIL'
if strcmp(sn,'KIL') % & (y == 2009 & mo < 6 | y < 2009) <- the station was there even before the year 2009!
  sn = 'KIL1';
  if y >=2009 && mo >= 8
    sn = 'KIL2';
  end
end
isn = strcmp(sn,stn_name);
o.station = stn_num(isn);
o.camnr = stn_num(isn);


if exist('AIDA_tools/.data/miraclepos.dat','file') == 2
  
  load AIDA_tools/.data/miraclepos.dat
  o.pos = miraclepos(isn,2:4); % lon lat alt
  o.alt = o.pos(3);
  o.pos(3)
  o.longlat = miraclepos(isn,2:3);
else 
  disp('you did something stupid and put miraclepos.dat somewhere else. Please move it back to AIDA_tools/.data/ or modify AIDA_tools/Fit_tools/read_miracle_asc.m accordingly');
  %Using image header coordinates.
  %%CHECK should pos be [long lat] or [lat long]?
  if exist(header,'var')
    o.pos=[str2num(header.LongitudeDeg) str2num(header.LatitudeDeg)];
    sprintf('\nUsing coordinates from image header.\n %s: %s, %s\n Errors are possible.\n', ...
            header.Station, str2num(header.LongitudeDeg), str2num(header.LatitudeDeg));
  end
end  

o.beta = [];
o.alfa = [];
o.az = 0;
o.ze = 0;

