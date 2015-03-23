% HH_TOMO1234_NEW01 - script for tomographing 2007 HIPAS-observations

% 00 Identifier of this script.
version_string = '1234_New01';

% 0 Location of the cameras
pos0 = [-146.84       64.872];
pos1 = [-145.15       62.393];
longlat = [-146.84       64.872;
           -145.15       62.393];
%% 1 Image-pre-processing options
%% 1.1 Air Force Research Lab keo imager located at HAARP
po_haarp = typical_pre_proc_ops('none');
po_haarp.filetype = 'afrl-keo';
po_haarp.medianfilter = 3;
%load ../../S00_070319_134300_5577_HAARP.acc
%po_haarp.optpar = S00_070319_134300_5577_HAARP([7:14 6 end]);
load /home/DATA/work/HH-tomo/S00_070319_053800_5577_HAARP.acc
po_haarp.optpar = S00_070319_053800_5577_HAARP([7:14 6 end]);

%% 1.2 AFRL Apogee-camerra located at HIPAS
po_apogee = typical_pre_proc_ops('none');
po_apogee.filetype = 'afrl-raw';
%load /home/DATA/HH200703/S00_070319_052420_5577_HIPAS-2007@.acc.mat
load /home/DATA/work/HH-tomo/S00_070319_061510_5577_HIPAS-2007@.acc
po_apogee.optpar = S00_070319_061510_5577_HIPAS_2007_([7:14,6,end]);
po_apogee.medianfilter = 3;

%% 1.3 sbig-ST9 camera located at HIPAS
po_st9 = typical_pre_proc_ops('none');
po_st9.filetype = 'sbig';             
po_st9.log2obs = @KoschSBIG_HIPAS2007;

%load /home/DATA/HH200703/S0_HIPAS_stars008.acc
%po_st9.optpar = S0_HIPAS_stars008([6:13 5 14]);
load /home/DATA/work/HH-tomo/S00_HIPAS_star030_m2.acc
po_st9.optpar = S00_HIPAS_star030_m2([7:14 6 end]);
po_st9.medianfilter = 3;

%% 2 Geometry of the set-up
%% 2.1 Positions relative to HIPAS
r_0 = [0 0 0];

[x,y,z] = makenlcpos(pos0(2),pos0(1),0.2,pos1(2),pos1(1),0.2);
r_stns = [0,0,0;x,y,z];
for i1 = 1:length(stns),
  [x,y,z] = makenlcpos(longlat(1,2),longlat(1,1),0.2,longlat(i1,2),longlat(i1,1),0.2);
  r_stns(i1,:) = [x,y,z];
end

%% 2.2 Transformation matrix
[trmtr] = maketransfmtr(pos0(2)*pi/180,pos0(1)*pi/180,pos1(2)*pi/180,pos1(1)*pi/180);
for i1 = 1:length(stns),
  trmtr{i1} = maketransfmtr(longlat(1,2)*pi/180,longlat(1,1)*pi/180,...
                            longlat(i1,2)*pi/180,longlat(i1,1)*pi/180);
end

%% 3 Flat field correction matrices
ff_haarp =  max(0,real(ffs_correction2([277, 277],po_haarp.optpar,po_haarp.optpar(9))));
ff_apogee = max(0,real(ffs_correction2([256, 256],po_apogee.optpar,po_apogee.optpar(9))));
ff_st9 =    max(0,real(ffs_correction2([170, 170],po_st9.optpar,po_st9.optpar(9))));



%% 4 Set-up of Tomographic paraphenalia
% In the retrieval of the altitude distribution we use the fast
% projection and back-projection of 3-D volume emission
% distributions based on smooth base functions (Rydesater and
% Gustavsson 2001) - but here we use cos^2-shaped base functions.
% 
% Set up the geometry of the base function block
ds = 3;  % Size (full-width-at-half-max) of base function in km:
sx = 60; % Number of base functions in WEST-EAST
sy = 60; % Number of base functions in NORTH-SOUTH
sz = 60;% Number of base functions along the magnetic zenith
%%
% |ds| should preferably a little smaller and the number of
% elements a little bit bigger.
% 
% Position of the lower south-west corner
r0 = [-3*60/2 -3*60/2-20 160]; % Should be OK,
%%
% Unit vector along the first (x) second and third dimension of the
% base-function-block:
dr1 = [ds 0 0]; 
dr2 = [0 ds 0];
dr3 = [0 0 ds];
%%
% Note that this makes up a block sheared along the magnetic
% zenith.
% 
% Setting up the base function block and its location
I3D0 = zeros([sy sx sz]);
[r,X,Y,Z] = sc_positioning(r0,dr1,dr2,dr3,I3D0);
XfI = r0(1)+dr1(1)*(X-1)+dr2(1)*(Y-1)+dr3(1)*(Z-1);
YfI = r0(2)+dr1(2)*(X-1)+dr2(2)*(Y-1)+dr3(2)*(Z-1);
ZfI = r0(3)+dr1(3)*(X-1)+dr2(3)*(Y-1)+dr3(3)*(Z-1);

