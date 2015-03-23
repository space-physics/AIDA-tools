% Spec_cal_jobb_Miracle - Example of spectral camera sensitivity calibration

%   Copyright © Bjorn Gustavsson (20030901)
%   This is free software, licensed under GNU GPL version 2 or later

% global bx by

%%% Somehow make the image size known
%
%imgsiz = [1024 1024];
%bx = imgsiz(2);
%by = imgsiz(1);
%
%%% Load the names of the files to scan through
%
%load files0310.mat
%files = files0310(15:end,:);
%
%%% Filename-base for saving (temporary) results in:
saveFilename = 'SOD100221';
%%% Set the optical parameters
%
%load S010_S10_191827_0.acc
%optpar = S010_S10_191827_0([7:14 6 15]);
%
%%% Set the long,lat position of the camera
%
%pos = [20.36 69.35];

path='Sod100221/Summed/'; % had to add images per minute to "see" the stars
                                       % using the add_pngs routine
tmp=dir([path,'SOD100221*.png']);
filenames=str2mat({tmp.name});
pathfiles=[repmat(path,size(filenames,1),1),filenames];


files = pathfiles(:,:);

%%% Set the optical parameters in some way:
%
filename = 'SOD_100221_00193330_____0400';
load([filename, '.acc'])
%optpar = acc2optpar(SOD_100221_00193330_____0400);
optpar = acc2optpar(eval(filename));

%%% Set the long,lat position of the observation position
%
load ../.data/miraclepos.dat
pos = miraclepos(1,2:3);
%%%%%%%
%
% Start of phase 1: Finding stars in images
%
%%%%%%%

%% Make a structure of what typical image pre-processing options
%% to use
PO = typical_pre_proc_ops('miracle_asc')
PO.filetype = 'miracle_asc';
PO.medianfilter = 0;
%% Make a structure of options for the star search
o.exptime = str2num(filename(25:28));

OPTS = spc_typical_ops
OPTS.Mag_limit=2;

%% Automatic search of stars from `Pulkovo Spectrophotometric
%% Catalog' in all images

[IDENTSTARS,STARPARS,filtnr,Stime] = spc_scan_for_stars(files,pos,optpar,PO,OPTS);

%% Check of the results - tedious and boooring

%[ok] = check_scan_for_stars(files,pos,optpar,IDENTSTARS,STARPARS,PO,OPTS);

time_s = Stime(:,1)+Stime(:,2)/60+Stime(:,3)/3600;

%%%%%%%
%
% Start of phase 2: Removal of bad star-identification
%                   or `weed out the weaklings'
%%%%%%%

% Determine bad time intervals for each star (due to clouds)
%filtnr0=ones(length(filtnr));
%[BT,sis] = spc_cal_bad_times(IDENTSTARS,time_s,filtnr0,optpar);
filtnr0=ones(length(filtnr));
cloudy = 1;
if cloudy  %ALWAYS set to 1 to get to the cloud selection
  [BT, sis, err] = spc_load_bad_times([filename, '_bt.mat']);
	if err ~= 0
  	[BT,sis] = spc_cal_bad_times(IDENTSTARS,time_s,filtnr0,optpar);
		spc_save_bad_times(sis, BT, [filename, '_bt'])
	end
else
  
  sis = 1:length(unique(IDENTSTARS(:,9)));
  BT = zeros([length(sis) 2]);
  
