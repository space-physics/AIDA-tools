function [keo,wl_emi,t_obs,optps,filenames,exptimes] = alis_imgs2keos(filenames,PO)
% ALIS_IMGS2KEOS - make overview-keograms
%   
% [keo,wl_emi,t_obs,optps,filenames] = alis_imgs2keos(filenames,PO)
% 
% Input:
%  FILENAMES - string array of filenames.

%  PO - struct with preprocessing options
% 
% See also INIMG, TYPICAL_PRE__PROC_OPS, IMGS_KEOGRAMS


%   Copyright © 20050805 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

locnrs = 69;
l_n_c = 0;

[d,h,o] = inimg(filenames(1,:),PO);

[keo1,exptimes,Tstrs,filters,optps] = imgs_keograms(filenames,locnrs,l_n_c,o.optpar,PO);
keo = keo1';

t_obs = Tstrs(:,4) + Tstrs(:,5)/60 + Tstrs(:,6)/3600;

[t_obs,t_sindx] = sort(t_obs);

filenames = filenames(t_sindx,:);
exptimes = exptimes(t_sindx);
keo = keo(:,t_sindx);
filters = filters(t_sindx);
optps = optps(t_sindx,:);

%%% QD-fix of emissions from filters
filters(filters==0) = 5577;
filters(filters==1) = 6300;
filters(filters==2) = 1000;
filters(filters==3) = 1000;
filters(filters==4) = 8446;
filters(filters==5) = 4278;
filters(filters<1000) = 10*filters(f_fix_indx);



% $$$ f_fix_indx = find(filters==0);
% $$$ filters(f_fix_indx) = 5577;
% $$$ f_fix_indx = find(filters==1);
% $$$ filters(f_fix_indx) = 6300;
% $$$ f_fix_indx = find(filters==2);
% $$$ filters(f_fix_indx) = 1000;
% $$$ f_fix_indx = find(filters==3);
% $$$ filters(f_fix_indx) = 1000;
% $$$ f_fix_indx = find(filters==4);
% $$$ filters(f_fix_indx) = 8446;
% $$$ f_fix_indx = find(filters==5);
% $$$ filters(f_fix_indx) = 4278;
% $$$ f_fix_indx = find(filters<1000);
% $$$ filters(f_fix_indx) = 10*filters(f_fix_indx);
% $$$ 


wl_emi = filters;
