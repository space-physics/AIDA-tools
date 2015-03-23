function [trmtrs,eMfan,Vem,X,Y,Z,U,V] = ASK_slice2trmtr(phi_slice,Ops)
% ASK_SLICE2TRMTR - projection matrix from blobs in slice || B to ASK-image
%   
% Calling:
%   [trmtrs,eMfan,Vem,X,Y,Z,U,V] = ASK_slice2trmtr(phi_slice,Ops)
% Input:
%   phi_slice - angle from North of the horizontal extension of 2-D
%               slice [radians]
%   Ops       - options struct, controlling the set-up and workings
%               of the function. Fields with their default values
%               and their usage:
%               maxAlt (250 km) The highest altitude of the slice
%               minAlt ( 80 km) The lowest altitude of the slice
%               dS     (  1 km) The blob-size, emission in the 3-D
%                               slice is modeled with
%                               cos(dx)^2*cos(dz)^2T shaped blobs,
%                               where dx and dz are distance away
%                               from blob centre and pi/2 at
%                               neighbouring centres
%               PlotStuff    0  Flag controlling illustrative
%                               plotting.
%               keyboardwait 0  Flat for stopping inside the
%                               function. 
%  The default returned when ASK_slice2trmtr is called without
%  input arguments.
% 
%  The function calculates the projection matrix for the current
%  ASK camera (selected with ASK_v_select, often done implicitly
%  with ASK_read_vs) The function uses vs.vcnv(vs.vsel,:) for
%  camera calibration to determine the look-direction and which
%  pixels a blob will project to.

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

global vs


dOps.maxAlt       = 250; % Highest altitude of 2-D block
dOps.minAlt       =  80; % Lowest altitude of 2-D block
dOps.dS           =   1; % Size of blob
dOps.PlotStuff    =   0; % Plot figures of what's done.
dOps.keyboardwait =   0; % Dont wait at keyboard inside this function 

% If no input arguments
if nargin == 0
  % Just return the default arguments
  trmtrs = dOps;
  return
elseif nargin > 1
  % otherwise if there is a user-supplied options struct merge that
  % one ontop of the default options
  dOps = merge_structs(dOps,Ops);
end


sizim1 = [vs.dimy(vs.vsel) vs.dimx(vs.vsel)];

%% Geometry Set-up for ASK-arc-splitting
%

%% Magnetic field for EISCAT sites
B = get_B_EISCAT;
%%
% 1 - Ramfjord
% Magnetic field direction average between ground and 300 km:
eB = sum(B(1).B);eB = -eB'/norm(eB);
% Horisontal unit vector for the slice
eSliceHor = [cos(phi_slice),sin(phi_slice),0];
%% Unit vector perpendicular to both eB and eSliceHor
%  This vector we should rotate line-of-sight around to get the
%  image fans.
e2rot = cross(eSliceHor,eB);
% Incermental angle for varying zenith angle in meridional plane -
% for making lines-of-sight fan:
dphi = 1e-2*pi/180;
% And the rotation matrix for rotations around e2rot:
RotAroundE2rot = rot_around_v(e2rot,dphi);

%% Magnetic zenith should be a good point to start rotating
%around... 
eLOS = eB;

% Azimuth and Zenith angles of magnetic zenith:
ze_B = atan(sum(eB(1:2).^2).^.5/eB(3));
az_B = atan2(eB(1),eB(2));
ze_tmp = ze_B;
az_tmp = az_B;

% Image point of magnetic zenith:
[uB,vB] = project_directions(az_B,...
                             ze_B,...
                             [vs.vcnv(vs.vsel,:),11],11,...
                             [vs.dimy(vs.vsel),vs.dimx(vs.vsel)]);

if dOps.PlotStuff
  plot(uB,vB,'bh'),hold on
  plot([1,sizim1(2)*[1 1],1,1],[1,1,sizim1(2)*[1,1],1],'k')
end


uP = uB;
vP = vB;
az_tmp = az_B;
ze_tmp = ze_B;

