function [fp] = find_fp(spath,name)
% FIND_FP is a function that locates a named file
%    in directory SPATH under first the working 
%    directory then under ~/.stctk/'SPATH' and finally
%    under '$(stardir)'/'SPATH'. Usefull for possibility
%    to let multiple users have different setup.
%    
% Calling:
%  [fp] = find_fp(spath,name)
% 
%    See also function FINDSTN_LOAD.

%       Bjorn Gustavsson 7-9-97
%	Copyright © 1997 by Bjorn Gustavsson

global stardir
home = getenv('HOME');

lname = fullfile(spath,name);

if ( exist(lname,'file') )
  
  filename = lname;
  
else
    
    
  fullname = fullfile(home,'/.stctk/',spath,'/',name);
  
  if ( exist(fullname,'file') )
    
    filename = fullname;
    
  else
    
    filename = fullfile(stardir,spath,name);
    
  end
  
end

fp = fopen(filename,'r');
