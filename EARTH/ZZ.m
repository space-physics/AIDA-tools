function z = ZZ( phi, Lambda, alt )
% z = ZZ( phi, Lambda, alt )
%


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


a = 6378.137+alt;
if length(a) == 1
  z = ( NN(phi,alt) + alt ) .*cos(Lambda).*cos(phi);
else
  z = ( NN(phi,alt) + alt ) .*cos(Lambda).*cos(phi);
end
