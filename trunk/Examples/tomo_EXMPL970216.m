%% Template/example script for auroral tomography,

%%
% This script is developed to be used as a template script for
% tomographic reconstruction of ALIS data. It should be well suited
% for adaption to most cases, and could as well be used by other
% ground based auroral imaging systems - provided that the requisit
% background information about the image locations and the
% geometrical characteristics of the imagers is made available for
% the functions that require so. 

%% Tomography for ALIS
% Skeleton script for auroral tomography, developed for use with
% ALIS data. The tomographic inversion is based on the
% "quick-and-'dirty'-but-more-accurate" projection algorithm based
% on blobbs (smooth basis functions, in this implementation cos^2)
% by Peter Rydesaeter [Rydesaeter and Gustavsson 2001]. The
% currently available itterative inversions are ART, mSIRT, SIRT
% and FMAPE is on the task list.
% 
% This script could be used as a pattern script. For adaption to
% specific events adjust, modify and wrap to make it fit your needs and
% whishes.

%% Step 1: loading images
% To load images and set up camera parameters:
%  1, make an array of fits file names for all images from one
%  event (same time)
%[q,w] = my_unix('ls -1 --color=never 970216/[56]*.RAF');
alisdataroot = '/media/MYBOOK_3/bjorn-tmp/ALIS/stdnames';
cd(alisdataroot)
cd('1997/02/16/20')
w5 = dir('*A.fits');
w6 = dir('*N.fits');
%file_list = str2mat(w(2,:),w(9,:))
file_list = str2mat(w5(2).name,w6(2).name)

stns = tomo_inp_images(file_list);
% stns = tomo_inp_images(file_list,[],POs);
% or
% stns = tomo_inp_images(file_list,img_ops);
% Where FILE_LIST is the image files from the different stations
% (=viewing positions). IMG_OPS should be a structure as returned
% from TYPICAL_PRE_PROC_OPS (or an array of such structures). For
% format of IMG_OPS see INIMG. If only FILE_LIST is given default
% parameters are used for image pre-processing, 2-D 3x3 median
% filtering, quadrant correction and image resizing to 256x256
% pixels.
%
% The function automatically searches for optical parameters.

%% Setting up the geometry
% Still not very polished/finished set up of the geography/geometry
% of the 3-D region of/for/(in which) the reconstruction. Some use
% of INV_PROJECT_IMG might be helpfull for determining/selecting an
% appropriate region of the reconstruction. One thing to remember
% is that MATLAB(R) is building their 3-D arrays as V(y,x,z). Here
% a choise is wether to use the direction along the magnetic field
% or the vertical as the third dimension. The 'field aligned
% proximity' filtering should preferably be used with r3 || e_m.
% 1, Make the base function block:
Vem = zeros([90 100 64]);
% set the lower south-west corner:
r0 = [-64*2 -64*2 80];
r0 = [-128 -64 80];
% Set blob separation:
dl = 1.8;
% Define the latice unit vectors
dr1 = [dl 0 0];
dr2 = [0 dl 0];
% With e3 || vertical:
dr3 = [0 0 dl];
% or || magnetic zenith:
dr3 = [0 -dl*tan(pi*12/180) dl*cos(pi*12/180)];
% above is an error, below is a corrected version
dr3 = [0 -dl*tan(pi*12/180) dl];
% Calculate duplicate arrays for the position of the base functions:
[r,X,Y,Z] = sc_positioning(r0,dr1,dr2,dr3,Vem);
XfI = r0(1)+dr1(1)*(X-1)+dr2(1)*(Y-1)+dr3(1)*(Z-1);
YfI = r0(2)+dr1(2)*(X-1)+dr2(2)*(Y-1)+dr3(2)*(Z-1);
ZfI = r0(3)+dr1(3)*(X-1)+dr2(3)*(Y-1)+dr3(3)*(Z-1);

%% Set the number of size layers 
% the projection algorithm divides the base into classes based on
% the size of their footprint in the image. Here it is needed to
% select the number of layers to use in the image projection, more
% is better and slower: 8 minimum, 10 better, 16 getting on the
% slow side...
nr_layers = 10;

%% Creating the station  structure 
% Here we make the structure array holding the projection matrix,
% the filter kernels and size grouping of the base functions needed
% for the fast projection.
% Set up the stuff on the camera and 3D structure needed for the
% fast projection.
for i1 = 1:length(stns),
  
  rstn = stns(i1).obs.xyz;
  optpar = stns(i1).optpar;
  imgsize = size(stns(i1).img);
  cmt = stns(i1).obs.trmtr;
  [stns(i1).uv,stns(i1).d,stns(i1).l_cl,stns(i1).bfk] = camera_set_up_sc(r,X,Y,Z,optpar,rstn,imgsize,nr_layers,cmt);
  
