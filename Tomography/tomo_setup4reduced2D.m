function [trmtrs,U,V,X,Y,Z] = tomo_setup4reduced2D(stns,OPS)
% tomo_setup4reduced2D - Set up coordinates and projection matrices
% for a plane between 2 stations that is parallel with B (Tromso by
% default, arbitrary magnetic field can be given as a field in the
% options structure: OPS.B). 
%
% Calling
%   [trmtrs,U,V,X,Y,Z] = tomo_setup4reduced2D(stns,OPS)
%   OPS = tomo_setup4reduced2D
% Input:
%   stns - stations structure, with at least 2 elements, out of
%          which the two first is used to define the horizontal
%          direction of the plane to build.
%   OPS  - options structure with fields shaping the outputs and
%          the running of the function. Fields are:
%          maxAlt - highest altitude of the 2-D slice (250 km)
%          minAlt - lowest  altitude of the 2-D slice (80 km)
%          ds     - Size of blobs (2 km)
%          PlotStuff - flag for plotting intermediate steps (1),
%                      set to 0 to turn off.
%          keyboardwait - stop with a keyboard prompt at the end of
%                         the function (0), set to 1 to stop.

%   Copyright � 20120330 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

dOps.maxAlt       = 250; % Highest altitude of 2-D block
dOps.minAlt       =  80; % Lowest altitude of 2-D block
dOps.ds           =   2; % Size of blob
dOps.PlotStuff    =   1; % Plot figures of what's done.
dOps.keyboardwait =   0; % Dont wait at keyboard inside this function 

% If the function is called without input arguments, then just
% return the default options:
if nargin == 0
  trmtrs = dOps;
  return
elseif nargin > 1
  % ...on the other hand if there's an options struct given then
  % merge that one ontop of the default options
  dOps = catstruct(dOps,OPS);
end

%% Geometry Set-up for Stations and the plane-of-interest
%
rStn1toStn2 = stns(2).obs.xyz - stns(1).obs.xyz;
rStn1toStn2(3) = 0; % This is something that is a bit dodgy. I
                    % don't know with is better here, to stick to a
                    % solidly horizontal unit-vector at station 1
                    % or to stick with the curvature of the
                    % earth. BG 20120123
eS1toS2 = rStn1toStn2/norm(rStn1toStn2);

%% Magnetic field for EISCAT sites
B = get_B_EISCAT;
if isfield(dOps,'B')
  B = dOops.B;
end
%%
% 1 - Ramfjord
% Magnetic field direction, average between ground and 300 km:
eB = sum(B(1).B);eB = -eB'/norm(eB);
eBp = (stns(1).obs.trmtr*eB);
% Incermental angle for varying zenith angle in meridional plane -
% for making lines-of-sight fan:
dphi = 1e-2*pi/180*35; % This is hardcoded for giving ~256 elements
                       % in a image-fan for the ALIS camera located
                       % in Skibotn 2008. BG 20120123
%% TODO: Fix this to allow for a more flexible use

%% Unit vector perpendicular to both eB and eS1toS2
%  This vector we should rotate line-of-sight around to get the
%  image fan.
e2rot = cross(eS1toS2,eB);
% And the rotation matrix for rotations around e2rot:
RotAroundE2rot = rot_around_v(e2rot,dphi);

%% Azimuth and Zenith angles for line-of-sight:
eLOS = eB;
ze_B = atan(sum(eLOS(1:2).^2).^.5/eLOS(3));
az_B = atan2(eLOS(1),eLOS(2));
ze_tmp = ze_B;
az_tmp = az_B;

% Image point of magnetic zenith (for checking only):
sizim1 = size(stns(1).img);
[uB,vB] = project_directions(az_tmp,...
                             ze_tmp,...
                             stns(1).obs.optpar,stns(1).obs.optpar(9),...
                             sizim1)
uP = uB;
vP = vB;
% rotate the zenith angle in one direction around E2ROT until it
% leaves the image field-of-view:
while 1 <= uP && uP <= sizim1(2) && 1<=vP && vP <= sizim1(1)
  
  eLOS = (RotAroundE2rot*eLOS); % Rotate line-of-sight vector
  ze_tmp = atan(sum(eLOS(1:2).^2).^.5/eLOS(3)); 
  az_tmp = atan2(eLOS(1),eLOS(2));
  % Get the image coordinates that line-of-sight direction:
  [uP,vP] = project_directions(az_tmp,ze_tmp,...
                               stns(1).obs.optpar,stns(1).obs.optpar(9),...
                               sizim1);
  if dOps.PlotStuff
    plot(uP,vP,'g*'),
  end
end

