function [I,dI] = spc_spectral_int_conv(wl_center,delta_wl,BSCNR,dispOPS)
% SPC_SPECTRAL_INT_CONV - convert Pulkovo intensity to #/cm^2/s/fw
%
% Calling:
%  [I,dI] = spc_spectral_int_conv(wl_center,delta_wl,BSCNR,dispOPS)
% Input:
%  WL - wavelengths (nm), multiple regions is ok size (NxM)
%  FILTER_TR - filter transmission characteristics (NxM)
%  BSCNR - Bright star catalog index of star
%  DISPOPS - display-option-struct with field 'disp_things'
%             [ {0} | 1 ] and 'plot_things' [ {0} | 1 ]
% Output:
%  I - stellar intensity #photons/cm^2/s/fw
%  DI - gradient in I: DI = (I(max(wl))-I(min(wl)))
% 

%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


global c0;		% Speed of light [m/s]
global h;		% Plank's constant [Js]
global kB;		% Boltzmann constant [J/K]
global m_e;             % electron rest mass
global q_e;             % elementary charge

c0      = 2.99792458e8;	            % Speed of light [m/s]
h       = 6.62618e-34;              % Plank's constant [Js]
kB      = 1.380662e-23;             % Boltzmann constant [J/K]
m_e     = 9.10939e-31;              % electron rest mass [kg]
q_e     = 1.6021773e-19;            % elementary charge [C]


% Conversion of the Pulkovo spectrophotometric intensity unit to
% photons/cm^2/s/nm
Catalog2photons_s_cm2_nm = wl_center*1e-9*1e-4/h/c0*1e-9;
% Center wavelengths
wls0 = wl_center;
% and filter pass-bands
delta_wls = delta_wl;

% Display settings:
disptrue = 0;
plottrue = 0;
if nargin >= 4 & isfield(dispOPS,'disp_things') & ...
      dispOPS.disp_things == 1
  disp(wl_center)
  disptrue = 1;
end
if nargin >= 4 & isfield(dispOPS,'plot_things') & ...
      dispOPS.plot_things == 1
  plottrue = 1;
end

% Wavelength grid for all the filters.
for i1 = length(wls0):-1:1,
  
  wls_filter(i1,:) = linspace(wls0(i1)-delta_wls(i1)/2,wls0(i1)+delta_wls(i1)/2,15);
  
end


%Was: for si = 1:length(BSCNR),
for si = length(BSCNR):-1:1,
  
  % BSC-number of the current star
  b_s_nr = BSCNR(si);
  % Calculate the photon flux for the current star
  [wls,I_e] = getspec(b_s_nr);
  qwei = find(gradient(wls)<0);
  if ~isempty(qwei)
    wls = wls(1:qwei);
    I_e = I_e(1:qwei);
  end
  
  I_filter = interp1(wls,I_e,wls_filter);
  
  I(si,:) = [sum(I_filter.*gradient(wls_filter),2)]';
  dI(si,:) = [ ( I_filter(:,1) - I_filter(:,end) )./( wls_filter(:,1) - wls_filter(:,end) )]';
  
  if disptrue
    disp(I_filter)
  end
  if plottrue
    clf
    plot(wls,I_e)
    hold on
    title(['sis = ',num2str(si),' bsc_nr = ',num2str(b_s_nr)])
    plot(wls_filter',I_filter','o')
    drawnow
  end
  
  I(si,:) = I(si,:).*Catalog2photons_s_cm2_nm;
  
end
