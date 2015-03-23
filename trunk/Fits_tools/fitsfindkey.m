function [i] = fitsfindkey(V,S)
% fitsfindkey - Searches a FITS header V for keyword S
% 
% Calling:
%  [i] = fitsfindkey(V,S)

for i = 1:length(V)
  if strcmp(V{i}, S),
    return;
  end
end
i=0;%if not found return 0

