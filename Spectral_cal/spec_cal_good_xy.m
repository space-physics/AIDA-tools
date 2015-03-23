function ii = spec_cal_good_xy(T,X,Y,dx,dy)
% SPC_GOOD_XY - Get index to points in X,Y that are not scattered
% [dx,dy] outside a parametrised curve (P_x,P_y) where P_X is cubic
% least suare fitted polynomial to [T,X] cykl.
%   
% Calling:
% ii = spec_cal_good_xy(T,X,Y,dx,dy)
%


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

J = find(X~=0);

px = polyfit(T(J),X(J),3);
XP = polyval(px,T(J));

py = polyfit(T(J),Y(J),3);
YP = polyval(py,T(J));

ii = find(abs(X(J)-XP) < dx & ... 
	  abs(Y(J)-YP) < dy);

plot(XP,YP,'r')
hold on
plot(X(J),Y(J),'g+')
plot(X(ii),Y(ii),'ko')
plot(X(J(ii)),Y(J(ii)),'bh')
axis([0 333 0 333])
drawnow
hold off
