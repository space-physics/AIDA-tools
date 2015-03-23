function [xtr,ytr,ztr,tu1,tv1,tu2,tv2,minl] = triangulate(img1,r1,img2,r2,cm1,cm2,PO,Opts)
% TRIANGULATE - stereoscopic triangulation from a pair of images
% TRIANGULATE is a function for determination of 3D positions of
% objects imaged in 2 images (IMG1 and IMG2) from different
% locations (R1 and R2). The optical transfer function are
% described in PO(1).optpar and PO(2).optpar, CM1 and CM2 are
% optional correction matrices to transform the coordinate systems
% of the cameras. Opts is an options struct. The user is to
% identify the same spatial structure (points) in both images, the
% 3-D coordinates of the structure is calculated as the mid-point
% on the shortest intersection between the lines-of-sight to the
% two points.
%
% Calling:
% [xtr,ytr,ztr,tu1,tv1,tu2,tv2] = triangulate(img1,r1,img2,r2,checktmp,cm1,cm2,PO,OPS)
% OPS = triangulate
% 
% Input:
%  img1  - Image 1 to use to identify common points.
%  r1    - 1x3 array of coordinates for camera 1
%  img2  - Image 2 to use to identify common points.
%  r2    - 1x3 array of coordinates for camera 2
%  cm1   - additional rotation matrix, allowing correcting between
%          local coordinate system 1 and the common coordinates
%  cm2   - additional rotation matrix, allowing correcting between
%          local coordinate system 2 and the common coordinates
%  PO    - array [1 x 2] with fields PO([1,2]).optpar for the
%          optical parameters of the cameras, and optionally
%          PO([1,2]).flipimage [0,1] with 0 (default) for pixel
%          (1,1) in the lower left corner 1 for displaying the 
%          image with pixel (1,1) in the upper left
%          corner. Typically produced with typical_pre_proc_ops
%  Opts  - options structure with fields  
%          ax1 (default [1 256 1 256]) image-1 region to display
%          ax2 (default [1 256 1 256]) image-2 region to display
%          cx1 (default 'auto') image-1 caxis range
%          cx2 (default 'auto') image-2 caxis range
%          SubplotsNotFigs (default 1) display images in
%                subplots in one figure or in two eparate figures 
%          epipolar_lines (default 0) set to 1 to overlay epi-polar
%                lines.
%          epipolar_range (default [80,20,500]) range of epi-polar
%                line [ Z0, dZ, Zmax] (km).
%          checktmp (default 0) set to 1 to display triangulation
%                result lines-of-sight and shortest intersection
%                line.
%
% Output: 
%  xtr  - x-position of triangulated points
%  ytr  - y-position of triangulated points
%  ztr  - z-position of triangulated points
%  tu1  - horisontal image coordinates of triangulated points (img1)
%  tv1  - vertical image coordinates of triangulated points (img1)
%  tu2  - horisontal image coordinates of triangulated points (img2)
%  tv2  - vertical image coordinates of triangulated points (img2)
%  minl - lengths of the shortest intersections.
% 
% Overly briefly, and maybe not all that clarifying about the
% optpar field necessary i the PO struct:
%  optpar - is a vector caracterising the optical
%           transfer function, or an OPTPAR struct, with fields:
%           sinzecosaz, sinzesinaz, u, v that define the horizontal
%           components of a pixel l-o-s, and the pixel coordinates
%           for the corresponding horizontal l-o-s components,,Opts
%           respectively, and optionally a field rot (when used a
%           vector with 3 Tait-Bryant rotaion angles)
%
% See also CAMERA_MODEL, CAMERA_INVMODEL, CAMERA_ROT, CAMERA_BASE.


%   Copyright � 2001-2010 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Default Options
dOpts.ax1 = [1 256 1 256];
dOpts.ax2 = [1 256 1 256];
dOpts.cx1 = 'auto';
dOpts.cx2 = 'auto';
dOpts.SubplotsNotFigs = 1;
dOpts.epipolar_lines = 0;
dOpts.epipolar_range = [80,20,500];
dOpts.checktmp = 0;

% If triangulate is called without input arguments just return the
% default options
if nargin == 0;
  xtr = dOpts;
  return
end
% Else merge the two options structs, with the user-Opts
% overwriting the defaults
if nargin > 7 && ~isempty(Opts)
  dOpts = catstruct(dOpts,Opts);
end

% Extract the optical parameters
optp1 = PO(1).optpar;
optp2 = PO(2).optpar;

% Determine if we're plotting in one or two figures
if isfield(dOpts,'SubplotsNotFigs')
  SubplotsNotFigs = dOpts.SubplotsNotFigs;
