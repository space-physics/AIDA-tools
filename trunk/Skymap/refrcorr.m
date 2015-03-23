function [apze] = refrcorr(ze)
% REFRCORR - From true zenith angle to apparent zenith correcting
% for refraction in the atmosphere. This approximation is good up
% to zenith angles of about 80 degrees.
% 
% Calling:
%   [apze] = refrcorr(ze)
% Input: 
%   ZE - zenith angle (radians).
% Output:
%   APZE - apparent zenith angle (radians)
% 
% REFRCORR  a _very_ simple correction function for zenith angles.
% It completly neglects the curvature of the earth, as well as 
% temperature and pressure profiles. This is a slight modification 
% of the procedure in FUNDAMENTAL ASTRONOMY by H. Karttunen, 
% P. Kroeger, H. Oja, M. Poutanen and K.J. Donner


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

n0 = 1+2.8119e-4;
apze = max( ze - ( 1 - 1/n0 ) * tan( ze ) , ze - .01 );