%% 5 Build the STNS structs
filelist = char('/home/DATA/HH200703/HAARP/070319/070319_053415_6300_HAARP.keo',...
                   '/home/DATA/HH200703/HIPAS/070319/070319_053300_5577_HIPAS-2007@.raw',...
                   '/home/DATA/HH200703/HIPAS/st9/19Mar07/HIPAS263.ST9');
stns_HH = tomo_inp_images(filelist,[],[po_haarp,po_apogee,po_st9]);
stns_HH(1).optpar = po_haarp.optpar;
stns_HH(2).optpar = po_apogee.optpar;
stns_HH(3).optpar = po_st9.optpar;

%%
% Setup the number of layers to divide the base functions into
% Might be larger, 16?
nr_layers = 16;
%%
% Set up the projection matrices and base function foot-point
rstns = r_stns([2 1 1],:);
for i1 = 1:length(stns_HH),
  
  optpar = stns_HH(i1).optpar;
  imgsize = size(stns_HH(i1).img);
  %cmt = stns_DR(i1).obs.cmtr;
  stns_HH(i1).r = rstns(i1,:);
  [stns_HH(i1).uv,stns_HH(i1).d,stns_HH(i1).l_cl,stns_HH(i1).bfk] = camera_set_up_sc(r,X,Y,Z,stns_HH(i1).optpar,rstns(i1,:),imgsize,nr_layers);
  
end
%%
% Check that they work
load /home/DATA/work/HH-tomo/imgs_HH.mat

img_test{1} = fastprojection(ones(size(X)),stns_HH(1).uv,stns_HH(1).d,stns_HH(1).l_cl,stns_HH(1).bfk,size(imgs_HAARP5577{1}),ff_haarp); 
img_test{2} = fastprojection(ones(size(X)),stns_HH(2).uv,stns_HH(2).d,stns_HH(2).l_cl,stns_HH(2).bfk,size(imgs_HIPAS5577{1}),ff_apogee);
img_test{3} = fastprojection(ones(size(X)),stns_HH(3).uv,stns_HH(3).d,stns_HH(3).l_cl,stns_HH(3).bfk,size(imgs_HIPAS6300{1}),ff_st9);   


subplot(1,3,1)
imagesc(imgs_HAARP6300{1}),caxis([-.5 .8])
hold on
contour(img_test{1},10,'k','linewidth',2)
subplot(1,3,2)
imagesc(imgs_HIPAS5577{1}),caxis([-.5 .8])
hold on
contour(img_test{2},10,'k','linewidth',2)
subplot(1,3,3)
imagesc(imgs_HIPAS6300{1}),caxis([-0.05 0.1])
hold on
contour(img_test{3},10,'k','linewidth',2)

% Scale Haarp images to Rayleighsar!
for i1 = 1:4,
  imgs_HAARP6300{i1} = imgs_HAARP6300{i1}*130*.16;
  imgs_HAARP5577{i1} = imgs_HAARP5577{i1}*130*.11;
end  

%% 6 Set the tomo_options - REMAINS!

qb_HAARP = [22   103    99   180];
qb_APOGEE = [82, 172, 62, 174];
qb_ST9 = [42, 151, 36, 145];
rn_HAARP = [35    66   124   157];
rn_APOGEE = [106   148   112   154];
rn_ST9 = [ 92   125    88   114];

tomo_ops.tomotype = 2;
tomo_ops.randorder = NaN;
tomo_ops.qb = [qb_HAARP;
               qb_APOGEE;
               qb_ST9];
tomo_ops.renorm = [rn_HAARP;
                   rn_APOGEE;
                   rn_ST9];
tomo_ops.renorm(1,:) = NaN;
tomo_ops.filtertype = 3;
tomo_ops.filterkernel = ones(3)/9;


t_ops13 = tomo_ops;
t_ops13.qb = t_ops13.qb([1 3],:);
t_ops13.renorm = t_ops13.renorm([1 3],:);

t_ops12 = tomo_ops;
t_ops12.qb = t_ops12.qb([1 2],:);
t_ops12.renorm = t_ops12.renorm([1 2],:);

