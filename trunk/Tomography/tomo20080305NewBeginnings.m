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
dateNtime4MSIS = [2008 3 5 18 41 10]; % Changed change to take
                                      % stns(1).obs.time and
                                      % longlat as input to msis!
   
MSISpars_f107af107pap = [70,87,3];
%% 0 Definition of Home Directory
Uname = getenv('USERNAME'); %%## Changed stuff here to make this
                            %"run" both here and for you...
if strcmp(Uname,'bjorn') % Yup that's my Soton name...
  homedir = '/home/bjorn/';
else
  homedir = '/bira-iasb/home/cyrils/';
end
%% 1 Locating the data
  % Just set this to where the data is located on your local media.
  

if strcmp(Uname,'bjorn') % and I "don't like it very much"...
  data_dir = strcat(homedir,'Downloads/Cyril/');
else
  data_dir = strcat(homedir,'projects/ALIS/stdnames/');
end
cd(data_dir);
  
  
%% 1.1 Read the list of ALIS-ASK events
  % This will give us information about the interesting time
  % periods and which ALIS stations have data available.
if strcmp(Uname,'bjorn') % and I "don't like it very much"...
  % For my version of this I just run everything for the images you
  % sent me - so nooo looping,,,
else
  alis_events = strcat(homedir,'ALIS/analysis/tomography_2008/ALIS-events-2008.txt');
  events = alis_event_reader(alis_events);
end
%% 1.2 Set up for data pre-processing
  % The preprocessing options will be needed anyway, so we migh
  % just as well set them early on.
  PO = typical_pre_proc_ops;
  PO.find_optpar = 0;   % Dont look for optpar in the data base
  PO.fix_missalign = 0; % ...and dont whine about it either
  PO.central_station = 10;
  POs(1:7) = PO;        % replicate this for all stations

%  PO = typical_pre_proc_ops;
%  PO.find_optpar = 0;
%  PO.fix_missalign = 0;
%  PO.central_station = 11;
%  POs(1:7) = PO;

  i1 = 1;
%% 1.3 Get lists with all files of interest
if strcmp(Uname,'bjorn') % and I "don't like it very much"...
  % For my version of this I just run everything for the images you
  % sent me with the optical parameters
  silkim  = load('S03_2008030520220000S.acc'); % *S*ilkimuotka
  abisko  = load('S05_2008030521420000A.acc'); % *A*bisko
  skibotn = load('S010_2008030519200000B.acc');% Ski*B*otn
  tjaut   = load('S04_2008030521420000T.acc'); % *T*jautjas
  
  optpB = skibotn([7:14 6 end]);
  optpA = abisko([7:14 6 end]);
  optpT = tjaut([7:14 6 end]);
  optpS = silkim([7:14 6 end]);

  dFiles = {'2008030518411000B.fits','2008030518411000S.fits','2008030518411000T.fits'};
else
  dFiles = alis_find_data2(events(i1).stns,...
                           events(i1).date,...
                           events(i1).start_time,...
                           events(i1).stop_time,...
                           data_dir);
% Data directory
  data_dir2 = strcat(data_dir,'2008/03/05/18');
  cd(data_dir2);
  
%% 1.4 Load optical parameters
  % On my computer I apparently stored the optpars in this
  % directory. Adjust after local conditions...
  silkim  = load('/home/cyrils/ALIS/analysis/tomography_2008/S03_2008030520220000S.acc'); % *S*ilkimuotka
  abisko  = load('/home/cyrils/ALIS/analysis/tomography_2008/S05_2008030521420000A.acc'); % *A*bisko
  skibotn = load('/home/cyrils/ALIS/analysis/tomography_2008/S010_2008030519200000B.acc');% Ski*B*otn
  tjaut   = load('/home/cyrils/ALIS/analysis/tomography_2008/S04_2008030521420000T.acc'); % *T*jautjas
%  kiruna  = load('/home/cyrils/ALIS/analysis/tomography_2008/S07_2008030521420000K.acc'); % *K*iruna
  
