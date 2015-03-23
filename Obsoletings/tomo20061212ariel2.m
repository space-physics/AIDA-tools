% TOMO20061212ARIEL2 - script for tomographing ALIS 20061212 event
if 1
  data_dir = '/media/My Book/ALIS/stdnames/';
  cd(data_dir)
  events = alis_event_reader('/home/bjorn/ALIS-ASK/ALIS-ASK-events.txt');
  PO = typical_pre_proc_ops('alis');
  PO.find_optpar = 0;
  PO.fix_missalign = 0;
  POs(1:7) = PO;
  i1 = 14;
  dFiles = alis_find_data2(events(i1).stns,...
                           events(i1).date,...
                           events(i1).start_time,...
                           events(i1).stop_time,...
                           data_dir);
  cd 2006/12/12/
  
  load S03_2006121219201500S.acc
  load S05_2006121220191000A.acc
  load S010_2006121219222500B.acc
  load S04_2006121219495500T.acc
  optpB = S010_2006121219222500B([7:14 6 end]);
  optpA = S05_2006121220191000A([7:14 6 end]);
  optpT = S04_2006121219495500T([7:14 6 end]);
  optpS = S03_2006121219201500S([7:14 6 end]);
  POs(1).optpar = optpB;
  POs(2).optpar = optpA;
  POs(3).optpar = optpS;
  POs(6).optpar = optpT;
  for i2 = [1 2 3 6],
    [keoBAST{i2},exptimes{i2},Tstrs{i2},filters{i2},optps{i2}] = imgs_keograms(dFiles{i2},120,0,POs(i2).optpar,POs(i2));
    t{i2} = Tstrs{i2}(:,4) + Tstrs{i2}(:,5)/60 + Tstrs{i2}(:,6)/3600;
  end
  if 1
    plot(t{1}(filters{1}==4278),1,'b.','markersize',18)
    hold on
    plot(t{1}(filters{1}==5577),1,'g.','markersize',18)
    plot(t{1}(filters{1}==6300),1,'r.','markersize',18)
    plot(t{1}(filters{1}==8446),1,'k.','markersize',18)
    plot(t{2}(filters{2}==4278),2,'b.','markersize',18)
    plot(t{2}(filters{2}==5577),2,'g.','markersize',18)
    plot(t{2}(filters{2}==6300),2,'r.','markersize',18)
    plot(t{3}(filters{3}==4278),3,'b.','markersize',18)
    plot(t{3}(filters{3}==5577),3,'g.','markersize',18)
    plot(t{3}(filters{3}==6300),3,'r.','markersize',18)
    plot(t{6}(filters{6}==4278),4,'b.','markersize',18)
    plot(t{6}(filters{6}==5577),4,'g.','markersize',18)
    plot(t{6}(filters{6}==6300),4,'r.','markersize',18)
    plot(t{6}(filters{6}==8446),4,'k.','markersize',18)
  end
  timetick
  axis([19+1/3 19+22/60 0 5])
  
  i_tb = find(filters{1}==4278);
  i_tg = find(filters{1}==5577);
  
end


file_list = str2mat(dFiles{1}(1,:),dFiles{2}(1,:),dFiles{3}(1,:),dFiles{6}(1,:));

stns = tomo_inp_images(file_list,[],POs([1 2 3 6]));

r_B = stns(1).obs.xyz;

Vem = zeros([100 100 74]);
% set the lower south-west corner:
ds = 2.5;
r0 = [-128 -64 80];
r0 = r_B + [-64*ds -64*ds 80]+[10 0 0];
% Define the latice unit vectors
dr1 = [ds 0 0];
dr2 = [0 ds 0];
% With e3 || vertical:
dr3 = [0 0 ds];
% or || magnetic zenith:
dr3 = [0 -ds*tan(pi*12/180) ds];
% Calculate duplicate arrays for the position of the base functions:
[r,X,Y,Z] = sc_positioning(r0,dr1,dr2,dr3,Vem);
XfI = r0(1)+dr1(1)*(X-1)+dr2(1)*(Y-1)+dr3(1)*(Z-1);
YfI = r0(2)+dr1(2)*(X-1)+dr2(2)*(Y-1)+dr3(2)*(Z-1);
ZfI = r0(3)+dr1(3)*(X-1)+dr2(3)*(Y-1)+dr3(3)*(Z-1);

