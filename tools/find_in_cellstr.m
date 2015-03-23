function ind_true = find_in_cellstr(in_str,in_cellstr)
% FIND_IN_CELLSTR - search for string in cellstrings
%   
% Calling:
%   ind_true = find_in_cellstr(in_str,in_cellstr)

ind_true = [];
j1 = 1;
for i1 = 1:length(in_cellstr),
  
  if ( any(findstr(in_str,in_cellstr{i1})) )
    ind_true(j1) = i1;
    j1 = j1+1;
  end
  
end
