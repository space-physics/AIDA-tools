function th = ASK_print_dat(time_mjs,FormatNoOrString,OPS)
% ASK_PRINT_DAT - prints the date corresponding to a modified
% Julian second value in the lower left corner of the current
% axes.
% 
% Calling:
%   th = ASK_print_dat(time_mjs,FormatNoOrString)
% Input:
%   time_mjs - Modified Julian time, as returned from ASK_TT_MJS
%   FormatNoOrString - Date/time format string - see DATESTR
% Output:
%   th - handle to the text object.
% 
% SEE also: ASK_TT_MJS, DATESTR

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

dOPS.txtcolour = [0 0 0];
dOPS.txtpos = [];
dOPS.txtXYT = 'T';
dOPS.fontsize = 14;
if nargin == 0
  th = dOPS;
  return
end
if nargin > 2
  dOPS = merge_structs(dOPS,OPS);
end
if nargin == 1
  str = ASK_dat2str(time_mjs,'yyyy-mm-dd');
else
  str = ASK_dat2str(time_mjs,FormatNoOrString);
end

if isempty(dOPS.txtpos)
  ax = axis;
  txtpos = [ax(1)+0.05*(ax(2)-ax(1)),ax(3)+0.05*(ax(4)-ax(3))];
else
  txtpos = dOPS.txtpos;
end
switch dOPS.txtXYT
 case 'T'
  th = title(str,'fontsize',dOPS.fontsize,'color',dOPS.txtcolour);
 case 'Y'
  th = xlabel(txtpos(1),txtpos(2),str,'fontsize',dOPS.fontsize,'color',dOPS.txtcolour);
 case 'X'
  th = ylable(txtpos(1),txtpos(2),str,'fontsize',dOPS.fontsize,'color',dOPS.txtcolour);
 otherwise
  if isempty(dOPS.txtpos)
    ax = axis;
    txtpos = [ax(1)+0.05*(ax(2)-ax(1)),ax(3)+0.05*(ax(4)-ax(3))];
  else
    txtpos = dOPS.txtpos;
  end
  th = text(txtpos(1),txtpos(2),str,'fontsize',dOPS.fontsize,'color',dOPS.txtcolour);
end