end
% Get figure for image display and optionally figure for the
% temporary triangulation display.
fig1 = gcf;
if ( dOpts.checktmp )
  figtmp = figure;
end

bxy1 = size(img1);
bx1 = bxy1(2);
by1 = bxy1(1);

bxy2 = size(img2);
bx2 = bxy2(2);
by2 = bxy2(1);

% Calculate the camera rotation matrix for camera 1
if isstruct(optp1)
  rot1 = camera_rot(optp1.rot(1),optp1.rot(2),optp1.rot(3));
  optmod1 = optp1.mod;
else
  rot1 = camera_rot(optp1(3),optp1(4),optp1(5));
  optmod1 = optp1(9);
end

% Calculate the camera rotation matrix for camera 1
if isstruct(optp2)
  rot2 = camera_rot(optp2.rot(1),optp2.rot(2),optp2.rot(3));
  optmod2 = optp2.mod;
else
  rot2 = camera_rot(optp2(3),optp2(4),optp2(5));
  optmod2 = optp2(9);
end

% correct for the curvature of the earth between the 2 camera
% positions R1 and R2
if (nargin>4) && ~isempty(cm1)
  rot1 = cm1*rot1;
else
  cm1 = eye(3);
end
if (nargin>5) && ~isempty(cm2)
  rot2 = cm2*rot2;
else
  cm2 = eye(3);
end

%% Display the images
%% First image 1
figure(fig1)
clf
if SubplotsNotFigs
  ax1 = subplot(1,2,1);
end
if isfield(PO(1), 'flipimage')
  % Respect the FMI-image flipping preferences
  if PO(1).flipimage == 1
    imagesc(img1), axis image
  else 
    imagesc(img1),axis xy
  end
else
  imagesc(img1),axis xy
end
% Zoom to the desired image region
if isfield(dOpts,'ax1')
  axis(dOpts.ax1)
end
% Set the intensity scale
if isfield(dOpts,'cx1')
  caxis(dOpts.cx1)
end
xlabel('add point | enough points |     ','fontsize',14)
hold on

%% And then image 2 
if SubplotsNotFigs
  ax2 = subplot(1,2,2);
else
  fig2 = figure;
end
if isfield(PO(2), 'flipimage')
  % Respect the FMI-image flipping preferences
  if PO(2).flipimage == 1
    imagesc(img2), axis image
  else 
    imagesc(img2),axis xy
  end
else
  imagesc(img2),axis xy
end
% Zoom to the desired image region
if isfield(dOpts,'ax2')
  axis(dOpts.ax2)
end
% Set the intensity scale
if isfield(dOpts,'cx2')
  caxis(dOpts.cx2)
end
% If we're going to overlay epi-polar lines get the range here
if isfield(dOpts,'epipolar_range')
  epi_lmin = dOpts.epipolar_range(1);
  epi_dl = dOpts.epipolar_range(2);
  epi_lmax = dOpts.epipolar_range(3);
end

xlabel('add point (l)| enough points (m)| skip point (r)','fontsize',14)
hold on
iPoint = 1;
button = 1;

