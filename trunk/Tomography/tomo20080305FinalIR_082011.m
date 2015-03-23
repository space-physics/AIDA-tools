% TOMO20080305FinalIR_082011 - script for tomographing ALIS 20080305 event, 18:40 UT
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

%% 0 Definition of Home Directory
homedir = '/bira-iasb/home/cyrils/';

%% 1 Locating the data
  % Just set this to where the data is located on your local media.
  
  data_dir = strcat(homedir,'projects/ALIS/stdnames/');
  cd(data_dir);
  
  
%% 1.1 Read the list of ALIS-ASK events
  % This will give us information about the interesting time
  % periods and which ALIS stations have data available.
  alis_events = strcat(homedir,'ALIS/analysis/tomography_2008/ALIS-events-2008.txt');
  events = alis_event_reader(alis_events);

%% 1.2 Set up for data pre-processing
  % The preprocessing options will be needed anyway, so we migh
  % just as well set them early on.
  PO = typical_pre_proc_ops;
  PO.find_optpar = 0;   % Dont look for optpar in the data base
  PO.fix_missalign = 0; % ...and dont whine about it either
  PO.central_station = 11;
  POs(1:7) = PO;        % replicate this for all stations

%  PO = typical_pre_proc_ops;
%  PO.find_optpar = 0;
%  PO.fix_missalign = 0;
%  PO.central_station = 11;
%  POs(1:7) = PO;

  i1 = 1;
%% 1.3 Get lists with all files of interest
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
  kiruna  = load('/home/cyrils/ALIS/analysis/tomography_2008/S07_2008030521420000K.acc'); % *K*iruna
  
%%
  % This is how to sort the actual optpars out of an *.acc file
  optpB = skibotn([7:14 6 end]);
  optpA = abisko([7:14 6 end]);
  optpT = tjaut([7:14 6 end]);
  optpS = silkim([7:14 6 end]);
  optpK = kiruna([7:14 6 end]);
  
%%
  % Assign the optical parameters to the corresponding PO-structs
  POs(1).optpar = optpB; % Ski*B*otn
  POs(2).optpar = optpA; % *A*bisko
  POs(3).optpar = optpS; % *S*ilkimuotka
  POs(6).optpar = optpT; % *T*jautjas
  POs(4).optpar = optpK; % *K*iruna

%% 1.5 Make keograms for data overviewing
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
  
    
%% 1.6 Sort out which exposures we really have 4278 from everywhere.
  if 1
    plot(t{1}(filters{1}==4278),1,'b.','markersize',18)
    hold on
    plot(t{1}(filters{1}==5577),1,'g.','markersize',18)
    plot(t{1}(filters{1}==6300),1,'r.','markersize',18)
    plot(t{1}(filters{1}==8446),1,'k.','markersize',18)
    plot(t{2}(filters{2}==4278),2,'b.','markersize',18)
    plot(t{2}(filters{2}==5577),2,'g.','markersize',18)
    plot(t{2}(filters{2}==6300),2,'r.','markersize',18)
    plot(t{3}(filters{3}==4278),3,'b.','markersize',18)
    plot(t{3}(filters{3}==5577),3,'g.','markersize',18)
    plot(t{3}(filters{3}==6300),3,'r.','markersize',18)
    plot(t{6}(filters{6}==4278),4,'b.','markersize',18)
    plot(t{6}(filters{6}==5577),4,'g.','markersize',18)
    plot(t{6}(filters{6}==6300),4,'r.','markersize',18)
    plot(t{6}(filters{6}==8446),4,'k.','markersize',18)  % Only 4 stations are taken to begin with, Kiruna out
  end
  
  % Change here the UT time suiting your data for consistent plotting. Here 18:40
  timetick
  axis([18+35/60 18+45/60 0 5])
  
  i_tb = find(filters{1}==4278); % Select only images with filter 4278 A
  i_tg = find(filters{1}==5577);
  i_tr = find(filters{1}==6300);
  i_to = find(filters{1}==8446);