% Then it should just be to read in the images - with background
% reduction, this could easily be done with imgs_plot_bg_red
%stns(n).img = imgs_plot_bg_red(files([bg1,imgnr,bg2,:),PO,1,1,1,ff_X,[],[],[],'','img');
% and then set it off in a manner similar to this.

%% Set the initial guesses for the parameters
%           1  2  3  4                    5                     6    7   8     9 10    11 12 13 14 15
%           I,x0,y0,z0,dsx,dsy,dzu,dzd,gamma,fi,alpha,vx,vy,vz,D
I0r(1,:) = [1,12,12,12,  15, 15, 10, 10,    2, 0,    2, 0, 0, 0,1];
I0r(2,:) = [1,12,12,12,  15, 15, 10, 10,2,0,2,0,0,0,1];
I0r(3,:) = [1,12,12,12,  15, 15, 10, 10,2,0,2,0,0,0,1];
I0r(4,:) = [1,12,12,12,  15, 15, 10, 10,2,0,2,0,0,0,1];

I0g = I0r;

%     I,  x0, y0, z0,sx,sy,szu,szd,gamma,fi,alpha,vx,vy,vz,D
UB = [1e5 30  30  30 3    3   3   3   6   pi/2 6     1, 1, 1,1];
LB = [0  -30 -30 -30 0.3  0.3 0.3 0.3 0.5  0   0.25,-1,-1,-1,0];

load MSIS20070319.dat
tauO1D = tau_O1D(MSIS20070319(:,2)*1e6,...
                 MSIS20070319(:,4)*1e6,...
                 MSIS20070319(:,3)*1e6,...
                 MSIS20070319(:,6),...
                 zeros(size(MSIS20070319(:,6))),...
                 MSIS20070319(:,6));
tauO1D3D = ZfI;
tauO1D3D(:) = interp1(MSIS20070319(:,1),tauO1D,ZfI(:));

imgs_HIPAS5577{1} = max(-1.5,min(1,imgs_HIPAS5577{1}));     
imgs_HIPAS5577{2} = max(-1,min(1.5,imgs_HIPAS5577{2}+0.5)); 
imgs_HIPAS5577{3} = max(-1,min(1.5,imgs_HIPAS5577{3}+0.7)); 
imgs_HIPAS5577{4} = max(-1,min(1.5,imgs_HIPAS5577{4}+0.75));

fms_opts = optimset('fminsearch');
fms_opts.Display = 'iter';        

% 7 Run the tomography for 5577
load HH1234G2_00.mat % load the preceding tomographic results.
fK = conv2(conv2(ones(3)/9,ones(2)/4,'full'),ones(2)/4,'full');
fK2 = fK.^2;
fK = fK2/sum(fK2(:));

load HH1234h_06.mat I_R

i_i = 0;
for t_indx = [2 4], % Times for the pulses.
  
  var_pars = 1:9;
  lb = LB;
  ub = UB;
  
  I0 = I_G{t_indx};
  I0(2:4) = I_R{t_indx}(2:4);
  I0(1) = I0(1)*130*.11;
  
  lb(2:4) = I0(2:4)+lb(2:4);
  ub(2:4) = I0(2:4)+ub(2:4);
  lb(5:8) = I0(5:8).*lb(5:8);
  ub(5:8) = I0(5:8).*ub(5:8);
  
  ub = ub(var_pars);
  lb = lb(var_pars);
  I0 = I_G{t_indx};
  
  stns_HH(1).img = conv2(imgs_HAARP5577{t_indx},fK,'same');
  stns_HH(2).img = conv2(imgs_HIPAS5577{t_indx},fK,'same');
  if test_only
    hh_5577_error(I0,var_pars, I0g(t_indx,:),stns_HH([1,2]),XfI,YfI,ZfI,t_ops12);
  else
    I_G{t_indx} = fminsearchbnd(@(I0) hh_5577_error(I0,var_pars, I0g(t_indx,:),stns_HH([1,2]),XfI,YfI,ZfI,t_ops12),I0,lb,ub,fms_opts);
    disp(['5577: ',num2str(t_indx)])
    disp(I_G{t_indx})
    figure
    hh_5577_res_plot(I_G{t_indx},var_pars, I0g(t_indx,:),stns_HH([1,2]),XfI,YfI,ZfI,t_ops12);
    save(['HH',version_string,sprintf('_%02d',i_i),'.mat'],'I_G')
  end
  
end

fms_opts.TolFun = 0.001;
fms_opts.MaxFunEvals = 100;
fms_optq = fms_opts;
fms_optq.MaxFunEvals = 60;

load HH1234h_06.mat I_R
% 8 Run the tomography for 6300
i_i = [6 6];

for t_indx = 1:4, % Times for the pulses.
  
  disp([i_i,t_indx])
  var_pars = [1,2,3,4,5,6,7,8,9,12,13,15];
  I_R{t_indx}(1) = I_R{t_indx}(1)*130*0.16;

end
for t_indx = 1:4, % Times for the pulses.
  
  disp([i_i,t_indx])
  var_pars = [1,2,3,4,5,6,7,8,9,12,13,15];
  I_0 = I_R{t_indx};
  I_0(1) = I_0(1);
  I0 = I0r(t_indx,:);
  
  lb = LB;
  ub = UB;
  lb(2:4) = I0(2:4)+lb(2:4);
  ub(2:4) = I0(2:4)+ub(2:4);
  ub(5:8) = I0(5:8).*ub(5:8);
  ub = ub(var_pars);
  lb = lb(var_pars);
  
  stns_HH(1).img = imgs_HAARP6300{t_indx};
  stns_HH(3).img = imgs_HIPAS6300{t_indx};
  if test_only
    hh_6300_qerror(I_0,var_pars, I0g(t_indx,:),stns_HH([1,3]),XfI,YfI,ZfI,tauO1D3D,t_ops13,i_i);
    disp(['HH1234_t',sprintf('%02d',i_i),'f.mat'])
  else
    
    for i_tmp = 1:4,
      I_0 = I_R{i_tmp};
      [I_tmp{i_tmp},tmp_val(i_tmp)] = fminsearchbnd(@(I_0) hh_6300_qerror(I_0,var_pars,I0,stns_HH([1,3]),XfI,YfI,ZfI,tauO1D3D,t_ops13,i_i),...
                                                    I_0,lb,ub,fms_optq);
    end
    disp(tmp_val)
    [min_tmp,min_tmp] = min(tmp_val);
    I_R{t_indx} = I_tmp{min_tmp};
    [I_R{t_indx}] = fminsearchbnd(@(I_0) hh_6300_qerror(I_0,var_pars,I0,stns_HH([1,3]),XfI,YfI,ZfI,tauO1D3D,t_ops13,i_i),...
                                  I_R{t_indx},lb,ub,fms_opts);
    try
      figure('name',['6300: ',sprintf('%02d',t_indx)])
      hh_6300_qres_plot(I_R{t_indx},var_pars, I0,stns_HH([1,3]),XfI,YfI,ZfI,tauO1D3D,t_ops13,i_i);
      print('-depsc2 -painters',['6300-',sprintf('%02d-%02d',t_indx,i_i),'.eps'])
    catch
      disp(['probs for res_plot: ',num2str(t_indx)])
    end
    disp(['6300: ',num2str(t_indx)])
    disp(I_R{t_indx})
    save(['HH',version_string,sprintf('_%02d',i_i),'.mat'],'I_R')
    
  end
  
end

for t_indx = 1:4, % Times for the pulses.
  
  disp([i_i,t_indx])
  var_pars = [1,2,3,4,5,6,7,8,9,12,13,15];
  I_0 = I_R{t_indx};
  I0 = I0r(t_indx,:);
  
  lb = LB;
  ub = UB;
  lb(2:4) = I0(2:4)+lb(2:4);
  ub(2:4) = I0(2:4)+ub(2:4);
  ub(5:8) = I0(5:8).*ub(5:8);
  ub = ub(var_pars);
  lb = lb(var_pars);
  
  stns_HH(1).img = imgs_HAARP6300{t_indx};
  stns_HH(3).img = imgs_HIPAS6300{t_indx};
  if test_only
    hh_6300_qerror(I_0,var_pars, I0g(t_indx,:),stns_HH([1,3]),XfI,YfI,ZfI,tauO1D3D,t_ops13,i_i);
    disp(['HH1234_t',sprintf('%02d',i_i),'f.mat'])
  else
    
    for i_tmp = 1:4,
      I_0 = I_R{i_tmp};
      [I_tmp{i_tmp},tmp_val(i_tmp)] = fminsearchbnd(@(I_0) hh_6300_qerror(I_0,var_pars,I0,stns_HH([1,3]),XfI,YfI,ZfI,tauO1D3D,t_ops13,i_i),...
                                                    I_0,lb,ub,fms_optq);
    end
    disp(tmp_val)
    [min_tmp,min_tmp] = min(tmp_val);
    I_R{t_indx} = I_tmp{min_tmp};
    [I_R{t_indx}] = fminsearchbnd(@(I_0) hh_6300_qerror(I_0,var_pars,I0,stns_HH([1,3]),XfI,YfI,ZfI,tauO1D3D,t_ops13,i_i),...
                                  I_R{t_indx},lb,ub,fms_opts);
    try
      figure('name',['6300: ',sprintf('%02d',t_indx)])
      hh_6300_qres_plot(I_R{t_indx},var_pars, I0,stns_HH([1,3]),XfI,YfI,ZfI,tauO1D3D,t_ops13,i_i);
      print('-depsc2 -painters',['6300-',sprintf('%02d-%02d',t_indx,i_i),'.eps'])
    catch
      disp(['probs for res_plot: ',num2str(t_indx)])
    end
    disp(['6300: ',num2str(t_indx)])
    disp(I_R{t_indx})
    save(['HH',version_string,sprintf('_%02d',i_i),'.mat'],'I_R')
    
  end
  
end



%   Copyright � 2007 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later
