function SkMp = revert_optpar(SkMp)
% REVERT_OPTPAR - revert optical parameters to initial guess
%   
% Calling:
% SkMp = revert_optpar(SkMp)

% ATTEMPTED: Rephrased revert_optpar into fcn!

%   Copyright © 2007 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

SkMp.optpar = SkMp.previous_optpar;
SkMp.optmod = SkMp.previous_optmod;
optpar = SkMp.optpar;
SkMp.oldfov = 0;
set(SkMp.ui3(3),'value',optpar(3))
set(SkMp.ui3(1),'value',-optpar(4))
set(SkMp.ui3(4),'value',180/pi*atan(1/2/optpar(2)))
set(SkMp.ui3(2),'value',optpar(5))
[SkMp] = updstrpl(SkMp);
