function SP = fix_subplots_tomo(nrimages)
% FIX_SUBPLOTS_TOMO - determine useful subplot orientation
% 
% Calling:
%  SP = fix_subplots_tomo(nrimages)

%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

SP = [4,4];

if nrimages <=4
  SP = [2,2];
elseif nrimages <=6
  SP = [2,3];
elseif nrimages <=8
  SP = [2,4];
elseif nrimages == 9
  SP = [3,3];
elseif nrimages <=12 % Well prepared for limited expansion...
  SP = [3,4];
elseif nrimages <=16 % Well prepared for some expansion...
  SP = [4,4];
elseif nrimages <=20 % Well prepared for some not so limited expansion...
  SP = [5,4];
elseif nrimages <=25 % Well prepared for very not limited expansion...
  SP = [5,5];
end
