function J = gen_susan(I,w,OPS)
% gen_susan - Generalized SUSAN 2-D filtering
% SUSAN filtering with filter kernel W scaled with generalized
% Gaussian of intensity difference. Different prefiltering
% functions can be selected as well as width and exponent of the
% intensity scaling. GEN_SUSAN can produce filtering with
% caracteristics similar to wiener2 and medfilt2 and "everything
% inbetween"
% 
% Calling:
% J = gen_susan(I,w,OPS)
% 
% INPUT:
% I - 2-D matrix,
% W - Filter kernel, 
%       Default: ones(3)/9 
% OPS - options struct with fields:
%   TAU - width of intensity weighting. 1/eps -> filtering similar to
%         linear filter, std(I(:)) and I give results similar to
%         sigma-filter/wiener2. 
%         Default: 1, more useful values have to be set manually,
%         ex: 3 for std = 3*I.^0.5
%   GAMMA - shape factor, 2 <-> Gaussian, 1 <-> double sided
%         exponential, Wi(i,j) = W(i,j)*exp(-abs((Ip-I(i,j))/TAU).^GAMMA)
%         Default: 2
%   PRE_FILTER - [{'n'}|'f'|'w'|'m'|'s'], 'n' for none, 'f' for
%         FILTER2 (using same filter kernel), 'w' for
%         WIENER2 (using size(W) as neighbourhood region),
%         'm' for MEDFILT2, 's' for GEN_SUSAN, using same
%         filter kernel but others options default.
%   Kernelsize4pre_filter - size of kernel to use for prefiltering,
%         default is [3,3], set to [] to use fK.
%   INCLUDE_CENTER - [{1}|0] to include the center point or not to
%         include the center point, default is to include it.
%   PROPORTIONAL - 
% OUTPUT:
%   J - Filtered image, always of type DOUBLE; ro
%       with no input arguments GEN_SUSAN returns the default
%       OPS-struct. 
% 
% GEN_SUSAN is a generalization of "Smoothing over Univalue Segment
% Assimilating Nucleus" S.M. Smith and J.M. Brady. SUSAN - a new
% approach to low level image processing.  Int. Journal of Computer
% Vision, 23(1):45--78, May 1997.
% 
% No error checking.
%
% See also: WIENER2, MEDFILT2, FILTER2, SYMNIN_FILTER


%   Copyright © 20050129 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% If no input arguments give the OPS-struct with default options.
if nargin == 0
  
  J.gamma = 2;
  J.pre_filter = 'n';
  J.kernelsize4pre_filter = [3,3];
  J.tau = 1;
  J.proportional = 0.5;
  J.include_center = 0;
  return
  
end

% Default filter kernel
if nargin == 1 || isempty(w)
  w = ones(3)/9;
end

% If no OPS given creat a default one.
if nargin <= 2
  OPS = gen_susan;
else  % If there are an OPS-struct complete it with defaults for
      % missing fields.
  if ~isfield(OPS,'gamma')
    OPS.gamma = 2;
  end
  if ~isfield(OPS,'tau')
    OPS.tau = 1;  % Pretty useless value but there has to be something...
  end
  if ~isfield(OPS,'pre_filter')
    OPS.pre_filter = 'n';
  end
  if ~isfield(OPS,'kernelsize4pre_filter')
    OPS.kernelsize4pre_filter = [3,3];
  end
  if ~isfield(OPS,'include_center')
    OPS.include_center = 0;
  end
  if ~isfield(OPS,'proportional')
    OPS.proportional = 0.5;
  end
end

class0 = class(I);
I = double(I);

regsize = size(w);

% Constant extrapolation at the edges. Higher order extrap too
% complicated and since there is a need for filtering there should
% be some noise and that makes higher order extrapolation even worse?
I_internal = I([ones(1,ceil((regsize(1)-1)/2)) 1:end size(I,1)*ones(1,(regsize(1)-1)/2)],...
               [ones(1,ceil((regsize(2)-1)/2)) 1:end size(I,2)*ones(1,(regsize(2)-1)/2)]);

% Pre-filtering
switch OPS.pre_filter
 case 'f'
  if isempty(OPS.kernelsize4pre_filter)
    %I_internal = filter2(w,I_internal);
    I = filter2(w,I);
  else
    W = ones(OPS.kernelsize4pre_filter);
    W = W/sum(W(:));
    %I_internal = filter2(W,I_internal);
    I = filter2(W,I);
  end
 case 'w'
  try 
    if isempty(OPS.kernelsize4pre_filter)
      %I_internal = wiener2(I_internal,size(w));
      I = wiener2(I,size(w));
    else
      %I_internal = wiener2(I_internal,OPS.kernelsize4pre_filter);
      I = wiener2(I,OPS.kernelsize4pre_filter);
    end
  catch
    warning('susan:nonexistinprefilter',...
            'Could not find WIENER2 for SUSAN prefiltering')
  end
 case 'm'
  try 
    if isempty(OPS.kernelsize4pre_filter)
      %I_internal = medfilt2(I_internal,size(w));
      I = medfilt2(I,size(w));
    else
      %I_internal = medfilt2(I_internal,OPS.kernelsize4pre_filter);
      I = medfilt2(I,OPS.kernelsize4pre_filter);
    end
  catch
    warning('susan:nonexistinprefilter',...
            'Could not find MEDFILT2 for SUSAN prefiltering')
  end
 case 's'
  if isempty(OPS.kernelsize4pre_filter)
    %I_internal = gen_susan(I_internal,w);
    I = gen_susan(I,w);
  else
    W = ones(OPS.kernelsize4pre_filter);
    W = W/sum(W(:));
    %I_internal = gen_susan(I_internal,W);
    I = gen_susan(I,W);
  end
 otherwise
  % sit quiet and happy
end

[Iy,Ix] = size(I);

% Initialization
J = 0;
S_W = 0;


%% Filtering
%          sy,sx
%          ___
%         \
% J(y,x) = >  I(y+i-sy/2,x+j-sx/2)*W(i,j)*exp(-|Ip(y,x)-I(y+i-sy/2,x+j-sx/2)|^gamma/(tau*I(y+i-sy/2,x+j-sx/2))^gamma)
%         /___
%
%         i,j = 1,1
%        -------------------------------------------------------------------------------------
%          sy,sx
%          ___
%         \
%          > W(i,j)*exp(-|Ip(y,x)-I(y+i-sy/2,x+j-sx/2)|^gamma/(tau*I(y+i-sy/2,x+j-sx/2))^gamma)
%         /___
%
%         i,j = 1,1
%
%
for i1 = 1:regsize(1),
  
  for j2 = 1:regsize(2),
    
    if OPS.include_center==0 && abs(i1-(regsize(1)+1)/2)<eps  && abs(j2-(regsize(2)+1)/2)<eps 
      % then do not include that point (center point)
    else
      WI = max(realmin,...
               exp( - abs((I-I_internal(i1:(i1-1+Iy),j2:(j2-1+Ix)))./...
                          (abs(max(1,I)).^OPS.proportional.*OPS.tau)).^OPS.gamma ));
      W = w(1+end-i1,1+end-j2)*WI;
      J = J+I_internal(i1:(i1-1+Iy),j2:(j2-1+Ix)).*W;
      S_W = S_W + W;
    end
  end
  
end

% Trapping of error due to inf/nan in S_W. This can occur for cases
% where the image intensity varies too much from the center
% point. This is just a QD-HACK!
% Todo: Test this infnan avoiding problem - gen_susan
S_W(~isfinite(S_W(:))) = 1; 
J = J./S_W;
J = cast(J,class0);
