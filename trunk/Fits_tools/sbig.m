function [hheader,data,obs,header] = sbig(fname,fixheader2fits)
% SBIG - reads files in SBIG image format, 
%  the SBIG format is a fits like file format, the difference from
%  the fits format is that it has a 2048 bytes ascii format header
%  with different keywords than the fits standard.
%  
% Calling:
% [header,data,obs] = sbig(filename)
% [header,data,obs] = sbig(filename,fixheader2fits)
%
% INPUT:
%   FILENAME - file filename
%   FIXHEADER2FITS - [{1} | 0] translate or not translate the
%   keywords in the header to the fits standard keywords.
% 
% OUTPUT:
%   HEADER - primary sbig header, by default keys mapped to the
%            standard fits keywords.
%   DATA - first data block
%   OBS - Struct with meta-data, such as exposure time, time of
%         observation, filter...
% 
% Slightly adapted from readst9 by A. Senior Dept of C.S. Univ. of
% Lancaster

if nargin < 1
  error('Too few arguments: No filename')
end
if nargin == 1
  fixheader2fits = 1;
end
fname = deblank(fname);
fid = fopen(fname);
if fid == -1
  error('Can''t open %s',fname);
end

% read 2048-byte header block
[header,c] = fread(fid,2048,'uchar=>char');
if c ~= 2048
  error('Error reading header of %s',fname);
end

% parse header
% first separate out each line...
k = 1;
%TBR: hheader = header;
while 1
  [H{k},c,err,next] = sscanf(header,'%[^\n\r]\n\r',1);
  if strcmp(H{k},'End')
    break;
  end
  if  ~isempty(err)
    error(err);
  end
  if next>length(header)
    break
  end
  k = k+1;
  header = header(next:end);
end
hheader = header;

%  ... check it really is a camera image ...
if ~strcmp(H{1},'ST-9 Image')
  error('%s is not an uncompressed ST-9 image',fname);
end

% ... and then convert each parameter line to a field in the output
% structure.

obs=[];

for k=2:length(H)-1
  [par,c,err,next] = sscanf(H{k},'%s = ',1);
  par = lower(par);
  val = H{k}(next:end);
  obs.(par) = val;% obs = setfield(obs,par,val);
end

% read image

ncols = str2num(obs.width);
nrows = str2num(obs.height);
nbits = ceil(log(str2num(obs.sat_level)+1)/log(2));

switch nbits
 case 16  
  [data,c] = fread(fid,ncols*nrows,'uint16=>uint16');
 case 8
  [data,c] = fread(fid,ncols*nrows,'uint8=>uint8');
 otherwise
  error('Can''t understand a %d-bit image',nbits);
end

if c ~= ncols*nrows
  error('Error reading image in %s',fname);
end

% image is stored in the file in row order with each row
% left-right.

data = reshape(double(data),ncols,nrows);
fclose(fid);

if fixheader2fits
  
  fid = fopen(fname);
  curr_line = strtrim(fgets(fid));
  byte_count = length(curr_line);
  header = curr_line;
  while ~strcmp(curr_line(1:min(3,end)),'End')
    curr_line = strtrim(fgets(fid));
    header = char(header,curr_line);
    byte_count = byte_count+length(curr_line);
  end
  
  header = header(1:2:end,:);
  [j_h] = fitsfindinheader(header,'height');
  [j_w] = fitsfindinheader(header,'width');
  [j_d] = fitsfindinheader(header,'date');
  [j_t] = fitsfindinheader(header(:,1:6),'time');
  [j_e] = fitsfindinheader(header(:,1:9),'Exposure ');
  [j_f] = fitsfindinheader(header(:,1:9),'Filter');
  [j_o] = fitsfindinheader(header(:,1:9),'Observer');
  [j_T] = fitsfindinheader(header(:,1:6),'temperature');
  date_obs = ['DATE-OBS= ',datestr(header(j_d,length('date')+3:end),29),'T',header(j_t,length('time')+4:end)];
  Header = 'SIMPLE  =                    T';
  Header = char(Header,'BITPIX  =                   16');
  Header = char(Header,'NAXIS   =                    2');
  Header = char(Header,strrep(lower(header(j_h,:)),'height','NAXIS1 '));
  Header = char(Header,strrep(lower(header(j_w,:)),'width ','NAXIS2  '));
  Header = char(Header,date_obs);
  Header = char(Header,strrep(lower(header(j_e,:)),'exposure ','EXPTIME '));
  Header = char(Header,strrep(lower(header(j_f,:)),'filter','FILTER '));
  Header = char(Header,strrep(lower(header(j_T,:)),'temperature ','CCD-TEMP'));
  Header = char(Header,strrep(header(j_o,:),'Observer ','OBSERVER'));
  header([j_d,j_e,j_f,j_h,j_o,j_T,j_t,j_w],:) = [];
  header = char(Header,header(2:end,:));
  fclose(fid);
  
end

