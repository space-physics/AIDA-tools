function res = errDeParallax2DiffuseS(Par,var_pars,par0,trmtr2d21d,Ie2H,E,ImgCuts,Y,Z,biasAmplitudes,biasVals,out_arg_type,z_max)
% errDeParallax2DiffuseS - error function for estimating electron spectra
% from auroral arcs seen of magnetic zenith
%
% Calling:
%  res = errDeParallax2(Par,var_pars,par0,trmtr2d21d,Ie2H,E,ImgCuts,Y,Z,biasAmplitudes,biasVals,out_arg_type)
% Input:
%  Par            - 
%  var_pars       - 
%  par0           - 
%  trmtr2d21d     - Projection matrix from 2-D horizontal-altitude
%                   volume emission distribution, down to linear
%                   image cut. [nZ*nY x nPixels]
%  Ie2H           - Cell array {nLambda x 1} with projection metrices
%                   from electron spectra to altitude variation of
%                   volume emission rate each cell element: [nZ x nE]
%  E              - Array of energies for Ie2H{i1}(i2,:). Assumed
%                   to be keV.
%  ImgCuts        - Cell array {nLambda x 1} with observed image
%                   intensities in a linear image cut [1 x nPixels]
%  Y              - Horizontal grid [nZ x nY] (km), Should be
%                   skewed so that columns are paralell with the
%                   magnetic field.
%  Z              - Altitude grid [nZ x nY] (km), should be flat in
%                   the sense that each line (Z(iZ,:)) is at the
%                   same altitude.
%  biasAmplitudes - Amplitude of 
%  biasVals       - 
%  out_arg_type   - 


%   Copyright � 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% constraining_error = 0;

if nargin >12
  [i110,i110] = min(abs(Z(:,1)-z_max));
else
  [i110,i110] = min(abs(Z(:,1)-106));
end
I0 = par0;          % The complete parameter set, with stable
                    % parameters as well
if ~isempty(Par)
  I0(var_pars) = Par; % Insert the variable parameters into that
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

for i1 = 1:(size(I0,1)-1),
  %disp(I0(i1,:))
  % Before first we extract the parameters for this arc:
  Imax = I0(i1,1);     % Peak intensity of this arc
  x0   = I0(i1,2);     % Horizontal center of this arc
  dx   = I0(i1,3);     % Horizontal width of this arc
  g_x  = I0(i1,4);     % Spatial shape factor of this arc -
                       % bias towards 2, constrain between 1.5 and 3
  E0   = I0(i1,5);%*1e3% Central energy of this arc
  dE   = I0(i1,6);%*1e3% Width in energy of this arc
  g_E  = I0(i1,7);     % Shape factor energy-wise of this arc
  Ddx =  I0(i1,8);     % Ratio of dx between left and right side of
                       % x0, bias towards zero, constrain to
                       % between -0.1 and 0.1
  g_E2 = I0(i1,9);     % Exponent for power of E before the
                       % exponential term in electron flux.
  
  % First we make the electron spectra from the current
  % electron energy spectrum parameters for arc i1:
  Ie = E.^g_E2.*exp(-abs(E-E0).^g_E/dE^g_E).*E; 
  % Then we make the horizontal intensity variation of the
  % precipitation:
  Ix = Imax * exp( -abs( (Y(i110,:) - x0)./(dx*(1+Ddx*(Y(i110,:) - x0>0)))).^g_x);
  % Then we make altitude profiles for all the emissions:
  for i2 = length(ImgCuts):-1:1,
    
    I_Z{i2} = Ie2H{i2}*Ie;
    %[Izmax,izmax] = max(I_Z{i2})
    % I_Z2 = Ie2H2*Ie;
    % The altitude-horizontal variation of the volume emission
    % rates should just be the outer product of the two:
    %Ivh{i2} = I_Z{i2}*Ix;
    Ivh = I_Z{i2}*Ix;
    % Ivh2 = I_Z2*Ix';
    Vem{i2} = Vem{i2} + Ivh;%{i2};
    % Vem2 = Vem2 + Ivh2;
    
  end
  if out_arg_type ~= 1
    Ie2D = Ie2D + Ie*Ix;
  end
end
%VemDisc = Vem;
% Special treatment of diffuse aurora
for i1 = (size(I0,1)),
  
  I0_L = I0(i1,1);
  I0_R = I0(i1,2);
  y_0  = I0(i1,3);
  dy   = I0(i1,4);
  E0_L = I0(i1,5);
  E0_R = I0(i1,6)*E0_L;
  dE   = I0(i1,7); % Fix this one to 1-2
  DdE  = I0(i1,8); % Fix this baby to 1! 
  IeL  = exp(-abs(E-E0_L).^2/dE^2).*E;
  IeR  = exp(-abs(E-E0_R).^2/(dE*DdE)^2).*E;
  IxR  = I0_L * (1 + erf( (Y(i110,:) - y_0)./dy)/2 );
  IxL  = I0_R * (1 - erf( (Y(i110,:) - y_0)./dy)/2 );
  for i2 = length(ImgCuts):-1:1,
    
    I_Z{i2} = Ie2H{i2}*IeL;
    %Ivh{i2} = I_Z{i2}*IxL;
    Ivh = I_Z{i2}*IxL;
    Vem{i2} = Vem{i2} + Ivh;%{i2};
    
  end
  if out_arg_type ~= 1
    Ie2D = Ie2D + IeL*IxL;
  end
  for i2 = length(ImgCuts):-1:1,
    
    I_Z{i2} = Ie2H{i2}*IeR;
    %Ivh{i2} = I_Z{i2}*IxR;
    Ivh = I_Z{i2}*IxR;
    Vem{i2} = Vem{i2} + Ivh;%{i2};
    
  end
  if out_arg_type ~= 1
    Ie2D = Ie2D + IeR*IxR;
  end
  
end
% $$$ for i1 = 1:length(ImgCuts),
% $$$   Vem{i1} = Vem{i1}';
% $$$ end
%%% keyboard

% $$$ minVem = min(Vem(:));
% $$$ err = abs(minVem)*(minVem<0);
% $$$ w_stns = [2,1.5];
err = 0;
for i1 = length(ImgCuts):-1:1,
  
  
  % Extract the the cut-out along selected cut
  cutImg{i1}  = ImgCuts{i1};%interp2(stns(i1).img,u,v);
  cutProj{i1} = trmtr2d21d*Vem{i1}(:);%interp2(stns(i1).proj,u,v);
  
  % square Image difference:
  % err1 = w_stns(min(i1,numel(w_stns)))*sum(sum(( i_reg(:) - p_reg(:) ).^2));
  % Wheighted square errors
  %err1 = sum(( ImgCuts{i1} - cutProj{i1} ).^2./(abs(cutProj{i1}).^.5+1));
  % Scrap that weighted stuff! WE NEED to give higher weights to
  % the brighter parts!
  err1 = sum( ( ImgCuts{i1}(3:end-1) - cutProj{i1}(3:end-1) ).^2 );
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
  res.Vem{1} = Vem{1};
  res.Vem{2} = Vem{2};
  res.cutImg = cutImg;
  res.cutProj = cutProj;
  res.Ie2D = Ie2D;
 otherwise
end
