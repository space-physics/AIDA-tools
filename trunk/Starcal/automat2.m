function [diff] = automat2(optpar,starteauw,mode,optpar2,lock_par,imsiz)
% AUTOMAT2 - total square of deviation between image and catalog position stars
% Input OPTPAR is the optical parameters, STARTEAUW is a matrix that
% gives the identified stars, MODE is scalar that specifies which
% give the optical transfer function. LOCK_PAR is a vector with
% length equal to the length of OPTPAR with 1 for constraining OPTPAR to
% the value in OPTPAR2
% 
% Calling:
% [diff] = automat2(optpar,starteauw,mode,optpar2,lock_par)
% 
% See also: AUTOMAT4

%   Copyright ©  1997 by Bjorn Gustavsson <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

%time = 1;

alpha0 = optpar(3);
beta0 = optpar(4);
gamma0 = optpar(5);
if length(optpar) > 9
  [e1,e2,e3] = camera_base(alpha0,beta0,gamma0,optpar(10));
else
  [e1,e2,e3] = camera_base(alpha0,beta0,gamma0);
end
% $$$ az0 = optpar(3);
% $$$ el0 = optpar(4);
% $$$ roll0 = optpar(5);
qwe = optpar(8);

% $$$ [e1,e2,e3] = camera_base(az0,el0,roll0);

Nrstj = size(starteauw,1);
tdiff = 0;

for i = 1:Nrstj,
  
  az = starteauw(i,1);
  el = starteauw(i,2);
  
  [u,w] = camera_model(az,el,e1,e2,e3,optpar,mode,imsiz);
  tdiff = tdiff + (u-(starteauw(i,3)))^2+(w-(starteauw(i,4)))^2;
  
end

if ( mode ~= 3 )
  
  diff = tdiff^.5 + ( qwe - 1 )^2;
  
else
  
  diff = tdiff^.5;
  
end

fix = 1e6*abs(optpar-optpar2).^1.25.*lock_par;
diff = diff + fix*fix';
