function res = tomo_err4sliceGACT(Par,var_pars,par0,M2Dto1D,Ie2H,E,ImgCuts,X2D,Y2D,Z2D,biasAmplitudes,biasVals,out_arg_type,z_max,OPS)
% tomo_err4sliceGACT - error function for estimating electron spectra
% from auroral arcs seen of magnetic zenith
%
% Calling:
%  res = tomo_err4sliceGACT(Par,var_pars,par0,M2Dto1D,Ie2H,E,ImgCuts,X,Y,Z,biasAmplitudes,biasVals,out_arg_type,z_max)
% Input:
%  Par            - Array with freely variable parameters
%  var_pars       - Index of Par into the array with all parameters
%  par0           - array with all parameters:
% 
%  par0(i1,1) Peak intensity of this arc
%  par0(i1,2) Horizontal center of this arc
%  par0(i1,3) Horizontal width of this arc
%  par0(i1,4) Spatial shape factor of this arc -
%             bias towards 2, constrain between 1.5 and 3
%  par0(i1,5) Central energy of this arc
%  par0(i1,6) Width in energy of this arc
%  par0(i1,7) Shape factor energy-wise of this arc
%  par0(i1,8) Ratio of dx between left and right side of
%             x0, bias towards zero, constrain to
%             between -0.1 and 0.1
%  par0(i1,9) Exponent for power of E before the
%             exponential term in electron flux.
% 
%  M2Dto1D        - Projection matrices from 2-D
%                   horizontal-altitude volume emission distribution, down to linear
%                   image cuts. Cell array with n_ImgCuts matrices
%                   with size of [nZ*nY x nPixels], making it
%                   possible to use images from multiple
%                   observations sites with different viewing
%                   angles.
%  Ie2H           - Cell array {n_ImgCuts x 1} with projection
%                   matrices from electron spectra to altitude
%                   variation of volume emission rate each cell
%                   element: [nZ x nE]
%  E              - Array of energies for Ie2H{i1}(i2,:). Assumed
%                   to be keV.
%  ImgCuts        - Cell array {n_ImgCuts x 1} with observed image
%                   intensities in a linear image cut [1 x nPixels]
%                   Location of image observation site and filter
%                   have to match the ordering in M2Dto1D and Ie2H
%                   respectively.
%  X              - Horizontal grid [1 x nY x nZ] (km), Should be
%                   skewed so that columns are paralell with the
%                   magnetic field.
%  Y              - Horizontal grid [1 x nY x nZ] (km), Should be
%                   skewed so that columns are paralell with the
%                   magnetic field.
%  Z              - Altitude grid [1 x nY x nZ] (km), should be flat in
%                   the sense that each line (Z(iZ,:)) is at the
%                   same altitude.
%  biasAmplitudes - Amplitude of 
%  biasVals       - 
%  out_arg_type   - 
%  z_max          - altitude at which horizontal position is given
%  OPS            - options structure.

%   Copyright � 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% constraining_error = 0;

dOPS.normregs = {[],[]};
dOPS.transpVem = 1;
if nargin > 14 && ~isempty(OPS)
  dOPS = merge_structs(dOPS,OPS);
end
% Adding CSW 02/2012 ???? Dimensions????
X = squeeze(X2D)';
Y = squeeze(Y2D)';
Z = squeeze(Z2D)';

if nargin >12
  [peakI,iZpeakI] = min(abs(Z(:,1)-z_max));  % bug CSW 02/2012?
                                             %    [iZpeakI,iZpeakI] = min(abs(Z(:,1)-z_max));
else
  [peakI,iZpeakI] = min(abs(Z(:,1)-106)); % bug CSW 02/2012?
end

I0 = par0;          % The complete parameter set, with stable
                    % parameters as well
if ~isempty(Par)
  I0(var_pars(:)) = Par; % Insert the variable parameters into that
                         % array. This way we can optimize the selected
                         % var_pars while keeping the others constant -
                         % subspace search...
  I0 = reshape(I0,9,[])'; % Reshape parameter array to [nArcs x 9] to
                          % make for [I0 x0 dx gx E0 dE gE Ddx g_E2] 
end
for i2 = length(ImgCuts):-1:1,
  Vem{i2} = zeros(size(Z));
