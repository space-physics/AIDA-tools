function [varargout] = ASK_draw_fov(imsiz1,optpar1,imsiz2,optpar2,r1,r2,alt,cmtr,varargin)
% ASK_DRAW_FOV - Draw one cameras field-of-view in another cameras f-o-v
%            or just calculate the camera f-o-v edge
% 
% Calling:
%   [ph] = ASK_draw_fov(imsiz1,optpar1,imsiz2,optpar2,r1,r2,alt,cmtr,varargin)
%   [u,v] = ASK_draw_fov(imsiz1,optpar1,imsiz2,optpar2,r1,r2,alt,cmtr,varargin)
%   [u,v,ph] = ASK_draw_fov(imsiz1,optpar1,imsiz2,optpar2,r1,r2,alt,cmtr,varargin)
% Input:
%   imsiz1   - Size of image #1
%   optpar1  - Optical parameters of camera #1
%   imsiz2   - Size of image #2
%   optpar2  - Optical parameters of camera #2
%   r1       - location of camera #1 [x1,y1,z1] (km), optional
%   r2       - location of camera #1 [x2,y2,z2] (km), optional
%   alt      - altitude for which to calculate f-o-v
%   cmtr     - rotation matrix for transformation from local
%              horizontal coordinate systems at r1 and r2, If left
%              empty defaults to eye(3)
%   varargin - cell-array with property-value pairs sent forward to
%              plot function, see PLOT for details. Ex {'r--','linewidth',2}
% Output:
%   ph - plot-handle to plotted lines
%   u  - horizontal image coordinates of f-o-v of camera #1 in
%        images from camera #2
%   v  - vertical image coordinates of f-o-v of camera #1 in
%        images from camera #2
%
% If function is called with 2 output arguments only U and V is
% calculated and no plotting is done, with other number of output
% arguments plotting is done

% Modified from draw_fov.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies

if nargin < 7 
  % Then cameras assumed at same location...
  r1 = [0,0,0]; % YUP that's right even 
  r2 = [0,0,0]; % if there are bot an r1 & r2
  alt = 100;    % but alt is missing then scrappit! Folk's that
                % don't understand that can go commit undescribable
                % acts on themself. BG 20110731
end

if nargin < 8 | isempty(cmtr)
  cmtr = eye(3);
end
% Calculate projection of camera #1 field-of-view at desired
% altitude - if cameras co-located any altitude will do, for
% example the default.
[xx,yy,zz] = inv_project_img(ones(imsiz1),r1,optpar1(9),optpar1,[0 0 1],alt,cmtr);
% Pack the edges into an array. This should make up a square in 3-D
r = [ [xx(:,1);xx(end,:)';xx(end:-1:1,end);xx(1,end:-1:1)'],...
      [yy(:,1);yy(end,:)';yy(end:-1:1,end);yy(1,end:-1:1)'],...
      [zz(:,1);zz(end,:)';zz(end:-1:1,end);zz(1,end:-1:1)'] ];

% Calculate the image coordinates of this array in camera #2 images
[u,v] = project_point(r2,optpar2,r',eye(3),imsiz2);

% If no output argument is requeste
if ( nargout ~= 2 )
  isholdon = ishold;
  hold on
  ph = plot(u,v,varargin{:});
  if ~isholdon
    hold off
  end
end

if nargout == 1
  
  varargout{1} = ph;
  
elseif nargout == 2
  
  varargout{1} = u;
  varargout{2} = v;
  
elseif nargout == 3
  
  varargout{1} = u;
  varargout{2} = v;
  varargout{3} = ph;
  
end