%end

%% 2 Tomography set-up
%
%% Setting up the "station-struct"
% Here we start with setting up the "station-struct"
% First put together a list of one file from each station
%file_list = str2mat(dFiles{1}(145,:),dFiles{2}(145,:),dFiles{3}(145,:),dFiles{6}(145,:));
file_list = char(dFiles{1}(12,:),dFiles{2}(12,:),dFiles{3}(12,:),dFiles{6}(12,:));

stns = tomo_inp_images(file_list,[],POs([1 2 3 6]));


%% 3 Set up block-of-blobs
%
% Observations were made above Skibotn
%r_B = stns(1).obs.xyz;

%load stationpos.inm  % OLD VERSION
%r_B = stationpos(10,:);

% r_B = stns(1).obs.pos; % MY NEW VERSION
r_B = stns(1).obs.xyz; % MY NEW VERSION

%% 3.1 Allocate space for blobs
nx = 200;
ny = 200;
nz = 148;
nds = 2.5*100/nx;

%Vem = zeros([100 100 74]);
Vem = zeros([ny nx nz]);

% set the lower south-west corner:
%ds = 2.5; % resolution of 2.5 km
ds = nds;

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
nr_layers = 12;  % try 20

%% 4.2 Creating the station structure 
% Here we make the structure array holding the projection matrix,
% the filter kernels and size grouping of the base functions needed
% for the fast projection.
% Set up the stuff on the camera and 3D structure needed for the
% fast projection.
for i1 = 1:length(stns),
  
  rstn = stns(i1).obs.xyz;  %
  % rstn = stns(i1).obs.pos;   % MY NEW VERSION % Position of station i1
  optpar = stns(i1).optpar;  % Optical parameters of station i1
  imgsize = size(stns(i1).img);  % Image size of station i1
  %  cmtr = stns(i1).obs.trmtr;
  cmtr = stns(i1).obs.cmtr; % Correction matrix of station i1
  [stns(i1).uv,stns(i1).d,stns(i1).l_cl,stns(i1).bfk] = camera_set_up_sc(r,...
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
  %  stns(i1).r = stns(i1).obs.pos; % MY NEW VERSION
  stns(i1).r = stns(i1).obs.xyz;
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
                                 [256 256],1);
  subplot(2,2,i1)
  imagesc(stns(i1).proj)
  
end


%% 5 Start with the actual reconstructions

%% 5.1 Begin with making start guesses.
tomo_ops = make_tomo_ops(stns);
tomo_opssirt = tomo_ops;
%tomo_opssirt.tomo_type = 2; % BUG
tomo_opssirt(1).tomotype = 2;
tomo_artops = tomo_ops(1);
tomo_ops34 = tomo_ops(3:4);

% Use Chapman altitude profiles, peak altitude 110 km and 15 km wide
% Not used any more. Next three lines put in comment (Aug. 2011)
%alt_max5577 = 110;
%width = 15;
%Vem0 = tomo_start_guess1(stns(1),alt_max5577,width,XfI,YfI,ZfI);
 
%% New routine startguess with aeronomic calculations. Dec 2010 - Aug. 2011
analys_dir = strcat(homedir,'ALIS/analysis/tomography_2008/');
cd(analys_dir);

Energy =linspace(50,10000,400);
altalis=ZfI(1,1,:);
iso=2;
zalis=squeeze(altalis);

% Initialisation of aeronomic start guess
Am = matdegrad3_alis_tomo(Energy,iso,zalis);
mu_E  = 2000; % 1000 eV of characteristic mean energy of the gaussian (default = 100 eV)
sig_E = 800;  % variance of the gaussian (default = 50 eV)
Par= [mu_E, sig_E];

factor = 0.256; % taken from Janhunen, 2001, himself taken from Rees and Luckey 1974
Am = Am * 1e-3 * factor; % Am in cm-1. Factor 0.256 only for 1 keV electrons, Janhunen
Vem0 = aeronomic_alt4tomo(Par,stns(1),Am,Energy,XfI,YfI,ZfI,tomo_ops);
%cd /home/cyrils/projects/ALIS/stdnames/2008/03/05/18;
cd(data_dir2); % cd back to the data directory chosen before

