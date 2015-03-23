function n = NN( phi, alt )
% n = NN( phi, alt )
%


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


f = 1/298.257;
e = (2*f-f*f)^.5;
a = 6378.137;

% n = sqrt(1-e*e*sin(phi).*sin(phi));
n = a./sqrt(1-e.^2.*sin(phi).^2);