% Rotate the line-of-sight vector one tick back into the image
% field-of-view:
eLOS = (RotAroundE2rot'*eLOS);
% (...the transpose of a rotation matrix rotates in the opposite
% directions...)

% Start gathering parameters for building the projection matrix,
% such as azimuth and zenith angles
iM = 1;
ze_tmp = atan(sum(eLOS(1:2).^2).^.5/eLOS(3));
az_tmp = atan2(eLOS(1),eLOS(2));
% This should make up the first line-of-sight pixel coordinates of
% the fan that falls inside the image field-of-view:
[uP,vP] = project_directions(az_tmp,ze_tmp,...
                             stns(1).obs.optpar,stns(1).obs.optpar(9),...
                             sizim1);

% Rotate the line-of-sight vector in the other direction across the
% image field-of-view:
while 1 <= uP && uP <= sizim1(2) && 1<=vP && vP <= sizim1(1)
  
  % as long as we're inside the image area we save away the
  % line-of-sight; to make a 1D-fan:
  az_M(iM) = az_tmp; % Azimuth and 
  ze_M(iM) = ze_tmp; % Zenith angle
  uPM(iM) = uP;      % Corresponding 
  vPM(iM) = vP;      % pixel coordinates
  if dOps.PlotStuff
    plot(uP,vP,'b.')
  end
  iM = iM + 1;
  % Rotate the line-of-sight vector:
  eLOS = (RotAroundE2rot'*eLOS);
  ze_tmp = atan(sum(eLOS(1:2).^2).^.5/eLOS(3));
  az_tmp = atan2(eLOS(1),eLOS(2));
  % Calculate its image coordinates:
  [uP,vP] = project_directions(az_tmp,ze_tmp,...
                               stns(1).obs.optpar,stns(1).obs.optpar(9),...
                               sizim1);
  
end

% Stack away the image coordinates of the beam-fan:
U{1} = uPM;
V{1} = vPM;

if dOps.PlotStuff
  plot([1 256 256 1 1],[1 1 256 256 1],'r')
  hold on
  pause(0.5)
end

% This is the line-of-sight fan:
eMfan = [sin(az_M').*sin(ze_M') cos(az_M').*sin(ze_M') cos(ze_M')];
eMfan = (stns(1).obs.trmtr*eMfan')';

% This should be the position of the line-of-sights at the highest
% altitude.
for i1 = 1:length(eMfan)
  
  r_maxAlt(i1,:) = point_on_line(stns(1).obs.xyz,...
                                 eMfan(i1,:),...
                                 dOps.maxAlt/eMfan(i1,3));
end
% Then we calculate the positions of those field-lines at the
% lowest altitudes:
for i1 = 1:length(eMfan)
  
  r_minAlt(i1,:) = point_on_line(r_maxAlt(i1,:),eBp',(dOps.minAlt-dOps.maxAlt)/eBp(3));
  
end
% This should be used to build the 2-D block-of-blobs
if dOps.PlotStuff
  clf
  plot3(r_minAlt(:,1),r_minAlt(:,2),r_minAlt(:,3),'b.-'),
  hold on,
  plot3(r_maxAlt(:,1),r_maxAlt(:,2),r_maxAlt(:,3),'r.-'),
  for i1 = 1:length(stns),
    phStn(i1) = plot3(stns(i1).obs.xyz(1),stns(i1).obs.xyz(2),stns(i1).obs.xyz(3),'*');
    set(phStn(i1),'color',rand(1,3))
  end
  pause(0.5)
end

% This should be the lowest corners:
r001 = point_on_line(r_maxAlt(1,:),eBp',(dOps.minAlt-dOps.maxAlt)/eBp(3))
r002 = point_on_line(r_maxAlt(end,:),eBp',(dOps.minAlt-dOps.maxAlt)/eBp(3))

% Blob-size in km:
dS = dOps.ds;

% Horizontal base vector in the direction between the stations:
dr1 = eS1toS2*dS;
% Tricky part: The base-vector along B should have a component
% perpendicular to eS1toS2 that is dS long. This we should have
% because we want the blob to be cos^2 dr1 * cos^2 (dr3 perp dr1)
% so that consecutive layers do not overlap, but still are skewed
% so that blob(i1,i2,i3) and blob(i1,i2,i3+1) are on the same
% magnetic field-line.
%
% So we start with calculating that component, by subtracting from 
%                 eB   the component that is parallel to eS1toS2:
eB_perp_eS1toS2 = eB' - dot(eB',eS1toS2)*eS1toS2;
% Then we get the factor to scale eB with:
ScF4eB = dS/norm(eB_perp_eS1toS2);
% And the base-vector:
dr3 = ScF4eB*eB';
% And a third base vector to complement the system, here we choose
% one that is also horizontal. that way all layers V3D(:,:,iN) will
% be at the same altitude:
dr2 = dS*cross(eS1toS2,[0 0 1]);


[uU2,vU2,lU2] = project_point(stns(2).obs.xyz,...
                              stns(2).obs.optpar,...
                              r_maxAlt',...
                              stns(2).obs.trmtr',...
                              sizim1);
[uL2,vL2,lL2] = project_point(stns(2).obs.xyz,...
                              stns(2).obs.optpar,...
                              r_minAlt',...
                              stns(2).obs.trmtr',...
                              sizim1);

if dOps.PlotStuff
  [uU1,vU1,lU1] = project_point(stns(1).obs.xyz,...
                                stns(1).obs.optpar,...
                                r_maxAlt',...
                                stns(1).obs.trmtr,...
                                sizim1);
  [uL1,vL1,lL1] = project_point(stns(1).obs.xyz,...
                                stns(1).obs.optpar,...
                                r_minAlt',...
                                stns(1).obs.trmtr,...
                                sizim1);
  clf
  plot(uPM,vPM)
  hold on
  plot(uL1,vL1,'r')
  plot(uU1,vU1,'g--')
  pause(0.5)
  clf
  plot(uU2,vU2,'+')
  hold on
  plot(uL2,vL2,'r')
  pause(0.5)
end

% Calculate the number of blobs needed to fill the full slice:
l_bob = norm(r_maxAlt(1,:)-r_maxAlt(end,:));
h_bob = norm(r_maxAlt(1,:)-r_minAlt(1,:));
nHor = ceil(l_bob/dS);
nVer = ceil(h_bob/dS);

% Allocate that amount of memmory:
Vem = zeros([1 nHor nVer]);

% set the lower south-west corner:
r0 = r001;
% TODO: Check that the right one of r001 and r002 is selected as
% the LSW-corner!

% Calculate duplicate arrays for the position of the base functions:
[r,Xi,Yi,Zi] = sc_positioning(r0,dr1,dr2,dr3,Vem);
X = r0(1)+dr1(1)*(Xi-1)+dr2(1)*(Yi-1)+dr3(1)*(Zi-1);
Y = r0(2)+dr1(2)*(Xi-1)+dr2(2)*(Yi-1)+dr3(2)*(Zi-1);
Z = r0(3)+dr1(3)*(Xi-1)+dr2(3)*(Yi-1)+dr3(3)*(Zi-1);

if dOps.PlotStuff
  clf
  plot3(r_minAlt(:,1),r_minAlt(:,2),r_minAlt(:,3),'b.-'),
  hold on,
  plot3(r_maxAlt(:,1),r_maxAlt(:,2),r_maxAlt(:,3),'r.-'),
  for i1 = 1:length(stns),
    phStn(i1) = plot3(stns(i1).obs.xyz(1),stns(i1).obs.xyz(2),stns(i1).obs.xyz(3),'*');
    set(phStn(i1),'color',rand(1,3))
  end
  plot3(r(1,:),r(2,:),r(3,:),'g-'),
  
end

% Here check wether the slice cuts closer to the vertical or the
% horisontal direction in STNS(2).img:
phi2 = atan2(diff(vU2(4:5)),diff(uU2(4:5)))*180/pi;
% Then make te fan from one pixel per column:
if ( 45 < phi2 && phi2 < 135 || ...
     -135 < phi2 && phi2 < -45 )
  v2i = 1:size(stns(2).img,1); % 256;
  u2i = interp1(vL2(1<=uL2&uL2<=256&1<=vL2&vL2<=256),...
                uL2(1<=uL2&uL2<=256&1<=vL2&vL2<=256),v2i,'pchip');
else % Or row:
  u2i = 1:size(stns(2).img,2); % 256;
  v2i = interp1(uL2(1<=uL2&uL2<=256&1<=vL2&vL2<=256),...
                vL2(1<=uL2&uL2<=256&1<=vL2&vL2<=256),u2i,'pchip');
end


U{2} = u2i;
V{2} = v2i;
% Polar coordinates of the fan in the second camera
[az2i,ze2i] = inv_project_directions(u2i,v2i,stns(2).img,...
                                     r,... % Unused argument
                                     stns(2).obs.optpar(9),...
                                     stns(2).obs.optpar,...
                                     [0 0 1],100,...  % Unused arguments
                                     eye(3));
% Yup, here there is a whole lot of repeated calculations between
% line-of-sight vector components and the corresponding
% azimuth-zenith angles. There really should be a 
e2Fan = [sin(az2i).*sin(ze2i) cos(az2i).*sin(ze2i) cos(ze2i)];
e2Fan = (stns(2).obs.trmtr'*e2Fan')';

% ...and finaly calculate the projection matrices:
trmtrs{1} = trmtr3Dto1D(X,Y,Z,stns(1).obs.xyz,eMfan,dS); 
trmtrs{2} = trmtr3Dto1D(X,Y,Z,stns(2).obs.xyz,e2Fan,dS); 


if dOps.keyboardwait
  keyboard
end