%%
% Take quick look of this...
close;
slice(Vem0,47*ny/100,50*nx/100,20*nz/100),shading interp,
pause(3)
slice(Vem0,47,50,20),shading interp,view(0,90)
pause(3)
slice(Vem0,47,50,20),shading interp,view(90,0)

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

%% 5.4 Selected cuts and colour filters
% Here we select 2 horisontal cuts and three vertical cuts through
% the block-of-blobs
% zoom in this to select the indices for slices in y-directions...
i_z = [10 12 14 16 20 22 24 26 28]; % 100 105 110 115 120 125 130 135 140 km
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

[alts,widths] = meshgrid([100,105,110,115,120,125,130],[10,15]);
%for i2 = length(i_tb):-1:1,
%for i2 = 57:-1:1,
%for i2 = 65:-1:36,
i_T = i_tb; % Choose only Blue emissions N2+ 4278 A
%i_T = i_tg; % Green line OI 5577A
%i_T = i_tr; % Red line OI 6300A
%i_T = i_to; % OI 8446A

cd(analys_dir); % save to analysis directory defined l. 248
%% 5.5 Reconstructions
% In this loop we reconstruct the 3-D volume emission rates for all
% times with 4278 observations for all 4 stations.
for i2 = length(i_T):-1:1,
  
  i_stns = [1,2,3,6];

% 5.5.1 Reading of images
  for i3 = 1:length(i_stns)
    [d,h,o] = inimg(dFiles{i_stns(i3)}(i_T(i2),:),POs(i_stns(i3)));
    stns(i3).img = d;
    if i3 == 3
      stns(i3).img(227,195:197) = mean(stns(i3).img(227,[193,199])); 
      stns(i3).img(228,195:197) = mean(stns(i3).img(228,[193,199])); 
      stns(i3).img(229,195:197) = mean(stns(i3).img(229,[193,199])); 
      stns(i3).img(230,195:197) = mean(stns(i3).img(230,[193,199])); 
    end
  end
  disp([i3 i_stns(i3) o.time])
  
% 5.5.2 Start guess - modified Aug. 2011
  %[Vem0,stns] =
  %tomo_start_guess_altvar1([alts(:),widths(:)],stns,XfI,YfI,ZfI,tomo_ops);   % Chapman start guess
  [Vem0,stns] = aeronomic_alt4tomo(Par,stns,Am,Energy,XfI,YfI,ZfI,tomo_ops); % Aeronomic start guess
  
% 5.5.3 Set the number of iterative loops
  nr_laps = 1;    % Number of iterations (over all stations)
  fS = [7 5 3 3]; % Filter-kernel size
  Vem = Vem0;     % Keep the start guess aside
  
% 5.5.4 Calculate filter kernel
  i_f = 1;
  [xf,yf] = meshgrid(1:fS(i_f),1:fS(i_f));           
  fK = exp(-(xf-mean(xf(:))).^2/mean(xf(:)).^2-(yf-mean(yf(:))).^2/mean(yf(:))^2);
  tomo_ops(1).filterkernel = fK;
  
% 5.5.5 Start with reconstruction
  for i_f = 2:length(fS),
    [xf,yf] = meshgrid(1:fS(i_f),1:fS(i_f));            
    fK = exp(-(xf-mean(xf(:))).^2/mean(xf(:)).^2-(yf-mean(yf(:))).^2/mean(yf(:))^2);
    tomo_opssirt(1).filterkernel = fK;
    [Vem,stns(1:2)] = tomo_steps(Vem,stns(1:2),tomo_opssirt(1:2),2);
  end
  
