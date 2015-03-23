%% 1 Optical parameters
% The ASK-optpar.mat file contains 3 structs with fields for the
% azimuth and zenith angles in 256x256 matrices, together with
% fields for the pixels in 256x256 matrices (in units: "fraction of
% image size"). To do for Hanna: recalculate the ASK 1,2,3 az and
% ze matrices, the ones here seems very shady, see below...
load 620120124193524r1-frame1.acc
load 620120124193524r1-frame3.acc
load 20120124193524r3-frame16.acc % 20120124193524r3-frame16.acc
optpASK1 = X620120124193524r1_frame1([7:14 6 end])
%           620120124193524r1-frame1.acc
% optpASK3 = X620120124193524r1_frame3([7:14 6 end]);
optpASK3 = X20120124193524r3_frame16([7:14,6,end])
%           20120124193524r3-frame16.acc


%% 2 Geometry of the set-up
%% 2.1 ASK positions:
r_0 = [0 0 0]; % Jupp. 
%%
% All calculations is done in a coordinate system where the
% position of the ASK instrument is in the origin.

%% 4 Set-up of paraphenalia for the fast projction
% For the estimation of the ion drift we use the fast
% projection of 3-D volume emission distributions based on
% smooth base functions (Rydesater and Gustavsson 2001) - but here
% we use cos^2-shaped base functions. 
% 
%% 4.1 Set up the geometry of the base function block
ds = 1/6;  % Size (full-width-at-half-max) of base function in km:
ds = 1/4.5;
sx = 68; % Number of base functions in WEST-EAST direction
sy = 78; % Number of base functions in NORTH-SOUTH direction
sz = 600;% Number of base functions along the magnetic zenith direction
sx = round(68*4.5/6) % Number of base functions in WEST-EAST direction
sy = round(68*4.5*ds) % Number of base functions in NORTH-SOUTH direction
sz = round(600*2*4.5*ds);% Number of base functions along the magnetic zenith direction
%%
% |ds| should preferably a little smaller and the number of
% elements a little bit bigger.
% 
%% 4.1.1 Magnetic field
% These might have to/should be adjusted to the accurate values at
% the observation site:
ze_B = (90-82.28)*pi/180;   % dip angle average 100<-300
az_B = (180+4.05)*pi/180; % azimuth angle (clockwise from north)
e_B = [sin(az_B)*sin(ze_B) cos(az_B)*sin(ze_B) cos(ze_B)];
%% WARNING!
% The above values are obtained from the EISCAT web-site/or directly
% from http://omniweb.gsfc.nasa.gov/cgi/vitmo/vitmo_model.cgi
% for the time of interest. Unfortunately the nubers are calculated
% along the vertical - not tracing the magnetic field line!
% The below values are much closer to the unit vector of the
% magnetic "field line" that has the foot-point at the ESR site:
e_b = [-0.013272     -0.14735        0.989];
e_B
e_b
e_B = e_b;

%% 4.1.2 Position of the lower south-west corner
h0 = 200;
[xt1,yt1,zt1] = inv_project_img(ones(256,256),[0 0 0],optpASK1(9),optpASK1,[0 0 1],h0);
[xt3,yt3,zt3] = inv_project_img(ones(256,256),[0 0 0],optpASK3(9),optpASK3,[0 0 1],h0);
pcolor(xt1,yt1,-ones(256,256)),shading flat
ax = floor(axis);
r0_top = [ax([1,3]),h0];
r0 = point_on_line(r0_top,e_B,-110)+[0,2,0];
r0 = [-13.404      -11.176-1        91.21];
% r0 = [-12.5          -17       90.997];
%% 4.1.3 Orientation of the block
% Unit vector along the first (x) second and third dimension of the
% base-function-block:
e_p = e_B;
e_p(3) = 0;
% e_1 should be perpendicular to eB and a vector in the meridional
% plane that is horisontal:
e_1 = cross(e_B,e_p);
% Lets make e_2 in the other direction of that initial horisontal
% vector, that way, if e_B was in the north-south plane e1 would be
% due East and e2 due north:
e_2 = - e_p/norm(e_p);
e_1 = e_1/norm(e_1);
% Scale e_3 so that its vertical component is 1, this makes up a
% skewed block of blobs with each layer shifted horisontally
e_3 = e_B/e_B(3);

dr3 = ds*e_3;
dr1 = ds*e_1;
dr2 = ds*e_2;
%%
% Note that this makes up a block tilted to be || with magnetic
% zenith, and one other dimension perpendicular to the southward
% component and horizontal. Right?
% 
% 4.2 Setting up the base function block and its location
I3D0 = ones([sy sx sz]);
[r,X,Y,Z] = sc_positioning(r0,dr1,dr2,dr3,I3D0);
XfI = r0(1)+dr1(1)*(X-1)+dr2(1)*(Y-1)+dr3(1)*(Z-1);
YfI = r0(2)+dr1(2)*(X-1)+dr2(2)*(Y-1)+dr3(2)*(Z-1);
ZfI = r0(3)+dr1(3)*(X-1)+dr2(3)*(Y-1)+dr3(3)*(Z-1);

size(I3D0)
%% 4.3 Setting the number of layers
% nr_layers are the number of "size groups" we divide the 3-D block
% into, all blobbs within one "size group" will have the same sized
% foot-print in the images and will be projected-filtered together.
nr_layers = 60;
%% 4.4 Creating the station  structure 
% Here we make the structure array holding the projection matrix,
% the filter kernels and size grouping of the base functions needed
% for the fast projection.
% Set up the stuff on the camera and 3D structure needed for the
% fast projection.
optp{1} = optpASK1;
optp{2} = optpASK3;

for i1 = 1:2,
  
  rstn = [0 0 0];
  imgsize = [256 256];
  cmt = eye(3);
  [stns(i1).uv,stns(i1).d,stns(i1).l_cl,stns(i1).bfk,~,stns(i1).sz3d] = camera_set_up_sc(r,X,Y,Z,optp{i1},rstn,imgsize,nr_layers,cmt,ds);
  
end

%% 4.5 Test that the fast projection works
I3D0 = zeros(size(X));
I3D0(12,24,:) = 1.2;
I3D0(24,12,:) = 1;
I3D0(24,36,:) = 1.2;
I3D0(36,24,:) = 1.1;
I3D0(24,24,:) = 3.3;

I3D0(12,12,:) = 1;
I3D0(12,36,:) = 1.2;
I3D0(36,12,:) = 1.1;
I3D0(36,36,:) = 1.3;

I3D0(1,1,:) = 1.2;
I3D0(sy,1,:) = 1;
I3D0(1,sx,:) = 1.2;
I3D0(sy,sx,:) = 1.1;

I3D0(:,:,1:4)   = .3;
I3D0(:,:,200:206) = 0.8;
I3D0(:) = 1;
I3D0(:) = 0;
I3D0(19,   17:sx,    end) = 1;
I3D0(   sy,17:sx,    end) = 1;
I3D0(19:sy,   sx,    end) = 1;
I3D0(19:sy,17,       end) = 1;
I3D0(19,   17:sx,100    ) = 1;
I3D0(   sy,17:sx,100    ) = 1;
I3D0(19:sy,   sx,100    ) = 1;
I3D0(19:sy,17,   100    ) = 1;

I3D0(:) = 1;
size(I3D0)

img_t{1} = fastprojection(I3D0,...
                          stns(1).uv,stns(1).d,stns(1).l_cl,stns(1).bfk,256*[1 1],...
                          ones(256,256),stns(1).sz3d);
img_t{2} = fastprojection(I3D0,...
                          stns(2).uv,stns(2).d,stns(2).l_cl,stns(2).bfk,256*[1 1],...
                          ones(256,256),stns(2).sz3d);

subplot(2,2,1),imagesc(img_t{1})
subplot(2,2,2),imagesc(img_t{2})

I3D0(:) = 0;
I3D0([1 end],1:6:end,1:35:end) = 1;
I3D0(1:6:end,[1 end],1:35:end) = 2;
whos I3D0 XfI ZfI YfI X
img_t{1} = fastprojection(I3D0,...
                          stns(1).uv,stns(1).d,stns(1).l_cl,stns(1).bfk,256*[1 1],...
                          ones(256,256),stns(1).sz3d);
img_t{2} = fastprojection(I3D0,...
                          stns(2).uv,stns(2).d,stns(2).l_cl,stns(2).bfk,256*[1 1],...
                          ones(256,256),stns(2).sz3d);


subplot(2,2,3),imagesc(img_t{1})
subplot(2,2,4),imagesc(img_t{2})
%%
I3D0(:) = 0;
I3D0(1:19:end,1:19:end,41:225:end) = 1;
img_t{1} = fastprojection(I3D0,...
                          stns(1).uv,stns(1).d,stns(1).l_cl,stns(1).bfk,256*[1 1],...
                          ones(256,256),stns(1).sz3d);
img_t{2} = fastprojection(I3D0,...
                          stns(2).uv,stns(2).d,stns(2).l_cl,stns(2).bfk,256*[1 1],...
                          ones(256,256),stns(2).sz3d);
figure
subplot(1,2,1)
imagesc(img_t{1})
subplot(1,2,2)
imagesc(img_t{2})
%%
I3D0(:) = 0;
I3D0(14,35,100) = 1e3;
size(I3D0)

img_t{1} = fastprojection(I3D0,...
                          stns(1).uv,stns(1).d,stns(1).l_cl,stns(1).bfk,256*[1 1],...
                          ones(256,256),stns(1).sz3d);
img_t{2} = fastprojection(I3D0,...
                          stns(2).uv,stns(2).d,stns(2).l_cl,stns(2).bfk,256*[1 1],...
                          ones(256,256),stns(2).sz3d);
figure
[Xmax,Ymax] = inv_project_img(ImStack{1}(:,:,12),[0 0 0],optpASK1(9),optpASK1,[0 0 1],113.2,eye(3));
subplot(2,2,1)
pcolor(Xmax,Ymax,ImStack{1}(:,:,12)),shading flat          
hold on
pcolor(Xmax,Ymax,ImStack{1}(:,:,12)),shading flat          
subplot(2,2,3)
imagesc(ImStack{1}(:,:,12))
hold on
contour(img_t{1},10,'r')
subplot(2,2,2)
imagesc(img_t{2})

%% 6 Set the tomo_options - REMAINS!
% 
qb_ASK2 = [5 256-5 5 256-5];

mod_ops.qb = [qb_ASK2];


fms_ops = optimset('fminsearch');
fms_ops.Display = 'iter';        


% $$$ 20120124193457d1
% $$$ 20120124193457d2
% $$$ 20120124193457d3
% $$$ 
% $$$ 20120124193524r1
% $$$ 20120124193524r1w
% $$$ 20120124193524r2
% $$$ 20120124193524r2w
% $$$ 20120124193524r3
% $$$ 20120124193524r3w
