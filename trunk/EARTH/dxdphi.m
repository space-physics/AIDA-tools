function dXdPhi =  dxdphi( phi, Lambda, alt )
% dXdPhi =  dxdphi( phi, Lambda )
%


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


a = 6378.137;
f = 1/298.257;
e = (2*f-f*f)^.5;

% dxdf = (-a*sin(Lambda).*sin(phi));

dXdPhi = (a*e^2*cos(phi).^2.*sin(Lambda))./(2*(1 - e^2*sin(phi)).^(3/2)) - sin(Lambda).*sin(phi).*(alt + a./(1 - e^2*sin(phi)).^(1/2));
