%% Example showing how to produce a emission-production-profile matrix
%
% ...from an emissions.dat output file produced by the Southampton IC 
% electron+ion-chemistry code. An obviou requirement is that the
% code was run with an input spectra where this makes sense (that
% is a series of monoenergetic input spectra, preferably in sorted
% order, a series of Maxwellians might also be appropriate)

%% 1 load the file with the energy grid:
load sp_energy_changeBG2.dat % name of file with the electron
                             % precipitation parameterised.
E = sp_energy_changeBG2(:,3); % In eV

%% 2 Read the emissions.dat file:
EmsO1p0 = soton_ionchem_emissions_parser('emissions.dat');

try
  % find the profiles of the first desired emission (6730):
  idxN2_6730 = 1 + find(strcmp(EmsO1p0.reactions_vec{2}(EmsO1p0.profile_vars),'N2_6730'));
  % and extract those profiles:
  a_N26730 = squeeze(EmsO1p0.data(:,idxN2_6730,2:2:end));
catch
  disp('Couldn''t find N2_6730 in the emissions.dat output file')
end

try
  % find the profiles of the first desired emission (6730):
  idxO_7774  = 1 + find(strcmp(EmsO1p0.reactions_vec{2}(EmsO1p0.profile_vars),'OI_7774'));
  idxO_7774D = 1 + find(strcmp(EmsO1p0.reactions_vec{2}(EmsO1p0.profile_vars),'OI_7774_D'));
  % and extract-n-add those profiles:
  a_O7774 = squeeze( EmsO1p0.data(:,idxO_7774,2:2:end) + ...
                     EmsO1p0.data(:,idxO_7774D,2:2:end) );
catch
  disp('Couldn''t find both OI_7774 sources in the emissions.dat output file')
end