%% Set the number of size layers 
% the projection algorithm divides the base into classes based on
% the size of their footprint in the image. Here it is needed to
% select the number of layers to use in the image projection, more
% is better and slower: 8 minimum, 10 better, 16 getting on the
% slow side...
nr_layers = 10;

%% Creating the station  structure 
% Here we make the structure array holding the projection matrix,
% the filter kernels and size grouping of the base functions needed
% for the fast projection.
% Set up the stuff on the camera and 3D structure needed for the
% fast projection.
for i1 = 1:length(stns),
  
  rstn = stns(i1).obs.xyz;
  optpar = stns(i1).optpar;
  imgsize = size(stns(i1).img);
  cmtr = stns(i1).obs.trmtr;
  [stns(i1).uv,stns(i1).d,stns(i1).l_cl,stns(i1).bfk] = camera_set_up_sc(r,...
                                                    X,...
                                                    Y,...
                                                    Z,...
                                                    optpar,...
                                                    rstn,...
                                                    imgsize,...
                                                    nr_layers,...
                                                    cmtr);
  
end

for i1 = 1:length(stns),
  stns(i1).r = stns(i1).obs.xyz;
end

for i1 = 1:length(stns),
  stns(i1).proj = fastprojection(ones(size(X)),...
                                 stns(i1).uv,...
                                 stns(i1).d,...
                                 stns(i1).l_cl,...
                                 stns(i1).bfk,...
                                 [256 256],1);
  subplot(2,2,i1)
  imagesc(stns(i1).proj)
  
end

tomo_ops = make_tomo_ops(stns);
tomo_artops = tomo_ops(1);
tomo_ops34 = tomo_ops(3:4);
alt_max5577 = 110;
width = 15;
Vem0 = tomo_start_guess1(stns(1),alt_max5577,width,XfI,YfI,ZfI);
slice(Vem0,47,50,20),shading interp,
pause(3)
slice(Vem0,47,50,20),shading interp,view(0,90)
pause(3)
slice(Vem0,47,50,20),shading interp,view(90,0)
%% Intensity scaling
% This start guess should then be scaled.
% Function to scale 3D intensities to give projections that are in
% the same intensity range as the images. Not needed here since the
% function is already called from within TOMO_START_GUESS, but
% might be usefull in the working process.
% [stns,Vem] = adjust_level(stns,Vem,1);

%% Tomographic update:
% Here are the itterative tomographic steps and filtering made.
[POs(1).ffc] = ffs_correction2(imgsize,POs(1).optpar,3);
[POs(2).ffc] = ffs_correction2(imgsize,POs(2).optpar,3);
[POs(3).ffc] = ffs_correction2(imgsize,POs(3).optpar,3);
[POs(6).ffc] = ffs_correction2(imgsize,POs(6).optpar,3);

