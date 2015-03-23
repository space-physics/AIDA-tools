function P = atm_att_est(Intens,zenith_a)
% ATM_ATT_EST - Estimate of the atmospheric absorption 
% from variation of the star intensity INTENS with zenith angle
% ZENITH_A
%
% Calling:
%  P = atm_att_est(Intens,zenith_a)
%



%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

I = [];
Z = [];
for i = 1:size(Intens,1),
  
  [in] = find(Intens);
  I = [I, Intens(in)];
  Z = [Z, zenith_a(in)];
  
end

P = polyfit(1./cos(Z),log(I),1);
