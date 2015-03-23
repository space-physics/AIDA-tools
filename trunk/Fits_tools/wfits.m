function ok = wfits(header,data,name)
% WFITS - function to write fits files.
%
% Calling:
% function ok = wfits(header,data,name)
% 
% Input:
%         HEADER - string matrix with 80 characters
%         per line.
%         Mandatory entries in the header are:
%         1 'SIMPLE  '
%         2 'BITPIX  '
%         3 'NAXIS   '
%         4 'NAXISn  '
%         : other
%         last 'END  '
%         For valid values for the keyworlds see fits documentation
%         DATA is the imaegearray to be stored.
%         NAME is the filename.
% 


%   Copyright © 19980525 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


[fid] = fopen(name,'w');
if (fid == -1),
  %msgstr = sprintf('Unable to open the file: %s\n',name);
  %error(msgstr)
  error('Unable to open the file: %s\n',name)
end

fprintf(fid,'%s',header');
for i = 1:size(header,1)
  
  key{i} = sscanf(header(i,:),'%8s=',1);
  keyval{i}=deblank(header(i,[10:end]));
  
end

if ~( strncmp(header(i,:),'END',3) == 1 )
  
  error('Missing ''END'' in header')
  
end
blank = '                                                                                ';

while rem( i,36 ) ~= 0 
  
  fwrite(fid,blank,'char');
  i = i+1;
  
end


bitpix=sscanf(keyval{fitsfindkey(key,'BITPIX')},'%d');

if ( bitpix == 8 )
  
  fwrite(fid,data','uint8');
  
elseif ( bitpix == 16 )
  
  fwrite(fid,data','int16');
  
end
if ( bitpix == 32 )
  
  fwrite(fid,data','int16');
  
end
if ( bitpix == -32 )
  
  fwrite(fid,data','float32');
  
end
fclose(fid);
if nargout ~= 0
  ok = 1;
end