%%
  % This is how to sort the actual optpars out of an *.acc file
  optpB = skibotn([7:14 6 end]);
  optpA = abisko([7:14 6 end]);
  optpT = tjaut([7:14 6 end]);
  optpS = silkim([7:14 6 end]);
 % optpK = kiruna([7:14 6 end]);
end  
  
%% - TO CHANGE WHEN STATIONS CHANGE
  % Assign the optical parameters to the corresponding PO-structs
POs(1).optpar = optpB; % Ski*B*otn
POs(2).optpar = optpA; % *A*bisko
POs(3).optpar = optpS; % *S*ilkimuotka
                       %POs(4).optpar = optpK;                        % KIRUNA NOT TO INCLUDE
POs(6).optpar = optpT; % *T*jautjas

if 0 %%## I skip this part completely just to get out of all the
     % looping...
     % Put back in as you need when you've gotten things to hum
     % along again... 
  
%% 1.5 Make keograms for data overviewing - TO CHANGE WHEN STATIONS CHANGE
  % This we do to find times where we have data at all stations in
  % one emission, and to get an overview of exposure times, and
  % auroral activity...
  for i2 = [1 2 3 6],
    [keoBAST{i2},exptimes{i2},Tstrs{i2},filters{i2},optps{i2}] = imgs_keograms(dFiles{i2},120,0,POs(i2).optpar,POs(i2));
  % Apparently Tstrs contains an array with full date-time of an
  % observation [y,m,d,h,m,s] so here we calculate hour-of-day
  % for each exposure.
    t{i2} = Tstrs{i2}(:,4) + Tstrs{i2}(:,5)/60 + Tstrs{i2}(:,6)/3600;
  end
  
    
%% 1.6 Sort out which exposures we really have 4278 from everywhere. - TO
%% CHANGE WHEN STATIONS CHANGE 
  if 1
    plot(t{1}(filters{1}==4278),1,'b.','markersize',18)
    hold on
    plot(t{1}(filters{1}==5577),1,'g.','markersize',18)
    plot(t{1}(filters{1}==6300),1,'r.','markersize',18)
    plot(t{1}(filters{1}==8446),1,'k.','markersize',18)
    
    plot(t{2}(filters{2}==4278),2,'b.','markersize',18)
    plot(t{2}(filters{2}==5577),2,'g.','markersize',18)
    plot(t{2}(filters{2}==6300),2,'r.','markersize',18)
    %plot(t{2}(filters{2}==8446),2,'k.','markersize',18)
    
    plot(t{3}(filters{3}==4278),3,'b.','markersize',18)
    plot(t{3}(filters{3}==5577),3,'g.','markersize',18)
    plot(t{3}(filters{3}==6300),3,'r.','markersize',18)
    plot(t{3}(filters{3}==8446),3,'k.','markersize',18)
    
%    plot(t{4}(filters{4}==4278),4,'b.','markersize',18)  % Kiruna
%    plot(t{4}(filters{4}==5577),4,'g.','markersize',18)
%    plot(t{4}(filters{4}==6300),4,'r.','markersize',18)
    %plot(t{4}(filters{4}==8446),4,'k.','markersize',18)  
    
    plot(t{6}(filters{6}==4278),4,'b.','markersize',18)
    plot(t{6}(filters{6}==5577),4,'g.','markersize',18)
    plot(t{6}(filters{6}==6300),4,'r.','markersize',18)
    plot(t{6}(filters{6}==8446),4,'k.','markersize',18)  % Only 4 stations are taken to begin with, Kiruna out
  end
  
  % Change here the UT time suiting your data for consistent plotting. Here 18:40
  timetick;
  %axis([18+40/60 18+55/60 0 5])
  axis([t{1}(1) t{1}(end) 0 5]);
  %%
  i_tb = find(filters{1}==4278); % Select only images with filter 4278 A
  i_tg = find(filters{1}==5577);
  i_tr = find(filters{1}==6300);
  i_to = find(filters{1}==8446);
  
  % That stuff above was assuming that the observations were done with some
  % sensible filter sequence where the same filters were used at each
  % station. Somehow, the person designing the filter-sequence tried to
  % outsmart reality. This obviously did not work as he planned...
  
  i_stns = [1,2,3,6];  % select Skibotn, Abisko, Silkkimuotka and Tjautjas
  for iT = 1:length(filters{1})
    filters4thisTime = [filters{i_stns(1)}(iT),filters{i_stns(2)}(iT),filters{i_stns(3)}(iT),filters{i_stns(4)}(iT)];
    iOK = find(filters4thisTime==filters{1}(iT));
    inmgs2read4time{iT} = i_stns(iOK);
  end
  
