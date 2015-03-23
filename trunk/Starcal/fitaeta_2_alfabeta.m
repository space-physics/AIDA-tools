function [alfa,beta] = fitaeta_2_alfabeta(fi,theta)
% FITAETA_2_ALFABETA - converts AZIMUTH & ZENITH rotations
% to 2 Gaussian rotations
% 
% Calling:
% function [alfa,beta] = fitaeta_2_alfabeta(fi,theta)

%   Copyright ©  19970907 by Bjorn Gustavsson <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later



raz = fi*pi/180;
rze = theta*pi/180;

alfa = 180/pi*atan(sin(raz).*tan(rze));
beta = -180/pi*asin(-cos(raz).*sin(rze));