% 5.5.6 Save away the reconstruction
  % ...in the selected slices, should be through EISCAT N-S, E-W,
  % Skibotn, and at 4 altitudes
  
  VsG(:,i2,:)  = Vem(:,i_x(1),:); % i_x = 39
  Vs39(:,i2,:) = Vem(:,i_x(1),:); % i_x = 39
  Vs41(:,i2,:) = Vem(:,i_x(2),:); % i_x = 41
  Vs43(:,i2,:) = Vem(:,i_x(3),:); % i_x = 43 <-> EISCAT
  Vs45(:,i2,:) = Vem(:,i_x(4),:); % i_x = 45
  Vs61(:,i2,:) = Vem(:,i_x(5),:); % i_x = 61 <-> Skibotn
  Vew(:,:,i2)  = Vem(i_y(1),:,:); % Difference in y plane  i_y=70, EISCAT
  Vh1(:,:,i2)  = Vem(:,:,i_z(1)); % Difference of altitudes i_z=9, 100 km
  Vh2(:,:,i2)  = Vem(:,:,i_z(2)); % i_z=12, 105 km
  Vh3(:,:,i2)  = Vem(:,:,i_z(3)); % i_z=14, 110 km
  Vh4(:,:,i2)  = Vem(:,:,i_z(4)); % i_z=16, 115 km
  Vh5(:,:,i2)  = Vem(:,:,i_z(5)); % i_z=20, 125 km
  Vh6(:,:,i2)  = Vem(:,:,i_z(6)); % i_z=22, 130 km
  Vh7(:,:,i2)  = Vem(:,:,i_z(7)); % i_z=24, 135 km
  
  % Writing away the temporary fits for Skibotn
  subplot(1,2,1)
  imagesc(stns(1).img)
  subplot(1,2,2)
  imagesc(stns(1).proj)
  %imgs_smart_caxis(0.003,stns(1).proj)
  
  altalis=ZfI(1,1,:);
  for ih=1:size(altalis),
    zalis(ih)=altalis(1,1,ih);
  end
  
  print('-dpng',['Skibotn_4278_August',sprintf('%03d',i_T(i2)),'.png'])
  cd(analys_dir); % save to analysis directory defined l. 248
  save(['tomo-',sprintf('%03d',i_T(i2)),'_MART_4278_August.mat'],'Vem','zalis','XfI','YfI','ZfI'); % save only filter 4278 AA
%  cd(data_dir2);  % back to the data directory
end
%keyboard
%% SAVE all VER reconstructed values for future exploitation
save(['tomo_Vh1-MART_1838-1843_4278_August.mat'],'Vh1','XfI','YfI','ZfI','Tstrs','i_T');
save(['tomo_Vh2-MART_1838-1843_4278_August.mat'],'Vh2','XfI','YfI','ZfI','Tstrs','i_T');
save(['tomo_Vh3-MART_1838-1843_4278_August.mat'],'Vh3','XfI','YfI','ZfI','Tstrs','i_T');
save(['tomo_Vh4-MART_1838-1843_4278_August.mat'],'Vh4','XfI','YfI','ZfI','Tstrs','i_T');
save(['tomo_Vh5-MART_1838-1843_4278_August.mat'],'Vh5','XfI','YfI','ZfI','Tstrs','i_T');
save(['tomo_Vh6-MART_1838-1843_4278_August.mat'],'Vh6','XfI','YfI','ZfI','Tstrs','i_T');
save(['tomo_Vh7-MART_1838-1843_4278_August.mat'],'Vh7','XfI','YfI','ZfI','Tstrs','i_T');
save(['tomo_VsG-MART_1838-1843_4278_August.mat'],'VsG','XfI','YfI','ZfI','Tstrs','i_T');
save(['tomo_Vew-MART_1838-1843_4278_August.mat'],'Vew','XfI','YfI','ZfI','Tstrs','i_T');
save(['tomo_Vs43-MART_1838-1843_4278_August.mat'],'Vs43','XfI','YfI','ZfI','Tstrs','i_T');


%% 6 Visualization
prefix = 'Figure_slices_120km_'

