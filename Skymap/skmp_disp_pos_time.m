function skmp_disp_pos_time(SkMp)
% SKMP_DISP_POS_TIME - extracts position and time from SkMp
% 
% Calling:
%   skmp_disp_pos_time(SkMp)
% Input:
%   SkMp - the skymap/starcal struct.


%   Copyright � 1999 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

r1 = sprintf('\nPos  : %0.2f, %0.2f',SkMp.pos0(1),SkMp.pos0(2));
r2 = sprintf('Time : %4.0f-%2.0f-%2.0f %2.0f:%2.0f:%2.2f\n',SkMp.tid0(:));

% disp(str2mat(r1,r2))
disp(char(r1,r2))
