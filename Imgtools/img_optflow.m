function varargout = img_optflow(I1,I2,OPS)
% IMG_OPTFLOW - optical-flow displacements with intensity-scaling adjustment
%   
% Calling:
%   OPS = img_optflow
%   [Xdisplacement,Ydisplacement,Idisplacement] = img_optflow(I1,I2,OPS)
%   AllParameters = img_optflow(I1,I2,OPS)
% Input:
%   I1  - Image #1, double [ NY x NX]
%   I2  - Image #2, double [ NY x NX]
%   OPS - optional options structure (the default options are
%         returned when IMG_OPTFLOW is called without input arguments)
% Output:
%   OPS - the default options
%   Xdisplacement - Tranformation matrix for horizontal points in
%                   image 1 (where image points linspace(1,NX,n) in
%                   image 1 should end up in image #2
%   Ydisplacement - Tranformation matrix for vertical points in
%                   image 1 (where image points linspace(1,NY,n) in
%                   image 1 should end up in image #2
%   Idisplacement - intensity scaling matrix.
%   AllParameters - a row-vector build with [Xdisplacement(:)',Ydisplacement(:)',Idisplacement(:)']
%                   that is easier to use for calling
%                   errFcnAuroralFlow
%  
% The morphing of image I1 is calculated as:
% 
%    I2p = Iscale.*interp2(I1,X,Y,'*linear');
%
% Where the X and Y matrices are calculated as:
%
%  X = interp2(xP0,yP0,xP,1:size(I1,2),[1:size(I1,1)]','*linear');
%  Y = interp2(xP0,yP0,yP,1:size(I1,2),[1:size(I1,1)]','*linear');
%  Iscale = interp2(xP0,yP0,Ip,1:size(I1,2),[1:size(I1,1)]','*spline');
% 
% Here yP0 and xP0 are simple plaid grids built according to:
% [xP0,yP0] = meshgrid(linspace(1,size(I1,2),n),linspace(1,size(I1,2),n))

%   Copyright � 20110830 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later



% Preform the spatial image transformation and scale the intensities:

%% First make default options struct:
dOPS.MaxGridSize = 2^6+1; % the grid sizes will refine according to
                          % 2^(n-1) + 1, i.e.: 2,3,5,9,17,33,65...
i1 = 1:(log2(dOPS.MaxGridSize-1)+1);
dOPS.TolX = 1./2.^(i1/2+1/2)/2; % Start with fairly coarse
                                % tolerances on the spatial shifts
                                % so that the minimization stops
                                % reasonably fast.
dOPS.XYregsize = 20./2.^(i1*2/3-2/3); % Start searching for best
                                      % spatial shifts in a
                                      % 20-by-20 pixel wide region
                                      % then reduce the size to
                                      % speed up the optimization
                                      % 20./2.^(i1/2-1/2);
dOPS.nrOfTries = 2;   % The number of times to start fminsearch if
                      % not reaching a 
%% If there is no input arguments 
if nargin == 0
  % then simply return the default options:
  varargout = {dOPS};
  return
end

%% If there is a user-supplied options struct merge that one ontop
% of the default one:
if nargin > 2
  dOPS = merge_structs(dOPS,OPS);
end

% Make the default options for fminsearc/fminsearchbnd:
fmsOPS = optimset('fminsearch');

% Make the default options for errFcnAuroralFlow
fOPS = errFcnAuroralFlow;
fOPS2.outputType = 2;

% Make the 1-D grids for all the number of gridsizes we need - Ok
% it is a bit excessive to do here, but you also know what they say
% about premature optimization...
for i1 = (log2(dOPS.MaxGridSize-1)+1):-1:1,
  x{i1} = linspace(1,size(I1,2),2^(i1-1)+1);
  y{i1} = linspace(1,size(I1,1),2^(i1-1)+1);
end

tic
FS = stoploop({'Stop, stop, it''s good enough', 'some time has elapsed'}) ;

% Make a first 2-D grid for making 
[X,Y] = meshgrid(x{1},y{1});
% the start-guess for the parameters to the optimization:
vP{1} = [X(:)',Y(:)',ones(size(X(:)'))];

% loop over finer and finer grids
for i1 = 1:(log2(dOPS.MaxGridSize-1)+1),
  
  % With possibly changing tolerances on the parameter variations:
  fmsOPS.TolX = dOPS.TolX(i1);
  % Make upper and lower bounds for the parameter spaces to
  % optimize over:
  minP = vP{i1};
  maxP = vP{i1};
  minP(1:1:2*length(vP{i1})/3) = minP(1:1:2*length(vP{i1})/3)-dOPS.XYregsize(i1);
  maxP(1:1:2*length(vP{i1})/3) = maxP(1:1:2*length(vP{i1})/3)+dOPS.XYregsize(i1);
  minP((2*length(vP{i1})/3+1):end) = minP((2*length(vP{i1})/3+1):end)*0.3;
  maxP((2*length(vP{i1})/3+1):end) = maxP((2*length(vP{i1})/3+1):end)*3;
  
  exitflag = 0;
  i2 = 1;
  while exitflag ~= 1 && i2 <= dOPS.nrOfTries(min(i1,length(dOPS.nrOfTries)))
    % Run the optimization - until a local minimum is reached
    % (exitflag == 1) or the number of tries has exceeded its
    % maximum:
    [vP{i1},fv(i1),exitflag] = fminsearchbnd(@(varpars) errFcnAuroralFlow(varpars,1:length(vP{i1}),vP{i1},I1,I2,sqrt(length(vP{i1})/3),fOPS),vP{i1},minP,maxP);
    i2 = i2+1;
  end
  [I2p] = errFcnAuroralFlow(vP{i1},1:length(vP{i1}),vP{i1},I1,I2,sqrt(length(vP{i1})/3),fOPS2);
  subplot(2,2,1)
  imagesc(I1)
  subplot(2,2,2)
  imagesc(I2)
  subplot(2,2,4)
  imagesc(I2p)
  subplot(2,2,3)
  imagesc(I2p-I2),caxis([-1 1]*0.2)
  dT(i1) = toc;
  pause(5)
  if FS.Stop() 
    break;
  end
  % Then make start guess for the next finer grid
  vP{i1+1} = parsOnrefinedGrid4AF(vP{i1},x{i1},y{i1},x{i1+1},y{i1+1}); 
  
end

FS.Clear();                                                        
clear FS


% $$$ xP0 = linspace(1,size(I1,2),nPoints);
% $$$ yP0 = linspace(1,size(I1,1),nPoints);
% $$$ % In 2-D <=> corner to corner
% $$$ [xP0,yP0] = meshgrid(xP0,yP0);
% $$$ 
% $$$ % make matrices for the mapping of [xP0,yP0] into I1
% $$$ xP = xP0;
% $$$ yP = yP0;
% $$$ Ip = xP;
% $$$ % And assign the corresponding parameters there
% $$$ xP(:) = Par(1:(nPoints^2));
% $$$ yP(:) = Par(nPoints^2+[1:(nPoints^2)]);
% $$$ Ip(:) = Par(2*nPoints^2+[1:(nPoints^2)]);


if nargout > 1 
  [Xdisplacement,Ydisplacement] = meshgrid(x{i1},y{i1});
  [X0,Y0] = meshgrid(x{i1},y{i1});
  Idisplacement = Ydisplacement;
  
  Xdisplacement(:) = vP{i1}(1:length(Xdisplacement(:)));
  Ydisplacement(:) = vP{i1}(length(Xdisplacement(:))+[1:length(Xdisplacement(:))]);
  Idisplacement(:) = vP{i1}(2*length(Xdisplacement(:))+[1:length(Xdisplacement(:))]);
  Xdisplacement = Xdisplacement - X0;
  Ydisplacement = Ydisplacement - Y0;
  varargout{1}  = Xdisplacement;
  varargout{2}  = Ydisplacement;
  varargout{3}  = Idisplacement;
  varargout{4}  = X0;
  varargout{5}  = Y0;
  
else
  varargout = vP;
end
% dT;