for i2 = 1:length(i_T)

  % Plot Vem altitude
  subplot(1,3,1)
  %pcolor(XfI(20:end,:,12),...
  %       YfI(20:end,:,12),...
  %       Vh6(20:end,:,i2))
  pcolor(XfI(:,:,12),...
         YfI(:,:,12),...
         Vh6(:,:,i2))
  %shading flat
  shading interp  % switch to interp to get a nicer curve (less pixelised)
  imgs_smart_caxis(0.003,squeeze(Vh6(:,:,i2)))
  cx2(i2,:) = caxis;
  %axis([-75 75 75 200])
  axis([-75 65 75 200])
  hold on;
  % Plots line of EISCAT position in latitude/longitude plane
  plot(XfI(1,i_x(1),12)*[1 1],[50 250],'w')
  plot([-100 100],173*[1 1],'w')
  annotation('textbox',[0.189 0.7361 0.08264 0.06561],...
    'String',{'UHF'},...
    'FontWeight','bold',...
    'FontSize',13,...
    'LineStyle','none',...
    'Color',[1 1 1]);
  hold off
  ylabel('Dist. S-N of Kiruna (km)','FontSize',13);
  xlabel('Dist. E-W of Kiruna (km)','FontSize',13);
  
  subplot(1,3,2)
  %pcolor(squeeze(YfI(20:end-10,12,:)),...
  %       squeeze(ZfI(20:end-10,12,:)),...
  %       squeeze(VsG(20:end-10,i2,:))) % CS 2010
  pcolor(squeeze(YfI(:,12,:)),...
         squeeze(ZfI(:,12,:)),...
         squeeze(VsG(:,i2,:))) % CS 2010
  %shading flat
  shading interp  % switch to interp to get a nicer curve (less pixelised)
  %imgs_smart_caxis(0.003,squeeze(VsG(30:end-10,i2,:)))
  imgs_smart_caxis(0.003,squeeze(VsG(:,i2,:)))
  cx1(i2,:) = caxis;
%  axis([50 190 80 250])
  axis([75 200 100 200])
  title(sprintf('BAST 2008-03-05 %02d:%02d:%02d',Tstrs{1}(i_tb(i2),4),Tstrs{1}(i_tb(i2),5),Tstrs{1}(i_tb(i2),6)),'fontsize',16);
  ylabel('Altitude (km)','FontSize',13);
  xlabel('Dist. S-N of Kiruna (km)','FontSize',13);
  
  % Plot against altitude
  subplot(1,3,3)
  pcolor(squeeze(XfI(12,:,:)),...
         squeeze(ZfI(12,:,:)),...
         squeeze(Vew(:,:,i2)))
  %shading flat
  shading interp  % switch to interp to get a nicer curve (less pixelised)
  %axis([-75 75 80 250])
  axis([-75 65 100 200])
  %imgs_smart_caxis(0.003,squeeze(Vew(:,:,i2)))
  %cx3(i2,:) = caxis;
  imgs_smart_caxis(0.003,squeeze(VsG(:,i2,:)))
  cx3(i2,:) = caxis;
  
  ylabel('Altitude (km)','FontSize',13);
  xlabel('Dist. E-W of Kiruna (km)','FontSize',13);

  
  drawnow
  %colorbar;%('location','southoutside');
  pause(0.2)

  print('-djpeg','-r100',sprintf('%s_%03d',prefix,i_tb(i2)) );
  
end