%% Loop until user have gotten enough triangulation points.
while ( button ~= 2 && lower(char(button)) ~= 'm')
  
  % First identify a point in image 1
  figure(fig1)
  if SubplotsNotFigs
    title('')
    axes(ax1)
    title('identify point in this image')
  end
  [x1,y1,button] = ginput(1);
  % If point identified (left button or "l"-key)
  if ( button == 1 || lower(char(button)) == 'l')
    
    % Then identify a point in image 2
    if SubplotsNotFigs
      title('')
      axes(ax2)
      title('identify point in this image')
    else
      figure(fig2);
    end
    hold on
    % Plot epi-polar lines if that's wanted...
    if isfield(dOpts,'epipolar_lines') 
      if dOpts.epipolar_lines
        [xx1,yy1,zz1] = inv_project_points(x1,y1,img1,...
                                           r1,optmod1,optp1,...
                                           [0,0,1],[epi_lmin:epi_dl:epi_lmax],cm1);
        %£££ Above here we should in with cm1 or cm1'
        r_epi = [xx1;yy1;zz1];
        %£££ And here we should in with cm2! (cm2'?)
        [u2,v2] = project_point(r2,optp2,r_epi,cm2,size(img2));
        tmp_ph = plot(u2,v2,'k-','linewidth',1.5);
        [x2,y2,button] = ginput(1);
        delete(tmp_ph)
      end
    else
      [x2,y2,button] = ginput(1);
    end
    % If the point is selected in both images
    if ( button == 1 || lower(char(button)) == 'l')
      % Then calculate the corresponding pixel lines-of-sight by
      % first calculating the polar coordinates in the
      % camera-rotated system
      [fi,taeta] = camera_invmodel(x1,y1,optp1,optmod1,[by1 bx1]);
      % Then make it a unit vector
      epix = [sin(taeta).*sin(fi); sin(taeta).*cos(fi); cos(taeta)];
      % Then rotate it to the local horizontal coordinate system
      epix = rot1*epix;
      e1 = epix';
      
      % Same thing for the pixel identified in camera 2
      %bx = bx2;
      %by = by2;
      [fi,taeta] = camera_invmodel(x2,y2,optp2,optmod2,[by2 bx2]);
      epixf = [sin(taeta).*sin(fi); sin(taeta).*cos(fi); cos(taeta)];
      epix = rot2*epixf;
      e2 = epix';
      %% The best 3-D point to choose is the mid-point on the
      %  shortest line separation between the two points. (There is
      %  no guarantee that 2 lines in 3-D intersects exactly). The
      %  requirement for a shortest intersection is that the
      %  intersecting line is perpendicular to both lines-of-sight.
      %  That is (with r_l being the difference vector between 2
      %  points on the lines-of-sight):
      %    r_l.e1 = 0
      %    r_l.e2 = 0
      %  when r_l is written out to r1+e1*l1 - (r2 + e2*l2) it turns into
      %    e1.r1+ e1.e1*l1 - e1.r2 + e1.e2*l2 = 0
      %    e2.r1+ e2.e1*l1 - e2.r2 + e2.e2*l2 = 0
      %  Which is a nice system of linear equations that we solve with
      %  direct matrix inversion!!!
      rhs = [dot(r2,e1)-dot(r1,e1) dot(r2,e2)-dot(r1,e2)];
      M = [1 -dot(e1,e2);dot(e1,e2) -1];
      % lmatr = (inv(M)*rhs')';
      lmatr = (M\rhs')';
      
      minlength = diff2_ps_on_ls(lmatr,r1,e1,r2,e2);
      
      % temporary plot for control of triangulation result |
      % ---------------------------------------------------v
      if ( dOpts.checktmp )
	figure(figtmp);
	hold on
	plot3(r1(1),r1(2),r1(3),'r+')
	plot3(r2(1),r2(2),r2(3),'r+')
	xp(1) = r1(1);
	yp(1) = r1(2);
	zp(1) = r1(3);
	qw = lmatr(1)*e1;
	xp(2) = r1(1)+qw(1);
	yp(2) = r1(2)+qw(2);
	zp(2) = r1(3)+qw(3);
	plot3(xp,yp,zp,'g')
	xp(1) = r2(1);
	yp(1) = r2(2);
	zp(1) = r2(3);
	qw = lmatr(2)*e2;
	xp(2) = r2(1)+qw(1);
	yp(2) = r2(2)+qw(2);
	zp(2) = r2(3)+qw(3);
	plot3(xp,yp,zp,'b')
	
	rmin = .5*(r1+lmatr(1)*e1+r2+lmatr(2)*e2);
	plot3(rmin(1),rmin(2),rmin(3),'k*')
	disp('  lmin')
	disp(lmatr)
	drawnow
	view(30,30)
	grid on
	rotate3d on
	xlabel('    i       minlength')
	disp([ iPoint       minlength])
	qwas = gca;
	set(qwas,'Projection','perspective');
	
	title('add point | enough points | skip point ')
	[x3,y3,button] = ginput(1);
	%-------------------------------------------------^
      else
        disp([iPoint minlength])
	rmin = .5*(r1+lmatr(1)*e1+r2+lmatr(2)*e2);
      end % if ( dOpts.checktmp )
      % If the selected point is considered good
      if ( button == 1 || lower(char(button)) == 'l')
	% Then assign the next output points
	xtr(iPoint) = rmin(1);
	ytr(iPoint) = rmin(2);
	ztr(iPoint) = rmin(3);
	tu1(iPoint) = x1;
	tv1(iPoint) = y1;
	tu2(iPoint) = x2;
	tv2(iPoint) = y2;
        minl(iPoint) = minlength;
        iPoint = iPoint+1;
        figure(fig1)
        if SubplotsNotFigs
          axes(ax1)
          hold on
          plot(x1,y1,'w+')
          axes(ax2)
          hold on
          plot(x2,y2,'w+')
        else
          hold on
          plot(x1,y1,'w+')
          figure(fig2)
          hold on
          plot(x2,y2,'w+')
        end
	
      end % if ( button == 1 )
      
    end
      
  end
  
end

if ( dOpts.checktmp )
  close(figtmp)
end

if ~SubplotsNotFigs
  close(fig2)
end
hold off
