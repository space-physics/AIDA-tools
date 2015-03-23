function x = XX( phi, Lambda , alt )
% x = XX( phi, Lambda , alt )
%


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


f = 1/298.257;
e = (2*f-f*f).^.5;
a = 6378.137;

if length(a) == 1
  x = ( NN(phi,alt) + alt ).*sin(Lambda).*cos(phi);
else
  x = ( NN(phi,alt) + alt ).*sin(Lambda).*cos(phi);
end