%%
for i2 = 1:length(i_T)
  subplot(1,3,1)
  pcolor(squeeze(YfI(20:end-10,12,:)),...
         squeeze(ZfI(20:end-10,12,:)),...
         squeeze(VsG(20:end-10,i2,:))) % CS 2010
  %shading flat
  shading interp  % switch to interp to get a nicer curve (less pixelised)
  imgs_smart_caxis(0.003,squeeze(VsG(30:end-10,i2,:)))
  cx1(i2,:) = caxis;
  axis([50 190 80 250])
  
  
  subplot(1,3,2)
  pcolor(XfI(20:end,:,12),...
         YfI(20:end,:,12),...
         Vh2(20:end,:,i2))
  %shading flat
  shading interp  % switch to interp to get a nicer curve (less pixelised)
  imgs_smart_caxis(0.03,squeeze(Vh2(30:end-10,:,i2)))
  cx2(i2,:) = caxis;
  axis([-75 75 75 200])
  title(sprintf('%02d:%02d:%02d',Tstrs{1}(i_tb(i2),4),Tstrs{1}(i_tb(i2),5),Tstrs{1}(i_tb(i2),6)),'fontsize',16)
  hold on
  plot(XfI(1,i_x(1),12)*[1 1],[50 250],'w')
  plot([-100 100],173*[1 1],'w')
  hold off
  
  
  subplot(1,3,3)
  pcolor(squeeze(XfI(12,:,:)),...
         squeeze(ZfI(12,:,:)),...
         squeeze(Vew(:,:,i2)))
  %shading flat
  shading interp  % switch to interp to get a nicer curve (less pixelised)
  
  axis([-75 75 80 250])
  imgs_smart_caxis(0.03,squeeze(Vew(:,:,i2)))
  cx3(i2,:) = caxis;
  
  
  drawnow
  pause(0.1)
end



