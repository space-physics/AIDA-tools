function vs = ASK_read_vs(num,filename,quiet)
% ASK_READ_VS -  the procedure to read the videoevent setup - the new version
%   
% Calling:
%   vs = ASK_read_vs(num,filename,quiet)
% Input:
%   num      - index of selected event/camera
%   filename - optional char array of camera setup files. If not
%              given 'video_setup.txt' in the 'videodir' will be
%              used. 'videodir' is set in ASK_site_setup.m
%   quiet    - optional argument for supression of event summary
%              output. Either 1 or 'quiet' for supression.

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

%global hities % Does not seem to be used at all here?

global vs % WITH: vcam,vdir,vname,vmjs,vnf,vnl,vres,vftr,vlon,vlat,vcnv,dimx,dimy,vtyp,vflt,vdrk,vsel,vnstep

% ASK_site_setup
ASK_site_init

vs.videodir = videodir;
vs.HDIR = HDIR;


if nargin > 1 & ~isempty(filename)
  
  filenames = filename;
  nev = size(filenames,1); % number of events
  
else
  
  [status,result] = system(['wc ',fullfile(videodir,'video_setup.txt')]);
  [a,COUNT,ERRMSG,NEXTINDEX] = sscanf(result,'%d %d %d %s');
  nev = a(1);
  filenames = '';
  fID = fopen(fullfile(videodir,'video_setup.txt'),'r');
  if fID > 0
    while ~feof(fID)
      if isempty(filenames)
        filenames = fgetl(fID); % readf, 1, filenames
      else
        filenames = str2mat(filenames,fgetl(fID)); % readf, 1, filenames
      end
    end
    fclose(fID);
  else
    error(['Could not open file: ',fullfile(videodir,'video_setup.txt')])
  end
  
end

if nargin < 3 | isempty(quiet)
  quiet = 0;
else 
  quiet = 1;
end
if nargin < 1 | isempty(num)
  
  if ~quiet
    disp('read_setup  reads in settings for analysis of videodata')
    disp('            To select an event, pass its number as a ')
    disp('            keyword: read_vs, num=1   ')
    disp('The list of the events:')
    disp(filenames)
    disp('Default is one (the first event)')
    %disp(' ADDED in JANUARY 2006')
    %disp(' keyword filename - to specify the description filename')
  end
  vs.vsel = 1;
  
else
  
  vs.vsel = num;
  quiet = 1;
  
end

for i1 = 1:nev,
  if ~quiet
    disp(fullfile(videodir,'setup',filenames(i1,:)))
  end
  fID = fopen(deblank(fullfile(videodir,'setup',filenames(i1,:))),'r');
  str = fgetl(fID);
  % skipping the first line comment
  % Get the camera name
  str = fgetl(fID);
  vs.vcam{i1} = str;
  % Get the directory name
  str = fgetl(fID);
  vs.vdir{i1} = str;
  % Get the file base name
  str = fgetl(fID);
  vs.vname{i1} = str;
  % Get the start time of data-block
  YMDhmsms = fscanf(fID, '%f %f %f %f %f %f %f',7)';
  YMDhmsms(6) = YMDhmsms(6) + YMDhmsms(7)/1000;
  YMDhmsms = YMDhmsms(1:6);
  mjs = ASK_TT_MJS(YMDhmsms);
  vs.vmjs(i1) = mjs;
  str = ASK_dat2str(mjs);
  if ~quiet
    disp([num2str(i1),'     ', filenames(i1,:),'      ',str])
  end
  % first image number (and increment)
  fgets(fID);
  qwe = str2num(fgets(fID));
  vs.vnf(i1) = qwe(1);
  vs.vnstep(i1) = 1;
  if length(qwe) > 1
    vs.vnstep(i1) = qwe(2);
  end
  % last image number
  nrFrames = fscanf(fID, '%f',1);
  vs.vnl(i1) = nrFrames;
  % Temporal resolution
  dT = fscanf(fID, '%f\n',1);
  vs.vres(i1) = dT;
  % Filter NAME (?!?) 
  % TODO: see if we can do with filter wavelength instead
  % - nope, doesn't seem so: RG#NNN appears somewhere...
  str = fgetl(fID);
  if ~isempty(str2num(str))
    % vs.vftr{i1} = str2num(str);% fscanf(fID,'%f',1);
    vs.vftr{i1} = str;% fscanf(fID,'%f',1);
  else
    vs.vftr{i1} = str;
  end
  % Latitude:
  lat = fscanf(fID, '%f',1);
  vs.vlat(i1) = lat;
  long = fscanf(fID, '%f',1);
  vs.vlon(i1) = long;
  
  % build/find Camera parameters
  str = fgetl(fID);
  str = fgetl(fID);
  %
  % Here there is two possibilities - either a description file, or
  % a look-up table for conversion coefficients.
  %
  [fP,fN,fExt] = fileparts(str);
  if  strcmp(fExt,'.lut')
    [cnv_t1,cnv_t2,cnv_data] = ASK_read_cnvlut(fullfile(videodir,str));
    conv = ASK_find_cnv(mjs);
  else
    fID2 = fopen(fullfile(videodir,str),'r');
    conv = fscanf(fID2,'%f %f %f %f %f %f %f %f',1);
    fclose(fID2);
  end
  vs.vcnv(i1,:) = conv;
  % conversion coefficients are read in here...
  % readf, 1, x, y
  x_y = fscanf(fID,'%f %f\n',2)';
  vs.dimx(i1) = x_y(1);
  vs.dimy(i1) = x_y(2);
  str = fgetl(fID);
  vs.vtyp{i1} = str;
  str = fgetl(fID);
  vs.vdrk{i1} = str;
  str = fgetl(fID);
  vs.vflt{i1} = str;
  fclose(fID);
end
ASK_get_imcal;
