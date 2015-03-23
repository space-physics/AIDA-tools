function res = err4FlamingRaysC(Par,var_pars,par0,stns,ImRois,Z3D,x2D,y2D,Ie2H,E,out_arg_type,z_max)
% err4FlamingRaysC - error function for estimating electron spectra
% from auroral ray seen off magnetic zenith
%
% Calling:
%   res = err4FlamingRays(Par,var_pars,par0,stns,ImRois,Z3D,x2D,y2D,Ie2H,E,out_arg_type,z_max)
% Input:
%  Par            - varying parameters
%  var_pars       - indices of varying parameters into the full
%                   parameter array par0
%  par0           - full parameter array. ### MORE!
%  stns           - struct describing geomertic part of image
%                   projection tailored for fastprojection, see
%                   camera_set_up_sc and fastprojection, and
%                   TOMO20080305NewBeginnings for more details.
%  ImRois         - cell array (same size as stns) with binary
%                   "region of interest" matrices, with 1 for the
%                   regions surrounding the auroral rays in the
%                   corresponding images of stns
%  Z3D            - 3-D matrix with altitudes of blob centres, as
%                   used for setting up the stns structs [ny,nx,nz].
%  x2D            - west-east horizontal coordinates for gound
%                   plane of 3-D block-of-blobs.
%  y2D            - south-north horizontal coordinates for gound
%                   plane of 3-D block-of-blobs.
%  Ie2H           - Cell array {nLambda x 1} with projection matrices
%                   from electron spectra to altitude variation of
%                   volume emission rate each cell element: [nZ x nE]
%                   preferably calculated on a far denser grid than
%                   Z3D and then averaged to the altitude
%                   resolution of Z3D with cos^2 weights.
%  E              - Array of energies for Ie2H{i1}(i2,:). Assumed
%                   to be keV.
%
%
% More details:
%  * The function can calculate the volume emission rate distribution
%  from multiple rays of precipitation - in case it is difficult to
%  isolate one ray well. This is done by giving PAR0 for more than
%  one ray (n x 10 parameters/ray)
%  * The function does not include any
%  contribution from diffuse background aurora so that should be
%  done to the images beforehand.
%  * In this function it is way preferable to have a skewed
%  horizontal 3-D grid.
%  * The horisontal intensity variation of a ray is calculated
%  relative to its footprint centres.
%  * another tedious procedure will be to make the
%  region-of-interest matrices. That on the other hand I think will
%  be relatively simple with inpolygon after ginput-ing points of
%  the polygon bounding/surrounding the ray.
%  * The function should be minimised with fminsearch/fminsearchbnd
%  * To speed things up the optimal parameters for one time-step
%  can/should be used as start parameters for the next time-step.
%  * The main problem will be to make good start guesses for the
%  parameters. More on this later.
%  


%   Copyright © 2012 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% constraining_error = 0;

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
for i2 = length(stns):-1:1,
  Vem{i2} = zeros(size(Z3D));
end


for i1 = 1:(size(I0,1)),
  %disp(I0(i1,:))
  % Before first we extract the parameters for this arc:
  Imax = I0(i1,1);     % Peak intensity of this arc
  x0   = I0(i1,2);     % Horizontal center of this arc
  y0   = I0(i1,3);     % Horizontal center of this arc
  dS   = I0(i1,4);     % Horizontal width of this arc
  g_x  = I0(i1,5);     % Spatial shape factor of this arc -
                       % bias towards 2, constrain between 1.5 and 3
  E0   = I0(i1,6);%*1e3% Central energy of this arc
  dE   = I0(i1,7);%*1e3% Width in energy of this arc
  g_E  = I0(i1,8);     % Shape factor energy-wise of this arc
  g_E2 = I0(i1,9);    % Exponent for power of E before the
                       % exponential term in electron flux.
  
  % First we make the electron spectra from the current
  % electron energy spectrum parameters for arc i1:
  Ie = E.^g_E2.*exp(-abs(E-E0).^g_E/dE^g_E).*gradient(E);
  if out_arg_type == 2
    IeOutput{i1} = Ie;
  end
  % Then we make the horizontal intensity variation of the
  % precipitation:
  I_hor = Imax * exp( -abs( ((y2D - y0)./dS).^2 + ...
                            ((x2D - x0)./dS).^2).^(g_x/2));
  % Then we make altitude profiles for all the emissions:
  for i2 = length(stns):-1:1,
    
    I_Z{i2} = Ie2H{i2}*Ie;
    % The altitude-horizontal variation of the volume emission
    % rates should just be the outer product of the two:
    for i3 = length(I_Z{i2}):-1:1,
      % This should make up a horizontal slice of the volume
      % emission rate of emission at 
      Ivh = I_Z{i2}(i3)*I_hor;
      Vem{i2}(:,:,i3) = Vem{i2}(:,:,i3) + Ivh;%{i2};
    end
    % keyboard
    
  end
  
end

err = 0;
for i1 = length(stns):-1:1,
  
  % Extract the the cut-out along selected cut
  currImg{i1}  = stns(i1).img;
  currProj{i1} = fastprojection(Vem{i1},...
                                stns(i1).uv,...
                                stns(i1).d,...
                                stns(i1).l_cl,...
                                stns(i1).bfk,...
                                [256 256],1,stns(i1).sz3d);
  currProj{i1} = conv2(currProj{i1},ones(3)/9,'same');
  % sum of square of Image difference - over the selected region of interest:
  err1 = sum( ( stns(i1).img(:) - currProj{i1}(:) ).^2.*(ImRois{i1}(:)==1) );
  err = err + err1;
  % keyboard
end

%%% This snippet is just an old example of how to bias parameters
%to be close to some prefered/physically sensible range of
%values. Potentially adapt to needs as necessary...
% $$$ if ~isempty(biasAmplitudes)
% $$$   err = err + sum(biasAmplitudes(:).*( Par(:) - biasVals(:) ).^2);
% $$$   err = err + 500*sum( ( 2 - I0(:,6) ).^5 .* ( I0(:,6) < 2) );
% $$$ end

if err < 0 | ~isfinite(err)
  keyboard
end
switch out_arg_type
 case 1 % Error
  res = err;
 case 2 % Vem and projections
  res.par = I0;
  res.err = err;
  res.IeOutput = IeOutput;
  res.Vem{1} = Vem{1};
  res.Vem{2} = Vem{2};
  res.currImg = currImg;
  res.currProj = currProj;
 otherwise
end
