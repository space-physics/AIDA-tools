function ASK_keo_autoprint(spPos,outputformat)
% ASK_KEO_AUTOPRINT - 
%   
% Calling:
%   ASK_keo_autoprint(spPos,outputformat)
% Input:
%  spPos        - subplot position of axis to take xticklabels from
%  outputformat - string for choosing output format:
%                 [ {'png'} | 'eps' | 'both' ], the default is to
%                 just print the png files.
% 

% Copyright B Gustavsson 20101119 <bjorn@irf.se>
% This is free software, licensed under GNU GPL version 2 or later

if nargin == 0
  % Then we just take a chance and guess that there is a
  % subplot(5,1,1) with time-ticks on the x-axis!
  subplot(5,1,1)
else
  subplot(spPos(1),spPos(2),spPos(3))
end
if nargin < 2
  outputformat = 'png';
end

% Extract the (time-)ticklabel on the x-axis:
TH = get(gca,'xticklabel');

% Clean out ":" from the first and last ticklabel:
TH{1} = strrep(TH{1},':','');
TH{end} = strrep(TH{end},':','');

% Create eps and png-filenames:
fname1 = [TH{1},'-',TH{end},'-01.eps'];
fname2 = [TH{1},'-',TH{end},'-01.png'];

orient tall

% Print out the figure to the files:
switch outputformat
 case 'png'
  print('-dpng','-painters',fname2)
 case 'eps'
  print('-depsc2','-painters',fname1)
 case 'both'
  print('-depsc2','-painters',fname1)
  print('-dpng','-painters',fname2)
 otherwise
  disp(['Unknown output format given: ',outputformat])
  disp('I''m not sure what to do but I'' pass it along to print')
  disp('and hope that she knows what to do')
  fname = [TH{1},'-',TH{end},'-01'];
  print(outputformat,'-painters',fname)
end
