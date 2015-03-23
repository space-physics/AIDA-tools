function [fi,taeta] = starbestaemft2(az,el,e1,e2,e3)
% STARBESTAEMFT2 determines the possition of stars relative to axis
% axis e1, e2, e3 in cylindrical (?) coordinates, with the polar angle as
% radial distance. Fi is currently taken counterclockwise from e1.
% 
% Calling:
% [fi,taeta] = starbestaemft2(az,el,e1,e2,e3)


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


raz = az*pi/180;
rel = el*pi/180;
rze = pi/2-rel;

es(1,:) = sin(rze)'.*sin(raz)';
es(2,:) = sin(rze)'.*cos(raz)';
es(3,:) = cos(rze)';

ese1(1,:) = es(1,:)*e1(1);
ese1(2,:) = es(2,:)*e1(2);
ese1(3,:) = es(3,:)*e1(3);
sese1 = sum(ese1);

ese2(1,:) = es(1,:)*e2(1);
ese2(2,:) = es(2,:)*e2(2);
ese2(3,:) = es(3,:)*e2(3);
sese2 = sum(ese2);

ese3(1,:) = es(1,:)*e3(1);
ese3(2,:) = es(2,:)*e3(2);
ese3(3,:) = es(3,:)*e3(3);
sese3 = sum(ese3);

taeta = atan(((sese1).^2+(sese2).^2).^.5./(sese3));
fi = atan2( sese2 , sese1 );
