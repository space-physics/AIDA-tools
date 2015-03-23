function Wb = make_depend_from_inmem(filename_pattern)
% MAKE_DEPEND_FROM_INMEM - Extracts currently used functions with
%   filename_pattern in the full path to the file.
%   
% Example:
%   filename_pattern = 'home/usrnm'
%   Wb = make_depend_from_inmem(filename_pattern);

M = inmem;
Wb = {};
for i = length(M):-1:1,
  
  W{i} = which(M{i});
  
end
W = sort(W);
for i = 1:length(W),
  a = strfind(W{i},filename_pattern);
  if ~isempty(a)
    Wb{end+1} = W{i};
  end
  a = [];
end
Wb = str2mat(Wb);
