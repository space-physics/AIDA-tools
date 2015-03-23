function [fitsok] = isfits(filename)
%   ISFITS - Determine if file in FILENAME is in fits format.
%
% Calling:
%   [FITSOK] = ISFITS(FILENAME)
% 
% Input:
%   FILENAME - string with filename (relative or full path)
% ISFITS acctually only checks the filename extension. Not if the
% actual file is a correct fits file - which can only be done with
% successful reading?


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

error(nargchk(1, 1, nargin));

fitsok = 0;
[fpath,fname,fext] = fileparts(filename);

if (~isempty(fext))
  if fext(1) == '.'
    fext = fext(2:end);
  end
  extension = deblank(lower(fext));
  
  switch extension
   case 'fits16'
    fitsok = 1;
    
   case 'fits'
    fitsok = 1;
    
   case 'fit'
    fitsok = 1;
    
   case 'raf'
    fitsok = 1;
    
   case 'wra'
    fitsok = 1;
    
   case 'qlf'
    fitsok = 1;
    
   case 'qlk'
    fitsok = 1;
    
  end
end
