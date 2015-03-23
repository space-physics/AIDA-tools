function [j_out] = fitsfindinheader(H,s)
% FITSFINDINHEADER finds string S in fitsheader H
% 
% Calling:
%  j = fitsfindinheader(H,s)


% Copyright Peter Rydesaeter

j_out  = [];%if not found return empty
ji = 1;
for i1 = 1:size(H,1)
  if findstr(lower(H(i1,:)), lower(s)),
    j_out(ji) = i1;
    ji = ji+1;
  end
end

