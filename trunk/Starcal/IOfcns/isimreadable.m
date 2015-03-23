function [ok] = isimreadable(filename)
%   [OK] = ISIMREADABLE(FILENAME)
%   ISIMREADABLE Determine if file FILENAME in in an image
%   format  matlab can read.

%   Copyright © 19970907 Bjorn Gustavsson<bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

ok = 0;

idx = find(filename == '.');
if (~isempty(idx))
  extension = lower(filename(idx(end)+1:end));
  switch extension
    
   case 'bpm'
    ok = 1;
   case 'hdf'
    ok = 1;
   case 'jpg'
    ok = 1;
   case 'jpeg'
    ok = 1;
   case 'pcx'
    ok = 1;
   case 'tiff'
    ok = 1;
   case 'tif'
    ok = 1;
   case 'xwd'
    ok = 1;
    
  end
  
end
