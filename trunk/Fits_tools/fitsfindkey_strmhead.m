function [j_out] = fitsfindkey_strmhead(H,S)
% fitsfindkey_strmhead - Searches a FITS header H for keyword S
% 
% Calling:
%  [J] = fitsfindkey_strmhead(H,S)

% Copyright Peter Rydesaeter

j_out=[];%if not found return empty
ji = 1;
for i1 = 1:size(H,1)
  if findstr(lower(H(i1,1:12)), lower(S)),
    j_out(ji) = i1;
    ji = ji+1;
  end
end

