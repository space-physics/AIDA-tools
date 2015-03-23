%% Example of using imgs_keograms

%%
% * this is pretty much what produced kaogram images for the HF
% gyro-stepping experiment at 20020307

%% Basic set-up
% First we need to load file-names and other assorted stuff. For
% keograms this also includes which columns and line to collect
% into keograms.

% 0 Moving to where the data is located:
cd('/home/DATA/work/Heating')
cd('/alis/stdnames/2002/03/07')
% 1, load the filenames
q = dir('17/*B.fits');
files0307 = [repmat('17/',[size(q,1) 1]),str2mat(q(:).name)];
q = dir('18/*B.fits');
files0307 = [files0307;repmat('18/',[size(q,1) 1]),str2mat(q(:).name)];
q = dir('19/*B.fits');
files0307 = [files0307;repmat('19/',[size(q,1) 1]),str2mat(q(:).name)];

% 2, select columns
cols = [150,155,157,160,162,165,170,175];
% 3, and no lines
colsnlin = 0*cols;
%%
% This time around the pre_processing options needed are a little
% bit more complex. This is mainly due to the presence of rather
% low-frequency interference.

% 1, start with the typical pre processing options
PO = typical_pre_proc_ops;
% 2, the interference appears mostly at these vertical spatial
% frequencies:
PO.v_interf_notches = [11 12 13 14 22 23 24];
% 3 to remove this low frequencies, we need to remove strong spikes
% in the images - such as the brightest stars:
load(fullfile(fileparts(which('skymap')),'stars','Ybs.bjg'))
% 3b, here we select the stars brighter than magnitude 2
is = find(Ybs(:,end-1)<2);
PO.remove_these_stars = [Ybs(is,1)+Ybs(is,2)/60+Ybs(is,3)/3600 Ybs(is,4)+Ybs(is,5)/60+Ybs(is,6)/3600];
% 3c, Then we need to calculate where in the image the stars will
% appear, and for that we need the optical parameters:
load S010_S10_191827_0.acc
PO.optpar = S010_S10_191827_0([7:14 6 end]);
% 4, to avoid problems with odd-sized images:
PO.outimgsize = 256;

%% Make the keograms:
% All in one go, |imgs_keograms| can produce keograms of lines and
% columns in the same call as well 

[k150,k155,k157,k160,k162,k165,k170,k175,exptimes,tstrs] = imgs_keograms(files0307(383:845,:),cols,colsnlin,PO.optpar,PO);
%% 
% This function give observation times, here |tstrs| as a Nx6 array
% with |[YYYY MM DD HH MM SS.dd]|. That needs to be put into
% something more easily usefull:
times = tstrs(:,4) + tstrs(:,5)/60 + tstrs(:,6)/3600;
t = (times-18)*60;

clf

hon = 18+[-6:3:60]/60;
hoff = 18+[-6:3:60]/60+2/60;

%% Post processing,
% Here ALIS made observations at 5577 and 4278 A during an HF-radio
% wave experiment. The enhancements at those emission lines are by
% far weaker than the background intensity. Thus much background
% needs to be removed, and carefully.

% 1, Here first just take the average enhancement in the central
% columns 
enh = (k155+k160+k162+k165+k170)/5;
enh = enh';
% 2, and cut away what is outside as well
enh = enh(70:110,:)';
% 3, subtract the average of the first and last line
enh = enh-repmat(mean(enh(:,[1 end]),2),[1 41]);
enh = enh';

%% Plot ALIS keogram

% During this time the ALIS exposure times happened to be taken
% after the exposure. Thus we have to correct for that.
% -7/3600 is because the obs-time is taken at the _END_ of an exposure
pcolor(times(170:end-30)'-7/3600,1:min(size(enh)),5*enh(:,170:end-30)*53.9384/16/7)
shading flat
caxis([-7 25])
%%
% Here the intensity for the latter part is scaled by a factor of 5
% since that is approximatelly how much weaker the 4278 A
% enhancement is compared to the enhancement at 5577 A.
hold on
pcolor(times(1:169)',1:min(size(enh)),enh(:,1:169)*46.1609/16/7)
shading flat
% Set the axis to something fixed,
axis([17.9 19 1 40])
% Add the HF-pump period
heateronoff(3,hon,hoff)
% Change the tick labels on the x-axis.
timetick
% Add a title (with a lot of space in it...)
title('5577 A                                             4278 A *5','fontsize',18)
ylabel('#pixel','fontsize',16)
% Compress the color scale a little
caxis([-7 25])
my_cbar([-7 25]);
xlabel('Time (UT)','fontsize',16)
% Save away the position and size of the axes.
ax_pos414 = get(gca,'position');



%   Copyright © 2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later
