function [ticks,tickn,tickv,tickm] = ASK_time_axis(StartTimeMJS,dTime,less)
% ASK_TIME_AXIS - formated time onto the x-labels
%   
% Calling:
%    [ticks,tickn,tickv,tickm] = ASK_time_axis(StartTimeMJS,dTime,less)
% 
% Adapted from time_axis.pro, NOT TESTED WITH MUCH SUCCESS? Is used
% in ASK_keogram_overlayed.m!

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

major = [1/300,1/120,1/60, 1/30, 0.05, 0.1, 0.25, 0.5, 1,2,5,10,15,30,60,120,180,240];% number of minutes per major tick
minor = [2,        5,   4,    2,    3,    6,   3,   6, 4,1,5, 5, 3, 3, 4,  4,  6,  8];% number of minor ticks
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
tickv   = [0:numb]*step*60.0 + start;
ticks   = numb; % -1 removed, guessing at index from 1 instead of
                % from 0...
tickn{1} = '';

for i1 = 1:(ticks+1),
  
  [year,month,day,hour,minute,sec] = ASK_MJS_TT(mjs_Date + tickv(i1));
  tickn{i1} = sprintf('%02d:%02d',hour,minute);
  if (opt <= 8)
    tickn{i1} = sprintf('%02d:%02d:%02d',hour,minute,floor(sec));
  end
  if (opt <= 2)
    tickn{i1} = sprintf('%02d:%02d:%05.2f',hour,minute,sec);
  end
end
% whos tickn tickv
tickv = tickv - start_t;
ddd = find(tickv > dTime);
count = length(ddd);
% whos tickn tickv

if (count > 0)
  tickv(ddd) = [];
end
tickm = minor(opt);


t0 = axis;
t0 = t0(1);
tickv = t0 + tickv/3600;
set(gca,'xtick',tickv,'xticklabel',tickn)

% $$$ pro time_axis, mjs, length, ticks, tickn, tickv, tickm, less=less
% $$$ ;
% $$$ ; the procedure to make the correct settings for the time axis
% $$$ ; Inputs: mjs - start time of the plot, length - length in seconds
% $$$ ; Outputs: ticks, tickn, tickv, tickm. These should be passed to
% $$$ ;  plot as keywords, e.g. xtickn=tickn, xminor=tickm.
% $$$ ; The xrange of the plot should be from 0 to length. i.e. xran=[0,length]
% $$$ ; The x values of the plot should therefore be mjs-mjs0, where mjs0 is the
% $$$ ; first mjs value.
% $$$ ;
% $$$ ; Dan added keyword less 20/08/08, to help persuade the routine to make less tick marks
% $$$ ;
% $$$ ; Time axis setup
% $$$ ;
% $$$ major = [1.0/300.0d0,1.0/120.0d0,1.0/60.0d0, 1.0/30.0d0, 0.05, 0.1, 0.25, 0.5,1,2,5,10,15,30,60,120,180,240] ; number of minutes per major tick
% $$$ minor = [2,          5,          4,          2,    3,   6,    3,   6,4,1,5, 5, 3, 3, 4,  4,  6,  8] ; number of minor ticks
% $$$ timetick = length/60./5.  ; approximate number of minutes for each tick
% $$$ if keyword_set(less)
% $$$   timetick = length/60./3.
% $$$ end
% $$$ dd = where(major le timetick, count)
% $$$ if (count le 0)
% $$$   opt = 1 
% $$$ else
% $$$   opt = dd(count-1)
% $$$ end
% $$$ step = major(opt)
% $$$ numb = floor(length/60./step) +1
% $$$ mjs_tt, mjs,y,m,d,ho,mi,se,ms
% $$$ tt_mjs, y,m,d,0,0,0,0,mjs_d
% $$$ start_t = mjs-mjs_d
% $$$ start   = ( floor( (mjs-mjs_d)/60./step )+1 )*step*60.
% $$$ tickv   = findgen(numb)*step*60.0+start
% $$$ tickn   = strarr(numb)
% $$$ ticks   = numb-1
% $$$ 
% $$$ for i = 0:ticks,
% $$$   mjs_tt,mjs_d+tickv(i),y,m,d,ho,mi,se,ms
% $$$   tickn(i) = string(ho,mi,form='(i2.2,":",i02.2)');
% $$$   if (opt <= 7)
% $$$     tickn(i) = string(ho,mi,se, form='(i2.2,":",i02.2,":",i02.2)');
% $$$   end
% $$$   if (opt le 1)
% $$$     tickn(i) = string(ho,mi,se+0.001*ms, form='(i2.2,":",i02.2,":",f05.2)');
% $$$   end
% $$$ end
% $$$ 
% $$$ tickv = tickv - start_t;
% $$$ ddd = where(tickv gt length, count);
% $$$ if (count > 0)
% $$$   tickv(ddd) = length
% $$$   tickn(ddd) = ' '
% $$$ end
% $$$ tickm=minor(opt)
