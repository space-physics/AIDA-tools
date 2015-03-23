function [header] = fits_header(fid,filename)
% FITS_HEADER reads the first fits-file header, returns header and fid
% positioned at the end of header.
%
% Calling:
%  [header] = fits_header(fp,filename)
%
% INPUT:
%   FID - file pointer/file identifier as returned from FOPEN
%   FILENAME - file name
% 
% OUTPUT:
%   HEADER - primary fits header

no_end_yet = 1;
reached_endoffile = 0;

i1 = 1;
while ( no_end_yet )
  
  s = fread(fid,80,'char');
  
  st = char(s');
  
  if ( strncmp(st,'END',3) == 1 )
  
    no_end_yet = 0;
    
  end
  
  %key{i1} = sscanf(st,'%8s=',1);
  %keyval{i1}=deblank(st(10:end));
  
  if ( i1 == 1 )
    header = st;
  else
    % header = str2mat(header,st);
    header = char(header,st);
  end
  i1 = i1+1;
  if feof(fid)
    reached_endoffile = 1;
    break
  end
end
if no_end_yet || reached_endoffile
  disp(['There is something fishy with fits file: ',filename])
  return
end
i1 = i1-1;
while rem(i1,36) ~= 0
  fread(fid,80,'char');
  i1 = i1+1;
end
