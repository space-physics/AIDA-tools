function [M,Xs] = ASK_play_keolines2(Keos,time_V,OPS)
% ASK_PLAY_KEOLINES - 
%   



dOPS.intcut = 0.001;
dOPS.minints = [];
dOPS.getcuts = 0;
if nargin == 0
  M = dOPS;
  return
end
if nargin > 2
  dOPS = merge_structs(dOPS,OPS);
end

Ix{1} = imgs_smart_caxis(dOPS.intcut,Keos{1});
Ix{2} = imgs_smart_caxis(dOPS.intcut,Keos{2});
Ix{3} = imgs_smart_caxis(dOPS.intcut,Keos{3});

lAXIS = [1 size(Keos{1},1),0,max([Keos{1}(:);Keos{2}(:);Keos{3}(:)])];

clf
subplot(6,1,3)
imagesc(time_V(:,4)+time_V(:,5)/60+time_V(:,6)/3600,1:256,Keos{3}),
colorbar_labeled('(R)'),axis xy
hold on
set(gca,'xtick',2+17/60+[44:46]/3600,'xticklabel',{'02:17:44','02:17:46','02:17:46'},'fontsize',11,'tickdir','out')
%set(gca,'xtick',19+30/60+[44:46]/3600,'xticklabel',{'02:17:44','02:17:46','02:17:46'},'fontsize',11)
subplot(6,1,2)
imagesc(time_V(:,4)+time_V(:,5)/60+time_V(:,6)/3600,1:256,Keos{2}),colorbar_labeled('(R)'),axis xy
set(gca,'xtick',2+17/60+[44:46]/3600,'xticklabel','','fontsize',11,'tickdir','out')
subplot(6,1,1)
imagesc(time_V(:,4)+time_V(:,5)/60+time_V(:,6)/3600,1:256,Keos{1}),colorbar_labeled('(R)'),axis xy
hold on
axis tight
set(gca,'xtick',2+17/60+[44:46]/3600,'xticklabel','','fontsize',11,'tickdir','out')
subplot(2,1,2)
for i1 = 1:size(time_V,1)
  subplot(2,1,2)
  llph = plot([4*Keos{1}(:,i1),Keos{2}(:,i1)*0,Keos{3}(:,i1)],'linewidth',2);
  axis([0 257 0 10000]),
  axis(lAXIS)
  set(gca,'fontsize',12)
  %legend(llph([1,3]),'4*I(5620)','I(7774)','location','best')
  legend(llph([1,3]),'4*I(5620)','I(7774)','location','northwest')
  ylabel('Rayleighs (7774 A)','fontsize',15)
  %title(num2str(i1),'fontsize',15)
  subplot(6,1,3)
  lph = plot((time_V(i1,4)+time_V(i1,5)/60+time_V(i1,6)/3600)*[1,1],[1,256],'r','linewidth',2);
  subplot(6,1,1)
  hold on
  Lph = plot((time_V(i1,4)+time_V(i1,5)/60+time_V(i1,6)/3600)*[1,1],[1,256],'b','linewidth',2);
  if nargout > 1
    [Xs{i1}] = ginput;
  end
  M(i1) = getframe(gcf);
  delete(lph)
  delete(Lph)
end
