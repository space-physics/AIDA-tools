function dYdPhi = dydphi( phi, Lambda )
% dYdPhi = dydphi( phi, Lambda )
%


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

a = 6378.137;
f = 1/298.257;
e = (2*f-f*f)^.5;

% dydf = (a*(1-e*e)*cos(phi));

dYdPhi = cos(phi).*(alt - (a*(e^2 - 1))./(1 - e^2*sin(phi)).^(1/2)) - (a*e^2*cos(phi).*sin(phi).*(e^2 - 1))./(2*(1 - e^2*sin(phi)).^(3/2));
