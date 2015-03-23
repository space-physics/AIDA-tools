function varargout = gtopo2maps(gtopo_file,gtopo_hdr,ops)
% GTOPO2MAPS - Parse gtopo digital elevation models
%   
% Calling:
%   [long,lat,alt,X,Y,Z] =  gtopo2maps(gtopo_file,gtopo_hdr,OPS)
%   OPS                  =  gtopo2maps
% Input:
%   gtopo_file - filename of gtopo digital elevation model
%   gtopo_hdr  - filename of gtopo header file
%   OPS        - options struct
% Output:
%   long - longitude array (degrees)
%   lat  - latitude array (degrees)
%   alt  - altitude array
%   X    - Horizontal distance from center (east)  [km]
%   Y    - Horizontal distance from center (north) [km]
%   Z    - Altitude distance from center (zenith)  [km]
% or when GTOPO2MAPS is called without input arguments
%   OPS - the default options is returned.

%   Copyright � 2010 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% TODO: Check gtopo2maps outputs!

% Set values for the default options:
def_ops.lat0 = nan;   
def_ops.long0 = nan;
def_ops.out_name = 'default.mat';

if nargin == 0
  % If no input arguments: Return the default options:
  varargout{1} = def_ops;
  return;
elseif nargin > 2 && isstruct(ops)
  % otherwise, if there is an options struct input merge that ontop
  % of the default options:
  def_ops = merge_structs(def_ops,ops);
end

EARTH_HOME = fileparts(which('latlongh_2_xyz'));

% Open the gtopo-header file:
fp_hdr = fopen(gtopo_hdr,'r');
if fp_hdr < 0
  % Since that has to work, error out if it is not working:
  error(['gtopo2maps: could not open file ',gtopo_hdr,])
end

% Read the header:
hdr_string = '';
while ~feof(fp_hdr)
  curr_line = fgetl(fp_hdr);
  hdr_string = char(hdr_string,curr_line);% str2mat(hdr_string,curr_line);
end
fclose(fp_hdr);

% Build a struct from the header with field names and values
% according to what is found in gtopo_2_obs.txt:
obs = [];
header_parser_file_name = fullfile(EARTH_HOME,'gtopo_2_obs.txt');
fp = fopen(header_parser_file_name,'r');
while ~feof(fp)
  curr_line = fgetl(fp);
  if ischar(curr_line)
    [fieldname,curr_line] = strtok(curr_line,':');
    [hdr_field_key,curr_line] = strtok(curr_line(2:end),' ');
    [key_Evalue_string,curr_line] = strtok(curr_line(2:end),' ');
    cindx = fitsfindkey_strmhead(hdr_string,deblank(hdr_field_key));
    
    if ~isempty(cindx)
      key_val = eval(key_Evalue_string);
      obs.(fieldname) = key_val;% obs = setfield(obs,fieldname,key_val);
    else
      % obs = setfield(obs,fieldname,0);%%% Fixa fixen senare...
      obs.(fieldname) = 0;%%% Fixa fixen senare...
      warning(['MATLAB: gtopo2maps',sprintf('missing header info for?: %s',fieldname)])
    end
    
  end
end
fclose(fp);
obs

%        'int8'    'integer*1'      integer, 8 bits.
%        'int16'   'integer*2'      integer, 16 bits.
%        'int32'   'integer*4'      integer, 32 bits.
%        'int64'   'integer*8'      integer, 64 bits.

% Read the altitudes above sealevel:
fp_alts = fopen(gtopo_file,'r','ieee-be');
switch obs.nbits
 case 8
  alts = fread(fp_alts,[obs.nx,obs.ny],'int8');
 case 16
  alts = fread(fp_alts,[obs.nx,obs.ny],'int16');
 case 32
  alts = fread(fp_alts,[obs.nx,obs.ny],'int32');
 case 64
  alts = fread(fp_alts,[obs.nx,obs.ny],'int64');
 otherwise
end

fclose(fp_alts);
% This should give the correct longitude-latitude coordinates:
Long = obs.ulx + [0:(size(alts,1)-1)]*obs.dx;
Lat  = obs.uly - [0:(size(alts,2)-1)]*obs.dy;

% if there is limits in latitude or longitude crop down Lat, Long
% and alt accordingly:
if isfield(def_ops,'latlims')
  iLat = (min(def_ops.latlims)<=Lat&Lat<=max(def_ops.latlims));
  Lat = Lat(iLat);
  alts = alts(:,iLat);
end
if isfield(def_ops,'longlims')
  iLong = (min(def_ops.longlims)<=Long&Long<=max(def_ops.longlims));
  Long = Long(iLong);
  alts = alts(iLong,:);
end

% Assign Long Lat and alts to the output:
varargout{1} = Long;
varargout{2} = Lat;
varargout{3} = alts';

% If horizontal coordinates is requested to calculate them:
if nargout > 3
  
  [lats,longs] = meshgrid(Lat,Long);
  
  if ~isnan(def_ops.lat0)
    lat0 = def_ops.lat0;
  else
    lat0 = mean(Lat);
  end
  
  if ~isnan(def_ops.long0)
    long0 = def_ops.long0;
  else
    long0 = mean(Long);
  end
  xA = alts;
  yA = alts;
  zA = alts;
  
  %[xA(:),yA(:),zA(:)] = makenlcpos(long0,lat0,0,longs(:),lats(:),max(-10,alts(:)/1e3));
  [r_out] = latlongh_2_xyz(lat0,long0,0.15,lats(:),longs(:),max(-10,alts(:)/1e3));
  xA(:) = r_out(1,:);
  yA(:) = r_out(2,:);
  zA(:) = r_out(3,:);
  
  varargout{4} = yA';
  varargout{5} = xA';
  varargout{6} = zA';
  
end
