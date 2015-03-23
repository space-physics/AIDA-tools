% Spec_cal_jobb_exmplCell - Example of spectral camera sensitivity calibration


%   Copyright © 20110605 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% global bx by

%%% Somehow make the image size known
%
imgsiz = [256 256];
bx = imgsiz(2);
by = imgsiz(1);

%%% Load the names of the files to scan through
%
load files0310.mat
files = files0310(15:end,:);

%%% Filename-base for saving (temporary) results in:
saveFilename = 'Skibotn2002';

%%% Set the optical parameters
%
load S010_S10_191827_0.acc
optpar = S010_S10_191827_0([7:14 6 15]);

%%% Set the long,lat position of the camera
%
pos = [20.36 69.35];

%%%%%%%
%
% Start of phase 1: Finding stars in images
%
%%%%%%%

%%% Make a structure of what typical image pre-processing options
%%% to use
PO = typical_pre_proc_ops('alis')
PO.medianfilter = 0;
%%% Make a structure of options for the star search
%
OPTS = spc_typical_ops;

%%% Automatic search of stars from `Pulkovo Spectrophotometric
%%% Catalog' in all images
%
[IDENTSTARS,STARPARS,filtnr,Stime,extimes] = spc_scan_for_stars(files,pos,optpar,PO,OPTS);
% Then save away the identified stellar intensities for later
% re-loading:
spc_save_stars(PO, OPTS, IDENTSTARS, STARPARS, filtnr, Stime, files,[saveFileName,'-IDS'])
time_s = Stime(:,1)+Stime(:,2)/60+Stime(:,3)/3600;


%%% Check of the results - tedious and boooring
%
CheckItAll = 0;
if CheckItAll
  [ok] = check_scan_for_stars(files,pos,optpar,IDENTSTARS,STARPARS,PO,OPTS);
end


%%%%%%%
%
% Start of phase 2: Removal of bad star-identification
%                   or `weed out the weaklings'
%%%%%%%

cloudy = 1;
if cloudy
  % Determine bad time intervals for each star (due to clouds)
  [BT,sis] = spc_cal_bad_times(IDENTSTARS,time_s,filtnr,optpar);
  % Thes save the selected time-intervalls away for later re-loading
  spc_save_bad_times(sis, BT, [saveFilename,'_bt'])
  
else
  
  sis = 1:length(unique(IDENTSTARS(:,9)));
  BT = cell(1,length(unique(IDENTSTARS(:,9))));
  
end
% Sort out the bad time periods and star-fits which are `off
% course', and split IDENTSTARS into more specific matrixes.
[gI1,gI2,gI3,gT,gX,gY,gfilter,BSC_nr,sindx,uFilters] = spc_sort_out_the_bad_ones(IDENTSTARS,time_s,filtnr,BT,sis,OPTS);

bad_noise_stats = 1; % to reject intensity outliers
if bad_noise_stats
  % remove clearly bad outliers in intensity.
  [gI1,gI2,gI3,gT,gX,gY,gfilter] = ...
      spc_cal_bad_intens(gI1(1:length(sis),:),...
                         gI2(1:length(sis),:),...
                         gI3(1:length(sis),:),...
                         gT(1:length(sis),:),...
                         gX(1:length(sis),:),...
                         gY(1:length(sis),:),...
                         gfilter(1:length(sis),:),...
                         uFilters);
  % Thes save the intensity cropped intensities away for later re-loading
  spc_save_bad_intens(gI1,gI2,gI3,gT,gX,gY,gfilter, [saveFilename,'_bi']);
  
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

[theta_out,gZe,gffc,costheta] = spc_make_theta(gX,gY,optpar,sis,size(d));
%costheta = cos(theta_out);

exp_t = o.exptime;

% TODO: Check where to put exposure time!
%I1 = gI1 ./ gffc / exp_t;
%I2 = gI2 ./ gffc / exp_t;
%I2 = gI2 ./ costheta / exp_t;
for i1 = size(gI2,1):-1:1,
  for i2 = size(gI2,2):-1:1,
    if ~isempty(gI2{i1,i2})
      I2{i1,i2} = gI2{i1,i2} ./ costheta{i1,i2}; 
    end
  end
end

% Set the centre-wavelengths of the filters
wl_center = [428.5 559.0 631.0 845.5]; % nm
% and the bandwidths
delta_wl = [5.0 4.0 4.0 4.0]; % nm

% This needs modification, to tie the filter identifiers in Gfilter
% to the corresponding wavelengths (those above in wl_center)
filter2wl = [5       0     1     4];
filter2wl = [4278,   5577, 6300, 8446];

%%% Calculate the stellar intensities in (photons/m^2/s)?
[I_sis,dI] = spc_spectral_int_conv(wl_center,delta_wl,BSC_nr);



%%% Commented to here
% TODO: finish the documentation
hist_range = [0:.01:5]/10;

%[N5,nP5,Chi2_5,N0,nP0,Chi2_0,N1,nP1,Chi2_1,N4,nP4,Chi2_4] = spc_sens_hist(I2,I_sis,gfilter,filter2wl,hist_range);
% Estimate the distribution for the sensitivity in the different
% filters. This should be in (counts/(photon/m^2/s))
N_all = spc_sens_pdf(I2,I_sis,gfilter,filter2wl,hist_range);


% Then to get to surface brightness (photons/m^2/s/ster) take:
for i1 = size(N_all):-1:1,
  Brigthness_per_count(i1) = 1./mode(N_all{i1})/max(fcc_raw);
end

% Finaly convert to column emission rate/count:
Rayleighs_per_count = 1e-10*4*pi*Brigthness_per_count;


%%% example for the SP-ASI
exp_t = 16;

[N_hists,nP1_Gaussparams,Chi2_vals] = spc_sens_hist(I2,I_sis,gfilter,hist_range);
