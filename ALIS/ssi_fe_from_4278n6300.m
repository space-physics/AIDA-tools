function [feE,Cmtr,x_b100,Imax6300] = ssi_fe_from_4278n6300(theta,I4278,I6300,OPS)
% SSI_FE_FROM_4278N6300 - Single Station Inversion Fe(E) from 4278 and 6300
%   data. The function uses slices in images in 4278 and 6300 A
%   accompanied with the corresponding zenith angles to estimate
%   the electron energy distribution of precipitating auroral
%   electrons. The method assumes that the auroral electrons
%   precipitate in a few discrete regions comparatively narrow in
%   width. Coupled with the fact that the 6300 emission peaks at/in a
%   comparatively narrow altitude range between 190 and 210 km this
%   assumption makes it possible to determine the range to the
%   regions with signifficant precipitation. Then it is a linear
%   inverse problem to estimate the electron energy distribution
%   from the estimated altitude distribution of the 4278 A
%   emission. 
% 
% Calling:
% [feE,Cmtr,x_b100,Imax6300] = ssi_fe_from_4278n6300(theta,I4278,I6300,OPS)
% 
% Input:
%   THETA - zenith angle in radians.
%   I4278 - image intensity in projection of plane || magnetic field  4278 A emission from N_2^+
%   I6300 - image intensity in projection of plane || magnetic field  6300 A emission from O(1D)
%           The image intensities should be in Rayleighs
%   OPS   - struct with options, default structure is returned as
%   single output when the function is called with no input
%   arguments is specified.

% Copyright B. Gustavsson 20050805

%   Copyright © 20050805 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

feE.date = [45 0];          % Date (day of year) Time (day-seconds) of
                            % observation 
feE.latlong = [67 20];      % Latitude, longitude
feE.fluxes = [];            % Fluxes for MSIS
feE.e_m = [-sin(13/180*pi) cos(13/180*pi)];
feE.fi_m = atan2(feE.e_m(1),feE.e_m(2));
feE.width_weights = [1 .5]; % Single sided weight array, will be
                            % zero-phase symetrically expanded 
                            %[w0 w1] -> [w1 w0 w1]
feE.cut_off_fraction = 0.4; % truncated damped lsq SVD-truncation fraction. 
feE.damp_par = 1e-3;        % damped lsq SVD damp parameter instead
                            % of inv(S) use inv(S+damp_par)
feE.h_max = 190;            % assumed max of 6300 emission
if nargin == 0
  % If no input arguments an one output, give the default options
  return 
elseif nargin<4 | isempty(OPS)
  % If no options just take all the default ones
  OPS = feE;
else
  % Otherwise asume there are some meaningfull ones, but merge the
  % default in case not enough options is given.
  OPS = merge_structs(feE,OPS);
end
clear feE

%Make up spatial and energy grids
z_max4278 = 300;
z_min4278 = 85;
dz = 4;
% 2-D Grid for 4278 emission
z = z_min4278:dz:z_max4278;
% And for 6300
zr = z_min4278:dz:z_max4278+50;
xmax = 200 * ( cos(min(theta)) - sin(OPS.fi_m));
xmin = 200 * ( cos(max(theta)) - sin(OPS.fi_m));


x = xmin:dz:xmax;
Xr = xmin:dz:xmax;
[X,Z] = meshgrid(x,z);
[Xr,Zr] = meshgrid(Xr,zr);
x = -175:4:160;
Xr = -175:4:160;
[X,Z] = meshgrid(x,z);
[Xr,Zr] = meshgrid(Xr,zr);
% make them field aligned
Xr = Xr + Zr*sin( -13/180*pi );
X = X + Z*sin( -13/180*pi );
% filterfunction from 1km grid to smooth base functions
hfk = sin([0:8]*pi/8).^2;

% Energy grid
E0 = logspace(-1,log10(150),100);

% Create a model atmosphere
% Used for calculating transfer matrix from f_e(E) to 4278A N_2^+ emission

%%% BAKAyarrro! height in cm electron energies in eV, densities in cm^-3
[atm_msis_cgs] = msis([z_min4278:z_max4278]*1000,[31+14 18*3600+40*60],[67.5 20],[],1);


raa = atm_msis_cgs(:,8);
nO  = atm_msis_cgs(:,2);
nN2 = atm_msis_cgs(:,3);
nO2 = atm_msis_cgs(:,4);
% The actual transfer matrix. Based on M. Rees energy deposition
% calculations 
[Mtr_fe2I4278] = M_fe2I4278([85:300]*1000*100,E0*1000,raa,nN2,nO,nO2);
% Resample to my base functions
V4278 = conv2(Mtr_fe2I4278,hfk,'same');
V4278 = interp1(z_min4278:z_max4278,V4278,Z(:,1));



%%% Make a 2-D to 1-D camera.
% Single station position
r1 = [-50 0];

% Transfer matrix from 2-D volume emission down to 1-D image plane
[trmtr1,fi_out] = cos2_trmtr2d(r1,theta,X,Z,4);    % 4278
[trmtr1r,fi_out] = cos2_trmtr2d(r1,theta,Xr,Zr,4); % 6300

% Locate local maximas in 6300
[Imax6300,i_max6300] = find_loc_minmax(filtfilt([.5 1 1 1 .5]/4,1,I6300),1);
i_max6300(Imax6300<1e-2*max(Imax6300)) = [];
Imax6300(Imax6300<1e-2*max(Imax6300)) = [];

e_max6300 = [cos(theta(i_max6300))' sin(theta(i_max6300))'];
l_200     = OPS.h_max./e_max6300(:,2);

x_b200 = r1(1) + l_200'.*cos(theta(i_max6300));
x_b100 = x_b200+(100-OPS.h_max)*sin(OPS.fi_m);

z_b = z_min4278:4:z_max4278;

[X_B,Z_B] = meshgrid(sort(x_b100),z_b);

% Transfer matrixes from the altitude distributions in the arcs
% down to the image plane
[RM1] =     cos2_trmtr2d(r1,theta,X_B,Z_B,4);

for i = 2:length(OPS.width_weights),
  
  RM1 = RM1 + OPS.width_weights(i) * cos2_trmtr2d(r1,theta,X_B+dz*i,Z_B,dz);
  RM1 = RM1 + OPS.width_weights(i) * cos2_trmtr2d(r1,theta,X_B-dz*i,Z_B,dz);
  
end
for i = length(x_b100):-1:1,
  
  blk_D4278{i} = V4278';
  
end

%%%keyboard

% Transfer matrix from the electron fluxes in the separate arcs
% down to the image plane
Cmtr  = RM1*blkdiag(blk_D4278{:})';

[U,S,V] = svd(Cmtr);

cut_indx = round(min(OPS.cut_off_fraction*size(S,2),min(size(S))));
damp_par = OPS.damp_par;
feE = dlsq_svd(U(:,1:cut_indx),S(1:cut_indx,1:cut_indx)+damp_par*eye(cut_indx),V(:,1:cut_indx),I4278);
