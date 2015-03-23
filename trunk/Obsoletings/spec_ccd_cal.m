function [C_spasi,N,Pars,Chi2s] = spec_ccd_cal(data,optpar,imgPO,longlat,OPTS)
% SPEC_CAL_JOBB_SPASI - Spectral absolute camera calibration
% 
% Calling:
%  [C_spasi,N,Pars,Chi2s] = spec_ccd_cal(data,optpar,imgPO,longlat,OPTS)
%
% Comment: Most likely not working

% Example script for spectral camera sensitivity calibration

%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global bx by

%%% Somehow make the image size known
%
bx = 332;
by = 328;

%%% Load the names of the files to scan through
if isdir(data)
  cd(data)
  [q,w] = my_unix('ls -1 --color=never *.tif');
  files = w(1:end-1,:);
else
  files = data;
end

%%%%%%%
%
% Start of phase 1: Finding stars in images
%
%%%%%%%


%%% Automatic search of stars from `Pulkovo Spectrophotometric
%%% Catalog' in all images
[IDENTSTARS,STARPARS,filtnr,Stime,extime] = spc_scan_for_stars(files,longlat,optpar,imgPO,OPTS);

% Convert image counts to counts/s
for i = 1:length(extime),
  indx = find(IDENTSTARS(:,1)==i);
  % exposure time given in ms.
  IDENTSTARS(indx,5:7) = IDENTSTARS(indx,5:7)/extime(i)*1000;
end

% Fix of matlabs reading of 12-bit-tiff files. 
IDENTSTARS(indx,5:7) = IDENTSTARS(indx,5:7)/4;

%%% Check of the results - tedious and boooring
if isfield(OPTS,'check_ids') && OPTS.check_ids
  
  [ok] = check_scan_for_stars(files,longlat,optpar,IDENTSTARS,STARPARS,imgPO,OPTS);
  
end
time_s = Stime(:,1)+Stime(:,2)/60+Stime(:,3)/3600;
keyboard
%%%%%%%
%
% Start of phase 2: Removal of bad star-identification
%                   or `weed out the weaklings'
%%%%%%%

% Determine bad time intervals for each star (due to clouds)
[BT,sis] = spc_chk_if_bad_times(IDENTSTARS,time_s,filtnr,optpar,OPTS);
[BT,sis] = spc_cal_bad_times(IDENTSTARS,time_s,filtnr,optpar,OPTS);
% Sort out the bad time periods and star-fits which are `off
% course', and split IDENTSTARS into more specific matrixes.
[gI1,gI2,gI3,gT,gX,gY,gfilter,BSC_nr,sindx] = spc_sort_out_the_bad_ones(IDENTSTARS,time_s,filtnr,BT,sis,OPTS);

% Select the (unique) filter numbers to calibrate
filternrs = unique(filtnr(:));% [1 2 3];
% #1: 427.8nm
% #2: 557.7nm
% #3: 630.0nm
% #4: 486.1nm
% #5: 589.0nm

% remove clearly bad outliers in intensity.
[gI1,gI2,gI3,gT,gX,gY,gfilter] = ...
    spc_cal_bad_intens(gI1(1:length(sis),:),...
                       gI2(1:length(sis),:),...
                       gI3(1:length(sis),:),...
                       gT(1:length(sis),:),...
                       gX(1:length(sis),:),...
                       gY(1:length(sis),:),...
                       gfilter(1:length(sis),:),...
                       filternrs);

%%%%%%%
%
% Start of phase 3: Finally Physics
%
%%%%%%%

% flat-field-correction matrixes
ffc_raw = ffs_correction_raw([by bx],optpar,optpar(9))/bx/by;
ffc = ffs_correction2([by bx],optpar,optpar(9));

[theta_out,gZe,gffc] = spc_make_theta(gX,gY,optpar,sis);
costheta = cos(theta_out);

%%% Calculate the stellar intensities in (FIXME!!!!!) unit

I2 = gI2 ./ costheta;

% $$$ wl_center = [428.5 559.0 631.0 486.1 589.0];
% $$$ delta_wl = [4.0 4.0 4.0 4.0 4.0];

load f5577_spasi.dat
load f6300_spasi.dat
load f4278_spasi.dat

[Ig,dIg] = spc_spectral_filter_int_conv(f5577_spasi(:,1),f5577_spasi(:,2),BSC_nr);
[Ir,dIb] = spc_spectral_filter_int_conv(f6300_spasi(:,1),f6300_spasi(:,2),BSC_nr);
[Ib,dIb] = spc_spectral_filter_int_conv(f4278_spasi(:,1),f4278_spasi(:,2),BSC_nr);
I_sis = [Ib,Ig,Ir];

hist_range1 = [0:.01:.1]/10;
hist_range23 = [0:.01:1]/2;
hist_range1 = [0:.01:1]/10;%[0:.01:.1]/10;

% histogram of sensitivity estimates. 
[N1,nP1,Chi2_1,N2,nP2,Chi2_2,N3,nP3,Chi2_3] = spc_sens_hist(I2,I_sis,gfilter,filternrs,hist_range23);

% histogram of sensitivity estimates. Different intensity range for
% 4278
[N2,nP2,Chi2_2,N3,nP3,Chi2_3] = spc_sens_hist(I2,I_sis,gfilter,filternrs(2:3),hist_range23);
[N1,nP1,Chi2_1] = spc_sens_hist(I2,I_sis,gfilter,filternrs(1),hist_range1);



C_spasi = [median(nP1(abs(nP1(1:end-2,2))<0.06&sum(N1(1:end-1,1:end-1),2)>5,1))
           median(nP2(abs(nP2(1:end-1,2))<.1&sum(N2(1:end-0,1:end-1),2)>5,1))
           median(nP3(abs(nP3(1:end-1,2))<.1&sum(N3(1:end-0,1:end-1),2)>5,1))];
C_spasim = [mean(nP1(abs(nP1(1:end-2,2))<0.01&sum(N1(1:end-0,1:end-1),2)>5,1))
            mean(nP2(abs(nP2(1:end-1,2))<.01&sum(N2(1:end-0,1:end-1),2)>5,1))
            mean(nP3(abs(nP3(1:end-1,2))<.01&sum(N3(1:end-0,1:end-1),2)>5,1))];


Spasi_sens = 4*pi./C_spasi/ffc_raw(end/2,end/2)/1e6/4;



%%% example for the SP-ASI
exp_t = 16;
I1 = gI1 ./ gffc / exp_t;
I2 = gI2 ./ gffc / exp_t;
I2 = gI2 ./ costheta / exp_t;

hist_range1 = [0:.01:1];
[N1,nP1,Chi2_1,N2,nP2,Chi2_2,N3,nP3,Chi2_3] = spc_sens_hist(I2,I_sis,gfilter,filternrs,hist_range1);

C_spasi = [median(nP1(abs(nP1(1:end-1,2))<0.1&sum(N1(:,1:end-1),2)>5,1))
           median(nP2(abs(nP2(1:end-1,2))<.1&sum(N2(:,1:end-1),2)>5,1))
           median(nP3(abs(nP3(1:end-1,2))<.1&sum(N3(:,1:end-1),2)>5,1))];

Spasi_sens = 4*pi./C_spasi/ffc_rawt(end/2,end/2)/1e6/4;
