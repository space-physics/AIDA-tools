function varPout = parsOnrefinedGrid4AF(par0,Xp1,Yp1,Xp2,Yp2,OPS)

% Copyright Bjorn Gustavsson 20110306
% GNU copyleft 3.0 or later applies

% In 2-D <=> corner to corner
[xP1,yP1] = meshgrid(Xp1,Yp1);
[xP2,yP2] = meshgrid(Xp2,Yp2);

% make matrices for the mapping of [xP0,yP0] into I1
xP = xP1;
yP = yP1;
Ip = xP;

nPoints = length(xP1(:));

% And assign the corresponding parameters there
xP(:) = par0(1:(nPoints));
yP(:) = par0(nPoints+[1:(nPoints)]);
Ip(:) = par0(2*nPoints+[1:(nPoints)]);

% $$$ % Interpolate these mappings to full image size:
% $$$ X = interp2(xP1,yP1,xP,Xp2,Yp2,'*linear');
% $$$ Y = interp2(xP1,yP1,yP,Xp2,Yp2,'*linear');
% $$$ % Do the same for the intensity scaling
% $$$ Iscale = interp2(xP1,yP1,Ip,Xp2,Yp2,'*spline');

% Interpolate these mappings to full image size:
X = interp2(xP1,yP1,xP,xP2,yP2,'*linear');
Y = interp2(xP1,yP1,yP,xP2,yP2,'*linear');
% Do the same for the intensity scaling
Iscale = interp2(xP1,yP1,Ip,xP2,yP2,'*spline');

varPout = [X(:);Y(:);Iscale(:)];
