function [BT,sis] = spc_chk_if_bad_times(IDSTARS,time_s,filtnr,optpar,OPTS)
% SPC_CHK_IF_BAD_TIMES - Screen out bad time periods for each star
% due to clouds or other problems.
% 
% Calling:
%  [BT,sis] = spc_cal_bad_times(IDSTARS,time_s,filtnr,optpar,OPTS)
% Inputs:
%  IDSTARS - Identified stars, as produced by SPC_SCAN_FOR_STARS
%  TIME_S  - Times for corresponding stars
%  FILTNR  - Filter index for corresponding stars
%  OPTPAR  - Optical parameters of imager (See CAMERA)
%  OPTS    - Options struct, filed 'clrs', default 'grmmkbcccc'
% Output:
%  BT - bad time periods for each star,
%  SIS - star index (?) for corresponding stars


%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

B = unique(IDSTARS(:,9));
sis = [];
clrs = ['g','r','m','c','k','b','y','c','c','c'];
if nargin>=5 & isfield(OPTS,'clrs')
  clrs = OPTS.clrs;
end
clf

for si = 1:length(B),
  
  title(num2str(B(si)))
  hold on
  is = find(IDSTARS(:,9)==B(si)&IDSTARS(:,4)>0);
  
  % just plotting commands
  this_star = IDSTARS(is,6);
  this_time = time_s(IDSTARS(is,1));
  this_filters = filtnr(IDSTARS(is,1));
  this_uniq_filters = unique(this_filters);
  for iii = 1:length(this_uniq_filters),
    plot(this_time(this_filters==this_uniq_filters(iii)),...
         this_star(this_filters==this_uniq_filters(iii))/median(this_star(this_filters==this_uniq_filters(iii))),...
         [clrs(1+this_uniq_filters(iii)),'h'])
  end
  grid on
  timetick
  xlabel(['B = ',num2str(si),' BSNR(?) = ',num2str(B(si))])
  % just plotting commands 
  sis = [sis si];
  
end

[qwt,qwey,qweb] = ginput;

for i = 1:length(sis)
  BT(i,:) = qwt';
end
