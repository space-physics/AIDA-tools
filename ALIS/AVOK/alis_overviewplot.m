function alis_overviewplot(stn,az,ze,clrs,time_str)
% ALIS_OVERVIEWPLOT - graphics of the visible volumes and collour
% for images taken at time TIME_STR
%
% Calling:
% alis_overviewplot(stn,az,ze,clrs,time_str)
% 
% Input:
%   STN - Integer array of ALIS station numbers [1xN].
%    AX - Azimuth angle array [1xN], in degrees, clockvise from north
%    ZE - Zenith angle array [1xN], in degrees
%  CLRS - char array with valid colour chars [1xn], in 'bcgkmry' or
%         [1x3] double array elements from 0-1
% TIME_STR - string with observation time to label the overview


%   Copyright © 20050111 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


warning off

xmax = 100;
ymax = 100;
xmin = -100;
ymin = -100;

ap = [0   0  0
      64.14218725650279   -31.86799805059328  -0.4021440345184266
      53.13179754255706   21.58681354721001  -0.2578326940640405
      14.80937274138702   -56.36541170065802  -0.2662535704565858
      -65.07707331579783   57.72751986387349  -0.5932546375529117
      -58.9199195880307   2.001795856330272  -0.2724597759225365
      .5   3  0
      0 0 0
      0 0 0
      40 90 -.6
      -2 168 -.5
     ];

for i = 1:length(stn)
  
  if iscell(clrs)
    vvops.clrs = clrs{i};
  elseif min(size(clrs)) > 1
    vvops.clrs = clrs(i,:);
  elseif isnumeric(clrs)
    vvops.clrs = clrs;
  elseif isstr(clrs)
    vvops.clrs = clrs;
  else
    vvops.clrs = 'k';
  end
  
  qw = alis_visiblevol(stn(i),az(i),ze(i),30,80,0,vvops);
  vax = axis;
  drawnow
  grid off
  
end

plot(vax([1 2 2 1 1]),vax([3 3 4 4 3]),'k')
set(gca,'xtick',[])
set(gca,'ytick',[])

if isstr(time_str)
  ylabel(time_str,'fontsize',10)
else
  ylabel(sprintf('%02d:%02d:%02d',time_str(4),time_str(5),time_str(6)),'fontsize',10)
end
