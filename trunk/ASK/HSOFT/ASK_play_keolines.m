function M = ASK_play_keolines(keos,OPS)
% ASK_PLAY_KEOLINES - 
%   



dOPS.intcut = 0.001;
dOPS.minints = [];
dOPS.instcales = [1,1,1];
if nargin == 0
  M = dOPS;
  return
end
if nargin > 1
  dOPS = merge_structs(dOPS,OPS);
end

Ix{1} = imgs_smart_caxis(dOPS.intcut,keos{1});
Ix{2} = imgs_smart_caxis(dOPS.intcut,keos{2});
Ix{3} = imgs_smart_caxis(dOPS.intcut,keos{3});
lAXIS = [1 size(keos{1},1),...
         0,max([keos{1}(:)*dOPS.instcales(1);keos{2}(:)*dOPS.instcales(2);keos{3}(:)*dOPS.instcales(3)])];

if isempty(dOPS.minints)
  dOPS.minints = [Ix{1}(1),Ix{2}(1),Ix{3}(1)];
end
KeoRGB = cat(3,ASK_bytscl(keos{1},dOPS.minints(1),Ix{1}(2),1),...
               ASK_bytscl(keos{2},dOPS.minints(2),Ix{2}(2),1),...
               ASK_bytscl(keos{3},dOPS.minints(3),Ix{3}(2),1));


subplot(2,1,1)
imagesc(KeoRGB)
axis xy
hold on

for i1 = 1:size(KeoRGB,2)
  subplot(2,1,1)
  ph = plot(i1*[1,1],[1,256],'g');
  subplot(2,1,2)
  PH(i1,:) = plot([dOPS.instcales(1)*keos{1}(:,i1),...
                   dOPS.instcales(2)*keos{2}(:,i1),...
                   dOPS.instcales(3)*keos{3}(:,i1)],'linewidth',3);
  hold on
  axis(lAXIS)
  if i1>1
    set(PH(i1-1,:),'linewidth',1)
  end
  if i1>2
    set(PH(i1-2,:),'linewidth',0.5)
  end
  if i1>3
    delete(PH(i1-3,:))
  end
  drawnow
  M(i1) = getframe(gcf);
  delete(ph)
end
mplayer(M)