end
% Sort out the bad time periods and star-fits which are `off
% course', and split IDENTSTARS into more specific matrixes.
[gI1,gI2,gI3,gT,gX,gY,gfilter,BSC_nr,sindx] = spc_sort_out_the_bad_ones(IDENTSTARS,time_s,filtnr,BT,sis,OPTS);

% remove clearly bad outliers in intensity.
%[gI1,gI2,gI3,gT,gX,gY,gfilter,err] = ...
%    spc_cal_bad_intens(GI1(1:length(sis),:),...
%                       GI2(1:length(sis),:),...
%                       GI3(1:length(sis),:),...
%                       GT(1:length(sis),:),...
%                       GX(1:length(sis),:),...
%                       GY(1:length(sis),:),...
%                       Gfilter(1:length(sis),:),...
%                       [0 1 4 5]);

bad_noise_stats = 1; % to reject intensity outliers
if bad_noise_stats
% remove clearly bad outliers in intensity.
	[gI1_,gI2_,gI3_,gT_,gX_,gY_,gfilter_,err] = spc_load_bad_intens([filename, '_bi.mat']);
	if err ~= 0 & err ~= 3
		[gI1,gI2,gI3,gT,gX,gY,gfilter] = ...
		    spc_cal_bad_intens(gI1(1:length(sis),:),...
		                       gI2(1:length(sis),:),...
		                       gI3(1:length(sis),:),...
		                       gT(1:length(sis),:),...
		                       gX(1:length(sis),:),...
		                       gY(1:length(sis),:),...
		                       ones(size(gfilter(1:length(sis),:))),...
		                       1);
		spc_save_bad_intens(gI1,gI2,gI3,gT,gX,gY,gfilter, [filename, '_bi']);
	elseif err == 0
		gI1 = gI1_;
		gI2 = gI2_;
		gI3 = gI3_;
		gT = gT_;
		gX = gX_;
		gY = gY_;
		gfilter = gfilter_;
	end
end
disp('BLAH')
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



exp_t = o.exptime;

I1 = gI1 ./ gffc / exp_t;
I2 = gI2 ./ gffc / exp_t;
I2 = gI2 ./ costheta / exp_t;
I2 = gI2 ./ costheta; 


% Set the centre-wavelengths of the filters
wl_center = [427.8 557.7 630.0 845.5]; % nm
% and the bandwidths
delta_wl = [2, 2, 2, 2]; % nm

% This needs modification, to tie the filter identifiers in Gfilter
% to the corresponding wavelengths (those above in wl_center)
filter2wl = [5       0     1     4];
filter2wl = [4278,   5577, 6300, 8446];
filter2wl = [427,   557, 630, 844];

%%% Calculate the stellar intensities in (photons/m^2/s)?
[I_sis,dI] = spc_spectral_int_conv(wl_center,delta_wl,BSC_nr);

%[N5,nP5,Chi2_5,N0,nP0,Chi2_0,N1,nP1,Chi2_1,N4,nP4,Chi2_4] = spc_sens_hist(I2,I_sis,gfilter,filter2wl,hist_range);
% Estimate the distribution for the sensitivity in the different
% filters. This should be in (counts/(photon/m^2/s))
%N_all = spc_sens_pdf(I2,I_sis,gfilter,filter2wl,hist_range);
sens_range = [0:.01:5]/1000; % Typical for ALIS
N_all = spc_sens_hist(I2,I_sis,gfilter,filter2wl,sens_range);

% Then to get to surface brightness (photons/m^2/s/ster) take:
Brigthness_per_count = 1./mode(N_all{1:3:length(N_all)})/max(fcc_raw);

% Finaly convert to column emission rate/count:
Rayleighs_per_count = 1e-10*4*pi*Brigthness_per_count;


%%% example for the SP-ASI
%exp_t = 16;
%hist_range = [0:.01:5]/10;
%I1 = gI1 ./ gffc / exp_t;
%I2 = gI2 ./ gffc / exp_t;
%I2 = gI2 ./ costheta / exp_t;
%
%[N1,nP1,Chi2_1,N2,nP2,Chi2_2,N3,nP3,Chi2_3] = spc_sens_hist(I2,I_sis,gfilter,hist_range);
%
%
%% For heating tomografi
%global bx by
%
%imgsiz = [256 256]/2;
%bx = imgsiz(2);
%by = imgsiz(1);
%
%load kuma_files
%
%load Abisko_heating_nostrips.opt
%load Nikka_heating_nostrip.opt
%load Silki_heating_nostrp.opt
%optpar3 = [Silki_heating_nostrp 3 0];
%optpar6 = [Nikka_heating_nostrip 3 0];
%load alispos.dat
%alispos = alispos.*(ones([6 1])*[1 1/60 1/3600 1 1/60 1/3600]);                          
%alispos = [alispos(:,1)+alispos(:,2)+alispos(:,3) alispos(:,4)+alispos(:,5)+alispos(:,6)]
%pos = alispos(3,:);
%PO = typical_pre_proc_ops;
%PO.medianfilter = 0;
%OPTS = spc_typical_ops;
%
%files = F3_1740;
%optpar = optpar3;
%
%[IDENTSTARS,STARPARS,filtnr,Stime] = spc_scan_for_stars(files,pos,optpar,PO,OPTS);
%time_s = Stime(:,1)+Stime(:,2)/60+Stime(:,3)/3600;
%filtnr(:) = 1;
%
%% $$$ [BT,sis] = spc_cal_bad_times(IDENTSTARS,time_s,filtnr,optpar);
%sis = 1:length(unique(IDENTSTARS(:,9)));
%BT = zeros([length(sis) 2]);
%[gI1,gI2,gI3,gT,gX,gY,gfilter,BSC_nr,sindx] = spc_sort_out_the_bad_ones(IDENTSTARS,time_s,filtnr,BT,sis);
%ffc = ffs_correction2([bx by],optpar,optpar(9));
%
%[theta_out,gZe,gffc] = spc_make_theta(gX,gY,optpar,sis);
%costheta = cos(theta_out);
%wl_center = 630;
%delta_wl = 4;
%%%% Calculate the stellar intensities in (FIXME!!!!!) unit
%[I_sis,dI] = spc_spectral_int_conv(wl_center,delta_wl,BSC_nr);
%
%%%% example for ALIS
%[d,h,o] = inimg(files(2,:),PO);
%exp_t = o.exptime;
%hist_range = [0:.01:5]/10;
%I1 = gI1 ./ gffc / exp_t;
%I2 = gI2 ./ gffc / exp_t;
%I2 = gI2 ./ costheta / exp_t;
%
%[N1_3,nP1_3,Chi2_1_3] = spc_sens_hist(I2,I_sis,gfilter,hist_range);
%
%
%files = F6_1740;
%optpar = optpar6;
%pos = alispos(6,:);
%
%[IDENTSTARS,STARPARS,filtnr,Stime] = spc_scan_for_stars(files,pos,optpar,PO,OPTS);
%time_s = Stime(:,1)+Stime(:,2)/60+Stime(:,3)/3600;
%filtnr(:) = 1;
%% $$$ [BT,sis] = spc_cal_bad_times(IDENTSTARS,time_s,filtnr,optpar);
%sis = 1:length(unique(IDENTSTARS(:,9)));
%BT = zeros([length(sis) 2]);
%[gI1,gI2,gI3,gT,gX,gY,gfilter,BSC_nr,sindx] = spc_sort_out_the_bad_ones(IDENTSTARS,time_s,filtnr,BT,sis);
%ffc = ffs_correction2([bx by],optpar,optpar(9));
%
%[theta_out,gZe,gffc] = spc_make_theta(gX,gY,optpar,sis);
%costheta = cos(theta_out);
%
%%%% Calculate the stellar intensities in (FIXME!!!!!) unit
%[I_sis,dI] = spc_spectral_int_conv(wl_center,delta_wl,BSC_nr);
%
%%%% example for ALIS
%[d,h,o] = inimg(files(2,:),PO);
%exp_t = o.exptime;
%hist_range = [0:.01:5]/10;
%I1 = gI1 ./ gffc / exp_t;
%I2 = gI2 ./ gffc / exp_t;
%I2 = gI2 ./ costheta / exp_t;
%
%[N1_6,nP1_6,Chi2_1_6] = spc_sens_hist(I2,I_sis,gfilter,hist_range);
