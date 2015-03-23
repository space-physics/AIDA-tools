function q_of_h_n_E = ionization_profiles_from_flux(E_range,I_e_of_E,atmosphere,ipa)
% ionization_profiles_from_flux - simple model for volume emission as function of altitude.
%   After Sergienko and Ivanov 1993
%
% Calling:
%   q_of_h_n_E = ionization_profiles_from_flux(E_range,I_e_of_E,atmosphere,ipa)
% Input:
%   E_range - range of characteristic energies
%   lambda  - wavelength: [ 4278 | 5577 | 8446 | 6300 ]
%             use 4278 for all unquenched emissions from N2
%             use 8446 for emissions from atomic oxygen
%   atmosphere - [alt,N2,O,O2,density] {km,m^-3,kg/m^3}
%   ipa     - type of pitch angle distribution 1 for || 2 for
%             isotropic 

q_of_h_n_E = zeros(size(atmosphere,1),length(E_range));
h_atm = atmosphere(:,1);
nN2 = atmosphere(:,2);
nO = atmosphere(:,3);
nO2 = atmosphere(:,4);

dE = diff(E_range);
dE = [dE dE(end)];
E_cost_ion = [36.8,26.8,28.2]; 
ki = [1 0.7 0.4];
Partitioning = ( [ki(1)*nN2,ki(3)*nO,ki(2)*nO2] ./ ...
                 repmat(sum([ki(1)*nN2,ki(3)*nO,ki(2)*nO2],2),1,3) );

% First calculate the energy deposition as a function of altitude
for iE = 1:length(E_range),
  
  E = linspace(E_range(iE),E_range(iE)+dE(iE),20);
  % for both isotropic and field aligned electron beams
  [Am] = energy_deg(E,ipa,atmosphere(:,[1,2,4,3,5]));
  % add them all together
  q_of_h_n_E(:,iE) = sum(Am);% sum(Am,2)?
  
  q_of_h_n_E(:,iE) = q_of_h_n_E(:,iE).*(Partitioning(:,1)/E_cost_ion(1) + ...
                                        Partitioning(:,2)/E_cost_ion(2) + ...
                                        Partitioning(:,3)/E_cost_ion(3));
  
end

% Interpolate to the relevant altitude coordinates
%q_of_h_n_E = interp1(alt,q_of_h_n_E,h_atm);
