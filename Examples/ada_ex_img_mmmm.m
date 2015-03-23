%% Example of imgs_reg_mmmm
% This function processes a series of images and calculates max,
% mean, median and min in one or several regions on the image. This
% is useful to get quantitative oveviews of for example HF-pump
% experiments on radio induced optical emissions.


%% Preparatory steps
% The first thing to do is to get full filenames of the image
% sequence to analyse. Either absolute or relative paths will do.
% Here one can also choose to move to the directory where the data
% resides. However, it is a bad idea to write directly to that
% directory. 

% Move to the data directory
% data_dir = '/alis/stdnames/1999/02/21/';
% But on my PC I have the ALIS data stored in a more arcane order...

% $$$ data_dir = '/home/DATA/ALIS/19990221/s05';
% $$$ cd(data_dir)

data_dir = '/alis/stdnames/1999/02/21/';
cd(data_dir)


% Fixing the filenames for images from between 1700-1900 into a
% char array:
q = dir('17/*A.fits');
F5 = ([repmat('17/',[size(q,1) 1]),str2mat(q(:).name)]);
q = dir('18/*A.fits');
F5 = [F5;[repmat('18/',[size(q,1) 1]),str2mat(q(:).name)]];

% Put the filenames into one string-array.

% For this example file to work all images from 19990221 17:00:00
% to 18:30:00 UT should be put in a string array.


%% Set up for image corrections
% Here we use very basic image pre-processing options - no
% filtering. But when processing a large series of images it might
% be clever to set PO.outimgsize to the typical of the experiment
% that was running. Then the odd images taken with other binning
% factors before and after the run for calibration purposes will be
% resampled to the same resolution. Then they will not crash the
% analysis.

PO = typical_pre_proc_ops;
PO.medianfilter = 0;
PO.find_optpar = 0;
PO.outimgsize = 256;

%% Selecting regions
%
% A region are defined |[Xmin Xmax Ymin Ymax]| and several regions
% (possibly overlapping) can be used, it is just to ad each region
% line by line. Here for this example of heating the first and
% fourth lines cover the enhanced region and the other the
% surroounding unenhanced background region.
regs(1,:) = [82   154   111   191];
regs(2,:) = [164   192   122   184];
regs(3,:) = [98   148    66    94];
regs(4,:) = [104   133   134   172];
regs(5,:) = [98   148   203   229];
regs(6,:) = [43    77   106   202];

%% The Region statistics

% With waitbar while calculating the time-series
OPS.wb = 1;
% Or without
OPS.wb = 0;
% Calculating the time series 
[I_max,I_mean,I_median,I_min,Tr_t_b1,expt,filters] = imgs_regs_mmmm(F5,regs,OPS,PO);
% If the number of files is large this might take some time to
% process. Then it could be worthwhile to store that data:
% save Immm.mat I_max I_mean I_median I_min Tr_t_b1 expt filters

%% Post processing
%
% For some reason the intensities returned is in counts - not counts
% per second so we have to divide the intensities with the
% corresponding exposure times. To go from average to total
% intensity we just multiply with region area: 

I_m = I_mean./repmat(expt',[1 6])*diff(regs(1:2))*diff(regs(3:4));
%%
% There are ways to separate images taken with different filters,
% either we could do the call to |imgs_regs_mmmm| several times with
% only the files for images in each filter, or as here, separate
% them after one function call.
redindx = filters==6300;
greenindx = find(filters==5577);

t_red = rem(Tr_t_b1(filters==6300),24);
t_green = rem(Tr_t_b1(filters==5577),24);
Ir = I_m(redindx,:);

%% Plotting, raw
plot(t_red,(I_mean(filters==6300,4)-I_m(filters==6300,5)/2+I_mean(filters==6300,6)/2),'r.')
hold on
plot(t_green,(I_mean(filters==5577,4)-I_m(filters==5577,5)/2+I_mean(filters==5577,6)/2),'g.')
timetick
title('Approximate enhancements','fontsize',18)


%% Plotting, background reduced and fine
%
% For Heating experiments we are mainly interersted in the HF
% induced enhancement above the background. Thus there is a need to
% reduce the background. Here "friend of order" might interupt by
% noting that we took some data from background regions - surely it
% should only be to subtrackt those. That was what we tried above,
% and apparently there is a need to do a little better as the
% average intensities in the different regions not necessarily are
% equal even at times when the HF-pump is off.
i_r_off = [4 12 29 40 48 70 87 99]-3;
i_r_off = [1 11 28 38 47 68 86 101];
% LSQ-optimal background coefficients
bgcoeffs1 = [Ir(i_r_off,2) Ir(i_r_off,3) Ir(i_r_off,5) Ir(i_r_off,6)]\Ir(i_r_off,1);
bgcoeffs4 = [Ir(i_r_off,2) Ir(i_r_off,3) Ir(i_r_off,5) Ir(i_r_off,6)]\Ir(i_r_off,4);

% Pure red line enhancements
enh4_r = Ir(:,4)-[Ir(:,2) Ir(:,3) Ir(:,5) Ir(:,6)]*bgcoeffs4;


clf
plot(t_red(3:end-6),enh4_r(3:end-6),'r-','markersize',4) 
hold on
plot(t_red(3:end-6),enh4_r(3:end-6),'k.','markersize',18)
grid
timetick

%% Additional overlays
% 
% For red line observations it is vital to estimate the effective
% $$O(^1D)$$ lifetime. Here we simply overlay an exponential decay
% with a 40 s time constant.

% Set up for guesstimate-plot of red line decay
dtime = 0:5:120;
I20 = exp(-dtime/20);
I40 = exp(-dtime/40);

I_5 =  [24 0];%[217.88 -19.166]/10.00;
I_8 =  [23.875 0];%[219.66 -4.8566]/10.00;
I_9 =  [21.14 0];;%[210.07 -6.7482]/10.00;
I_10 = [19.475 0];%[171.21 0.65148]/10.00;

H_off = 17+[-8:8:80]/60;

plot(H_off(5)+dtime/3600,(I_5(1)-I_5(2))*I40+I_5(2),'k--','linewidth',2)
plot(H_off(8)+dtime/3600,(I_8(1)-I_8(2))*I40+I_8(2),'k--','linewidth',2)
plot(H_off(9)+dtime/3600,(I_9(1)-I_9(2))*I40+I_9(2),'k--','linewidth',2)
plot(H_off(10)+dtime/3600,(I_10(1)-I_10(2))*I40+I_10(2),'k--','linewidth',2)

axis([17+1/6 18.2 -20 40])
set(gca,'fontsize',18)
title('Average enhancement of 6300 A','fontsize',font_size)
xlabel('time (UT)','fontsize',font_size)
ylabel('Counts/s','fontsize',font_size)

% Plot the time instances where 5577 images were made
pdh = plot(rem(Tr_t_b1(greenindx),24),[32],'kd','markersize',10);

%%
% * This is pretty much the same figure as published in Gustavsson
% et al. [2002]


%   Copyright © 2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later
