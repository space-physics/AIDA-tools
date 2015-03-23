function [header,data] = fits2(name)
% FITS2 reads fits files stored in BE
%
% Calling:
% [header,data] = fits2(name)
%
% INPUT:
%   NAME - file name
%
% OUTPUT:
%   HEADER - primary fits header
%   DATA - first data block
% Not tested for multi-header data, does not read multi dimensional
% fits files

%   Copyright � 19970709 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

no_end_yet = 1;
reached_endoffile = 0;

% Try to open file:
[fid] = fopen(name,'r','ieee-be');
if (fid == -1),
  error(['Could not open file: ',name])
end
i1=1;

% Start with reading FITS-header:
while ( no_end_yet )
  
  s = fread(fid,80,'char');
  
  st=char(s');
  
  if ( strncmp(st,'END',3) == 1 )
  
    no_end_yet = 0;
    
  end
  % Buld cell arrays of fits-key word and key-values
  key{i1} = sscanf(st,'%8s=',1);
  keyval{i1}=deblank(st(10:end));
  % And an ordinary char-array
  if ( i1 == 1 )
    header = st;
  else
    % header = str2mat(header,st);
    header = char(header,st);
  end
  i1=i1+1;
  if feof(fid)
    reached_endoffile = 1;
    break
  end
end
% If we've reached End-Of-File before we've gotten an end of the
% header... 
if no_end_yet || reached_endoffile
  data = [];
  disp(['There is something fishy with fits file: ',name])
  return
end
i1 = i1-1;
while rem(i1,36) ~= 0
  fread(fid,80,'char');
  i1 = i1+1;
end

if ( nargout > 1 )
  % by now we should be able to tell the dimensions of the image in
  % the current fits-file:
  sx=sscanf(keyval{fitsfindkey(key,'NAXIS1')},'%d');
  sy=sscanf(keyval{fitsfindkey(key,'NAXIS2')},'%d');
  % ...and the data format/number of bits per pixel:
  bitpix=sscanf(keyval{fitsfindkey(key,'BITPIX')},'%d');
  % with those three numbers we should be able to read the image
  % field:
  data=0;
  if bitpix==8,
    data=fread(fid,[sx,sy],'uint8');
  end
  if bitpix==16,
    data=fread(fid,[sx,sy],'int16');
  end
  if bitpix==32,
    data=fread(fid,[sx,sy],'int16');
  end
  if bitpix==-32,
    data=fread(fid,[sx,sy],'float32');
  end
  if bitpix==-64,
    data=fread(fid,[sx,sy],'float64');
  end
  
  data = data';
  if ~all(size(data)==[sy sx])
    data(sy,sx) = 0;
  end
  
end
fclose(fid);
% before we leave we close the file after us!
