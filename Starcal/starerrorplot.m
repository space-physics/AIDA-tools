function starerrorplot(SkMp,nr)
% STARERRORPLOT - Plots the error of the starprojection.
%   
% Calling:
% starerrorplot(SkMp,nr)

%   Copyright © 20011105 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

u = SkMp.identstars(:,3);
v = SkMp.identstars(:,4);

[ua,va] = project_directions(SkMp.identstars(:,1)', ...
			     SkMp.identstars(:,2)', ...
			     SkMp.optpar,SkMp.optmod,size(SkMp.img));
ua = ua';
va = va';

figure(SkMp.errorfig)
switch(nr)
  
 case 1,
  
  clf
  axis([0 size(SkMp.img,2) 0 size(SkMp.img,1)])
  % H = 
  bquiver(u,v,u-ua,v-va,SkMp.prefs.sc_er_ar,SkMp.prefs.cl_er_ar);
  xlabel('Horizontal image coordinate (pixels)','fontsize',14)
  ylabel('Vertical image coordinate (pixels)','fontsize',14)
  title('Error arrows  *10','fontsize',14)
  
 case 2,
  
  clf
  plot(u-ua,v-va,[SkMp.prefs.cl_er_pt,'.'],'markersize',SkMp.prefs.sz_er_pt)
  ax = axis;
  hold on
  plot([-1 1 1 -1 -1],[-1 -1 1 1 -1])
  xlabel('Horizontal error (pixels)','fontsize',14)
  ylabel('Vertical error (pixels)','fontsize',14)
  title('Error scatter','fontsize',14)
  grid on
  hold off
  ax = [-max(abs(ax(1:2))) max(abs(ax(1:2))) -max(abs(ax(3:4))) ...
	max(abs(ax(3:4)))];
  ax(1) = min(ax(1),-1);
  ax(2) = max(ax(2),1);
  ax(3) = min(ax(3),-1);
  ax(4) = max(ax(4),1);
  axis([-max(abs(ax(1:2))) max(abs(ax(1:2))) -max(abs(ax(3:4))) max(abs(ax(3:4)))])
  
 case 3
  
  clf
  plot(u,u-ua,[SkMp.prefs.cl_er_pt,'.'],'markersize',SkMp.prefs.sz_er_pt)
  %TBR?: xa = axis;
  grid on
  xlabel('Horizontal image coordinate (pixels)','fontsize',14)
  ylabel('Horizontal error (pixels)','fontsize',14)
  title('Horizontal error','fontsize',14)
  
 case 4
  
  clf
  plot(v,v-va,[SkMp.prefs.cl_er_pt,'.'],'markersize',SkMp.prefs.sz_er_pt)
  %TBR?: xa = axis;
  grid on
  xlabel('Vertical image coordinate (pixels)','fontsize',14)
  ylabel('Vertical error (pixels)','fontsize',14)
  title('Vertical error','fontsize',14)
  
 case 5
  
  clf
  r = ((u-size(SkMp.img,2)/2).^2+(v-size(SkMp.img,1)/2).^2).^.5;
  ra = ((ua-size(SkMp.img,2)/2).^2+(va-size(SkMp.img,1)/2).^2).^.5;
  plot(r,r-ra,[SkMp.prefs.cl_er_pt,'.'],'markersize',SkMp.prefs.sz_er_pt)
  %TBR?: xa = axis;
  grid on
  xlabel('Radial image coordinate (pixels)','fontsize',14)
  ylabel('Radial error (pixels)','fontsize',14)
  title('Radial error','fontsize',14)
  
 case 6
  
  clf
  fi = atan2((u-size(SkMp.img,2)/2),(v-size(SkMp.img,1)/2))*180/pi;
  fia = atan2((ua-size(SkMp.img,2)/2),(va-size(SkMp.img,1)/2))*180/pi;
  plot(fi,fi-fia,[SkMp.prefs.cl_er_pt,'.'],'markersize',SkMp.prefs.sz_er_pt)
  grid on
  xlabel('Angular image coordinate (pixels)','fontsize',14)
  ylabel('Angular error (degrees)','fontsize',14)
  title('Angular error','fontsize',14)
  
 case 7
  
  clf
  hist(u-ua)
  grid on
  xlabel('Horizontal error (pixels)','fontsize',14)
  title('Horizontal error histogram','fontsize',14)
  
 case 8
  
  clf
  hist(v-va)
  grid on
  xlabel('Vertical error (pixels)','fontsize',14)
  title('Vertical error histogram','fontsize',14)
  
 case 9
  
  clf
  r = ((u-size(SkMp.img,2)/2).^2+(v-size(SkMp.img,1)/2).^2).^.5;
  ra = ((ua-size(SkMp.img,2)/2).^2+(va-size(SkMp.img,1)/2).^2).^.5;
  hist(r-ra)
  %TBR?: xa = axis;
  grid on
  xlabel('Radial error (pixels)','fontsize',14)
  title('Radial error histogram','fontsize',14)
  
 case 10
  
  clf
  fi = atan2((u-size(SkMp.img,2)/2),(v-size(SkMp.img,1)/2))*180/pi;
  fia = atan2((ua-size(SkMp.img,2)/2),(va-size(SkMp.img,1)/2))*180/pi;
  hist(fi-fia)
  %TBR? xa = axis;
  grid on
  xlabel('Angular error (degrees)','fontsize',14)
  title('Angular error histogram','fontsize',14)
  
 case 11
  
  clf
  r = ((u-size(SkMp.img,2)/2).^2+(v-size(SkMp.img,1)/2).^2).^.5;
  fi = atan2((u-size(SkMp.img,2)/2),(v-size(SkMp.img,1)/2))*180/pi;
  fia = atan2((ua-size(SkMp.img,2)/2),(va-size(SkMp.img,1)/2))*180/pi;
  plot(r,fi-fia,[SkMp.prefs.cl_er_pt,'.'],'markersize',SkMp.prefs.sz_er_pt)
  %TBR?: xa = axis;
  grid on
  xlabel('Radial image coordinate (pixels)','fontsize',14)
  ylabel('Angular error (degrees)','fontsize',14)
  title('Angular error','fontsize',14)
  
 otherwise
  
  disp(['Errorplot number: ',num2str(nr),' is not yet implemented'])
  
end
