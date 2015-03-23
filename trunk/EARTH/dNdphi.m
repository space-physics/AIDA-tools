function dndf = dNdphi( phi, Lambda )
% dndf = dNdphi( phi, Lambda )
%


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

a = 6378.137;
f = 1/298.257;
e = (2*f-f*f).^.5;

dndf =(-e*e*cos(phi).*sin(phi)./sqrt(1-e*e*sin(phi).*sin(phi)));

dNdPhi = (a*e^2*cos(phi))./(2*(1 - e^2*sin(phi)).^(3/2));
