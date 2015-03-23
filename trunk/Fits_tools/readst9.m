function S=readst9(fname)

fid=fopen(fname);
if fid==-1
  error(sprintf('Can''t open %s',fname));
end

% read 2048-byte header block

[header,c]=fread(fid,2048,'uchar=>char');
if c~=2048
  error(sprintf('Error reading header of %s',fname));
end

% parse header
% first separate out each line...
k=1;
while 1
  [H{k},c,err,next]=sscanf(header,'%[^\n\r]\n\r',1);
  if strcmp(H{k},'End')
    break;
  end
  if  ~isempty(err)
    error(err);
  end
  if next>length(header)
    break
  end
  k=k+1;
  header=header(next:end);
end

%  ... check it really is a camera image ...
if ~strcmp(H{1},'ST-9 Image')
  error(sprintf('%s is not an uncompressed ST-9 image',fname));
end

% ... and then convert each parameter line to a field in the output
% structure.

S=[];

for k=2:length(H)-1
  [par,c,err,next]=sscanf(H{k},'%s = ',1);
  par=lower(par);
  val=H{k}(next:end);
  S.(par) = val;% S=setfield(S,par,val);
end

% read image

ncols=str2num(S.width);
nrows=str2num(S.height);
nbits=ceil(log(str2num(S.sat_level)+1)/log(2));

switch nbits
 case 16  
  [image,c]=fread(fid,ncols*nrows,'uint16=>uint16');
 case 8
  [image,c]=fread(fid,ncols*nrows,'uint8=>uint8');
 otherwise
  error(sprintf('Can''t understand a %d-bit image',nbits));
end

if c~=ncols*nrows
  error(sprintf('Error reading image in %s',fname));
end

% image is stored in the file in row order with each row
% left-right.

S.image=reshape(double(image),ncols,nrows)';

fclose(fid);
