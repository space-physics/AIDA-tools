function [BadTimes,sis] = spc_cal_bad_times(IDSTARS,time_s,filtnr,optpar,OPTS)
% SPC_CAL_BAD_TIMES - Screen out bad time periods for each star
% due to clouds or other problems. The function will plot the
% stellar intensities as a function of time, if there is periods
% where the intensities are noticeably reduced it is possible to
% de-select those time-periods, for each individual star.
% 
% Calling:
%  [BadTimes,sis] = spc_cal_bad_times(IDSTARS,time_s,filtnr,optpar,OPTS)
% Inputs:
%  IDSTARS - Identified stars, as produced by SPC_SCAN_FOR_STARS
%  TIME_S  - Times for corresponding stars
%  FILTNR  - Filter index for corresponding stars
%  OPTPAR  - Optical parameters of imager (See CAMERA)
%  OPTS    - Options struct, filed 'clrs', default 'grmmkbcccc'
% 
% Output:
%  BadTimes - bad time periods for each star,
%  SIS - star index (?) for corresponding stars

%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later



% Set some colours
clrs = ['g','r','m','c','k','b','c','c','c','c']';
% If the user supplies a definition of what colours to use for each
% filter use them:
if nargin>=5 & isfield(OPTS,'clrs')
  clrs = OPTS.clrs;
end
% Adapt for colours defined as char-array or rgb-array.
if ischar(clrs(1))
  clrsIDX = 1;
else
  clrsIDX = 1:3;
end
% get the unique Bright star catalog number we have
B = unique(IDSTARS(:,9));
% And the unique filters we have
uF = unique(filtnr);

% work with each star in turn.
BadTimes{length(B)} = []; % Initialize 
sis = 1:length(B);
for si = 1:length(B),
  
  clf
  subplot(3,1,1)
  title([' BSNR = ',num2str(B(si))])
  hold on
  subplot(3,1,2)
  hold on
  subplot(3,1,3)
  hold on
  
  ax311Max = 0;
  is = (IDSTARS(:,9)==B(si)&IDSTARS(:,4)>0);
  CurrStar = IDSTARS(is,:);
  CurrTime = time_s(CurrStar(:,1));
  for iF = 1:length(uF),
    CurFStar = CurrStar(uF(iF)==filtnr(CurrStar(:,1)),:);
    CurFTime = CurrTime(uF(iF)==filtnr(CurrStar(:,1))');
    subplot(3,1,1)
    plot(CurFTime,CurFStar(:,5),'.','color',clrs(iF,clrsIDX))
    subplot(3,1,2)
    plot(CurFTime,CurFStar(:,6),'.','color',clrs(iF,clrsIDX))
    subplot(3,1,3)
    plot(CurFTime,CurFStar(:,7),'.','color',clrs(iF,clrsIDX))
    if length(CurrStar) > 100
      sCFS = sort(CurFStar(:,5));
      ax311Max = max(ax311Max,sCFS(end-5)*1.2);
    end
  end
  
  subplot(3,1,1)
  if ax311Max > 0
    ax1 = axis;
    axis([ax1(1:3),ax311Max])
  end
  grid on
  try
    timetick
  catch
  end
  ylabel('Peak I')
  subplot(3,1,2)
  grid on
  try
    timetick
  catch
  end
  ylabel('Total I')
  title(['star = ',num2str(si),', out of ',num2str(length(B)),' stars'])
  subplot(3,1,3)
  grid on
  try
    timetick
  catch
  end
  xlabel('Click the right mouse button if there are bad time periods to select for exclusion','fontsize',15)
  ylabel('Total I_{Gaussian}')
  % pause
  % just plotting commands 
  
  [Q1,Q2,Qb] = ginput(1);
  if ~isempty(Qb) & Qb == 3
    subplot(3,1,3)
    title('Select start and stop times of bad time periods to exclude...','fontsize',15)
    xlabel('...with any mouse button, end with "return" key','fontsize',15)
    [qwt,qwey,qweb] = ginput;
    BadTimes{si} = qwt';
  end
  
end

