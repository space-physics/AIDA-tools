function [ph,emissions] = sotonChem2em_AVplot(emissions,OPS,varargin)
% sotonChem2em_AVplot - plot altitude variation of emission rates
% from SOTON Chemistry model emission-file/struct 
%   
% Calling:
%   [ph,emissions] = sotonChem2em_AVplot(emissions,OPS,varargin)
% Input:
%   emissions - Emissions structure as returned from
%               soton_ionchem_emissions_parser
%   OPS       - Options struct (optional), the default options is
%               returne if the function is called without input
%               parameters. The defaults are:
%               OPS.T = [] - meaning that the time-axis will be
%                            taken from the emissions.t_out field
%                            if some othe mapping is desired just
%                            give the desired coordinates here.
%               OPS.indx4T = [] - meaning that modeled output for
%                            all instances in time shall be
%                            plotted. If any temporal subset of
%                            outputs is desired just give array
%                            with indices.
%               OPS.indxLambda2plot = [] - meaning that all modeled
%                                     emissions shall be plotted If
%                                     any subset of modeled outputs
%                                     is desired just give array
%                                     with indices.
%               OPS.ScaleLambda2plot = 1; - scalilng factor, for
%                                      adjusting to stuff like
%                                      bandpass transmission et al.
%               OPS.lineStyles = {'-','-.','--'} - Cell array with
%                                linestyles to cycle over, if
%                                emissions for several time-steps
%                                is plotted
%               OPS.axlims = 'auto' - automatic scaling, will be
%                            used as argument to AXIS
%               OPS.pIndxUpperLimOffset = 1; Oddity!
%  varargin - cell array of inputs passed on to loglog. Controlling
%             things such as linestyle, colours etc. 
% Example OPS settings:
%   OPS.T = logspace(log10(10),log10(1e4),42) - for a case when the
%           modeling the emissions at 42 log-space energies between
%           10 eV and 10 keV.
%  OPS.indx4T = 2*[1:42] - selecting every second time-step between
%           2 and 84.
%  OPS.indxLambda2plot = [4,5,6] select to plot only emissions nr
%                        4,5 and 6
%  ScaleLambda2plot: [0.06 1 1] scale emission #4 with 0.06.
%
% SEE also:  soton_ionchem_emissions_parser plot legend


% Copyright Bjorn Gustavsson 20110128,
% GPL version 3 or later applies.

dOPS.T = [];
dOPS.indx4T = [];
dOPS.indxLambda2plot = [];
dOPS.ScaleLambda2plot = 1;
dOPS.pIndxUpperLimOffset = 1;
dOPS.lineStyles = {'-','-.','--'};
dOPS.axlims = 'auto';

if nargin == 0
  ph = dOPS;
  return
end


holdstate = ishold;

if nargin > 1
  dOPS = catstruct(dOPS,OPS);
end

if ~isstruct(emissions)
  emissions = soton_ionchem_emissions_parser('emissions.dat');
end

if isempty(dOPS.indxLambda2plot)
  pIndx = 2:(size(emissions.data,2)-dOPS.pIndxUpperLimOffset);
else
  pIndx = dOPS.indxLambda2plot;
end
pIndx = pIndx(:);
try
  ScaleLambda2plot = dOPS.ScaleLambda2plot.*ones(size(pIndx));
catch
  error('size of OPS.ScaleLambda2plot (%d) should match size of wavelengths to plot (%d)',size(dOPS.ScaleLambda2plot),pIndx)
end

if isempty(dOPS.T)
  T = emissions.t_out;
else
  T = dOPS.T;
end
T = T(:);
if ~isempty(dOPS.indx4T)
  indxT = dOPS.indx4T(:);
else
  indxT = 1:length(T);
end
indxT = indxT(:);

if isempty(dOPS.indxLambda2plot)
  indxLambda2plot = 2:size(emissions.data,2);
else
  indxLambda2plot = dOPS.indxLambda2plot;
end
indxLambda2plot = indxLambda2plot(:);

h = emissions.data(:,1,2);
dh = abs(gradient(h));
sz_Lambda_T = size(emissions.data(1,indxLambda2plot,indxT));

i_T = dOPS.indx4T;
ph = [];
for i1 = 1:length(i_T),
  
  phC = plot((emissions.data(:,indxLambda2plot,i_T(i1))),emissions.data(:,1,i_T(i1))/1e5,varargin{:});
  hold on
  set(phC,'linestyle',dOPS.lineStyles{1+rem(i1,length(dOPS.lineStyles))})
  ph = [ph,phC];
  
end

set(gca,'xscale','log','yscale','linear')

axis(dOPS.axlims)

if ~holdstate
  hold off
end

