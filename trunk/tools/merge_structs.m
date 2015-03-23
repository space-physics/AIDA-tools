function S_out = merge_structs(S1,S2)
% MERGE_STRUCTS - Merge all fields of S2 into S1.
%   


S_out = S1;

fields2 = fieldnames(S2);
% for curr_field = [fields2(:)'],
for curr_field = fields2(:)',  
  S_out = setfield(S_out,curr_field{:},getfield(S2,curr_field{:}));
end
