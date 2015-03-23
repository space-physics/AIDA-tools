function y = YY( phi, Lambda, alt)
% y = YY( phi, Lambda, alt)
% 

%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

a = 6378.137+alt;
f = 1/298.257;
e = (2*f-f*f)^.5;

if length(a) == 1
  
  % y = (a*(1-e*e)*sin(phi));
  y = ( NN(phi,alt).*(1-e^2) + alt ).*sin(phi);
  
else
  
  % y = ((1-e*e)*a.*sin(phi));
  y = ( NN(phi,alt).*(1-e^2) + alt ).*sin(phi);
  
end
    
