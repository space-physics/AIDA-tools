function timetick(x)
% TIMETICK - change axis-labels to time/date format. Clever choice
% of format used from axis-lims
%
% Ingemar Häggström


if nargin==0
 x='x';
elseif strcmp(x,'off')
 set(gca,'xtickmode','auto','xticklabelmode','auto')
 return
end
tick=[x 'tick']; xt=get(gca,tick); dx=xt(2)-xt(1); nxt=length(xt);
xl=get(gca,[x 'lim']);

axsiz = get(gca,'position');
if strcmp(x,'x')
  goodmax_nticks = max(round(11/.775*axsiz(3)),2);
elseif strcmp(x,'y')
  goodmax_nticks = 11;
end  

if xl(2)-xl(1)>5
 dx=24; xt=[];
 while length(xt)<goodmax_nticks %%%11
  xt=ceil(xl(1)/dx)*dx:dx:xl(2);
  if dx==24, dx=12;
  elseif dx==12, dx=8;
  elseif dx==8, dx=6;
  elseif dx==6, dx=4;
  elseif dx==4, dx=3;
  elseif dx==3, dx=2;
  elseif dx==2, dx=1;
  else
    break
  end
 end
else
 dx=1/60; xt=ceil(xl(1)/dx)*dx:dx:xl(2);
 while length(xt)>goodmax_nticks  %%%11
  if dx==1/60, dx=1/30;
  elseif dx==1/30, dx=1/12;
  elseif dx==1/12, dx=1/6;
  elseif dx==1/6, dx=.25;
  elseif dx==.25, dx=1/3;
  elseif dx==1/3, dx=.5;
  elseif dx==.5, dx=1;
  else
    break
  end
  xt=ceil(xl(1)/dx)*dx:dx:xl(2);
 end
end

set(gca,tick,xt,[tick 'mode'],'man')
h=fix(xt-floor(xt/24)*24+.000001);
for k=1:length(xt)
 if dx<1
  xtk=xt(k)+.000001;
  m=round((xtk-floor(xtk))*60);
  nt(k,:)=sprintf('%02.0f%02.0f',h(k),m);
 else
  nt(k,:)=sprintf('%02.0f',h(k));
 end
end
set(gca,[tick 'label'],nt,[tick 'labelmode'],'man')
