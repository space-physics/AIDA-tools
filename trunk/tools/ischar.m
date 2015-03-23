function TrueOrFalse = ischar(str)
% ISCHAR - return true if STR is a char-array
%   This is a compatibility insurance function. Mathworks is making
%   ISSTR obsolete, so I have replaced calls to ISSTR with ISCHAR;
%   however ISCHAR might not exist on older versions of matlab. So
%   this is included to cover that case.

%   Copyright © 2011 Bjorn Gustavsson <bjorn.gustavsson@irf.se>, 
%   This is free software, licensed under GNU GPL version 2 or later


TrueOrFalse = isstr(str);