end

%% 2 Tomography set-up
%
%% Setting up the "station-struct"   - TO CHANGE WHEN STATIONS CHANGE
% Here we start with setting up the "station-struct"
% First put together a list of one file from each station
%file_list = char(dFiles{1}(145,:),dFiles{2}(145,:),dFiles{3}(145,:),dFiles{6}(145,:));

%file_list = char(dFiles{1}(12,:),dFiles{2}(12,:),dFiles{3}(12,:),dFiles{4}(12,:),dFiles{5}(12,:),dFiles{6}(12,:));

%%## Changed here too...
if strcmp(Uname,'bjorn') % Yup that's my Soton name...
  ii = 1; 
  file_list = char(dFiles{1}(ii,:),dFiles{2}(ii,:),dFiles{3}(ii,:));
  stns = tomo_inp_images(file_list,[],POs([1 3 6]));
else
  ii = 5; 
  file_list = char(dFiles{1}(ii,:),dFiles{2}(ii,:),dFiles{3}(ii,:),dFiles{6}(ii,:));
  stns = tomo_inp_images(file_list,[],POs([1 2 3 6]));
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
Vem = zeros([100 100 74]);% dRes = 2;Vem = zeros([100 100 74]*dRes);
% set the lower south-west corner:
ds = 2.5; % resolution of 2.5 km   ds = 2.5/dRes;
r0 = [-128 -64 80];
r0 = r_B + [-64*ds -64*ds 80]+[10 0 0];
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
  
  rstn = stns(i1).obs.xyz;  %
%  rstn = stns(i1).obs.pos;   % OLD VERSION % Position of station i1
  optpar = stns(i1).optpar;  % Optical parameters of station i1
  imgsize = size(stns(i1).img);  % Image size of station i1
  cmtr = stns(i1).obs.trmtr;
%  cmtr = stns(i1).obs.cmtr; % OLD VERSION % Correction matrix of station i1
  [stns(i1).uv,stns(i1).d,stns(i1).l_cl,stns(i1).bfk,stns(i1).sz3d] = camera_set_up_sc(r,...
                                                    X,...
                                                    Y,...
                                                    Z,...
                                                    optpar,...
                                                    rstn,...
                                                    imgsize,...
                                                    nr_layers,...
                                                    cmtr);
  
end

for i1 = 1:length(stns),
  %stns(i1).r = stns(i1).obs.pos;
  stns(i1).r = stns(i1).obs.xyz; % MY NEW VERSION
end

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
if strcmp(Uname,'bjorn') %%## adjusted here too
  analys_dir = pwd;
else
  analys_dir = strcat(homedir,'ALIS/analysis/tomography_2008/');
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
[POs(1).ffc] = ffs_correction2(imgsize,POs(1).optpar,3);
[POs(2).ffc] = ffs_correction2(imgsize,POs(2).optpar,3);
[POs(3).ffc] = ffs_correction2(imgsize,POs(3).optpar,3);
[POs(6).ffc] = ffs_correction2(imgsize,POs(6).optpar,3);

%[POs(4).ffc] = ffs_correction2(imgsize,POs(4).optpar,3);

%% 5.4 Selected cuts and colour filters
% Here we select 2 horisontal cuts and three vertical cuts through
% the block-of-blobs
% zoom in this to select the indices for slices in y-directions...
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
newGACT_snippetStart

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
