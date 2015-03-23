function dZdPhi = dzdphi( phi, Lambda )
% dZdPhi = dzdphi( phi, Lambda )
%


%   Copyright � 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

a = 6378.137;
f = 1/298.257;
e = (2*f-f*f)^.5;

%dzdf = (-a*cos(Lambda).*sin(phi));

dZdPhi = (a*e^2*cos(Lambda).*cos(phi).^2)./(2*(1 - e^2*sin(phi)).^(3/2)) - cos(Lambda).*sin(phi).*(alt + a./(1 - e^2*sin(phi)).^(1/2));
