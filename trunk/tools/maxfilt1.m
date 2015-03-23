function Iout = maxfilt1(Iin,reg)
% maxfilt1 - one dimensional sliding max-filter
% 
% Calling:
%   Iout = maxfilt1(Iin,reg)
% Input:
%   Iin - input array (N1 x N2), any type max can handle
%   reg - size of neighbourhood to take the sliding maximum value
%         from
% Output:
%   Iout - output array (N1 x N2) where Iout(i1,i2) is the maximum
%          value of Iin(i1+(-floor(reg/2+1):floor(reg/2+1)),i2)
%
% Not much error checking is done, function also does not allow for
% taking the maximum filter along dimension 2.

regSize = floor((reg+1)/2);

Iout = Iin;
for i1 = size(Iin,1):-1:1,
  Iout(i1,:) = max(Iin(max(1,i1-regSize):min(size(Iin,1),i1+regSize),:));
end
