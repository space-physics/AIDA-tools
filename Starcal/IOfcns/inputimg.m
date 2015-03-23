function [filename,fpath] = inputimg()
% INPUTIMG - 
%   

%   Copyright © 19970907 Bjorn Gustavsson<bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


[name,fpath] = uigetfile('*.*','INPUT IMAGE');
if ( name ~= 0 | min(size(name)) == 0 )
  
  fp = fopen(fullfile(fpath,name),'r');
  if ( fp > 0 )
    
    fileexist = 1;
    filename = name;
    fpath = fpath;
    
  else
    
    disp(['Couldn''t open file: ',fpath,name])
    filename = '';
    fpath = '';
    
  end
  fclose(fp);
  
end
