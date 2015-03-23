% TOMO20080305NewBeginnings - script for tomographing ALIS 20080305 event, 18:40 UT
%if 1
% Here we do all the same things as in the other example scripts
% but now we apply it all to a series of images.
%
% CSW and BG, Dec. 2010
%             Aug. 2011 Modification of the width and mean energy of the
%                       aeronomic start guess for better inversion. The
%                       VER inversion into flux will perform better with a
%                       wider VER peak, typically 800 eV.
%
% How to use this programme (ENTER is the ENTER keypad):
%
% >> tomo20080305FinalIR   % 1. launch the programme
% >> 1         ENTER       % 2. Choose 1 for MART, 2 for M-SIRT
% >> [3 2 2 1] ENTER       % 3. For MART, take the ugliest image first (#4), 
%                          %    then the two middle ones together (#2 and #3)
%                          %    and finally the best one (usually Skibotn, #1)
%                          %    for MSIRT, nothing is asked
% >>           ENTER       % 4. Quiet borders: select a relevant portion of
%                          %    the image, excluding the extreme borders
% >> [1 2 3 4] ENTER       % 5. Intensity Normalization: select a part of
%                          %    all four images (usually the brightest)
% >> 3         ENTER       % 6. Choose filter 3 proxfilt which works well
% >> ones(3)/9 ENTER       % 7. The famous 'ones', matrix filter kernel
% >>                       % 8. Now wait for the awesome results to appear!
% 
% BEWARE ll.384-386: change directory for saving the corresponding file!

%% -1 Date-n-time
%%## Added this here, so that the calls to MSIS is in the top
%    set-up script - that way we'll see it and know to change it
%    for other events...
% Just to get an MSIS with the right F10.7 and ap parameters at time:
dateNtime4MSIS = [2013 3 8 23 41 10]; % Changed change to take
                                      % stns(1).obs.time and
                                      % longlat as input to msis!
   
MSISpars_f107af107pap = [70,87,3];
%% 0 Definition of Home Directory
Uname = getenv('USER'); %%## Changed stuff here to make this
                            %"run" both here and for you...
if strcmp(Uname,'bgu001')
  homedir = '/home/bgu001/';
else
end
%% 1 Locating the data
% Just set this to where the data is located on your local media.

data_dir = strcat('/data/NIPR');
AbiskoDir = 'Abisko/2013/03/09';
TromsoDir = 'Tromso/2013/03/09';
KilpisDir = 'Kilpisjarvi/2013/03/09';
meta_data_dir = strcat('/data/NIPR/Example');
cd(meta_data_dir);

%% 0.1 Background atmosphere
% Just to get an MSIS at the right altitudes:
% [nHe,nO,nN2,nO2,nAr,Mass,nH,nN,Tex,Tn] = msis(dateNtime4MSIS,z2D,69.2,21,70,87,3);
% f107a = MSISpars_f107af107pap(1);
% f107p = MSISpars_f107af107pap(2);
% ap = MSISpars_f107af107pap(3);
% Currently broken f-mexing of msis.mex [nHe,nO,nN2,nO2,nAr,Mass,nH,nN,Tex,Tn] = msis(stns(1).obs.time,z2D,stns(1).obs.longlat(2),stns(1).obs.longlat(1),f107a,f107p,ap);
% Instead I use the NASA model-web MSIS implementation,
% unfortunately not yet available for 201303, so for now I have to
% stick to 2012:
MSISfilename = '/data/NIPR/Example/msis20120308.dat';
opsMSISfR = msisfileloader;
opsMSISfR.indH = 9;
opsMSISfR.indHe = 7;
opsMSISfR.indN = 10;
opsMSISfR.indAr = 8;
[h_msis,O,N2,O2,Mass,T,H,N,He,Ar,Tex] = msisfileloader(MSISfilename,opsMSISfR);

%% 1.1 Read the list of ALIS-ASK events
  % This will give us information about the interesting time
  % periods and which ALIS stations have data available.
if strcmp(Uname,'bgu001') % and I "don't like it very much"...
  % For my version of this I just run everything for the images you
  % sent me - so nooo looping,,,
else
end
%% 1.2 Set up for data pre-processing
% The preprocessing options will be needed anyway, so we migh
% just as well set them early on.
poA = typical_pre_proc_ops('none');
poA.central_station = 10;
poA.try_to_be_smart_fnc = @(filename)NIPR_ABK2013(filename);
poA.outimgsize = [1,1]*256;

poK = typical_pre_proc_ops('none');
poK.central_station = 10;
poK.try_to_be_smart_fnc = @(filename)NIPR_KIL2013(filename); 
poK.outimgsize = [1,1]*256;

poT = typical_pre_proc_ops('none');
poT.imreg = [127 648 49 569];
poT.central_station = 10;
poT.try_to_be_smart_fnc = @(filename)NIPR_TRO2013(filename);
poT.outimgsize = [1,1]*256;


i1 = 1;
%% 1.3 Get lists with files from stations of interest
% For my version of this I just run everything for the images you
% sent me with the optical parameters
ABK = load('ABK130304_01003052_____0400_adjust.acc');
TRO = load('emccd_tro_2013-03-05_21-35-59.acc');     
KIL = load('KIL130211_18223017_____0400_adjust.acc');

optpA = ABK([6:13 5 end]);
optpT = TRO([6:13 5 end]);
optpK = KIL([6:13 5 end]);

%% Kilpisj�rvi images
dFiles{1} = char('ABK130309_00155970_428_1000.png',...
                    'ABK130309_00160029_428_1000.png',...
                    'ABK130309_00160087_428_1000.png',...
                    'ABK130309_00160146_428_1000.png',...
                    'ABK130309_00160205_428_1000.png');

dFiles{2} = char('KIL130309_00155976_428_1000.png',...
                    'KIL130309_00160032_428_1000.png',...
                    'KIL130309_00160089_428_1000.png');

dFiles{3} = 'tro20130309_001600_658.jpg';
%% - TO CHANGE WHEN STATIONS CHANGE
% Assign the optical parameters to the corresponding PO-structs
poA.optpar = optpA; % *T*romso
poK.optpar = optpK; % *A*bisko
poT.optpar = optpT; % *K*ilpisjarvi

POs = [poA,poK,poT];

% to be included later: POs(4).optpar = optpB; % Ski*B*otn

%% 2 Tomography set-up
%
%% Setting up the "station-struct"   - TO CHANGE WHEN STATIONS CHANGE
% Here we start with setting up the "station-struct"
% First put together a list of one file from each station
%file_list = char(dFiles{1}(145,:),dFiles{2}(145,:),dFiles{3}(145,:),dFiles{6}(145,:));
if strcmp(Uname, 'bgu001')
  file_list = char(fullfile(data_dir,AbiskoDir,dFiles{1}(1,:)),...
                      fullfile(data_dir,KilpisDir,dFiles{2}(1,:)),...
                      fullfile(data_dir,TromsoDir,dFiles{3}(1,:)));
  stns = tomo_inp_images(file_list,[],POs([1 2 3]));
else
end

%% 3 Set up block-of-blobs
%
% Observations were made above Skibotn
%r_B = stns(1).obs.xyz;

%load stationpos.inm  % OLD OLD VERSION
%r_B = stationpos(10,:);

%r_B = stns(1).obs.pos; % OLD VERSION
r_B = stns(1).obs.xyz;


%% 3.1 Allocate space for blobs
%% TBD
Vem = zeros([100 100 74]);% dRes = 2;Vem = zeros([100 100 74]*dRes);
% set the lower south-west corner:
ds = 2.5; % resolution of 2.5 km   ds = 2.5/dRes;
%% TBD
r0 = [-128 -64 80];
r0 = r_B + [-64*ds -128*ds 80]+[10 0 0];
r0 = [-170 -120 80];
% Define the lattice unit vectors
dr1 = [ds 0 0];
dr2 = [0 ds 0];
% With e3 || vertical:
dr3 = [0 0 ds];
% or || magnetic zenith:
dr3 = [0 -ds*tan(pi*12/180) ds];

%% 3.2 Calculate duplicate arrays for the position of the base functions:
[r,X,Y,Z] = sc_positioning(r0,dr1,dr2,dr3,Vem);
XfI = r0(1)+dr1(1)*(X-1)+dr2(1)*(Y-1)+dr3(1)*(Z-1); % XfI(:,43,:) at EISCAT     , 2.5 km resol
YfI = r0(2)+dr1(2)*(X-1)+dr2(2)*(Y-1)+dr3(2)*(Z-1); % YfI(70,:,10) at 100 km alt, 2.5 km resol
ZfI = r0(3)+dr1(3)*(X-1)+dr2(3)*(Y-1)+dr3(3)*(Z-1); % ZfI(1,1,10) 100 km height , 2.5 km resol


%% 4 Do the projection characteristics of the cameras
%
%% 4.1 Set the number of size layers 
% the projection algorithm divides the base into classes based on
% the size of their footprint in the image. Here it is needed to
% select the number of layers to use in the image projection, more
% is better and slower: 8 minimum, 10 better, 16 getting on the
% slow side... % 10 by default
nr_layers = 17;
%%## Added this here, so that the calls to MSIS is in the top
%    set-up script - that way we'll see it and know to change it
%    for other events...

%% 4.2 Creating the station structure 
% Here we make the structure array holding the projection matrix,
% the filter kernels and size grouping of the base functions needed
% for the fast projection.
% Set up the stuff on the camera and 3D structure needed for the
% fast projection.
for i1 = 1:length(stns),
  
  rstn = stns(i1).obs.xyz;  
  %  rstn = stns(i1).obs.pos;   % OLD VERSION % Position of station i1
  % optpar = stns(i1).optpar;  % Optical parameters of station i1
  optpar = POs(i1).optpar;  % Optical parameters of station i1
  imgsize{i1} = size(stns(i1).img);  % Image size of station i1
  cmtr = stns(i1).obs.trmtr;
  %  cmtr = stns(i1).obs.cmtr; % OLD VERSION % Correction matrix of station i1
  [stns(i1).uv,stns(i1).d,stns(i1).l_cl,stns(i1).bfk,stns(i1).ds,stns(i1).sz3d] = camera_set_up_sc(r,...
                                                    X,...
                                                    Y,...
                                                    Z,...
                                                    optpar,...
                                                    rstn,...
                                                    imgsize{i1},...
                                                    nr_layers,...
                                                    cmtr);
  
end

for i1 = 1:length(stns),
  %stns(i1).r = stns(i1).obs.pos;
  stns(i1).r = stns(i1).obs.xyz; % MY NEW VERSION
end


%% Quirky fix:
stns(3).img = flipud(stns(3).img);

%% 4.3 Test of fast projection
% To make sure we have gotten it all right this far we calculate the
% image of a flat 3-D distribution for all cameras
for i1 = 1:length(stns),
  stns(i1).proj = fastprojection(ones(size(X)),...
                                 stns(i1).uv,...
                                 stns(i1).d,...
                                 stns(i1).l_cl,...
                                 stns(i1).bfk,...
                                 [256 256],1,stns(i1).sz3d);
  subplot(2,2,i1)
  imagesc(stns(i1).img)
  cX{i1} = caxis;
  hold on
  contour(stns(i1).proj,8,'k')
  caxis(cX{i1})
end


%% 5 Start with the actual reconstructions

%% 5.1 Begin with making start guesses.
tomo_ops = make_tomo_ops(stns);
tomo_opssirt = tomo_ops;
%tomo_opssirt.tomo_type = 2; % BUG
%for i=1:length(tomo_opssirt)
i=1;
tomo_opssirt(i).tomotype = 2;
%end
tomo_artops = tomo_ops(1);
try
  tomo_ops34 = tomo_ops(3:4);
catch
  tomo_ops34 = tomo_ops(2:3);
end
% Use Chapman altitude profiles, peak altitude 110 km and 15 km wide
% Not used any more. Next three lines put in comment (Aug. 2011)
%alt_max5577 = 110;
%width = 15;
%Vem0 = tomo_start_guess1(stns(1),alt_max5577,width,XfI,YfI,ZfI);

%% New routine startguess with aeronomic calculations. Dec 2010 - Aug. 2011
if strcmp(Uname, 'bgu001') %%## adjusted here too
  analys_dir = pwd;
else
end
cd(analys_dir);

%%## Changed energy grid to be linear in velocity, and extended
%%## highest energy to 20 keV.
Energy =linspace(50.^.5,20000.^.5,100).^2;

% altalis=ZfI(1,1,:);
% iso=2;
% zalis=squeeze(altalis);
% 
% % Initialisation of aeronomic start guess
% Am = matdegrad3_alis_tomo(Energy,iso,zalis);
% mu_E  = 2000; % 1000 eV of characteristic mean energy of the gaussian (default = 100 eV)
% sig_E = 500;  % variance of the gaussian (default = 50 eV)
% Par= [mu_E, sig_E];
% 
% factor = 0.256; % taken from Janhunen, 2001, himself taken from Rees and Luckey 1974
% Am = Am * 1e-3 * factor; % Am in cm-1. Factor 0.256 only for 1 keV electrons, Janhunen
% Vem0 = aeronomic_alt4tomo(Par,stns(1),Am,Energy,XfI,YfI,ZfI,tomo_ops);
% %cd /home/cyrils/projects/ALIS/stdnames/2008/03/05/18;
% cd(data_dir2); % cd back to the data directory chosen before
% 
% 
% 
% %%
% % Take quick look of this...
% close;
% slice(Vem0,47,50,20),shading interp,
% pause(3)
% slice(Vem0,47,50,20),shading interp,view(0,90)
% pause(3)
% slice(Vem0,47,50,20),shading interp,view(90,0)

%% 5.2 Intensity scaling
% This start guess should then be scaled.
% Function to scale 3D intensities to give projections that are in
% the same intensity range as the images. Not needed here since the
% function is already called from within TOMO_START_GUESS, but
% might be useful in the working process.
% [stns,Vem] = adjust_level(stns,Vem,1);

%% 5.3 Tomographic update (flat field):
% Here are the iterative tomographic steps and filtering made.
[POs(1).ffc] = ffs_correction2(imgsize{1},POs(1).optpar,3);
[POs(2).ffc] = ffs_correction2(imgsize{2},POs(2).optpar,3);
[POs(3).ffc] = ffs_correction2(imgsize{3},POs(3).optpar,3);

%[POs(4).ffc] = ffs_correction2(imgsize{4},POs(4).optpar,3);

%% 5.4 Selected cuts and colour filters
% Here we select 2 horisontal cuts and three vertical cuts through
% the block-of-blobs
% zoom in this to select the indices for slices in y-directions...
%% TBD
i_z = [10 12 14 16 18 20 22 24 26]; % 100 105 110 115 120 125 130 135 140 km
i_x = [39:2:45,61];%38 43 61];    % "good", 43 <-> EISCAT, 61 <-> Skibotn
i_y = [70];       % EISCAT

% XfI(:,i_x(...),:) - horizontal distance east of Kiruna in km, 2.5 km
%                     resolution. XfI(i_y,i_x,I_z) 
%                     ex. XfI(:,43,:) = plane X situated -47 km from
%                     Kiruna, containing EISCAT Tromso
% YfI(i_y(...),:,:) - distance north of Kiruna in km (since we are working
%                     with a 3D-block skewed to be parallel to the magnetic
%                     zenith, each layer is translated to dl * tan(mag_Ze)
%                     to the south, 2.5 km resolution. YfI(i_y,i_x,I_z)
%                     ex. YfI(70,:,1) = plane Y situated 140-180 km away
%                     from Kiruna, containing EISCAT Tromso
% ZfI(:,:,i_z(3))   - altitude of projection in km, 2.5 km resolution

%%## This might just as well go?
[alts,widths] = meshgrid([100,105,110,115,120,125,130,135],[10,15]);

%%## This was commented out, just mnemonix for indexicing?
%for i2 = length(i_tb):-1:1,
%for i2 = 57:-1:1,
%for i2 = 65:-1:36,
%i_T = i_tb; % Choose only Blue emissions N2+ 4278 A
%i_T = i_tg; % Green line OI 5577A
%i_T = i_tr; % Red line OI 6300A
%i_T = i_to; % OI 8446A

cd(analys_dir); % save to analysis directory defined l. 287


%% 5.4.2 GACT to Start Guess 
%        GAC SNIPPET!!!!!
%% 5.4.2.1 Set-up for GACT-in-slices
%%## Added this here - should be only set-up for the slice thingy
%%## in this script...

%% Automatic triangulation function to determine the peak altitude of 
% the emissions and hence the first guess for the tomography reconstruction
% of ALIS.
% to be called in tomography script
% Bjorn Gustavsson (c) 2012
% mod. C. Simon Wedlund Jan. 2012


%%## Clunky-fix of lookup-things for tomo_setup4reduced2D:
stns(1).obs.optpar = POs(1).optpar;
stns(2).obs.optpar = POs(2).optpar;
stns(3).obs.optpar = POs(3).optpar;
%%## That function looks for the optpars in stns.obs.optpar - I
%%## dont dare to fidget around too much at the moment to change
%%## this... 

OPS4red2D = tomo_setup4reduced2D;
OPS4red2D.PlotStuff = 1;  % plots activated or not
OPS4red2D.ds = 1;
OPS4red2D.zmax = 115;
%% Determines the directions of the plane intersecting the two first
% stations and parallel to the B-field, as a reference plane for future
% projections. First station is Skibotn and is the reference station.
% 1D slices/cuts of the intensity distribution in this plane will be used
% to determine the altitude/energy/intensity for the first guess of the
% tomography reconstruction
[M2Dto1D_12,U12,V12,X12,Y12,Z12] = tomo_setup4reduced2D(stns(1:2),OPS4red2D);
[M2Dto1D_13,U13,V13,X13,Y13,Z13] = tomo_setup4reduced2D(stns([1,3]),OPS4red2D);

%NEEEEEEEEEEEEEeeeeeeeeeeeewwwwwwwwwwwwwwsssssssssss! 20120220
% Am we need for calculations in the 2-D slice, that has its own
% altitude grid - I know, this will force us to more
% reinterpolations and mess...
z2D = squeeze(Z12(1,1,:)); % This is the altitude grid we need to
                           % calculate the auroral production
                           % matrices for.

%% Reinterpolate the atmosphere to the z2D grid:
nO =   interp1(h_msis,O,z2D,'linear','extrap');
nN2 =  interp1(h_msis,N2,z2D,'linear','extrap');
nO2 =  interp1(h_msis,O2,z2D,'linear','extrap');
Mass = interp1(h_msis,Mass,z2D,'linear','extrap');
Tn  =  interp1(h_msis,T,z2D,'linear','extrap');
nH =   interp1(h_msis,H,z2D,'linear','extrap');
nAr =  interp1(h_msis,Ar,z2D,'linear','extrap');
nN =   interp1(h_msis,N,z2D,'linear','extrap');
nHe =  interp1(h_msis,He,z2D,'linear','extrap');
Tex =  interp1(h_msis,Tex,z2D,'linear','extrap');

semilogx([nN2,nO2,nO,Mass],z2D)

%%## Removed, due to no clue about opts4ISR2IeofE: Am = ionization_profile_matrix(z2D,Energy,nO,nN2,nO2,Mass,opts4ISR2IeofE);
Am = ionization_profile_matrix(z2D,Energy,nO,nN2,nO2,Mass);
%%## Change here to more real altitude
%production-profile-matrices... (If even needed, it is needed for
%getting a physical intepretation of the starttguesses' electron
%spectra, not necessarily otherwise...)
Ie2H5577 = Am;
Ie2H4278 = Am;
Ie2H = {Ie2H5577,Ie2H5577}; % This one will be used by the
                            % err_GACT-function...




%%## I guess the looping should begin here with reading in images
%%## then the indices to tomo_arcpeakfinderinslice has to be
%%## checked/changed, and the code in NewGACT_snippetEND too...
%% 5.4.2.2 "Arc"-finding in slice
%%## Here is what I run for the set of images you sent me (once
%%## uppon a time...)
OPS4tarc = tomo_arcpeakfinderinslice
OPS4tarc.ipng = 1;
OPS4tarc.zmax = 118;
clf
[I_cuts,iPeaks] = tomo_arcpeakfinderinslice(stns([1,2]),U12,V12,OPS4tarc);
%%## tomo_arcpeakfinderinslice is simply the part of the scrip you
%%## did when I visited, with all the peak-finding and such,
%%## wrapped into a function. It is not necessarily the neatest of
%%## functions but at least it is wrapped a bit...

%% 5.4.2.3 GACT-StartGuess
%%## Here we fit the intensity-energy-precipitation in the plane between
%   stations 1 & 2 by minimizing tomo_err4GACT then extrapolating those
%   intensities to the entire 3-D bob...
% NewGACT_snippetEND
% [Vem,I2D] = tomo_start_guessGACT(stns,Energy,Ie2H,Xslice,Yslice,Zslice,M2Dto1D,U,V,I_cuts,iPeaks,X3D,Y3D,Z3D,ops);
[Vem,I2D] = tomo_start_guessGACT(stns(1:2),Energy,Ie2H,X12,Y12,Z12,M2Dto1D_12,U12,V12,I_cuts,iPeaks,XfI,YfI,ZfI,OPS4tarc);
%%## This should produce something nice here!:
clf
tomo_slice_i(XfI,YfI,ZfI,Vem,32,65,12),shading flat
StartGuess.Vem = Vem; % Keep the start guess aside -%%## add indices to this one...
%% 5.5 Reconstructions
% 
        
% 5.5.3 Set the number of iterative loops
nr_laps = 1;    % Number of iterations (over all stations)
fS = [7 5 3 3]; % Filter-kernel size

% 5.5.4 Calculate filter kernel
i_f = 1;
[xf,yf] = meshgrid(1:fS(i_f),1:fS(i_f));
fK = exp(-(xf-mean(xf(:))).^2/mean(xf(:)).^2-(yf-mean(yf(:))).^2/mean(yf(:))^2);
tomo_ops(1).filterkernel = fK;
tomo_opssirt(1).disp = 'disp';
% 5.5.5 Start with reconstruction %%## play around with the reconstruction
%%## versions and such again perhaps.
for i_f = 2:length(fS),
  [xf,yf] = meshgrid(1:fS(i_f),1:fS(i_f));
  fK = exp(-(xf-mean(xf(:))).^2/mean(xf(:)).^2-(yf-mean(yf(:))).^2/mean(yf(:))^2);
  tomo_opssirt(1).filterkernel = fK;
  [Vem,stns] = tomo_steps(Vem,...
                          stns,...
                          tomo_opssirt,2);
   
end
%%## From here also add back all the slicing-n-cutting through Vem...

%   Copyright � 20120130 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later