% rotate the zenith angle in one direction around E2ROT until it
% leaves the image field-of-view:
while 1 <= uP & uP <= sizim1(2) & 1<=vP & vP <= sizim1(1)
  
  eLOS = (RotAroundE2rot*eLOS); % Rotate line-of-sight vector
  ze_tmp = atan(sum(eLOS(1:2).^2).^.5/eLOS(3));
  az_tmp = atan2(eLOS(1),eLOS(2));
  % Get the image coordinates that line-of-sight direction:
  [uP,vP] = project_directions(az_tmp,ze_tmp,...
                               [vs.vcnv(vs.vsel,:),11],11,...
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
                             [vs.vcnv(vs.vsel,:),11],11,...
                             sizim1);

% Rotate the line-of-sight vector in the other direction across the
% image field-of-view:
while 1 <= uP & uP <= sizim1(2) & 1<=vP & vP <= sizim1(1)
  
  % as long as we're inside the image area we save away the
  % line-of-sight; to make a 1D-fan:
  az_M(iM) = az_tmp; % Azimuth and 
  ze_M(iM) = ze_tmp; % Zenith angle
  U(iM) = uP;        % Corresponding 
  V(iM) = vP;        % pixel coordinates
  if dOps.PlotStuff
    plot(uP,vP,'b.')
    drawnow
  end
  iM = iM + 1;
  % Rotate the line-of-sight vector:
  eLOS = (RotAroundE2rot'*eLOS);
  ze_tmp = atan(sum(eLOS(1:2).^2).^.5/eLOS(3));
  az_tmp = atan2(eLOS(1),eLOS(2));
  % Calculate its image coordinates:
  [uP,vP] = project_directions(az_tmp,ze_tmp,...
                               [vs.vcnv(vs.vsel,:),11],11,...
                               sizim1);
  
end

% The unit vectors of all lines-of-sight in the fan:
eMfan = [sin(az_M).*sin(ze_M); cos(az_M).*sin(ze_M); cos(ze_M)]';

% This should be the position of the line-of-sights at the highest
% altitude.
for i1 = 1:length(eMfan)
  
  r_maxAlt(i1,:) = point_on_line([0,0,0],...
                                 eMfan(i1,:),...
                                 dOps.maxAlt/eMfan(i1,3));
end
% and this the corresponding lowest altitudes:
for i1 = 1:length(eMfan)
  
  r_minAlt(i1,:) = point_on_line(r_maxAlt(i1,:),eB',(dOps.minAlt-dOps.maxAlt)/eB(3));
  
end

% This should be the lowest corners:
r001 = point_on_line(r_maxAlt(1,:),eB',(dOps.minAlt-dOps.maxAlt)/eB(3));
r002 = point_on_line(r_maxAlt(end,:),eB',(dOps.minAlt-dOps.maxAlt)/eB(3));

% Make the unit vectors for the 
dS = Ops.dS;
dr1 = dS*eSliceHor;
dr2 = dS*cross([0,0,1],eSliceHor);
dr3 = dS*eB'/eB(3);
% This gives a lattice base that have the horizontal unit distance
% of dS, and a vertical separation between horizontal layers of dS,
% while consecutive layers are skewed so that blobs are aligned
% with the magnetic field.

% Calculate the number of blobs in the horizontal and vertical:
l_bob = norm(r_maxAlt(1,:)-r_maxAlt(end,:));
h_bob = abs(r_maxAlt(1,3)-r_minAlt(1,3));
nHor = ceil(l_bob/dS);
nVer = ceil(h_bob/dS);

Vem = ones([1 nHor nVer]);

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
  phStn(i1) = plot3(0,0,0,'*');
  set(phStn(i1),'color',rand(1,3))
  plot3(r(1,1:10:end),r(2,1:10:end),r(3,1:10:end),'g-'),
  
end


% Calculate the projection matrix from the 3-D slice to the image fan:
trmtrs = trmtr3Dto1D(X,Y,Z,[0,0,0],eMfan,dS);
