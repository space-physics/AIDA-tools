% Spec_cal_jobb_spasi - calibration of South-Pole ASI

%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global bx by

%%% Somehow make the image size known
%
imgsiz = [256 256];
bx = 332;
by = 328;

%%% Load the names of the files to scan through
%
cd /home/DATA/SP_ASI
[q,w] = my_unix('ls -1 --color=never *.tif');

files = w(1:end-1,:);

%%% Set the optical parameters
%
load S017_20030710000310.acc
optpar = S017_20030710000310([7:14 6 15]);

%%% Set the long,lat position of the camera
%
pos = [0 -90];

%%%%%%%
%
% Start of phase 1: Finding stars in images
%
%%%%%%%

%%% Make a structure of what typical image pre-processing options
%%% to use
PO = typical_pre_proc_ops;
PO.imreg = [90.262 422.22 101.11 428.83];
PO.quadfix = 0;
PO.quadfixsize = 0;
PO.replaceborder = 0;
PO.badpixfix = 0;
PO.outimgsize = 0;
PO.medianfilter = 0;
PO.defaultccd6 = 1;
PO.bias_correction = 0;

%%% Make a structure of options for the star search
%
OPTS = spc_typical_ops;
OPTS.Mag_limit = 4.5;
%%% Automatic search of stars from `Pulkovo Spectrophotometric
%%% Catalog' in all images
[IDENTSTARS,STARPARS,filtnr,Stime,extime] = spc_scan_for_stars(files,pos,optpar,PO,OPTS);
% 7 minutes/3 images at my laptop.

% Convert image counts to counts/s
for i = 1:length(extime),
  indx = find(IDENTSTARS(:,1)==i);
  % exposure time given in ms.
  IDENTSTARS(indx,5:7) = IDENTSTARS(indx,5:7)/extime(i)*1000;
end

% Fix of matlabs reading of 12-bit-tiff files. 
IDENTSTARS(indx,5:7) = IDENTSTARS(indx,5:7)/4;

%%% Check of the results - tedious and boooring
[ok] = check_scan_for_stars(files,pos,optpar,IDENTSTARS,STARPARS,PO,OPTS);

time_s = Stime(:,1)+Stime(:,2)/60+Stime(:,3)/3600;

%%%%%%%
%
% Start of phase 2: Removal of bad star-identification
%                   or `weed out the weaklings'
%%%%%%%

% Determine bad time intervals for each star (due to clouds)
%% [BT,sis] = spc_chk_if_bad_times(IDENTSTARS,time_s,filtnr,optpar,OPTS);
[BT,sis] = spc_cal_bad_times(IDENTSTARS,time_s,filtnr,optpar,OPTS);
% Sort out the bad time periods and star-fits which are `off
% course', and split IDENTSTARS into more specific matrixes.
[GI1,GI2,GI3,GT,GX,GY,Gfilter,BSC_nr,sindx,uFilters] = spc_sort_out_the_bad_ones(IDENTSTARS,time_s,filtnr,BT,sis,OPTS);

% Select the (unique) filter numbers to calibrate
filternrs = unique(filtnr(:));% [1 2 3];
% #1: 427.8nm
% #2: 557.7nm
% #3: 630.0nm
% #4: 486.1nm
% #5: 589.0nm

% remove clearly bad outliers in intensity.
[gI1,gI2,gI3,gT,gX,gY,gfilter] = ...
    spc_cal_bad_intens(GI1(1:length(sis),:),...
                       GI2(1:length(sis),:),...
                       GI3(1:length(sis),:),...
                       GT(1:length(sis),:),...
                       GX(1:length(sis),:),...
                       GY(1:length(sis),:),...
                       Gfilter(1:length(sis),:),...
                       filternrs);

%%%%%%%
%
% Start of phase 3: Finally Physics
%
%%%%%%%

% flat-field-correction matrixes
ffc_raw = ffs_correction_raw([bx by],optpar,optpar(9))/bx/by;
ffc = ffs_correction2([bx by],optpar,optpar(9));

[theta_out,gZe,gffc] = spc_make_theta(gX,gY,optpar,sis);
costheta = cos(theta_out);

%%% Calculate the stellar intensities in (FIXME!!!!!) unit

%%% example for NIPR SP ASI
[d,h,o] = inimg(files(2,:),PO);
exp_t = o.exptime/1000; % exposure time given in ms

% I1 = gI1 ./ gffc / exp_t;
% I2 = gI2 ./ gffc / exp_t;
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

% hist_range1 = [0:.01:.1]/10;
hist_range23 = [0:.01:1]/10;
hist_range1 = [0:.01:.1]/10;

% histogram of sensitivity estimates. 
[N1,nP1,Chi2_1,N2,nP2,Chi2_2,N3,nP3,Chi2_3] = spc_sens_hist(I2,I_sis,gfilter,filternrs,hist_range23);

% histogram of sensitivity estimates. Different intensity range for
% 4278
[N_23,nP2_23,Chi2_23] = spc_sens_hist(I2,I_sis,gfilter,filternrs(2:3),hist_range23);
[N_1,nP1,Chi2_1] = spc_sens_hist(I2,I_sis,gfilter,filternrs(1),hist_range1);



C_spasi = [median(nP1(abs(nP1(1:end-2,2))<0.01&sum(N1(1:end-0,1:end-1),2)>5,1))
           median(nP2(abs(nP2(1:end-1,2))<.01&sum(N2(1:end-0,1:end-1),2)>5,1))
           median(nP3(abs(nP3(1:end-1,2))<.01&sum(N3(1:end-0,1:end-1),2)>5,1))];
C_spasim = [mean(nP1(abs(nP1(1:end-2,2))<0.01&sum(N1(1:end-0,1:end-1),2)>5,1))
            mean(nP2(abs(nP2(1:end-1,2))<.01&sum(N2(1:end-0,1:end-1),2)>5,1))
            mean(nP3(abs(nP3(1:end-1,2))<.01&sum(N3(1:end-0,1:end-1),2)>5,1))];


Spasi_sens = 4*pi./C_spasi/ffc_raw(end/2,end/2)/1e6/4;



%%% example for the SP-ASI
exp_t = 16;
I1 = gI1 ./ gffc / exp_t;
% I2 = gI2 ./ gffc / exp_t;
I2 = gI2 ./ costheta / exp_t;

hist_range1 = [0:.01:.1]*10;
[N1,nP1,Chi2_1,N2,nP2,Chi2_2,N3,nP3,Chi2_3] = spc_sens_hist(I2,I_sis,gfilter,filternrs,hist_range1);

C_spasi = [median(nP1(abs(nP1(1:end-1,2))<0.1&sum(N1(:,1:end-1),2)>5,1))
           median(nP2(abs(nP2(1:end-1,2))<.1&sum(N2(:,1:end-1),2)>5,1))
           median(nP3(abs(nP3(1:end-1,2))<.1&sum(N3(:,1:end-1),2)>5,1))];

Spasi_sens = 4*pi./C_spasi/ffc_rawt(end/2,end/2)/1e6/4;