end
Ie2D = 0;
% I0
for i1 = 1:(size(I0,1)),
  %disp(I0(i1,:))
  % Before first we extract the parameters for this arc:
  Imax = I0(i1,1); % Peak intensity of this arc
  x0   = I0(i1,2); % Horizontal center of this arc
  dx   = I0(i1,3); % Horizontal width of this arc
  g_x  = I0(i1,4); % Spatial shape factor of this arc -
                   % bias towards 2, constrain between 1.5 and 3
  E0   = I0(i1,5); % Central energy of this arc
  dE   = I0(i1,6); % Width in energy of this arc
  g_E  = I0(i1,7); % Shape factor energy-wise of this arc
  Ddx =  I0(i1,8); % Ratio of dx between left and right side of
                   % x0, bias towards zero, constrain to
                   % between -0.1 and 0.1
  g_E2 = I0(i1,9); % Exponent for power of E before the
                   % exponential term in electron flux.
  
  % First we make the electron spectra from the current
  % electron energy spectrum parameters for arc i1:
  Ie = E.^g_E2.*exp(-abs(E-E0).^g_E/dE^g_E).*E;

  % Then we make the horizontal intensity variation of the
  % precipitation:
  Ix = Imax * exp( -abs( (Y(iZpeakI,:) - x0)./(dx*(1+Ddx*(Y(iZpeakI,:) - x0>0)))).^g_x);  % Bug CSW 02/2012
%  Ix = Imax * exp( -abs( (Y(iZpeakI,:) - x0)./(dx*(1+Ddx*(Y(iZpeakI,:) - x0>0)))).^g_x);
 
  
  % Then we make altitude profiles for all the emissions:
  for i2 = length(ImgCuts):-1:1,
    
    I_Z{i2} = Ie2H{i2}*Ie'; % Bug corrected CSW 02/2012?
%    I_Z{i2} = Ie2H{i2}*Ie;

    % The altitude-horizontal variation of the volume emission
    % rates should just be the outer product of the two:
    Ivh = I_Z{i2}*Ix;     % Im stuck here CSW 17/02/2012!
    Vem{i2} = Vem{i2} + Ivh;
    
  end
  % keyboard
  if out_arg_type ~= 1
    Ie2D = Ie2D + Ie'*Ix;
  end
end

err = 0;
for i1 = length(ImgCuts):-1:1,
  
  
  % Extract the the cut-out along selected cut
  cutImg{i1}  = ImgCuts{i1};%interp2(stns(i1).img,u,v);
  % Calculate the image projection of the volume emission in the
  % 2-D slice:
  if dOPS.transpVem
    currVem = Vem{i1}';
  else
    currVem = Vem{i1};
  end
  cutProj{i1} = M2Dto1D{i1}*currVem(:);%interp2(stns(i1).proj,u,v);
  
  % square Image difference:
  % err1 = w_stns(min(i1,numel(w_stns)))*sum(sum(( i_reg(:) - p_reg(:) ).^2));
  % Wheighted square errors
  %err1 = sum(( ImgCuts{i1} - cutProj{i1} ).^2./(abs(cutProj{i1}).^.5+1));
  % Scrap that weighted stuff! WE NEED to give higher weights to
  % the brighter parts!
  if i1 <= length(dOPS.normregs) && ~isempty(dOPS.normregs{i1})
    IscaleFactor = mean(ImgCuts{i1}(dOPS.normregs{i1}(1):dOPS.normregs{i1}(2))./cutProj{i1}(dOPS.normregs{i1}(1):dOPS.normregs{i1}(2))');
  else
    IscaleFactor = 1;
  end
  cutProj{i1} = IscaleFactor*cutProj{i1};
  err1 = sum( ( ImgCuts{i1}(3:end-1) - cutProj{i1}(3:end-1)' ).^2 );
  % And to avoid edge effects skip the first few points in either
  % end...
  err = err + err1;
  
end

if ~isempty(biasAmplitudes)
  err = err + sum(biasAmplitudes(:).*( Par(:) - biasVals(:) ).^2);
  err = err + 500*sum( ( 2 - I0(:,6) ).^5 .* ( I0(:,6) < 2) );
end

if err < 0 || ~isfinite(err)
  keyboard
end
switch out_arg_type
 case 1 % Error
  res = err;
 case 2 % Vem and projections
  res.par = I0;
  res.err = err;
  for i2 = length(Vem):-1:1,
    res.Vem{i2} = Vem{i2};
  end
  res.cutImg = cutImg;
  res.cutProj = cutProj;
  res.Ie2D = Ie2D;
 otherwise
end
