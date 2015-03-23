function [ticks,tickn,tickv,tickm] = ASK_time_tick(StartTimeMJS,dTime,less)
% ASK_TIME_AXIS - suitable settings for time tick marks and labels.
% Inputs: mjs - start time of the plot, length - length in seconds
% Outputs: ticks, tickn, tickv, tickm. These should be passed to
%  plot as keywords, e.g. xtickn=tickn, xminor=tickm.
% The xrange of the plot should be from 0 to length. i.e. xran=[0,length]
% The x values of the plot should therefore be mjs-mjs0, where mjs0 is the
% first mjs value.

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies


major = [1.0/300.0,1.0/120.0,1.0/60, 1.0/30.0, 0.05, 0.1, 0.25, 0.5,1,2,5,10,15,30,60,120,180,240];% number of minutes per major tick
minor = [2,        5,        4,      2,        3,    6,   3,    6,  4,1,5, 5, 3, 3, 4,  4,  6,  8];% number of minor ticks
time_tick = dTime/60/5; % approximate number of minutes for each tick
if nargin > 2 && less
  time_tick = dTime/60/3;
end

opt = find( major <= time_tick, 1,'last');
if isempty(opt)
  opt = 1;
end

step = major(opt);


numb = floor(dTime/60./step);
[year,month,day,hour,minute,sec] = ASK_MJS_TT(StartTimeMJS);
mjs_Date = ASK_TT_MJS([year,month,day,0,0,0]);

start_t = StartTimeMJS - mjs_Date;
start   = ( floor( ( StartTimeMJS - mjs_Date )/60./step )+1 )*step*60;
tickv   = [0:numb]*step*60.0 + start; % findgen ???
ticks   = numb; % -1 removed, guessing at index from 1 instead of
                % from 0...


for i1 = 1:ticks,
  
  [year,month,day,hour,minute,sec] = ASK_MJS_TT(mjs_Date + tickv(i1));
  tickn{i1} = sprintf('%02d:%02d',hour,minute); % string(ho,mi,form='(i2.2,":",i02.2)');
  if (opt <= 8)
    tickn{i1} = sprintf('%02d:%02d:%02d',hour,minute,floor(sec)); % string(ho,mi,se, form='(i2.2,":",i02.2,":",i02.2)');
  end
  if (opt <= 2)
    tickn{i1} = sprintf('%02d:%02d:%05.2f',hour,minute,sec);  % string(ho,mi,se+0.001*ms, form='(i2.2,":",i02.2,":",f05.2)');
  end
end

tickv = tickv - start_t;
ddd = find(tickv > dTime);
count = length(ddd);
if (count > 0)
  tickv(ddd) = [];
end
tickm = minor(opt);

cAX = axis;
dT = cAX(2)-cAX(1);

set(gca,'xtick',ax(1)+dT/dTime*tickv(1:min(length(tickv),length(tickn))),...
        'xticklabel',tickn(1:min(length(tickv),length(tickn))))
