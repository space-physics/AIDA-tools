function I_of_T = ASK_add_int_radar(RadarSite,az,el,dphi,indices,Cams,optpar,r_camera,OPS)
% ASK_ADD_INT_RADAR - Image intenisity inside radar beam.
%   The calibrated ASK-image intensities inside a radar beam is
%   averaged for a sequence of images from one or more of the ASK
%   cameras.
% 
% Calling:
%  I_of_T = ASK_add_int_radar(RadarSite,az,el,dphi,indices,Cams,optpar,r_camera,OPS)
% Input:
%  RadarSite - Initial of radar site [ 'T' | 'E' ] is used for
%              setting default azimuth, elevation and beam-width
%  az        - Azimuth angle of radar beam in degrees clockwise
%              from north 
%  el        - Elevation angle of radar beam in degrees
%  dphi      - radar half-beam-width degrees
%  indices   - indices of images to read-n-average. [1 x N]
%  Cams      - Array with camera numbers [1,2,3] 
%  optpar    - cell array, {1 x nCams}, with optical parameter for
%              cameras 
%  r_camera  - camera position. Might be useful for Ramfjord since
%              the Pre building is a several 100-ms away from the
%              dish.
%  OPS       - Options struct, controlling image filtering 
%             fields are: filtertype and filterArgs. The available
%             filters are  [ {'none'} | 'conv2' | 'sigma' | 'median'
%             | 'susan' | 'medfilt2' | 'wiener2'] (sigma and wiener2;
%             and median and medfilt2 are "same-thing-different
%             name) SUSAN is bilateral filter, conv2 linear
%             filter. Then the filterArgs should be a cell array
%             with cell arrays, where the inner cell-array should
%             be the extra arguments to the respective
%             filter. Several filtertypes can be run
%             sequentially. Identical with the OPS struct argument
%             of ASK_read_v
% Output:
%  I_of_T - time-series with average intensity inside the nominal
%           radar beam. Cell array {1 x nCams} with time-series of
%           size [1 x length(indices)] scaled to Rayleighs

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies


global vs
% global asklut
dOPS = ASK_read_v;
if nargin == 0
  I_of_T = dOPS;
  return
end
if nargin >= 9
  dOPS = merge_structs(dOPS,OPS);
end
% j1 = floor(i1);

% And get the intensity calibration factors for the event
calib = ASK_get_ask_cal(vs.vmjs(vs.vsel),Cams);

for i1 = length(Cams):-1:1,
  
  ASK_v_select(Cams(i1),'quiet'); % Set current camera
  imsiz = [vs.dimx(vs.vsel),vs.dimy(vs.vsel)]; 
  % This got to be in there to calculate the image coordinates of the
  % radar beam once for each camera:
  [u0,v0,r] = ASK_get_radar(RadarSite,az,el,dphi,optpar{i1},imsiz,100,r_camera);
  % Then this has to make the Weighting mask for each camera.
  RoundMask = ASK_roundmask( vs.dimx(vs.vsel),vs.dimy(vs.vsel), u0, v0, r );
  nmask = sum(RoundMask(:));
  RoundMask = logical(RoundMask);
  
  for i2 = length(indices):-1:1,
    im1 = ASK_read_v(indices(i2),[],[],[],dOPS);   % Read the ASK#i1 image
    I_of_T{i1}(i2) = sum(im1(logical(RoundMask(:))))/nmask;
  end
  I_of_T{i1} = I_of_T{i1}*calib(i1)/vs.vres(vs.vsel);
  
end
