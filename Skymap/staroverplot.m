function dOPS = staroverplot(img,optpar,stars2plot,OPS)
% STAROVERPLOT plots the stars over an image.
% 
% Calling:
%   staroverplot(img,optpar,stars2plot,OPS);
%   dOPS = staroverplot;
% Input:
%  img        - image that is displayed; or to be displayed
%  optpar     - optical parameters used to calculate the image
%               positions of the stars, as obtained by STARCAL
%  stars2plot - stars to plot over the image, as obtained from
%               LOADSTARS2 
%  OPS        - struct with options controlling the function,
%               default struct returned when function is called
%               with fewer than 3 input arguments. Fields are:
%               star_pl_cl = [1 .7 .5] Plot colour of stars [R,G,B]
%               star_pl_sz = 2;        Plot size of stars
%               star_max_mag = 5;      Max magnitude of stars to overplot
%               imageTheImage = false  Set to true to force
%               redisplaying of image
%               OPS.cax field can be created with a valid input to
%               CAXIS.

%       Bjorn Gustavsson 7-9-97
%	Copyright � 1997 by Bjorn Gustavsson

global bx by bxy


dOPS.star_pl_cl   = [1 .7 .5];% Plot colour of stars
dOPS.star_pl_sz   = 2;        % Plot size of stars
dOPS.star_max_mag = 5;        % Max magnitude of stars to overplot
dOPS.imageTheImage = false;

if nargin < 3
  return
elseif nargin > 3 && ~isempty(OPS)
  dOPS = merge_structs(dOPS,OPS);
end

if isstruct(optpar)
  optmod = optpar.mod;
  [e1,e2,e3] = camera_base(optpar.rot(1),optpar.rot(2),optpar.rot(3));
else
  optmod = optpar(9);
  if length(optpar) > 9
    [e1,e2,e3] = camera_base(optpar(3),optpar(4),optpar(5),optpar(10));
  else
    [e1,e2,e3] = camera_base(optpar(3),optpar(4),optpar(5));
  end
end
bxy = size(img);
bx = bxy(2);
by = bxy(1);

magnitudes = stars2plot(:,4);

stars2plot = stars2plot(magnitudes < dOPS.star_max_mag,:);

az = stars2plot(:,1);
ze = stars2plot(:,2);
[u,w] = camera_model(az',ze',e1,e2,e3,optpar,optmod,size(img(:,:,1)));
indx = find(inimage(u,w,bx,by));
ua = u;
wa = w;

x = dOPS.star_pl_sz*cos(0:2*pi/8:2*pi);
y = dOPS.star_pl_sz*sin(0:2*pi/8:2*pi);
sz = max(size(ua));
if dOPS.imageTheImage
  imagesc(img),axis xy
  if isfield(dOPS,'cax')
    caxis(dOPS.cax)
  end
end
hold on
for i1 = sz(1):-1:1,
  px = .5*( 10 - magnitudes(i1) )*x + ua(i1);
  py = .5*( 10 - magnitudes(i1) )*y + wa(i1);
  line(px,py,'color',dOPS.star_pl_cl)
end
zoom on
hold off

