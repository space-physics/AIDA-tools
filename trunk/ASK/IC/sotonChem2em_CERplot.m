function [ph,CER,emissions] = sotonChem2em_CERplot(emissions,OPS,varargin)
% sotonChem2em_CERplot - plot column emission rates from SOTON Chemistry model emission-file/struct
%   
% Calling:
%   [ph,CER,emissions] = sotonChem2em_CERplot(emissions,OPS,varargin)
% Input:
%   emissions - Emissions structure as returned from
%               soton_ionchem_emissions_parser
%   OPS       - Options struct (optional), the default options is
%               returned if the function is called without input
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
dOPS.pIndxUpperLimOffset = 0;
dOPS.plotfcn = 'p'; % p - plot, s - semilogy, l - loglog

if nargin == 0
  ph = dOPS;
  return
end

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
try
  ScaleLambda2plot = dOPS.ScaleLambda2plot.*ones(size(pIndx'));
catch
  error('size of OPS.ScaleLambda2plot (%d) should match size of wavelengths to plot (%d)',size(dOPS.ScaleLambda2plot),pIndx)
end

if isempty(dOPS.T)
  T = emissions.t_out;
else
  T = dOPS.T;
end
if ~isempty(dOPS.indx4T)
  indxT = dOPS.indx4T;
  if ~ ( length(T) == length(indxT) )
    error('length of OPS.indx4T (%d) should match the lenngth of "time-steps" to plot (%d)',length(dOPS.indx4T),length(T))
  end
else
  indxT = 1:length(T);
end

if isempty(dOPS.indxLambda2plot)
  indxLambda2plot = 2:size(emissions.data,2);
else
  indxLambda2plot = dOPS.indxLambda2plot(:);
end

h = emissions.data(:,1,2)/100;
dh = abs(gradient(h));
sz_Lambda_T = size(emissions.data(1,indxLambda2plot,indxT));
CER = squeeze(sum(emissions.data(:,indxLambda2plot,indxT) .* ...
                  repmat(dh,sz_Lambda_T)));% .* ...
if ~isempty(ScaleLambda2plot)
  for i1 = 1:size(CER)
    CER(i1,:) = CER(i1,:)*ScaleLambda2plot(min(i1,length(ScaleLambda2plot)));%repmat(ScaleLambda2plot,size(T));
  end
end
% $$$ ph = loglog(T,...
% $$$             squeeze(sum(emissions.data(:,indxLambda2plot,indxT).*repmat(dh,sz_Lambda_T))).*repmat(ScaleLambda2plot,size(T)),...
% $$$             varargin{:});
switch dOPS.plotfcn
 case 'p'
  ph = plot(T,...
            CER,...
            varargin{:});
 case 's'
  ph = semilogy(T,...
                CER,...
                varargin{:});
 case 'l'
  ph = loglog(T,...
              CER,...
              varargin{:});
 otherwise
end

            


legend(ph,emissions.reactions_vec{2}(emissions.profile_vars(pIndx-1)),'interpreter','none')