end

for i1 = 1:length(stns),
  
  stns(i1).proj = fastprojection(ones(size(X)),...
                                 stns(i1).uv,...
                                 stns(i1).d,...
                                 stns(i1).l_cl,...
                                 stns(i1).bfk,...
                                 size(stns(i1).img),1);
  
end

%% Options for the tomographic inversion
% 
% To Set some parameters for The tomographic inversion.
tomo_ops = make_tomo_ops(stns);
% Or:
% tomo_ops = make_tomo_ops;
% Where STNS is an array of "station-structures" as described
% below.
% These options are: 1, 'quiet border' the frame around the images
% where the ratio between observed image and current projection is
% set to 1 this is to avoid problems with edge effects from a porly
% known flat-field sensitivity correction; 2, relative scaling of
% images and the normalization region to avoid problems with
% absolute sensitivity uncertainties and such; 3, choice of
% itterative method; 4, choise of 3-D filtering method and filter
% kernel.


%% Start guess
% To avoid the problems in the reconstruction stemming from
% uncertainties in absolute sensitivity, vignetting, orientation
% and non-overlapping-f-o-vs it is preferable to usee non-flat
% start guesses that tries to approximate the distribution of
% volume emission.
% A Cunning (?) method to obtain a resonable start guess for the
% reconstruction is to adjust a 3D distribution with chapman
% profiles centered at ALT with width WIDTH. STRONGLY
% RECOMENDED. It is found that the exact value of ALT does not
% affect the resulting reconstruction. But the regarding the width
% it is preferable to err on the narrow side here as the
% reconstruction tends to spread the volume emission in altitude
% rather than compress it.
alt_max5577 = 115;
width = 25;
[Vem0,stns] = tomo_start_guess(stns,alt_max5577,width,XfI,YfI,ZfI);
clf
slice(Vem0,47,50,20),shading interp,caxis([0 .7e8]),view(90,0)
%%
slice(Vem0,47,50,20),shading interp,caxis([0 .7e8]),view(0,90)
pause(3)
slice(Vem0,47,50,20),shading interp,caxis([0 .7e8]),view(90,0)
%% Intensity scaling
% This start guess should then be scaled.
% Function to scale 3D intensities to give projections that are in
% the same intensity range as the images. Not needed here since the
% function is already called from within TOMO_START_GUESS, but
% might be usefull in the working process.
% [stns,Vem] = adjust_level(stns,Vem,1);

%% Tomographic update:
% Here are the itterative tomographic steps and filtering made.
nr_laps = 1;
fS = [7 7 5 5 3 3];
Vem = Vem0;
for i_f = 1:6,                                                                 
  
  % Here we make the filter kernel smaller and smaller as the
  % reconstruction proceeds
  [xf,yf] = meshgrid(1:fS(i_f),1:fS(i_f));            
  fK = exp(-(xf-mean(xf(:))).^2/mean(xf(:)).^2-(yf-mean(yf(:))).^2/mean(yf(:))^2);
  % It is no more difficult than to adjust the
  % |tomo_ops.filterkernel|. And the other options are no more
  % difficult to modify
  tomo_ops(1).filterkernel = fK;
  
  [Vem,stns] = tomo_steps(Vem,stns,tomo_ops,nr_laps);
  pause(2)
end
clf
slice(Vem,47,50,20),shading interp,caxis([0 .7e8])
%%
pause(3)
slice(Vem,47,50,20),shading interp,caxis([0 .7e8]),view(0,90)
%%
pause(3)
slice(Vem,47,50,20),shading interp,caxis([0 .7e8]),view(90,0)

Vemx = Vem0;
for i_f = 1:6,                                                                 
  [xf,yf] = meshgrid(1:fS(i_f),1:fS(i_f));            
  fK = exp(-(xf-mean(xf(:))).^2/mean(2*xf(:)).^2-(yf-mean(0.7*yf(:))).^2/mean(yf(:))^2);
  tomo_ops(1).filterkernel = fK;
  [Vemx,stns] = tomo_steps(Vemx,stns,tomo_ops,nr_laps);
  pause(2)
end
clf
slice(Vemx,47,50,20),shading interp,caxis([0 .7e8])
pause(3)
slice(Vemx,47,50,20),shading interp,caxis([0 .7e8]),view(0,90)
pause(3)
slice(Vemx,47,50,20),shading interp,caxis([0 .7e8]),view(90,0)

% This tomographic tools requires the 'Camera' tools 'Fits_tools'
% and also a few functions currently (2001-08-22) residing in
% 'Starcal'.
