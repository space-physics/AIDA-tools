function [true] = inimage(x,y,bx,by)
% INIMAGE  tests if a point (X,Y) is within the image,
% that is within  the ranges: 1 <= X <= BX  and 1 <= Y <= BY 
%
% Calling:
% [true] = inimage(x,y,bx,by)


%   Copyright © 1997 Bjorn Gustavsson<bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


%for i1 = 1:max(size(x)),
for i1 = max(size(x)):-1:1,
  
  if ( x(i1) >=1 & x(i1) <= bx & y(i1) >= 1 & y(i1) <= by )
    
    true(i1) = 1;
    
  else
    
    true(i1) = 0;
    
  end
  
end
