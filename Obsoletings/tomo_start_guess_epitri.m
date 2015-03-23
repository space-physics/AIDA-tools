function Vem0 = tomo_start_guess_epitri(stns,date,e_m,par4_pa_n_e_distr,XI,YI,ZfI)
% TOMO_START_GUESS_EPITRI - build Vem0 from triangulations in the epipolar planes
%   Unfinished
% Calling:
%  Vem0 = tomo_start_guess_epitri(stns,date,e_m,p4_pa_ne)
%  
% Input:
%  stns - station struct as obtained from TOMO_INP_IMAGES and
%         CAMERA_SETUP_SC, as described in TOMO_SKELETON.
%  date - date of observations, used for getting the MSIS model
%         atmosphere.
%  e_m  - unit vector of the magnetic field.
%  p4_pa_ne - weighting between field aligned and isotropic, and
%             Maxwellian and monoenergetic electron flux.
%             [C_field||_Maxwell, C_iso_Maxwell;
%              C_field_mono     , C_iso_mono],
%              sum(p4_pa_ne(:)) will be normalised to 1
% XI - [Nx,Ny,Nz] sized array of indexes for the first dimension of
%      the 3-D block
% YI - [Nx,Ny,Nz] sized array of indexes for the second dimension of
%      the 3-D block
% ZfI - [Nx,Ny,Nz] sized array of altitude/distance in the third dimension of
%       the 3-D block
% 
% Output: 
%  Vem0 - [Nx,Ny,Nz] array with start guess of volume emission
%         rates. The guess is made by first taking the image
%         intensity along the projections of all n_stn*(n_stn-1)/2
%         epipolar planes || with the magnetic field and take the
%         most plausible intersections of the respective local
%         maximas as the positions of the arc. For the points
%         inbetween those triangulated points a gridfit/delaunay
%         triangulation is made to estimate the
%         altitude. subsequently those altitudes are used to
%         estimate the characteristic altitude variation of the
%         volume emission rates. This is done by calculating the
%         altitude variation for all characteristic energies that
%         give altitudes between min and max of the altitudes of
%         the triangulated points, with the requested weighting
%         between field aligned and isotropic pitch angle and
%         monoenergetic and Maxwellian energy distribution. The
%         altitude profile for the horizontal position is then
%         weighted with the median of the image intensities
%         projected to the relevant altitude.


%   Copyright © 2010 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

disp('You''re calling tomo_start_guess_epitri from:')
dbstack
disp('I stronlgy suggest that you switch to use: tomo_err4sliceGACT')

if nargin < 3 || isempty(e_m)
  
  e_m = [0 -sin(12/180*pi) cos(12/180*pi)];
  
end

% l should make r_epi be a long enough array of points along the
% e_m || epi-polar plane
% Remains to be set in some clever fashion
%# Take from stns.r0 and stns(1).dr1 (the one of dr1,dr2 most
%# paralell with e_m) and make l extend a good deal further than
%# the max horisontal scale of the 3-D block.
l = lmin:lmax;

for i1 = 1:length(stns),
  
  r1 = stns(i1).r;
  for i2 = (i1+1):length(stns),
    
    r2 = stns(i2).r;
    % unit vector between station #i and #j
    e_epi = r1 - r2;
    e_epi = e_epi/norm(e_epi);
    % make r_epi at distance z_typical away along the direction of
    % the magnetic field
    r_epi = r1 + z_typical*e_m;
    r_epi = l*e_m + repmat(r_epi,size(l));
    % Project r_epi to the image planes.
    [u1,v1] = project_point(r1,optp1,r_epi,stns(i1).obs.trmtr,size(stns(i1).img));
    [u2,v2] = project_point(r2,optp2,r_epi,stns(i2).obs.trmtr,size(stns(i2).img));
    % Get the image intensities in those cuts
    I1 = interp2(stns(i1).img,u1,v1);
    I2 = interp2(stns(i2).img,u2,v2);
    % Find the local maximas in those cuts
    [mI1_extr,indx_m1] = find_loc_minmax(I1,1);
    [mI2_extr,indx_m2] = find_loc_minmax(I2,1);
    % Determine az and ze of those maximas
    [fi1,taeta2] = camera_invmodel(u1(indx_m1),v1(indx_m1),optpar,optmod,imsiz);
    [fi2,taeta2] = camera_invmodel(u2(indx_m2),v2(indx_m2),optpar,optmod,imsiz);
    
    X = zeros(length(fi1),length(fi2));
    Y = zeros(length(fi1),length(fi2));
    Z = zeros(length(fi1),length(fi2));
    for j1 = 1:length(fi1),
      
      for j2 = 1:length(fi2),
        
        e1 = [cos(fi1(j1))*sin(taeta1(j1)),sin(fi1(j1))*sin(taeta1(j1)),cos(taeta1(j1))];
        e2 = [cos(fi1(j2))*sin(taeta1(j2)),sin(fi1(j2))*sin(taeta1(j2)),cos(taeta1(j2))];
        % Determine the intersections between the lines-of-sight
        % for those maximas
        r = stereo(r1,e1,r2,e2);
        X(j1,j2) = r(1);
        Y(j1,j2) = r(2);
        Z(j1,j2) = r(3);
        
      end
      
    end
    nr_bins = max(7,min(12,size(Z(:),1)));
    % Estimate the distribution of those intersections
    [Nz,Zh] = hist([Z(:);z_typical;z_typical],nr_bins);
    [z_maxindx,z_maxindx] = max(Nz);
    Z_max = Zh(z_maxindx);
    %%% Here we shall select the best intersections and discard all
    %%% the bad ones. 
    %# This is how to do it: Take the intersection closest to
    %# Z_max, remove the other intersections with either
    %# line-of-sight. Continue until we run out of feasible
    %# intersections. Feasible is the ones within \pm \delta Z of
    %# Z_max.
    [dZ,c_indx] = min(abs(Z(:)-Z_max));
    while dZ < ok_DeltaZ
      
      Z2d(end+1) = Z(c_indx);
      X2d(end+1) = X(c_indx);
      Y2d(end+1) = Y(c_indx);
      [b1,b2] = ind2sub(size(Z),c_indx);
      Z(b1,:) = [];
      Z(:,b2) = [];
      X(b1,:) = [];
      X(:,b2) = [];
      Y(b1,:) = [];
      Y(:,b2) = [];
      [dZ,c_indx] = min(abs(Z(:)-Z_max));
      
    end
  end
  
