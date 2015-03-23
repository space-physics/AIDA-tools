function SkMp = s_preferences(SkMp,whichP)
% PREFERENCES - set preferences for starcal and skymap
%   
% Calling:
% SkMp = s_preferences(SkMp,whichP)

%   Copyright © 2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

Pzoom = 1;
Pplot = 2;
Pcolor= 3;
Psize = 4;
Pcalib= 5;

title='Preferences for starcalibration';
lineNo=1;
PROMPT={'Side length of zoom region [dl] (pixels):',...
	'Plot-size of stars:',...
	'Plot colour of stars:',...
	'Size of star-point-mark:',...
	'Colour of star-point-mark:',...
	'Size of error-point-mark:',...
	'Colour of error-point-mark:',...
	'Length scaling of error arrows:',...
	'Colour of error arrows:',...
	'Penalty scaling of optpar pseudolocking:',...
	'Max number of stars for autocal:',...
	'Size range for stars (pixels) [autocal]:',...
	'Huber-tanh-norm length [autocal]:'};
DEF={num2str(SkMp.prefs.sz_z_r),...
     num2str(SkMp.prefs.pl_sz_st),...
     ['[',num2str(SkMp.prefs.pl_cl_st),']'],...
     num2str(SkMp.prefs.sz_st_pt),...
     SkMp.prefs.cl_st_pt,...
     num2str(SkMp.prefs.sz_er_pt),...
     SkMp.prefs.cl_er_pt,...
     num2str(SkMp.prefs.sc_er_ar),...
     SkMp.prefs.cl_er_ar,...
     num2str(SkMp.prefs.pscoptlck),...
     num2str(SkMp.prefs.mx_nr_st),...
     ['[',num2str(SkMp.prefs.sz_rg_st),']'],...
     num2str(SkMp.prefs.hu_nm_ln)};

switch whichP
 case Pzoom
  indx = 1;
  prompt = PROMPT(indx);
  def = DEF(indx);
  answer=inputdlg(prompt,title,lineNo,def);
  SkMp.prefs.sz_z_r = str2num(char(answer{1}));
  
 case Pplot
  indx = 2:9;
  prompt = PROMPT(indx);
  def = DEF(indx);
  answer=inputdlg(prompt,title,lineNo,def);
  
  SkMp.prefs.pl_sz_st = str2num(char(answer{1}));
  SkMp.prefs.pl_cl_st = str2num(char(answer{2}));
  SkMp.prefs.sz_st_pt = str2num(char(answer{3}));
  SkMp.prefs.cl_st_pt = (char(answer{4}));
  SkMp.prefs.sz_er_pt = str2num(char(answer{5}));
  SkMp.prefs.cl_er_pt = (char(answer{6}));
  SkMp.prefs.sc_er_ar = str2num(char(answer{7}));
  SkMp.prefs.cl_er_ar = (char(answer{8}));
  
 case Pcolor
  indx = [3 5 7 9];
  prompt = PROMPT(indx);
  def = DEF(indx);
  answer=inputdlg(prompt,title,lineNo,def);
  
  SkMp.prefs.pl_cl_st = str2num(char(answer{1}));
  SkMp.prefs.cl_st_pt = (char(answer{2}));
  SkMp.prefs.cl_er_pt = (char(answer{3}));
  SkMp.prefs.cl_er_ar = (char(answer{4}));
  
 case Psize
  indx = [2 4 6 8];
  prompt = PROMPT(indx);
  def = DEF(indx);
  answer=inputdlg(prompt,title,lineNo,def);
  
  SkMp.prefs.pl_sz_st = str2num(char(answer{1}));
  SkMp.prefs.sz_st_pt = str2num(char(answer{2}));
  SkMp.prefs.sz_er_pt = str2num(char(answer{3}));
  SkMp.prefs.sc_er_ar = str2num(char(answer{4}));
  
 case Pcalib
  prompt = PROMPT([10 11 12 13]);
  def = DEF([10 11 12 13]);
  answer=inputdlg(prompt,title,lineNo,def);
  
  SkMp.prefs.pscoptlck = str2num(char(answer{1}));
  SkMp.prefs.mx_nr_st = str2num(char(answer{2}));
  SkMp.prefs.sz_rg_st = str2num(char(answer{3}));
  SkMp.prefs.hu_nm_ln = str2num(char(answer{4}));

 otherwise
   SkMp = def_s_preferences(SkMp);
end
