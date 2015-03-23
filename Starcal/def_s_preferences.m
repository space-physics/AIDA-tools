function SkMp = def_s_preferences(SkMp)
% DEF_S_PREFERENCES - default preferences for starcal
%   
% "Private" function, not much use for a user to call this
% manually. The function is called from the GUI.
% Calling:
%  SkMp = def_s_preferences(SkMp)

%   Copyright ©  2002 by Bjorn Gustavsson <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

SkMp.prefs.sz_z_r = 10;        % Side length of zoom region [dl] (pixels)
SkMp.prefs.pl_sz_st = 10;      % Plot-size of stars
SkMp.prefs.pl_cl_st = [1 1 .6];% Plot colour of stars
SkMp.prefs.pl_cl_slst = 'g';	 % Plot colour of selected star
SkMp.prefs.pl_cl_slwn = 'r';	 % Plot colour of selection window
SkMp.prefs.sz_st_pt = 8;       % Size of star-point-mark
SkMp.prefs.cl_st_pt = 'r';     % Colour of star-point-mark
SkMp.prefs.sz_er_pt = 10;      % Size of error-point-mark
SkMp.prefs.cl_er_pt = 'r';     % Colour of error-point-mark
SkMp.prefs.sc_er_ar = 10;      % Length scaling of error arrows
SkMp.prefs.cl_er_ar = 'r';     % Colour of error arrows
SkMp.prefs.pscoptlck = 1e6;    % Penalty scaling of optpar pseudolocking
SkMp.prefs.mx_nr_st = 150;     % Max number of stars for autocal
SkMp.prefs.sz_rg_st = [.4 7];  % Size range for stars (pixels) [autocal] 
SkMp.prefs.hu_nm_ln = 16;      % Huber-tanh-norm length [autocal]