end

atmosphere = [];
if isfield(stns,'date')
  date = stns.date;
  z1d = squeeze(ZfI(1,1,:));
  try
    atmosphere = msis(z1d,date);
  catch
    % Den haer innehaller mer...
    load aurmod.mat
  end
end

% Here there should be one or another linear transformation of all
% the input parameters to gridfit. Probably r' = T_xyz2e1e2e3*r
%# just throw in X,Y,Z and transform X2d, Y2d, Z2d to that flat
%# coordinate system, which should be something like T^-1*(r-ro)
%# this should just map Z2d to the horizontal indices in the 3-D
%# block. Then everything should be more straightforward
%# afterwards.
invT = inv(stns(1).T);
r0 = stns(1).r0;
dr1 = stns(1).dr1;
dr2 = stns(1).dr2;
dr3 = stns(1).dr3;
%# Here invT should possibly be transposed, but "correct" at least
%# for octave...
Z2D = gridfit((X2d-r0(1))*invT(1,1)+(Y2d-r0(2))*invT(1,2)+(Z2d-r0(3))*invT(1,3),...
              (X2d-r0(1))*invT(2,1)+(Y2d-r0(2))*invT(2,2)+(Z2d-r0(3))*invT(2,3),...
              (X2d-r0(1))*invT(3,1)+(Y2d-r0(2))*invT(3,2)+(Z2d-r0(3))*invT(3,3),...
              XI(:,:,1),YI(:,:,1));
% Constrain Z2D to lie between the lowest and highest altitudes
% found with the automatic triangulation:
z_minmax = [min(Z2d(:)),max(Z2d(:))];
Z2D = max(z_minmax(1),min(z_minmax(2),Z2D));
% And Z2D should be inverse transformed.
%# Then this transform should be just [x,y,Z2D] = T*[X2d,Y2d,Z2d]+r0(3)
Z2D = r0(3) + dr1(3)*(XI(:,:,1)-1) + dr2(3)*(YI(:,:,1)-1) + dr3(3)*(Z2D-1);
Y2D = r0(2) + dr1(2)*(XI(:,:,1)-1) + dr2(2)*(YI(:,:,1)-1) + dr3(2)*(Z2D-1);
X2D = r0(1) + dr1(1)*(XI(:,:,1)-1) + dr2(1)*(YI(:,:,1)-1) + dr3(1)*(Z2D-1);


for i1 = 1:length(stns),
  
  Vem(i1,:,:,:) = tomo_start_guess2d(stns,X2D,Y2D,Z2D,ZfI,par4_pa_n_e_distr,atmosphere);
  
end
Vem = squeeze(median(Vem,1));

function Vem0 = tomo_start_guess2d(stns,x2d,y2d,z2d,z,par4_pa_n_e_distr,atmosphere)
% tomo_start_guess2d - physically feasible altitude profiled start guess 
% for auroral tomography. The altitude profiles are a linear
% combination of field-aligned and isotropical electrons both
% maxwellian and monoenergetic differential electron fluxes - with
% energies that gives maximum volume emission rates at Z2D. The
% horisontal distribution is determined by the projection of the
% image to the surface spanned by X2D,Y2D,Z2D.
% 
% Calling:
%  Vem0 = tomo_start_guess2d(stns,x2d,y2d,z2d,z,par4_pa_n_e_distr,atmosphere)
% Input:
%  stns - station struct
%  x2d  - [Nx,Ny] array of 1st horisontal coordinate for surface of max
%         volume emission rates.
%  y2d  - [Nx,Ny] array of 2nd horisontal coordinate for surface of max
%         volume emission rates.
%  z2d  - [Nx,Ny] array of vertical coordinate for surface of max
%         volume emission rates.
%  z    - [1xNz] array with altitude range of 3-D cube. 
%  p4_pa_ne - weighting between field aligned and isotropic, and
%             Maxwellian and monoenergetic electron flux.
%             [C_field||_Maxwell, C_iso_Maxwell;
%              C_field_mono     , C_iso_mono],
%              sum(p4_pa_ne(:)) should be 1
% atmosphere - atmosphere model

% Calculate the altitude profiles that are relevant for the
% emission LAMBDA and energy range E_RANGE (determined by Z2D and
% LAMBDA, or given explicitly)
I_of_h = simple_vol_em(E_range,lambda,atmosphere,par4_pa_n_e_distr);
[i_hm,i_hm] = max(I_of_h);
h_max = z1d(i_hm);

z1d = squeeze(z(1,1,:));
I0 = inv_project_img_surf(stns.img,stns.r,stns.optpar(9),stns.optpar,x2d,y2d,z2d);

for i1 = 1:size(x,1),
  
  for i2 = 1:size(x,2),
    
    f_of_h = interp2(z1d,h_max,I_of_h,z1d,z2d(i1,i2));
    Vem0(i1,i2,:) = I0(i1,i2)*f_of_h;
    
  end
  
end