i_z = [10 14];
i_x = [42 62];
i_y = [69];
for i2 = length(i_tb):-1:1,
%for i2 = 57:-1:1,
  
  [d,h,o1] = inimg(dFiles{1}(i_tb(i2),:),POs(1));
  disp([i2 o1.time])
  stns(1).img = d;
  [d,h,o2] = inimg(dFiles{2}(i_tb(i2),:),POs(2));
  stns(2).img = d;
  [d,h,o3] = inimg(dFiles{3}(i_tb(i2),:),POs(3));
  stns(3).img = d;
  [d,h,o4] = inimg(dFiles{6}(i_tb(i2),:),POs(6));
  stns(4).img = d;
  %disp([o1.filter o1.station o1.filter o2.station o2.filter o3.station o4.filter o4.station ])
  Vem0 = tomo_start_guess1(stns(1),alt_max5577,width,XfI,YfI,ZfI);
  nr_laps = 1;
  fS = [7 5 5 3];
  Vem = Vem0;
  %[Vem,stns(1)] = tomo_steps(Vem,stns(1),tomo_artops1,nr_laps);
  i_f = 1;
  [xf,yf] = meshgrid(1:fS(i_f),1:fS(i_f));            
  fK = exp(-(xf-mean(xf(:))).^2/mean(xf(:)).^2-(yf-mean(yf(:))).^2/mean(yf(:))^2);
  tomo_ops.filterkernel = fK;
  [Vem,stns(1:2)] = tomo_steps(Vem,stns(1:2),tomo_ops,2);
  [Vem,stns(3:4)] = tomo_altmaxIscaling(Vem,stns(3:4),tomo_ops34,XfI,YfI,ZfI);
  for i_f = 2:length(fS),
    
    [xf,yf] = meshgrid(1:fS(i_f),1:fS(i_f));            
    fK = exp(-(xf-mean(xf(:))).^2/mean(xf(:)).^2-(yf-mean(yf(:))).^2/mean(yf(:))^2);
    tomo_ops.filterkernel = fK;
    [Vem,stns(1:2)] = tomo_steps(Vem,stns(1:2),tomo_ops,nr_laps);
  end
  %[Vem,stns(1)] = tomo_steps(Vem,stns(1),tomo_artops1,nr_laps);
  Vs1(:,i2,:) = Vem(:,i_x(1),:);
  Vs2(:,i2,:) = Vem(:,i_x(2),:);
  Vew(:,:,i2) = Vem(i_y(1),:,:);
  Vh1(:,:,i2) = Vem(:,:,i_z(1));
  Vh2(:,:,i2) = Vem(:,:,i_z(2));
  subplot(1,2,1)
  imagesc(stns(1).img)
  subplot(1,2,2)
  imagesc(stns(1).proj)
  print('-dpng',['Skibotn',sprintf('%03d',i_tb(i2)),'.png'])
  save(['tomo-',sprintf('%03d',i_tb(i2)),'.mat'],'Vem')
end
for i2 = 1:72,
  subplot(1,3,1)
  pcolor(squeeze(YfI(20:end-10,12,:)),squeeze(ZfI(20:end-10,12,:)),squeeze(Vs1(20:end-10,i2,:))),shading flat
  imgs_smart_caxis(0.003,squeeze(Vs1(30:end-10,i2,:)))
  cx1(i2,:) = caxis;
  axis([50 190 80 250])
  subplot(1,3,2)
  pcolor(XfI(20:end,:,12),YfI(20:end,:,12),Vh2(20:end,:,i2)),shading flat
  imgs_smart_caxis(0.003,squeeze(Vh2(30:end-10,:,i2)))
  cx2(i2,:) = caxis;
  axis([-75 75 75 200])
  title(sprintf('%02d:%02d:%02d',Tstrs{1}(i_tb(i2),4),Tstrs{1}(i_tb(i2),5),Tstrs{1}(i_tb(i2),6)),'fontsize',16)
  hold on
  plot(XfI(1,i_x(1),12)*[1 1],[50 250],'w')
  plot([-100 100],173*[1 1],'w')
  hold off
  subplot(1,3,3)
  pcolor(squeeze(XfI(12,:,:)),squeeze(ZfI(12,:,:)),squeeze(Vew(:,:,i2))),shading flat
  axis([-75 75 80 250])
  imgs_smart_caxis(0.003,squeeze(Vew(:,:,i2)))
  cx3(i2,:) = caxis;
  drawnow
  pause(0.1)
end
for i2 = 1:72,
  subplot(1,3,1)
  pcolor(squeeze(YfI(:,12,:)),squeeze(ZfI(:,12,:)),squeeze(Vs1(:,i2,:))),shading flat
  caxis(Cx1(i2,:))
  axis([50 180 80 250])
  subplot(1,3,2)
  pcolor(XfI(20:end,:,12),YfI(20:end,:,12),Vh2(20:end,:,i2)),shading flat
  caxis(Cx2(i2,:))
  axis([-75 75 50 200])
  subplot(1,3,3)
  pcolor(squeeze(XfI(12,:,:)),squeeze(ZfI(12,:,:)),squeeze(Vew(:,:,i2))),shading flat
  axis([-75 75 80 250])
  caxis(Cx3(i2,:))
  drawnow
  pause(0.1)
