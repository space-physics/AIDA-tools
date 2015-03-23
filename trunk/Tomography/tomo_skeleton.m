%% TOMO_SKELETON - Template/example script for auroral tomography,
% 
% This script is developed to be used as a template script for
% tomographic reconstruction of ALIS data. It should be well suited
% for adaption to most cases, and could as well be used by other
% ground based auroral imaging systems - provided that the requisit
% background information about the image locations and the
% geometrical characteristics of the imagers is made available for
% the functions that require so. 
% 
% The tomographic inversion is based on the
% "quick-and-'dirty'-but-more-accurate" projection algorithm by
% Peter Rydesaeter [Rydesaeter and Gstavsson 2001]. The currently
% available itterative inversions are ART, mSIRT, SIRT and FMAPE is
% on the task list.
% 
% This script should be used freely as a pattern script. For
% adaption to specific events adjust, modify and wrap to make it
% fit your needs and whishes.

% Copyright Bjorn Gustavsson 20050110-20100310

%   Copyright © 20050110-20100310 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% To load images and set up camera parameters:
stns = tomo_inp_images(file_list,[],img_ops);
stns = tomo_inp_images(file_list);
% Where FILE_LIST is the image files from the different viewing
% positions. For format of IMG_OPS see INIMG. If only FILE_LIST is
% given default parameters are used for image pre-processing,
% 2-D 3x3 median filtering, quadrant correction and image resizing
% to 256x256 pixels.

% Still not very polished/finished set up of the geography/geometry
% of the 3-D region of/for/(in which) the reconstruction. Some use
% of INV_PROJECT_IMG might be helpfull for determining/selecting an
% appropriate region of the reconstruction. One thing to remember
% is that MATLAB(R) is building their 3-D arrays as V(y,x,z). Here
% a choise is wether to use the direction along the magnetic field
% or the vertical as the third dimension. The 'field aligned
% proximity' filtering should preferably be used with r3 || e_m.
Vem = zeros([90 100 64]);
r0 = [-64*2 -64*2 80];
r0 = [-128 -64 80];
dr1 = [1.8 0 0];
dr2 = [0 1.8 0];
dr3 = [0 0 1.8];
dr3 = [0 -1.8*tan(pi*12/180) 1.8];

[r,X,Y,Z] = sc_positioning(r0,dr1,dr2,dr3,Vem);
XfI = r0(1)+dr1(1)*(X-1)+dr2(1)*(Y-1)+dr3(1)*(Z-1);
YfI = r0(2)+dr1(2)*(X-1)+dr2(2)*(Y-1)+dr3(2)*(Z-1);
ZfI = r0(3)+dr1(3)*(X-1)+dr2(3)*(Y-1)+dr3(3)*(Z-1);

% Number of layers to use in image projection, more is better and
% slower: 8 minimum, 10 better, 16 getting on the slow side...
nr_layers = 10;

% Set up the stuff on the camera and 3D structure needed for the
% fast projection.
for i1 = 1:length(stns),
  
  rstn = stns(i1).obs.xyz;
  optpar = stns(i1).optpar;
  imgsize = size(stns(i1).img);
  cmt = stns(i1).obs.trmtr;
  [stns(i1).uv,stns(i1).d,stns(i1).l_cl,stns(i1).bfk] = camera_set_up_sc(r,X,Y,Z,optpar,rstn,imgsize,nr_layers,cmt);
  
end

% Cunning (?) method to obtain a resonable start guess for the
% reconstruction. The method adjust a 3D distribution with chapman
% profile centered at ALT with width WIDTH. STRONGLY RECOMENDED.
Vem = tomo_start_guess(stns,alt,width,Xm,Ym,Zm);

%% fast_projection test! 
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

% To Set some parameters for The tomographic inversion.
tomo_ops = make_tomo_ops
tomo_ops = make_tomo_ops(stns);
% These options are: 1, 'quiet border' the frame around the images
% where the ratio between observed image and current projection is
% set to 1 this is to avoid problems with edge effects an porly
% known flat-field sensitivity corrections; 2, relative scaling of
% images and the normalization region to avoid problems with
% absolute sensitivity uncertainties and such; 3, choice of
% itterative method; 4, choise of 3-D filtering method and filter
% kernel.

% Function to scale 3D intensities to give projections that are in
% the same intensity range as the images. Not needed here since the
% function is already called from within TOMO_START_GUESS, but
% might be usefull in the working process.
% [stns,Vem] = adjust_level(stns,Vem,1);

% Here are the itterative tomographic steps and filtering made.
[Vem,stns] = tomo_steps(Vem,stns,tomo_ops,nr_laps);

% This tomographic tools requires the 'Camera' tools 'Fits_tools'
% and also a few functions currently (2001-08-22) residing in
% 'Starcal'.
