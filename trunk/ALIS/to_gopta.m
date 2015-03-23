function OK = to_gopta(experiment_name,stations,start_stop,cycle_lengths,filter_seq,postitions,exptimes,img_intervals,GT,ops)
% TO_GOPTA - Produce ALIS gopta files (experiment control files)
% 
% THIS IS OUTRDATED! Worked for an earlier version of gopta. This
% should be updated!
% TODO: Update this to the current version of gopta.
%
% Calling:
% OK = to_gopta(experiment_name,stations,start_stop,cycle_lengths,filter_seq,postitions,exptimes,img_intervals,GT,ops)
%
% Input:
%   EXPERIMENT_NAME - name of experiments, string 
%   STATIONS - stations to be used in the experiment, cell array [1xN]
%              ex: {'Abisko','Kiruna','bus'} 
%   START_STOP - Start and stop times of experiment name, Start
%                time should rather be seen as sync-time, cell
%                array [2xN], ex: 
%                {'15:00:00'    '15:00:00'    '15:00:00'
%                 '21:05:00'    '21:05:00'    '21:05:00'}
%   CYCLE_LENGTHS - number of steps in filter sequence, int array
%                   [1xN], ex: [2 1 2]
%   FILTER_SEQ - filter sequence, cell array, [max(CYCLE_LENGTH)xN],
%                ex: {'6300','4278','5577'
%                     '4278','4278','8446'}
%   POSITIONS - camera rotations, or predefined positions, cell
%               array,  [1xN] or [max(CYCLE_LENGTH)xN], ex:
%               {'heating','heating',''}
%   EXPTIMES - exposure times (ms), int array [max(CYCLE_LENGTH)xN]
%   IMG_INTERVAL - interval between successive exposures (s) array
%                  [max(CYCLE_LENGTH)xN]
%   GT - Gain table for camera set-up, this controls the camera
%        read-out speed, read noise, and sensitivity.
%   OPS - Additional parameters to set, struct with fields:
%         binning, object, observer
%
% See also EISCAT_ALIS200411

% Copyright Bjorn Gustavsson 20050112

%   Copyright © 20050112 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

OK = 1;
for i = 1:length(stations)
  
  [success,mess,messid] = mkdir(upper(stations{i}(1)));
  
end

gopta_fig(stations,img_intervals,exptimes,filter_seq,experiment_name);
if ~exist('filter_seq','dir')
  mkdir('filter_seq')
end
eval(['print -depsc2 ',['filter_seq/',experiment_name]])
eval(['print -dpng ',['filter_seq/',experiment_name]])