end
for i2 = 1:72,
  subplot(1,3,1)
  pcolor(squeeze(YfI(:,12,:)),squeeze(ZfI(:,12,:)),squeeze(Vs1(:,i2,:))),shading flat
  caxis([0 1.7e8])
  axis([50 180 80 250])
  subplot(1,3,2)
  pcolor(XfI(20:end,:,12),YfI(20:end,:,12),Vh2(20:end,:,i2)),shading flat
  caxis([0 2.1e8])
  axis([-75 75 50 200])
  subplot(1,3,3)
  pcolor(squeeze(XfI(12,:,:)),squeeze(ZfI(12,:,:)),squeeze(Vew(:,:,i2))),shading flat
  axis([-75 75 80 250])
  caxis([0 5e8])
  drawnow
  pause(0.1)
end
fx = [0 5e8];
fx = [0 1.5e8];
for i2 = 1:72,
  subplot(1,3,1)
  pcolor(squeeze(YfI(20:end-10,12,:)),squeeze(ZfI(20:end-10,12,:)),squeeze(Vs1(20:end-10,i2,:))),shading flat
  caxis([0 Cx(i2)])
  %imgs_smart_caxis(0.003,squeeze(Vs2(:,i2,:)))
  axis([50 180 80 250])
  subplot(1,3,2)
  pcolor(XfI(20:end,:,12),YfI(20:end,:,12),Vh2(20:end,:,i2)),shading flat
  caxis([0 Cx(i2)])
  title(sprintf('%02d:%02d:%02d',Tstrs{1}(i_tb(i2),4),Tstrs{1}(i_tb(i2),5),Tstrs{1}(i_tb(i2),6)),'fontsize',16)
  %imgs_smart_caxis(0.003,squeeze(Vh2(:,:,i2)))
  axis([-75 75 75 225])
  hold on
  plot(XfI(1,i_x(1),12)*[1 1],[50 250],'w')
  plot([-100 100],173*[1 1],'w')
  hold off
  subplot(1,3,3)
  pcolor(squeeze(XfI(12,:,:)),squeeze(ZfI(12,:,:)),squeeze(Vew(:,:,i2))),shading flat
  axis([-75 75 80 250])
  caxis([0 Cx(i2)])
  %imgs_smart_caxis(0.003,squeeze(Vew(:,:,i2)))
  drawnow
  pause(0.1)
end
for i2 = 1:72,
  subplot(1,3,1)
  pcolor(squeeze(YfI(:,12,:)),squeeze(ZfI(:,12,:)),squeeze(Vs1(:,i2,:))),shading flat
  caxis(fx)
  %imgs_smart_caxis(0.003,squeeze(Vs2(:,i2,:)))
  axis([50 180 80 250])
  subplot(1,3,2)
  pcolor(XfI(30:end,:,12),YfI(30:end,:,12),Vh2(30:end,:,i2)),shading flat
  caxis(fx)
  title(sprintf('%02d:%02d:%02d',Tstrs{1}(i_tb(i2),4),Tstrs{1}(i_tb(i2),5),Tstrs{1}(i_tb(i2),6)),'fontsize',16)
  %imgs_smart_caxis(0.003,squeeze(Vh2(:,:,i2)))
  axis([-75 75 50 200])
  hold on
  plot(XfI(1,i_x(1),12),[50 250],'w')
  plot(173,[-100 100],'w')
  hold off
  subplot(1,3,3)
  pcolor(squeeze(XfI(12,:,:)),squeeze(ZfI(12,:,:)),squeeze(Vew(:,:,i2))),shading flat
  axis([-75 75 80 250])
  caxis(fx)
  %imgs_smart_caxis(0.003,squeeze(Vew(:,:,i2)))
  drawnow
  pause(0.1)
end



%   Copyright © 2010 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later
