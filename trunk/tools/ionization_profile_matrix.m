function [A] = ionization_profile_matrix(h,E,nO,nN2,nO2,density,OPTS)
% IONIZATION_PROFILE_MATRIX - calculate ionization profiles 
%   A(h,E) for electron fluxes in the energy range [E(i1) E(i1+1)],
%   here the final profile will be calculated over the energy ragne
%   [E(end) 2*E(end)-E(end)], that is the same dE as the second
%   last profile. Range and energy deposition profiles from
%   Sergienko and Ivanov 1993 are used.
%
% Calling:
%   Ie =   ionization_profile_matrix(t,h,E,...
%                    nO,nN2,nO2,...
%                    density,opts);
%   opts = ISR2IeofE; % to produce the default options
% 
% Input:
%  h    - altitude (m), double array [nh x 1]
%  E    - energy (eV) grid of the desired output spectra, double array
%         [nE x 1]
%  nO   - number density (m^-3) of atomic Oxygen [nh x 1]
%  nN2  - number density (m^-3) of molecular Nitrogen [nh x 1]
%  nO2  - number density (m^-3) of molecular Oxygen [nh x 1]
%  OPTS - Structure with options controlling the inversion
%         procedure. Current fields are:
%         OPTS.isotropic = 1; Run with isotropic electron precipitation,
%                     set to 2 for field-aligned and anything
%                     inbetween for any weighted mixture.
%
% See also ISR2IeofE3 ionizationMatrixSemeter

% The standard options:
dOPTS.isotropic = 1; % Run with isotropic electron precipitation,
                     % set to 2 for field-aligned and anything
                     % inbetween for any weighted mixture.

if nargin == 0 % Give defaults options back
  Ie = dOPTS;
  return
elseif nargin > 14
  dOPTS = catstruct(dOPTS,OPTS);
end


disp('Using "ionization_profile_matrix" from:')
dbstack
disp('consider changing to your own prefered function for calculating')
disp('the monoenergetic-production profile matrix.')

%% 1 stack the atmospheric profiles together:
atmosphere = [h,nN2,nO,nO2,density];

isotropic = 2;
parallell = 1;
%% 2 Calculate the ionization profiles for beams with energies in
% the intervals [E(k) E(k+1)], either for isotropic, field-aligned
% or a weighted mixture (the latter obviously takes twice as long to
% calculate):
if dOPTS.isotropic == 1
  % When using this code it should be described as using the
  % penetration depths and energy deposition of Sergienko and
  % Ivanov 199X Annales Geophysicae
  A = ionization_profiles_from_flux(E,ones(size(E)),atmosphere,isotropic);
elseif dOPTS.isotropic == 2
  A = ionization_profiles_from_flux(E,ones(size(E)),atmosphere,parallell);
else
  Ai = ionization_profiles_from_flux(E,ones(size(E)),atmosphere,isotropic);
  Ap = ionization_profiles_from_flux(E,ones(size(E)),atmosphere,parallell);
  A = (2-dOPTS.isotropic)*Ai + (dOPTS.isotropic-1)*Ap;
end
