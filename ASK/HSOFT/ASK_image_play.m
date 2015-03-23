function M = ASK_image_play(imgs1,imgs2,imgs3,OPS)
% ASK_IMAGE_PLAY - Convert image-stacks to matlab movie
%   

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

dOPS.times = [];
dOPS.txtcolour = 0.98*[1,1,1];
dOPS.txtpos = [15 24];
dOPS.txtXYT = '';
dOPS.fontsize = 16;

x = -9:9;
[x,y] = meshgrid(x,x);
fK4contour = exp(-abs(x.^2+y.^2).^(3/2)/7^3);fK4contour = fK4contour/sum(fK4contour(:));

dOPS.contourframe = 0; % { [0] | 1 | 2 | 3 | 4 }
dOPS.Intensity2RGB = [1,0,0;
                      0,1,0;
                      0,0,1;
                      1,1,1];
dOPS.fK4contour = fK4contour;

if nargin == 0
  M = dOPS;
  return
end
if nargin > 3;
  dOPS = merge_structs(dOPS,OPS);
end

for i2 = 4:-1:1
  sph(i2) = subplot(2,2,i2);
end
sphpos = get(sph,'position');
SPHpos = [sphpos{1};sphpos{2};sphpos{3};sphpos{4}];

set(sph(2),'position',SPHpos(2,:)+[-0.052841 -0.066337 0.052841 0.066337],'xtick',[],'ytick',[])
set(sph(1),'position',SPHpos(1,:)+[0 -0.066337 0.052841 0.066337],'xtick',[])
set(sph(3),'position',SPHpos(3,:)+[0 0 0.052841 0.066337])
set(sph(4),'position',SPHpos(4,:)+[-0.052841 0 0.052841 0.066337],'ytick',[])


for i2 = 1:size(imgs1,3)
  axes(sph(1))
  imagesc(cat(3,...
              ASK_bytscl(imgs3(:,:,i2))*dOPS.Intensity2RGB(1,1),...
              ASK_bytscl(imgs2(:,:,i2))*dOPS.Intensity2RGB(1,2),...
              ASK_bytscl(imgs1(:,:,i2))*dOPS.Intensity2RGB(1,3)))
  if ~isempty(dOPS.times)
    th = ASK_print_dat(dOPS.times(i2),'HH:MM:SS.FFF',dOPS);
  end
  axes(sph(2))
  %subplot(2,2,2)
  imagesc(cat(3,...
              ASK_bytscl(imgs3(:,:,i2))*dOPS.Intensity2RGB(2,1),...
              ASK_bytscl(imgs2(:,:,i2))*dOPS.Intensity2RGB(2,2),...
              ASK_bytscl(imgs1(:,:,i2))*dOPS.Intensity2RGB(2,3)))
  axes(sph(3))
  %subplot(2,2,3)
  imagesc(cat(3,...
              ASK_bytscl(imgs3(:,:,i2))*dOPS.Intensity2RGB(3,1),...
              ASK_bytscl(imgs2(:,:,i2))*dOPS.Intensity2RGB(3,2),...
              ASK_bytscl(imgs1(:,:,i2))*dOPS.Intensity2RGB(3,3)))
  axes(sph(4))
  %subplot(2,2,4)
  imagesc(cat(3,...
              ASK_bytscl(imgs3(:,:,i2))*dOPS.Intensity2RGB(4,1),...
              ASK_bytscl(imgs2(:,:,i2))*dOPS.Intensity2RGB(4,2),...
              ASK_bytscl(imgs1(:,:,i2))*dOPS.Intensity2RGB(4,3)))
  if dOPS.contourframe ~= 0
    axes(sph(dOPS.contourframe))
    hold on
    contour(conv2(imgs3(:,:,i2),fK4contour,'same'),linspace(0,max(max(imgs3(:,:,i2))),8),'r')
    contour(conv2(imgs2(:,:,i2),fK4contour,'same'),linspace(0,max(max(imgs2(:,:,i2))),8),'k')
    contour(conv2(imgs2(:,:,i2),fK4contour,'same'),linspace(0,max(max(imgs2(:,:,i2))),8),'w--')
    contour(conv2(imgs1(:,:,i2),fK4contour,'same'),linspace(0,max(max(imgs1(:,:,i2))),8),'b')
    hold off
  end
  set(sph(2),'xtick',[],'ytick',[])
  set(sph(1),'xtick',[])
  set(sph(4),'ytick',[])
  drawnow
  M(i2) = getframe(gcf);
end