for i = 1:length(stations)
  
  fname = [upper(stations{i}(1)),'/',experiment_name];
  if all(fname(end-1:end)~='.g')
    fname = [fname,'.g'];
  end
  fp = fopen(fname,'w');
  
  fprintf(fp,'#%s\n\n',experiment_name);
  if isfield(ops,'object')
    fprintf(fp,'%s\n',['object ',ops.object]);
  end
  if isfield(ops,'observer')
    fprintf(fp,'%s\n\n',['observer ',ops.observer]);
  end
  fprintf(fp,'load stdpos\n');
  
  if abs(round(cycle_lengths(i))-cycle_lengths(i))>eps
    error('Experiment cycle lengths should be integers...')
  end
  indx_ss = min(i,size(start_stop,2));
  indx_fs = min(i,size(filter_seq,2));
  indx_ps = min(i,size(postitions,2));
  indx_is = min(i,size(img_intervals,2));
  indx_es = min(i,size(exptimes,2));
  
  if ~isempty(start_stop{1,indx_ss})
    fprintf(fp,'set t gopta.start %s\n',start_stop{1,indx_ss});
  end
  
  if ~isempty(start_stop{2,indx_ss})
    fprintf(fp,'set t gopta.stop %s\n\n',start_stop{2,indx_ss});
  end
  fprintf(fp,'set i gopta.items %d\n\n',round(cycle_lengths(i)));
  for j = 1:cycle_lengths(i),
    fprintf(fp,'set i gopta.interval%d %d\n',j-1,img_intervals(j,indx_is));
  end
  fprintf(fp,'\n');
  for j = 1:cycle_lengths(i),
    fprintf(fp,'set i gopta.expose%d %d\n',j-1,exptimes(j,indx_es));
  end
  fprintf(fp,'\n');
  
  for j = 1:cycle_lengths(i),
    
    if all(filter_seq{j,indx_fs} == filter_seq{1+mod(j-2+cycle_lengths(i),cycle_lengths(i)),indx_fs})
      if j==1
        fprintf(fp,'filter %s\n',filter_seq{j,indx_fs});
      end
      filter_seq{j,indx_fs} = 'hold';
    end
    if ~ischar(filter_seq{j,indx_fs})
      filter_seq{j,indx_fs} = num2str(filter_seq{j,indx_fs});
    end
    fprintf(fp,'set s gopta.filter%d %s\n',j-1,filter_seq{j,indx_fs});
    
  end
  fprintf(fp,'\n');
  if min(size(postitions))==1
    
    for j = 1:cycle_lengths(i),
      fprintf(fp,'set s gopta.position%d %s\n',j-1,'hold');
    end
    if ~isempty(postitions{i})
      fprintf(fp,'position %s\n',postitions{i});
    end
    
  else
    
    for j = 1:cycle_lengths(i),
      if all(postitions{j,indx_ps} == postitions{1+mod(j-2+cycle_lengths(i),cycle_lengths(i)),indx_ps})
        if j==1
          fprintf(fp,'position %s',postitions{j,indx_fs});
        end
        postitions{j,indx_fs} = 'hold';
      end
      fprintf(fp,'set s gopta.position%d %d\n',j-1,postitions{j,indx_ps});
    end
    
  end
  fprintf(fp,'\n');
  if ~isempty(GT{i})
    fprintf(fp,'play off\n');
    fprintf(fp,'new GT,%s\n',GT{i});
  end
  if isfield(ops,'binning')
    fprintf(fp,'%s\n',['binning ',ops.binning]);
    fprintf(fp,'hw\n');
    fprintf(fp,'play\n');
    fprintf(fp,'play knapsu\n');
  end
  fclose(fp);
  
end


function ok = gopta_fig(stns,interv,expt,filters,expname)
% GOPTA_FIG - produce an overview figure of the experiment
%   

expnmn = '';
if nargin > 4
  expnmn = [': ',expname];
end
clf
load Spectr_cmap
spec_wide = interp1([Lambda 850],[Spectr_cmap;0 0 0],[Lambda,(max(Lambda)+1):850],'pchip');
Lambda = [Lambda,(max(Lambda)+1):850];
hold on

for i = 1:length(stns)
  hold on
  
  for j = 1:length(interv(:,i)),
    %filters{j,i}
    c = interp1(Lambda,spec_wide,str2num(filters{j,i})/10);
    ph = patch(sum(interv(1:j-1,i))+...
               [0 expt(j,i)/1000 expt(j,i)/1000 0 0],...
               -i+[.4 .4 -.4 -.4 .4],c);
    
    if j == length(interv(:,i))
      ax = axis;
      ax(2) = max(sum(interv));
      text(max(-ax(2)/7,-25),-i,...
           [upper(stns{i}(1)),stns{i}(2:end)],'FontWeight','bold','fontsize',16)
      plot([0,ax(2)],-i+[.4 .4],'k--')
      plot([0,ax(2)],-i-[.4 .4],'k--')
    end
    
  end
end
axis(ax)

set(gca,'yticklabel','')
xlabel('time (s)','fontsize',16)
title(['Filter/exposure sequence',expnmn],'fontsize',18,'Interpreter','none')

if nargout
  
  ok = 1;
  
end
% $$$ #Knutstorp:
% $$$ object Gopta test
% $$$ observer U. Br%G�%@ndstr%G�%@m
% $$$ set i gopta.items 3
% $$$ set t gopta.start 20:10:00
% $$$ set t gopta.stop  20:14:00
% $$$ #
% $$$ set i gopta.interval0 10
% $$$ set i gopta.interval1 20
% $$$ set i gopta.interval2 30
% $$$ set s gopta.filter0   5577
% $$$ set s gopta.filter1   6300
% $$$ set s gopta.filter2   4278
% $$$ set s gopta.position0 hold
% $$$ set s gopta.position1 hold
% $$$ set s gopta.position2 hold
% $$$ set i gopta.expose0   1000
% $$$ set i gopta.expose1   2000
% $$$ set i gopta.expose2   3000
% $$$ set s core 0,0

