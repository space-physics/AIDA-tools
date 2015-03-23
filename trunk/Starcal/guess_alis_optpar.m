function optpar = guess_alis_optpar(obs)
% GUESS_ALIS_OPTPAR - sets up initial guess for the optics
% parameter array.
%   
% Calling:
% optpar = guess_alis_optpar(obs)

%   Copyright  ©  2001 by Bjorn Gustavsson <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% focal widths % of full image 1 corresponds
% to approximatelly 54 degres fov side to
% side. -1 implies a mirroring.
optpar(1:2) = [-1 1];
%optical axis projected in the centre of the image.
optpar(6:7) = 0; 

if isempty(obs.beta)
  
  [alfa,beta] = fitaeta_2_alfabeta(obs.az,obs.ze);
  
else
  
  alfa = obs.alpha*0.025;
  beta = obs.beta*0.025;
  
end
optpar(3:5) = rem([alfa beta 0],90);
% alfa = pi/180*alfa;
% beta = pi/180*beta;
% [alfa,beta] = fitaeta_2_alfabeta(obs.az,obs.ze);
% $$$ %trivial little transformation...
% $$$ optpar(3) = 180/pi*atan2(sin(alfa)/(-sin(beta)^2+sin(beta)^2*sin(alfa)^2+1)^(1/2), ...
% $$$ 			 cos(alfa)*cos(beta)/(-sin(beta)^2+sin(beta)^2*sin(alfa)^2+1)^(1/2));
% $$$ optpar(4) = 180/pi*atan2(cos(alfa)*sin(beta),(-sin(beta)^2+sin(beta)^2*sin(alfa)^2+1)^(1/2));
% $$$ optpar(5) = 180/pi*atan2(-(sin(alfa)*sin(beta)*cos(0)-cos(beta)*sin(0))/...
% $$$ 			 (- sin(beta)^2+sin(beta)^2*sin(alfa)^2+1)^(1/2),... 
% $$$ 			 (sin(alfa)*sin(beta)*sin(0)+cos(beta)*cos(0))/...
% $$$ 			 (-sin(beta)^2+sin(beta)^2*sin(alfa)^2+1)^(1/2));
% $$$ %Or what would I do without the symbolic toolbox.

optpar(8) = .35;
