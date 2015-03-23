function [CalMtr,stn] = tomo_CalSensMat(stn,Vem,X3D,Y3D,Z3D)
% tomo_CalSensMat - calibration factors for FASTPROJECTION
% from volume emission rates (#photons/m^3/s) to Rayleighs.
%
% Calling:
%  [CalMtr,stn] = tomo_CalSensMat(stn,Vem,X3D,Y3D,Z3D)
% Input:
%  stn - tomo-stations struct, only one at a time 
%  Vem - 3-D array with volume emission distribution
%  X3D - 3-D array, Eastish coordinates, same size as Vem
%  Y3D - 3-D array, Northish coordinates, same size as Vem
%  Z3D - 3-D array, Up coordinates, same size as Vem
% Output:
%  CalMtr - sensitivity matrix [Rayleigh/(#photon/m^3/s)] same size
%           as stns.img, this is to be used as the seventh argument
%           to fastprojection. 
%  
% Example useage (sketch):
%   
%  for iStn = 1:length(stns),
%    Meta-code...
%    1, set up a flat Vem structure 80x80x20 perhaps
%    with a wide enough horizontal coverage to make sure that the
%    centre pixel enters the block-of-blobs from under and leaves
%    through the top - not from any side. This might require some
%    manual positioning of BOB for data where cameras have been
%    rotated far from zenith.
%    2, run camera_set_up_sc for stns(iStn),
%    3: [CalMtr,stns(iStn)] = tomo_CalSensMat(stn,Vem,X3D,Y3D,Z3D)
%    4  stns(iStn).CalMtr = CalMtr;
%    end

%% 1 calculate the azimuth, zenith, polar and "clock" angles for
%    every pixel in the images. polar is relative to the optical
%    axis, clock angle is the azimuthal angle around the optical
%    axis, azimuth and clock angles are clock-wise from north and
%    image-vertical respectively.
% 
% First step is to make a pixel grid:
[u,v] = meshgrid(1:size(stn.img,2),1:size(stn.img,1));
%%
% Pre-allocate the angular matrices:
az = u;
ze = u;
phi = u;
theta = u;
%% 
% Then calculate angular arrays:
[az(:),ze(:)] = inv_project_directions(u(:)',v(:)',stn.img,stn.obs.xyz,stn.optpar(9),stn.optpar,[0 0 1],100);
[phi(:),theta(:)] = camera_invmodel(u(:),v(:),stn.optpar,stn.optpar(9),size(stn.img));

% The "flat-field-variation of the fastprojection function seems to
% be:
sens_mtr = 1./cos(theta).^3;   %(iC1).*cos(ze).^p2(iC2));

%% 2 Calibration image,
%    from 1 photon/m^3s:
stn.proj = fastprojection(ones(size(Vem)),...
                           stn.uv,...
                           stn.d,...
                           stn.l_cl,...
                           stn.bfk,...
                           size(stn.img),...
                           sens_mtr);

%% 3 pixel closest to Optical axis:
[Imax,i1,i2] = max2D(cos(theta));

%% 4 unit vector in direction of optical axis:
e_OpticalAxis = [sin(az(i1,i2))*sin(ze(i1,i2)) cos(az(i1,i2))*sin(ze(i1,i2)) cos(ze(i1,i2))];

%% Line-of sight vector to bottom plane in Vem
r_in  = stn.obs.xyz + e_OpticalAxis * min(Z3D(:))/e_OpticalAxis(3);
%% Line-of sight vector to top plane in Vem
r_out = stn.obs.xyz + e_OpticalAxis * max(Z3D(:))/e_OpticalAxis(3);

%% Distance along line-of-sight through Vem:
l = norm(r_in-r_out)*1e3;

%% The image in stn.proj should now just be the image of 1
%  photon/m^3/s, and the fastprojection-flat-field is cos^3(theta)
%  so the calibrated factor should be: 
% 
%  Cal = 1/1e10 \int_l epsilon(l)dl 
%  
%  and since epsilon is 1 the integral becomes fairly simple to
%  calculate. So the calibrated conversion matrix becommes...
%
% Convert sens_mtr to Rayleighs/(#photons/(m^3s))
CalMtr = 1e-10*l*sens_mtr;
