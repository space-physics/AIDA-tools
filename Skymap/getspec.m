function [wavelengths,energyfluxes] = getspec(bright_star_nr,verbosity)
% GETSPEC - high resolution stellar spectras around visible wavelengths.
% 
%   GETSPEC is a matlab wrapper to getsp a C-shell script that
%   reads the Pulkovo Spectrophotometric Catalog. WAVELENGTHS are
%   given in nm, and ENERGYFLUXES in W/m^2/m
% 
% Calling:
%   [wavelengths,energyfluxes] = getspec(bright_star_nr,verbosity)
% Input:
%   BRIGHT_STAR_NR - bright star catalog index of star whose
%                    spectra we want.
% Output:
%   WAVELENGTHS - wavelengts (nm), not necessarily monotonic
%   ENERGYFLUXES - energy flux of the star in wavelength
%                  region. (W/m^2/m)
% 
% Works, provided the C-shell script getsp can be executed
% (typically one has to make sure one has execute permision on the
% file, otherwise all stars will erroneously lack speckra), and
% provided one can create a file '/tmp/test1.qWe' - which means
% that MS-DOS/WINDOWS are on thin ice (If anyone know how to fix
% this I'd be happy to know, BG:bjorn@irf.se)



%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global stardir

if nargin == 1
  verbosity = 1;
end
[stardir] = fileparts(which('skymap'));

qWe_cmd = ['cd ',stardir,'/stars/;./getsp ',num2str(bright_star_nr),' > /tmp/test1.qWe'];
%TBR?: [qWe_q,qWe_w] = unix(qWe_cmd);
[qWe_q,qWe_w] = unix(qWe_cmd);
if qWe_q == 0
  
  qWe_fp = fopen('/tmp/test1.qWe','r');
  qWe_i = 1;
  while(~feof(qWe_fp))
    qWe_l = fgets(qWe_fp);
    if ~isempty(str2num(qWe_l))
      qWe_spe15(qWe_i,1:length(str2num(qWe_l))) = str2num(qWe_l);
      if length(str2num(qWe_l))==1
	    qWe_spe15(qWe_i,2) = nan;
      end
      qWe_i = qWe_i+1;
    end
  end
  
  wavelengths = qWe_spe15(:,1);
  energyfluxes = qWe_spe15(:,2);
  unix('rm /tmp/test1.qWe');
  
elseif verbosity == 1
  
  disp(['No specra in `Pulkovo Spectrophotometric Catalog'' for star: ',num2str(bright_star_nr)])
  
end
