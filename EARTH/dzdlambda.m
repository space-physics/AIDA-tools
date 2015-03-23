function dZdLambda = dzdlambda( phi, Lambda )
% dZdLambda = dzdlambda( phi, Lambda )
%


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

a = 6378.137;
f = 1/298.257;
e = (2*f-f*f)^.5;
% dzdl = (-a*sin(Lambda).*cos(phi));

dZdLambda = -cos(phi).*sin(Lambda).*(alt + a./(1 - e^2*sin(phi)).^(1/2));
