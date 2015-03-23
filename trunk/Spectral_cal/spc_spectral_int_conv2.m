function [I,dI] = spc_spectral_int_conv2(wl_filter,filter_tr,BSCNR,dispOPS)
% SPC_SPECTRAL_INT_CONV2 - convert Pulkovo intensity to #/cm^2/s/fw
%   spc_spectral_int_conv2 should convert the photo-spectrometric
%   intensities from the Pulkovo catalog to #photons/cm^2/s
%   by a weighted integral over the wavelength region, WL_FILTER,
%   of the filter with transmission FILTER_TR.
% 
% Calling:
%   [I,dI] = spc_spectral_int_conv2(wl,filter_tr,BSCNR,dispOPS)
% Input:
%   WL_FILTER - wavelengths for filter transmissions [1 x n]
%   FILTER_TR - filter transmission characteristic [n_f x n] or a
%               function handle to a function f(wl_filter) that
%               returns the filter transmission at wl_filter
%   BSCNR - Bright star catalog index of star
%   DISPOPS - display-option-struct with field 'disp_things'
%             [ {0} | 1 ] and 'plot_things' [ {0} | 1 ]
% Output:
%   I - stellar intensity #photons/cm^2/s/fw
%   DI - gradient in I: DI = (I(max(wl))-I(min(wl)))
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


Catalog2photons_s_cm2_nm = wl_filter*1e-9*1e-4/h/c0*1e-9;

disptrue = 0;
plottrue = 0;
if nargin >= 4 & isfield(dispOPS,'disp_things')
  
  disptrue = 1;
  
end
if nargin >= 4 & isfield(dispOPS,'plot_things')
  
  plottrue = 1;
  
end

for si = 1:length(BSCNR),
  
  b_s_nr = BSCNR(si);
  [wls,I_e] = getspec(b_s_nr);
  qwei = find(gradient(wls)<0);
  if ~isempty(qwei)
    wls = wls(1:qwei);
    I_e = I_e(1:qwei);
  end
  
  for i2 = 1:size(filter_tr,1)
    if isa(filter_tr{1}, 'function_handle')
      I_filter = interp1(wls,I_e,wl_filter).*filter_tr{i2}(wl_filter).*Catalog2photons_s_cm2_nm;
    else
      I_filter = interp1(wls,I_e,wl_filter).*filter_tr(i2,:).*Catalog2photons_s_cm2_nm;
    end
    I(si,i2) = sum(I_filter.*gradient(wl_filter));
    
    if disptrue
      plot(wl_filter,I_filter)
      drawnow
    end
    if plottrue
      clf
      plot(wls,I_e)
      hold on
      title(['sis = ',num2str(si),' bsc_nr = ',num2str(b_s_nr)])
      plot(wl_filter',I_filter','o')
      drawnow
    end
    
  end
  
end