%% 6.1 More Visualizations (commented for now)
% for i3 = 1:size(Vh1,3)
%   pcolor(XfI(I1z,I2z,i_z(3)),YfI(I1z,I2z,i_z(3)),Vh3(I1z,I2z,i3)),
%   shading flat
%   axis([-50 75 -100 25])
%   imgs_smart_caxis(0.005,Vh3(I1z,I2z,i3))
% end
% 
% for i2 = 1:72,
%   subplot(1,3,1)
%   pcolor(squeeze(YfI(20:end-10,12,:)),squeeze(ZfI(20:end-10,12,:)),squeeze(VsG(20:end-10,i2,:))),shading flat
%   imgs_smart_caxis(0.003,squeeze(VsG(30:end-10,i2,:)))
%   cx1(i2,:) = caxis;
%   axis([50 190 80 250])
%   subplot(1,3,2)
%   pcolor(XfI(20:end,:,12),YfI(20:end,:,12),Vh2(20:end,:,i2)),shading flat
%   imgs_smart_caxis(0.003,squeeze(Vh2(30:end-10,:,i2)))
%   cx2(i2,:) = caxis;
%   axis([-75 75 75 200])
%   title(sprintf('%02d:%02d:%02d',Tstrs{1}(i_tb(i2),4),Tstrs{1}(i_tb(i2),5),Tstrs{1}(i_tb(i2),6)),'fontsize',16)
%   hold on
%   plot(XfI(1,i_x(1),12)*[1 1],[50 250],'w')
%   plot([-100 100],173*[1 1],'w')
%   hold off
%   subplot(1,3,3)
%   pcolor(squeeze(XfI(12,:,:)),squeeze(ZfI(12,:,:)),squeeze(Vew(:,:,i2))),shading flat
%   axis([-75 75 80 250])
%   imgs_smart_caxis(0.003,squeeze(Vew(:,:,i2)))
%   cx3(i2,:) = caxis;
%   drawnow
%   pause(0.1)
% end
% for i2 = 1:72,
%   subplot(1,3,1)
%   pcolor(squeeze(YfI(:,12,:)),squeeze(ZfI(:,12,:)),squeeze(Vs1(:,i2,:))),shading flat
%   caxis(Cx1(i2,:))
%   axis([50 180 80 250])
%   subplot(1,3,2)
%   pcolor(XfI(20:end,:,12),YfI(20:end,:,12),Vh2(20:end,:,i2)),shading flat
%   caxis(Cx2(i2,:))
%   axis([-75 75 50 200])
%   subplot(1,3,3)
%   pcolor(squeeze(XfI(12,:,:)),squeeze(ZfI(12,:,:)),squeeze(Vew(:,:,i2))),shading flat
%   axis([-75 75 80 250])
%   caxis(Cx3(i2,:))
%   drawnow
%   pause(0.1)
% end
% for i2 = 1:72,
%   subplot(1,3,1)
%   pcolor(squeeze(YfI(:,12,:)),squeeze(ZfI(:,12,:)),squeeze(Vs1(:,i2,:))),shading flat
%   caxis([0 1.7e8])
%   axis([50 180 80 250])
%   subplot(1,3,2)
%   pcolor(XfI(20:end,:,12),YfI(20:end,:,12),Vh2(20:end,:,i2)),shading flat
%   caxis([0 2.1e8])
%   axis([-75 75 50 200])
%   subplot(1,3,3)
%   pcolor(squeeze(XfI(12,:,:)),squeeze(ZfI(12,:,:)),squeeze(Vew(:,:,i2))),shading flat
%   axis([-75 75 80 250])
%   caxis([0 5e8])
%   drawnow
%   pause(0.1)
% end
% fx = [0 5e8];
% fx = [0 1.5e8];
% for i2 = 1:72,
%   subplot(1,3,1)
%   pcolor(squeeze(YfI(20:end-10,12,:)),squeeze(ZfI(20:end-10,12,:)),squeeze(VsG(20:end-10,i2,:))),shading flat
%   caxis([0 Cx(i2)])
%   %imgs_smart_caxis(0.003,squeeze(Vs2(:,i2,:)))
%   axis([50 180 80 250])
%   subplot(1,3,2)
%   pcolor(XfI(20:end,:,12),YfI(20:end,:,12),Vh2(20:end,:,i2)),shading flat
%   caxis([0 Cx(i2)])
%   title(sprintf('%02d:%02d:%02d',Tstrs{1}(i_tb(i2),4),Tstrs{1}(i_tb(i2),5),Tstrs{1}(i_tb(i2),6)),'fontsize',16)
%   %imgs_smart_caxis(0.003,squeeze(Vh2(:,:,i2)))
%   axis([-75 75 75 225])
%   hold on
%   plot(XfI(1,i_x(1),12)*[1 1],[50 250],'w')
%   plot([-100 100],173*[1 1],'w')
%   hold off
%   subplot(1,3,3)
%   pcolor(squeeze(XfI(12,:,:)),squeeze(ZfI(12,:,:)),squeeze(Vew(:,:,i2))),shading flat
%   axis([-75 75 80 250])
%   caxis([0 Cx(i2)])
%   %imgs_smart_caxis(0.003,squeeze(Vew(:,:,i2)))
%   drawnow
%   pause(0.1)
% end
% for i2 = 1:72,
%   subplot(1,3,1)
%   pcolor(squeeze(YfI(:,12,:)),squeeze(ZfI(:,12,:)),squeeze(VsG(:,i2,:))),shading flat
%   caxis(fx)
%   %imgs_smart_caxis(0.003,squeeze(Vs2(:,i2,:)))
%   axis([50 180 80 250])
%   subplot(1,3,2)
%   pcolor(XfI(30:end,:,12),YfI(30:end,:,12),Vh2(30:end,:,i2)),shading flat
%   caxis(fx)
%   title(sprintf('%02d:%02d:%02d',Tstrs{1}(i_tb(i2),4),Tstrs{1}(i_tb(i2),5),Tstrs{1}(i_tb(i2),6)),'fontsize',16)
%   %imgs_smart_caxis(0.003,squeeze(Vh2(:,:,i2)))
%   axis([-75 75 50 200])
%   hold on
%   plot(XfI(1,i_x(1),12),[50 250],'w')
%   plot(173,[-100 100],'w')
%   hold off
%   subplot(1,3,3)
%   pcolor(squeeze(XfI(12,:,:)),squeeze(ZfI(12,:,:)),squeeze(Vew(:,:,i2))),shading flat
%   axis([-75 75 80 250])
%   caxis(fx)
%   %imgs_smart_caxis(0.003,squeeze(Vew(:,:,i2)))
%   drawnow
%   pause(0.1)
% end
