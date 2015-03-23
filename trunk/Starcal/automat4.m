function [diff] = automat4(sp,starteauw,optmod,sp2,lock_par, imsiz)
% AUTOMAT4 - give sum tanh(dr)^2 between the image and catalog position of star
% in the image and the projected position. Input SP is the optical
% parameters, STARTEAUW is a matrix that gives the identified
% stars, OPTMOD is scalar that specifies the optical transfer
% function. SP2 is a priori values for SP and LOCK_PAR is a penalty
% magnitude vector.
% 
% Calling:
% [diff] = automat4(sp,starteauw,optmod,sp2,lock_par)
% 
% See also: AUTOMAT2

%   Copyright ©  1997 by Bjorn Gustavsson <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global s_prefs

hnl = s_prefs.hu_nm_ln;
%time = 1;

alpha0 = sp(3);
beta0 = sp(4);
gamma0 = sp(5);
if length(sp) > 9
  [e1,e2,e3] = camera_base(alpha0,beta0,gamma0,sp(10));
else
  [e1,e2,e3] = camera_base(alpha0,beta0,gamma0);
end
% $$$ az0 = sp(3);
% $$$ el0 = sp(4);
% $$$ roll0 = sp(5);
qwe = sp(8);

% $$$ [e1,e2,e3] = camera_base(az0,el0,roll0);

Nrstj = size(starteauw,1);
tdiff = 0;

for i = 1:Nrstj,
  
  az = starteauw(i,1);
  el = starteauw(i,2);
  
  [u,w] = camera_model(az,el,e1,e2,e3,sp,optmod,imsiz);
  pdiff = ((u-(starteauw(i,3)))^2+(w-(starteauw(i,4)))^2)^.5;
  
  % Huber-type Norm that more and more disregards errors larger
  % than pdiff >~ 5
  tdiff = tdiff + hnl^2*tanh(pdiff/hnl)^2;
  
end

if ( optmod ~= 3 )
  
  diff = tdiff^.5 + ( qwe - 1 )^2;
  
else
  
  diff = tdiff^.5;
  
end

%Wheighted penalty function with respect to start guess
fix = abs((sp-sp2).^2.*lock_par);
diff = diff + fix*fix';
