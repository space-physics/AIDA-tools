function varargout = errFcnAuroralFlow(varpars,ind4v_p,par0,I1,I2,nPoints,OPS)
% errFcnAuroralFlow - error function for auroral motion estimate
% 
% This function calculates the total square error between one
% skew-transformed intensity scaled image and anotother
% image. Under the conditions that the images of the same slowly
% evolving scene the transformation that minimizes the difference
% is the motion-field. This is intended for auroral imaging with
% time-resolution with the same time-scales as the motion of
% auroral structures. The intensity scaling of the skew-transformed
% image makes this method capable of handling cases where the
% brightness of auroral structures varies with time.
%
% Calling:
%  err = errFcnAuroralFlow(varpars,ind4v_p,par0,I1,I2,nPoints,OPS)
%  [I2p] = errFcnAuroralFlow(pars,varpars,par0,I1,I2,nPoints,OPS)
%  OPS = errFcnAuroralFlow
% 
% Input:
% varpars - parameters for varying during optimization
% ind4v_p - indices for varpars
% par0    - parameters for skew-n-intensity transformation,
%           [Xp, Yp, Ip] (1 x 3*nPoints^2). The first third will be
%           put into the matrix for the x-coordinate
%           transformation, the middle third will be put into the
%           matrix for the y-coordinate transformation. (These
%           transformations will make a spatially shift, rotation
%           and skewing transformation.) The last third will be
%           made into an intensity scaling matrix - that will be
%           used to scale the image intensity. The
%           "varpars,ind4v_p,par0" pattern makes it possible to
%           select any subset of the parameters to minimize over,
%           this should be equalt to subspace optimization.
% I1      - Image 1 (N x M), this image will be skew-intensity
%           transformed (the minimization will find the
%           transformation that makes the transformation of I1 as
%           close to I2 as possible.)
% I2      - Image (N x M)
% nPoints - number of points along each dimension of the Xp, Yp,
%           and Ip.
% OPS     - Options structure, with fields:
%           outputType (1 - error (default), 2 - skew-intensity
%           transformed I1, 3 - Xp, Yp, Ip - the low-resolution
%           transformation and scaling matrices, 4 - X, Y, Iscale
%           the full-resolution transformation and scaling matrices.)
% 
% This function could very well be called in a sequence with
% increasing number of points for the transformation matrixes -
% that way the first minimization should find the best average
% large-scale translationkeyboard-rotation skweing, while consequtive calls
% with larger number of points in the transformation matrices will
% distort I1 on smaller and smaller spatial scales.

% Copyright © Bjorn Gustavsson 20110306
% GNU copyleft 3.0 or later applies

% First create the default options struct
dOPS.outputType = 1;

% In case function called without input arguments, return default
% options struct.
if nargin < 1
  varargout{1} = dOPS;
  return
end
% If OPS in input parameters 
if nargin > 6
  % Cat the default and user-options structs together, with
  % precedence for user options.
  dOPS = catstruct(dOPS,OPS);
end
Par = par0;
% Just put the varpars into their proper positions
Par(ind4v_p) = varpars;

% Coordinates in I1p (from edge to edge)
xP0 = linspace(1,size(I1,2),nPoints);
yP0 = linspace(1,size(I1,1),nPoints);
% In 2-D <=> corner to corner
[xP0,yP0] = meshgrid(xP0,yP0);

% make matrices for the mapping of [xP0,yP0] into I1
xP = xP0;
yP = yP0;
Ip = xP;
% And assign the corresponding parameters there
xP(:) = Par(1:(nPoints^2));
yP(:) = Par(nPoints^2+[1:(nPoints^2)]);
Ip(:) = Par(2*nPoints^2+[1:(nPoints^2)]);

% Interpolate these mappings to full image size:
X = interp2(xP0,yP0,xP,1:size(I1,2),[1:size(I1,1)]','*linear');
Y = interp2(xP0,yP0,yP,1:size(I1,2),[1:size(I1,1)]','*linear');
% Do the same for the intensity scaling
Iscale = interp2(xP0,yP0,Ip,1:size(I1,2),[1:size(I1,1)]','*spline');

% Preform the spatial image transformation and scale the intensities:
I2p = Iscale.*interp2(I1,X,Y,'*linear');
%keyboard
% Calculate the sum of square error for optimization:
err = sum( ( I2p(isfinite(I2p(:))) - I2(isfinite(I2p(:)))).^2 ) + ...
      sum(~isfinite(I2p(:)));

switch dOPS.outputType
 case 1
  varargout{1} = err;
 case 2
  I2p(~isfinite(I2p(:))) = 0;
  varargout{1} = I2p;
 case 3
  varargout{1} = xP;
  varargout{2} = yP;
  varargout{3} = Ip;
 case 4
  varargout{1} = X;
  varargout{2} = Y;
  varargout{3} = Iscale;
 otherwise
  varargout{1} = err;
end
%keyboard
