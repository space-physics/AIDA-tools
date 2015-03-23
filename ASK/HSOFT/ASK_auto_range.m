function auto_range = ASK_auto_range(z,alpha,log_it,low,high)
% ASK_AUTO_RANGE - returns an array of automatic range 
% for the intensity calibration
% 
% keyword discard sets the range to be discarded (the extremes)
%  i.e. If discard is set to 0.1, the top 10% and bottom 10% will be
%       discarded before calculating the range. Default is 0.2.
% keyword low causes the low values to be emphasized
% keyword high causes the high values to be emphasized
% 
% Input is z (the data array)
% 
% Calling:
%   a_range = ASK_auto_range(z,alpha,log_it,low,high)
% Input:
%   z - data array. Real.
%   alpha - fraction to trim away from each end of the intensity
%           histogram. 
%   log_it  - limit the intensity range to be between [1/1e3 1]*highval
%             (optional flag)
%   low     - flag, if set to 1 then min(z(:)) is returned as lower
%             end of a_range
%   high    - flag, if set to 1 then max(z(:)) is returned as upper
%             end of a_range


% Modified from auto_range.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

if nargin == 1 | isempty(alpha)
  alpha = 0.2;
else
  alpha = min(1/2,max(0,alpha));
end
if alpha == 1/2
  auto_range=median(z(:))*[1,1];
else
  
  D = sort(z(z(:)>-1e29));
  n = length(D);
  highval = D(round(end-n*alpha));
  lowval = D(round(n*alpha));
  
  if nargin > 3 & ~isempty(low) & low
    lowval = D(1);
  end
  if nargin > 4 & ~isempty(high) & high
    highval = D(end);
  end
  if nargin > 2 & ~isempty(log_it) & log_it & (lowval <= 0)
    lowval = highval/1e3;
  end
  auto_range=[lowval, highval];
end
