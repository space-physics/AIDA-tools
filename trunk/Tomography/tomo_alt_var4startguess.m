function IofH = tomo_alt_var4startguess(H,E,A,h0,atmMSIS)
% TOMO_ALT_VAR4STARTGUESS - altitude variation for Maxwellian
% electron primary electron spectra, calculated from energy
% deposition profiles 
%   



%   Copyright © 2010 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


h_atm = atmMSIS(:,1);
nN2 = atmMSIS(:,2);
nO = atmMSIS(:,3);
nO2 = atmMSIS(:,4);

E0 = linspace(1e3,1e4,91);
I_of_h = zeros(size(atmMSIS,1),length(E0));

for iE = length(E0):-1:1,
  Ie(iE,:) = Ie_E_with_LET(E0,1,E);
end
Ie = Ie.*gradient(E)/sum(Ie.*gradient(E));

% Interpolate to the relevant altitude coordinates
I_of_h = A*Ie;

% Scale with the corresponding neutral densitites and lifetimes
switch lambda
 case 4278
  I_of_h = I_of_h.*repmat(.92*nN2./(.92*nN2+nO2+.56*nO),size(E0));
 case 5577
  I_of_h = I_of_h.*repmat(.92*nN2./(.92*nN2+nO2+.56*nO),size(E0));
 case 8446
  I_of_h = I_of_h.*repmat(.56*nO./(.92*nN2+nO2+.56*nO),size(E0));
 case 6300
  try
    tau = tau_O1D(nO,nO2,nN2,Tn,ne,Te);
  catch
    tau = tau_O1D(nO,nO2,nN2,1000,0,0);
  end
  A6300 = 0.0071;  % Einstein coefficient for O1D 6300 emission
  I_of_h = A6300*I_of_h.*repmat(.56*tau.*nO./(.92*N2+nO2+.56*nO),size(E0));
 otherwise
  I_of_h = I_of_h.*repmat(.92*nN2./(.92*nN2+nO2+.56*nO),size(E0));
end
