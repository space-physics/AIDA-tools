function is_true = in_ranges(t,t_ranges)
% IN_RANGES - True if T is in any of the T_RANGES intervalls
%   
% Calling:
%  is_true = in_ranges(t,t_ranges)
% Input:
%  t - array of numbers to search in
%  t_ranges - boundaries of ranges to check membership of elements
%             in t

%   Copyright © 2003 Bjorn Gustavsson <bjorn.gustavsson@irf.se>, 
%   This is free software, licensed under GNU GPL version 2 or later



if nargin ~= 2
  error('Wrong number of arguments')
end

if min(size(t_ranges)) == 1
  
  Tranges = reshape(t_ranges,2,[])';
  %This below should just be a simple reshape, just as the one above
  % for i = 1:length(t_ranges)/2,
  %   Tranges(i,1) = t_ranges(1+2*(i-1));%,[2 length(t_ranges)/2]);
  %   Tranges(i,2) = t_ranges(2*i);
  % end
  
else
  
  Tranges = t_ranges;
  
end
%Tranges
if length(t) > 1
  is_true = 0*t;
  for i1 = 1:length(Tranges(:,1)),
    is_true = is_true + ( Tranges(i1,1)<t & t<Tranges(i1,2) );
  end
else
  is_true = any( Tranges(:,1)<t & t<Tranges(:,2));
end
