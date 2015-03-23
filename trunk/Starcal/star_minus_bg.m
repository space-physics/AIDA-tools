function starint = star_minus_bg(in_starint)
% STAR_MINUS_BG - background reduction from star
%   
% Calling:
% starint = star_minus_bg(in_starint)


%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

xmin = 1;
xmax = size(in_starint,2);
ymin = 1;
ymax = size(in_starint,1);

starmat = medfilt2(in_starint([1 1:end end],[1 1:end end]),[3 3]);
starmat = starmat(2:end-1,2:end-1);

x = xmin:xmax;
y = ymin:ymax;
[x1,y1] = meshgrid(x,y);

b = [starmat(1,:),starmat(end,:),starmat(:,1)',starmat(:,end)',starmat(3,:),starmat(end-2,:),starmat(:,3)',starmat(:,end-2)'];
X = [x1(1,:),x1(end,:),x1(:,1)',x1(:,end)',x1(3,:),x1(end-2,:),x1(:,3)',x1(:,end-2)'];
Y = [y1(1,:),y1(end,:),y1(:,1)',y1(:,end)',y1(3,:),y1(end-2,:),y1(:,3)',y1(:,end-2)'];

bakgr2 = griddata(X,Y,b,x1,y1,'v4')*2/3+griddata(X,Y,b,x1,y1,'cubic')/3;

starint = in_starint - bakgr2;

