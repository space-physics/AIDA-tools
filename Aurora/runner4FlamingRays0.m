%% Example script: how to estimate electron energies in flaming rays

%% 0 Load parameters and images:
% 
% This file contains "out-of-date" excitation profiles for the
% given energy and altitude grid:
whos -file Excitation-profiles-20120124.mat 
load Excitation-profiles-20120124.mat
subplot(1,2,1)
pcolor(E,z_trans(2:end),log10(a_N26730)),shading flat
caxis([-10 0]+max(caxis))
subplot(1,2,2)
pcolor(E,z_trans(2:end),log10(a_O7774)),shading flat
caxis([-10 0]+max(caxis))
%%
% 
%% Load the short image sequence, together with the polygons
% bounding an isolated flaming ray. The polygons I made with GINPUT,
% simply clicking away points along something I judged to be
% outside the ray and uncontaminated by other rays.
whos -file ImS2.mat
load ImS2.mat

%% 1 Create one background mask that is the sum of the regions
%  covered by any polygon:
bgMask = inP{1};
for i1 = 2:length(ImStack)
  bgMask = bgMask + inP{i1};
end
%%
% Simply make the background mask extend out to the image edge:
bgMask(188:226,256) = 1;
bgMask = min(1,bgMask);
hold off
imagesc(bgMask)

%% 2 Calculate as good a back-ground as possible for each image in
%  6730 and 7774. The inpaint_nans function provides several fancy
%  inpainting (interpolating into areas from values on the
%  boundary, possibly taking into account gradients too):
for i1 = 1:size(ImStack{1},3),
  img4bg = wiener2(medfilt2(ImStack{1}(:,:,i1),[3,3]),[3,3]);
  img4bg(bgMask==1) = nan;                   
  imbg{1}(:,:,i1) = inpaint_nans(img4bg,4);
  img4bg = wiener2(medfilt2(ImStack{3}(:,:,i1),[3,3]),[3,3]);
  img4bg(bgMask==1) = nan;                   
  imbg{3}(:,:,i1) = inpaint_nans(img4bg,4);  
end
%%
%  Display the estimated background images
for i1 = 1:size(ImStack{1},3),
  subplot(2,2,1)
  imagesc(imbg{1}(:,:,i1)),cX = imgs_smart_caxis(0.003,imbg{1}(:,:,i1));colorbar
  subplot(2,2,2)
  imagesc(imbg{3}(:,:,i1)),cX = imgs_smart_caxis(0.003,imbg{3}(:,:,i1));colorbar
  subplot(2,2,3)
  imagesc(ImStack{1}(:,:,i1))
  subplot(2,2,4)
  imagesc(ImStack{3}(:,:,i1))
  title(sprintf('%d out of %d',i1,size(ImStack{1},3)))
  pause(1)
  clf
end
%% Set up the projection from 3-D to ASK images:
projection_setup0H
%% Set-up of conversion from electron flux to emissions:
setUpOfIe2H
clf
subplot(1,2,1)
pcolor(E,squeeze(ZfI(1,1,:)),log10(A1Z)),
shading flat
caxis([-10 0]+max(caxis))
colorbar_labeled('Ie''log')
xlabel('Energy (keV)')
ylabel('Altitude (km)')
subplot(1,2,2)
pcolor(E,squeeze(ZfI(1,1,:)),log10(A2Z)),
shading flat,
caxis([-10 0]+max(caxis)),
colorbar_labeled('Ie''log')
xlabel('Energy (keV)')
ylabel('Altitude (km)')

%% First run to scale input parameters:
%  First an array of initial parameters. Here the position is gotten from
%  manually projecting the images to ~115 km of altitude with
%  inv_project_img, then selecting a point close to the peak intensity of
%  the ray.
[Xmax,Ymax] = inv_project_img(ImStack{1}(:,:,12),[0 0 0],optpASK1(9),optpASK1,[0 0 1],113.2,eye(3));
pcolor(Xmax,Ymax,ImStack{1}(:,:,12)),shading flat          
%%
% That has a peak close to [ -6, -12.8], for the other parameters we just
% guess:
%           I0        x0            dx           y0          dy            g_x           E0           dE          g_E         g_E2     I1      E0      dE        g_E     g_E2                  
I0 = [      1      -6.0993          0.3      -12.828          0.3            2            3            3            2            1
            2            0          Inf            0          Inf            2           10            1            1            1];

I0b = I0';
I0b = I0b(:);
I0C = (I0(:,[1,2,4,3,6:end])/2 + I0(:,[1,2,4,5,6:end])/2)';

errOps.bias2cylindrical = 1e8;
fmsOPS = optimset('fminsearch');
fmsOPS.Display = 'final';
%            I0        x0     dx           y0      dy       g_x     E0      dE      g_E     g_E2     I1      E0      dE        g_E     g_E2                  
parTest = [ 4.7336,   -5.918, 0.31721, -13.253, 0.19745, 2.2325, .52487, 2.9215, 2.9828, 0.47734,  0.927, 16.56,  0.044845, 1.8183, 1];
%% 
% These are the upper and lower bounds on the parameters we search for:
parMin = [  eps(1),-12.0518, ds*1/3,    -18.553, ds*1/3,  0.6325, 0.1248, 0.9215, 0.5828, 0.25,      eps(1),  0.56,  0.044845, 0.5183, 0.25];
parMax = [473.36,     -0.0518, 2.1721,     -6.553, 3.9745,  4.2325,32.487, 29.215,  4.9828, 2.47734, 21.927, 16.56, 12.044845, 3.8183, 3.7833];
%%
% This is the indices into the full parameter array for the searched for
% parameters:
v_p =    [  1          2       3            4      5        6       7       8       9      10        11      17     18        19      20];
%% 
% First search is to get the scale of the fluxes into the right order of
% magniture, so search only for them:
vpI = [1 11];
parI = parTest([1 11]);
%%
% and start in the middle of it all, with time-slice 12:
i1 = 12;
Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
stns(1).img = Iq;
Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
stns(2).img = Iq;
parI = fminsearchbnd(@(I) err4FlamingRays(I,vpI,I0b,stns,{bgMask,bgMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,113,errOps),parI,[eps(1) eps(1)],[1e6 1e6],fmsOPS);
%%
% put those flux-scaling-factors into the start-guess:
parTest([1 11]) = parI;
errMask = bgMask;
errMask(:,250:end) = 0;
%% Search for all of them (for this time-step):
for i1 = 12%:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  %parTest = fminsearch(@(I) err4FlamingRays(I,v_p,I0b,stns,{bgMask,bgMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),parTest);
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),parTest,parMin,parMax,fmsOPS);
  It(i1,:) = parTest;
end
%% Then loop forward in time:
errOps.bias2cylindrical = 0e6;
parTest = It(12,:);
for i1 = 13:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  %parTest = fminsearch(@(I) err4FlamingRays(I,v_p,I0b,stns,{bgMask,bgMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),parTest);
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),parTest,parMin,parMax,fmsOPS);
  It(i1,:) = parTest;
  disp(i1)
end
%% ...and back to the beginning:
errOps.bias2cylindrical = 0e6;
parTest = It(12,:);
for i1 = 11:-1:1,
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  %parTest = fminsearch(@(I) err4FlamingRays(I,v_p,I0b,stns,{bgMask,bgMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),parTest);
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),parTest,parMin,parMax,fmsOPS);
  It(i1,:) = parTest;
  disp(i1)
end
%% Model the results:
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(It(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110);
  IeRay(i1,:) = res.IeOutput{1};
end

subplot(4,1,1)
pcolor([1:20]*1/32,E*1e3,log10(IeRay')),shading flat,caxis([-5 0]+max(caxis))
set(gca,'yscale','log')
hold on
xlabel('time (s)')
ylabel('Energy (eV)')
set(gca,'ytick',[100 1000 10000])
colorbar_labeled('/eV/m^2/s','log')
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(It(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,2,110);
  subplot(4,1,1)
  %semilogy(E,res.IeOutput{1})
  ph = plot((i1+0.5)/32*[1 1],E([1,end])*1e3,'k');
  subplot(4,2,5)
  imagesc(res.currImg{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256]) 
  ylabel('Obs')
  colorbar_labeled('R')
  title('ASK #1')
  set(gca,'xticklabel','')
  subplot(4,2,6)
  imagesc(res.currImg{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256]) 
  colorbar_labeled('R')
  title('ASK #3')
  set(gca,'xticklabel','')
  set(gca,'yticklabel','')
  subplot(4,2,7)
  imagesc(res.currProj{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256])
  ylabel('Mod')
  colorbar_labeled('R')
  subplot(4,2,8)
  imagesc(res.currProj{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256])
  set(gca,'yticklabel','')
  colorbar_labeled('R')
  subplot(4,2,3)
  pcolor(XfI(:,:,400),YfI(:,:,400),res.Vem{1}(:,:,400)),shading flat
  hold on
  %axis equal
  [~,i1_i2(1),i1_i2(2)] = max2D(res.Vem{1}(:,:,400));
  subplot(4,2,4)
  plot(squeeze(res.Vem{1}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'r','linewidth',2)
  hold on
  plot(squeeze(res.Vem{2}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'k','linewidth',2)
  axis([0 8e7 50 400])
  hold off
  mRay(i1) = getframe(gcf);
  delete(ph)
end
%%
% For a cylindicication filter the spatial parameters x0, y0, dx
% and dy a bit
It4G = It;
It4G(:,2) = filtfilt([.5 1 .5]/2,1,It4G(:,2));
It4G(:,[3,5]) = filtfilt([.5 1 .5]/2,1,It4G(:,[3 5])*2/3 + It4G(:,[5 3])/3);    
It4G(:,4) = filtfilt([.5 1 .5]/2,1,It4G(:,4));                              

parTest = It(1,:);
fmsOPS.MaxFunEvals = 200;
for iC = 6:8
  errOps.bias2cylindrical = 1e2*10^(6+(iC-6)/2);
  if iC == 1
    parTest = It4G(1,:);
  else
    parTest =  ITC{iC-1}(1,:);
  end
  for i1 = 1:size(ImStack{1},3),
    Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
    stns(1).img = Iq;
    Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
    stns(2).img = Iq;
    %parTest = fminsearch(@(I) err4FlamingRays(I,v_p,I0b,stns,{bgMask,bgMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),parTest);
    [parTest,errR{iC}(i1)] = fminsearchbnd(@(I) err4FlamingRays(I,v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),parTest,parMin,parMax,fmsOPS);
    ITC{iC}(i1,:) =  parTest;
    if iC == 1
      parTest =  It4G(i1,:);
    else
      parTest =  ITC{iC-1}(i1,:);
    end
    disp(i1)
  end
  parTest = ITC{iC}(1,:);
end
%% 
% First loop of error values:
% Exiting: Maximum number of function evaluations has been exceeded
errR{1} = [2657759409.894171
           2640100179.163435
           2746321565.242272
          11541785761.636139
           3144558017.879790
           4576837634.336136
           3407398114.896461
           3937427418.666677
          17770824807.537476
           3942172339.769755
           2968120850.661064
           3740747829.834550
           2839683606.829518
           2473258451.280153
           2698818228.372833
           2714860098.906149
           2704329990.587093
           2364466407.552040
          ];

% Second cylindicication:
errR{2} = [2657758763.165476
           2571699316.740769
           2905314511.581722
           2537885758.278136
           2987889402.615881
           3228651070.441468
           4095364731.518811
           3509993083.150541
          14799949578.554905
           2909136355.447273
           2762700844.629736
           2936960406.904617
           2493987502.223127
           2704486290.090350
           2667887022.392365
           2680677810.242246
           2370988527.559719
           2477273541.940722
           2632296893.586037
          ];
errR{3} = [2658009297.464191  1
           2571012837.895965  2
           2885615644.810588  3
           2623868133.077672  4
           2895827894.710540  5
           3057494306.411866  6
           3061055085.454221  7
           3770572822.834843  8
           3604029193.870496  9
           3585631336.206692 10
          13171466060.803993 11
           2755484696.615376 12
           2811664699.461828 13
           2524968613.689631 14
           2706352373.455245 15
           2638945652.516075 16
           2697134926.370265 17
           2337292865.508470 18
           2473022799.019317 19
           2051045778.145308 20
          ];
%%
%  
%  
% After first free loop:
%            0
%            0
%            0
%            0
%            0
%            0
%   3687859058.159735 
%   4131000522.711436 
%   4557743603.051517 
%   4083609161.793177 
%   3404450438.573254 
%   3395712135.431263 
%   3528021850.639008 
%   2913537426.133672 
%   2955117734.180073 
%   3105703984.010612 
%   3007203890.195779 
%   2871751554.566454 
%   2660952417.781180 
%   2360527354.445188 


ftsz = 12;

%% Model the results: 
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(ITC{end}(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110,errOps);
  ErrR{1}(i1) = res.err;
  IeRay(i1,:) = res.IeOutput{1};
end

xG = [150:25:250,256];
[xG,yG] = meshgrid(xG,xG);

%%
subplot(4,1,1)
pcolor([1:20]*1/32,E*1e3,log10(IeRay')),shading flat,caxis([-5 0]+max(caxis))
axIe = axis;
axis([axIe(1:3),5e3])
set(gca,'yscale','log')
hold on
xlabel('time (s)','fontsize',ftsz)
ylabel('Energy (eV)','fontsize',ftsz)
title('Electron spectra','fontsize',ftsz)
set(gca,'ytick',[100 1000 10000])
cbl_h = colorbar_labeled('/eV/m^2/s','log','fontsize',ftsz-2);
set(cbl_h,'position',get(cbl_h,'position')+[-0.01,0,0,0])
%%
for i1 = 11,%:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(ITC{1}(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,2,110);
  ErrR{1}(i1) = res.err;
  subplot(4,1,1)
  %semilogy(E,res.IeOutput{1})
  ph = plot((i1+0.5)/32*[1 1],E([1,end])*1e3,'k');
  subplot(4,2,5)
  imagesc(res.currImg{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256]) 
  hold on
  [~,hC1] = contour(res.currProj{1},7,'w');set(hC1,'linecolor',[1,1,1]*0.99)
  plot(xG,yG,'w:','linewidth',2,'color',[1 1 1]*0.99)
  plot(xG',yG','w:','linewidth',2,'color',[1 1 1]*0.99)
  hold off
  ylabel('Observations','fontsize',ftsz)
  colorbar_labeled('R','linear','fontsize',ftsz-2)
  title('ASK #1 (6730 A)','fontsize',ftsz)
  set(gca,'xticklabel','')
  set(gca,'xtick',[150:25:250])
  set(gca,'ytick',[150:25:250])
  %grid on
  subplot(4,2,6)
  imagesc(res.currImg{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256]) 
  hold on
  [~,hC2] = contour(res.currProj{2},7,'w');set(hC2,'linecolor',[1,1,1]*0.99)
  plot(xG,yG,'w:','linewidth',2,'color',[1 1 1]*0.99)
  plot(xG',yG','w:','linewidth',2,'color',[1 1 1]*0.99)
  hold off
  set(gca,'xtick',[150:25:250])
  set(gca,'ytick',[150:25:250])
  %grid on         
  colorbar_labeled('R','linear','fontsize',ftsz-2)
  title('ASK #3 (7774)','fontsize',ftsz)
  set(gca,'xticklabel','')
  set(gca,'yticklabel','')
  hold off
  set(gca,'xtick',[150:25:250])
  set(gca,'ytick',[150:25:250])
  %grid on
  subplot(4,2,7)
  imagesc(res.currProj{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256])
  ylabel('Modeled','fontsize',ftsz)
  colorbar_labeled('R','linear','fontsize',ftsz-2)
  set(gca,'xtick',[150:25:250])
  set(gca,'ytick',[150:25:250])
  hold on
  plot(xG,yG,'w:','linewidth',2,'color',[1 1 1]*0.99)
  plot(xG',yG','w:','linewidth',2,'color',[1 1 1]*0.99)
  %grid on
  plot3(1:256,256-max(res.currProj{1})/6000*25,ones(256,1),'color',[1,1,1]*0.99)
  plot3(1:256,256-max(res.currImg{1}(150:210,:))/6000*25,ones(256,1),'k')
  hold off
  subplot(4,2,8)
  imagesc(res.currProj{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256])
  hold on
  plot3(1:256,256-max(res.currProj{2})/6000*25,ones(256,1),'color',[1,1,1]*0.99)
  plot3(1:256,260-max(res.currImg{2}(150:210,:))/6000*25,ones(256,1),'k')
  plot(xG,yG,'w:','linewidth',2,'color',[1 1 1]*0.99)
  plot(xG',yG','w:','linewidth',2,'color',[1 1 1]*0.99)
  %grid on
  hold off
  set(gca,'yticklabel','')
  set(gca,'xtick',[150:25:250])
  set(gca,'ytick',[150:25:250])
  colorbar_labeled('R','linear','fontsize',ftsz-2)
  subplot(4,2,3)
  pcolor(XfI(:,:,400),YfI(:,:,400),res.Vem{1}(:,:,400)),shading flat
  xlabel('East of ESR (km)','fontsize',ftsz)
  ylabel('North of ESR (km)','fontsize',ftsz)
  title('Horizontal cut at 180 km (6730)','fontsize',ftsz)
  %axis equal
  [~,i1_i2(1),i1_i2(2)] = max2D(res.Vem{1}(:,:,400));
  subplot(4,2,4)
  plot(squeeze(res.Vem{1}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'r','linewidth',2)
  hold on
  plot(squeeze(res.Vem{2}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'k','linewidth',2)
  axis([0 4e9 50 400])
  ylabel('Altitude (km)','fontsize',ftsz)
  xlabel('(#/m^3/s)','fontsize',ftsz)
  title('Volume emission rate','fontsize',ftsz)
  hold off
  mRay(i1) = getframe(gcf);
  delete(ph)
end

%%
ITE = ITC{end};
for i1 = 1:size(ImStack{1},3),
  errOps.bias2cylindrical = 1e2*10^6;
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(ITE(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110,errOps);
  ErrE{1}(i1) = res.err;
  IeRay(i1,:) = res.IeOutput{1};
end

parTest = It(1,:);
fmsOPS.MaxFunEvals = 200;
for iE = 1:200,
  
  [sErrR,iErr] = sort(ErrE{1},'descend');
  errOps.bias2cylindrical = 1e2*10^6;
  parTest =  ITE(iErr(1),:);
  for i1 = 1,
    Iq = ( wiener2(ImStack{1}(:,:,iErr(i1)),[3,3]) - wiener2(imbg{1}(:,:,iErr(i1)),[3,3]) ) * 1/C_filter6370;
    stns(1).img = Iq;
    Iq = ( wiener2(ImStack{3}(:,:,iErr(i1)),[3,3]) - wiener2(imbg{3}(:,:,iErr(i1)),[3,3]) ) * 1/C_filter7774;
    stns(2).img = Iq;
    [parTest,ErrE{1}(iErr(i1))] = fminsearchbnd(@(I) err4FlamingRays(I,v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),...
                                                  parTest,parMin,parMax,fmsOPS);
    ITE(iErr(i1),:) =  parTest;
    disp([iE i1 iErr(i1)])
  end
  
end


%% Model the results again: 
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(ITE(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110,errOps);
  ErrR2{1}(i1) = res.err;
  IeRay(i1,:) = res.IeOutput{1};
end


subplot(4,1,1)
pcolor([1:20]*1/32,E*1e3,log10(IeRay')),shading flat,caxis([-5 0]+max(caxis))
set(gca,'yscale','log')
hold on
xlabel('time (s)')
ylabel('Energy (eV)')
set(gca,'ytick',[100 1000 10000])
colorbar_labeled('/eV/m^2/s','log')
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(ITE(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,2,110);
  ErrR{1}(i1) = res.err;
  subplot(4,1,1)
  %semilogy(E,res.IeOutput{1})
  ph = plot((i1+0.5)/32*[1 1],E([1,end])*1e3,'k');
  subplot(4,2,5)
  imagesc(res.currImg{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256]) 
  ylabel('Obs')
  colorbar_labeled('R')
  title('ASK #1')
  set(gca,'xticklabel','')
  subplot(4,2,6)
  imagesc(res.currImg{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256]) 
  colorbar_labeled('R')
  title('ASK #3')
  set(gca,'xticklabel','')
  set(gca,'yticklabel','')
  subplot(4,2,7)
  imagesc(res.currProj{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256])
  ylabel('Mod')
  colorbar_labeled('R')
  subplot(4,2,8)
  imagesc(res.currProj{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256])
  set(gca,'yticklabel','')
  colorbar_labeled('R')
  subplot(4,2,3)
  pcolor(XfI(:,:,400),YfI(:,:,400),res.Vem{1}(:,:,400)),shading flat
  hold on
  %axis equal
  [~,i1_i2(1),i1_i2(2)] = max2D(res.Vem{1}(:,:,400));
  subplot(4,2,4)
  plot(squeeze(res.Vem{1}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'r','linewidth',2)
  hold on
  plot(squeeze(res.Vem{2}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'k','linewidth',2)
  axis([0 8e7 50 400])
  hold off
  mRay(i1) = getframe(gcf);
  delete(ph)
end

fmsOPS.MaxFunEvals = 800;
parTest = It2(1,:);
for i1 = 1:20,
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  parTest = It2(1,:);
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),parTest,parMin,parMax,fmsOPS);
  It2(i1,:) = parTest;
  disp(i1)
end

%% Model the results again: 
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(It2(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110,errOps);
  ErrR2{1}(i1) = res.err;
  IeRay(i1,:) = res.IeOutput{1};
end


subplot(4,1,1)
pcolor([1:20]*1/32,E*1e3,log10(IeRay')),shading flat,caxis([-5 0]+max(caxis))
set(gca,'yscale','log')
hold on
xlabel('time (s)')
ylabel('Energy (eV)')
set(gca,'ytick',[100 1000 10000])
colorbar_labeled('/eV/m^2/s','log')
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(It2(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,2,110);
  ErrR{1}(i1) = res.err;
  subplot(4,1,1)
  %semilogy(E,res.IeOutput{1})
  ph = plot((i1+0.5)/32*[1 1],E([1,end])*1e3,'k');
  subplot(4,2,5)
  imagesc(res.currImg{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256]) 
  hold on
  contour(res.currProj{1},7,'w')
  hold off
  ylabel('Obs')
  colorbar_labeled('R')
  title('ASK #1')
  set(gca,'xticklabel','')
  subplot(4,2,6)
  imagesc(res.currImg{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256]) 
  hold on
  contour(res.currProj{2},7,'w')
  hold off
  colorbar_labeled('R')
  title('ASK #3')
  set(gca,'xticklabel','')
  set(gca,'yticklabel','')
  subplot(4,2,7)
  imagesc(res.currProj{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256])
  ylabel('Mod')
  colorbar_labeled('R')
  subplot(4,2,8)
  imagesc(res.currProj{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256])
  set(gca,'yticklabel','')
  colorbar_labeled('R')
  subplot(4,2,3)
  pcolor(XfI(:,:,400),YfI(:,:,400),res.Vem{1}(:,:,400)),shading flat
  hold on
  %axis equal
  [~,i1_i2(1),i1_i2(2)] = max2D(res.Vem{1}(:,:,400));
  subplot(4,2,4)
  plot(squeeze(res.Vem{1}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'r','linewidth',2)
  hold on
  plot(squeeze(res.Vem{2}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'k','linewidth',2)
  axis([0 8e7 50 400])
  hold off
  mRay(i1) = getframe(gcf);
  delete(ph)
end


fmsOPS.MaxFunEvals = 800;
parTest = It2(1,:);
for i1 = 1:20,
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  parTest = It3(i1,:);
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),parTest,parMin,parMax,fmsOPS);
  It3(i1,:) = parTest;
  disp(i1)
end


fmsOPS.MaxFunEvals = 800;
for i1 = 1:20,
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  parTest = It4(i1,:);
  I0b(v_p) = It2(i1,:);
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p4,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),...
                          parTest,parMin([1,3,5:end]),parMax([1,3,5:end]),fmsOPS);
  It4(i1,:) = parTest;
  disp(i1)
end


%% Model the results again: 
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  I0b(v_p) = It2(i1,:);
  res = err4FlamingRays(It4(i1,:),v_p4,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110,errOps);
  ErrR2{1}(i1) = res.err;
  IeRay(i1,:) = res.IeOutput{1};
end


subplot(4,1,1)
pcolor([1:20]*1/32,E*1e3,log10(IeRay')),shading flat,caxis([-5 0]+max(caxis))
set(gca,'yscale','log')
hold on
xlabel('time (s)')
ylabel('Energy (eV)')
set(gca,'ytick',[100 1000 10000])
colorbar_labeled('/eV/m^2/s','log')
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  I0b(v_p) = It2(i1,:);
  res = err4FlamingRays(It4(i1,:),v_p4,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,2,110,errOps);
  ErrR{1}(i1) = res.err;
  subplot(4,1,1)
  %semilogy(E,res.IeOutput{1})
  ph = plot((i1+0.5)/32*[1 1],E([1,end])*1e3,'k');
  subplot(4,2,5)
  imagesc(res.currImg{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256]) 
  hold on
  contour(res.currProj{1},7,'w')
  hold off
  ylabel('Obs')
  colorbar_labeled('R')
  title('ASK #1')
  set(gca,'xticklabel','')
  subplot(4,2,6)
  imagesc(res.currImg{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256]) 
  hold on
  contour(res.currProj{2},7,'w')
  hold off
  colorbar_labeled('R')
  title('ASK #3')
  set(gca,'xticklabel','')
  set(gca,'yticklabel','')
  subplot(4,2,7)
  imagesc(res.currProj{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256])
  ylabel('Mod')
  colorbar_labeled('R')
  subplot(4,2,8)
  imagesc(res.currProj{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256])
  set(gca,'yticklabel','')
  colorbar_labeled('R')
  subplot(4,2,3)
  pcolor(XfI(:,:,400),YfI(:,:,400),res.Vem{1}(:,:,400)),shading flat
  hold on
  %axis equal
  [~,i1_i2(1),i1_i2(2)] = max2D(res.Vem{1}(:,:,400));
  subplot(4,2,4)
  plot(squeeze(res.Vem{1}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'r','linewidth',2)
  hold on
  plot(squeeze(res.Vem{2}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'k','linewidth',2)
  axis([0 8e7 50 400])
  hold off
  mRay(i1) = getframe(gcf);
  delete(ph)
end


subplot(4,1,1)
pcolor([1:20]*1/32,E*1e3,log10(IeRay')),shading flat,caxis([-5 0]+max(caxis))
set(gca,'yscale','log')
hold on
xlabel('time (s)')
ylabel('Energy (eV)')
set(gca,'ytick',[100 1000 10000])
colorbar_labeled('/eV/m^2/s','log')
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  I0b(v_p) = It2(i1,:);
  res = err4FlamingRays(It4(i1,:),v_p4,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,2,110,errOps);
  ErrR{1}(i1) = res.err;
  subplot(4,1,1)
  %semilogy(E,res.IeOutput{1})
  ph = plot((i1+0.5)/32*[1 1],E([1,end])*1e3,'k');
  subplot(4,2,5)
  imagesc(res.currImg{1}-res.currProj{1}),axis([150 256 150 256]) 
  cx = imgs_smart_caxis(0.01,res.currImg{1}-res.currProj{1});
  hold on
  contour(res.currProj{1},4,'w')
  hold off
  ylabel('Obs')
  colorbar_labeled('R')
  title('ASK #1')
  set(gca,'xticklabel','')
  subplot(4,2,6)
  imagesc(res.currImg{2}-res.currProj{2}),axis([150 256 150 256]) 
  cx = imgs_smart_caxis(0.01,res.currImg{2}-res.currProj{1});
  hold on
  contour(res.currProj{2},4,'w')
  hold off
  colorbar_labeled('R')
  title('ASK #3')
  set(gca,'xticklabel','')
  set(gca,'yticklabel','')
  subplot(4,2,7)
  imagesc(res.currProj{1}),
  cx = imgs_smart_caxis(0.0003,res.currImg{1});axis([150 256 150 256]);
  hold on
  contour(res.currProj{1},5,'w')
  cI = linspace(0,max(cx),6);
  contour(res.currImg{1},cI(2:end),'k')
  hold off
  ylabel('Mod')
  colorbar_labeled('R')
  subplot(4,2,8)
  imagesc(res.currProj{2}),
  cx = imgs_smart_caxis(0.0003,res.currImg{2});axis([150 256 150 256]);
  hold on
  contour(res.currProj{2},5,'w')
  cI = linspace(0,max(cx),6);
  contour(res.currImg{2},cI(2:end),'k')
  hold off
  set(gca,'yticklabel','')
  colorbar_labeled('R')
  subplot(4,2,3)
  pcolor(XfI(:,:,400),YfI(:,:,400),res.Vem{1}(:,:,400)),shading flat
  hold on
  %axis equal
  [~,i1_i2(1),i1_i2(2)] = max2D(res.Vem{1}(:,:,400));
  subplot(4,2,4)
  plot(squeeze(res.Vem{1}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'r','linewidth',2)
  hold on
  plot(squeeze(res.Vem{2}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'k','linewidth',2)
  axis([0 8e7 50 400])
  hold off
  mRayD(i1) = getframe(gcf);
  delete(ph)
end


for i1 = 1:20,
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  parTest = It4(i1,:);
  I0b(v_p) = It2_ny(i1,:);
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p4,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),...
                          parTest,parMin([1,3,5:end]),parMax([1,3,5:end]),fmsOPS);
  It4(i1,:) = parTest;
  disp(i1)
end


for i1 = 1:20,
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  parTest = It2In(i1,:);
  I0b(v_p) = It2(i1,:);
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),...
                          parTest,parMin([1:end]),parMax([1:end]),fmsOPS);
  ItNy(i1,:) = parTest;
  disp(i1)
end

%% Model the results again: 
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(ItNy(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110,errOps);
  ErrR2{1}(i1) = res.err;
  IeRay(i1,:) = res.IeOutput{1};
end

subplot(4,1,1)
pcolor([1:20]*1/32,E*1e3,log10(IeRay')),shading flat,caxis([-5 0]+max(caxis))
set(gca,'yscale','log')
hold on
xlabel('time (s)')
ylabel('Energy (eV)')
set(gca,'ytick',[100 1000 10000])
colorbar_labeled('/eV/m^2/s','log')
for i1 = 1:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  res = err4FlamingRays(ItNy(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,2,110);
  ErrR{1}(i1) = res.err;
  subplot(4,1,1)
  %semilogy(E,res.IeOutput{1})
  ph = plot((i1+0.5)/32*[1 1],E([1,end])*1e3,'k');
  subplot(4,2,5)
  imagesc(res.currImg{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256]) 
  hold on
  contour(res.currProj{1},7,'w')
  hold off
  ylabel('Obs')
  colorbar_labeled('R')
  title('ASK #1')
  set(gca,'xticklabel','')
  subplot(4,2,6)
  imagesc(res.currImg{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256]) 
  hold on
  contour(res.currProj{2},7,'w')
  hold off
  colorbar_labeled('R')
  title('ASK #3')
  set(gca,'xticklabel','')
  set(gca,'yticklabel','')
  subplot(4,2,7)
  imagesc(res.currProj{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256])
  ylabel('Mod')
  colorbar_labeled('R')
  subplot(4,2,8)
  imagesc(res.currProj{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256])
  set(gca,'yticklabel','')
  colorbar_labeled('R')
  subplot(4,2,3)
  pcolor(XfI(:,:,400),YfI(:,:,400),res.Vem{1}(:,:,400)),shading flat
  hold on
  %axis equal
  [~,i1_i2(1),i1_i2(2)] = max2D(res.Vem{1}(:,:,400));
  subplot(4,2,4)
  plot(squeeze(res.Vem{1}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'r','linewidth',2)
  hold on
  plot(squeeze(res.Vem{2}(i1_i2(1),i1_i2(2),:)),squeeze(ZfI(i1_i2(1),i1_i2(2),:)),'k','linewidth',2)
  axis([0 8e7 50 400])
  hold off
  mRay(i1) = getframe(gcf);
  delete(ph)
end


v_p4 = v_p([1 3 5:end]);
parTest = It2(12,[1 3 5:end]);
fmsOPS.MaxFunEvals = 200;
I0b(v_p) = It2(12,:);
%% Search for all of them (for this time-step):
for i1 = 12%:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p4,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),...
                          parTest,parMin([1 3 5:end]),parMax([1 3 5:end]),fmsOPS);
  ItF(i1,:) = parTest;
end
%% Then loop forward in time:
parTest = ItF(12,:);
for i1 = 13:size(ImStack{1},3),
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p4,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),...
                          parTest,parMin([1 3 5:end]),parMax([1 3 5:end]),fmsOPS);
  ItF(i1,:) = parTest;
end
parTest = ItF(12,:);
%% Then loop backwards in time:
for i1 = 11:-1:1,
  Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
  stns(1).img = Iq;
  Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
  stns(2).img = Iq;
  parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p4,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),...
                          parTest,parMin([1 3 5:end]),parMax([1 3 5:end]),fmsOPS);
  ItF(i1,:) = parTest;
end

%%
% v_p2 = 1:10;
% errOps.bias2cylindrical = 1e8;
% parTest2 = parTest(1:10);
% for i1 = 12:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   %parTest = fminsearch(@(I) err4FlamingRays(I,v_p,I0b,stns,{bgMask,bgMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),parTest);
%   parTest2 = fminsearchbnd(@(I) err4FlamingRays(I,v_p2,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),parTest2,parMin(1:10),parMax(1:10),fmsOPS);
%   It2(i1,:) = parTest2;
% end
% 
% 
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   %parTest = fminsearch(@(I) err4FlamingRays(I,v_p,I0b,stns,{bgMask,bgMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),parTest);
%   parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),parTest,parMin,parMax,fmsOPS);
%   It2(i1,:) = parTest;
%   disp(sprintf('%d %02d-%02d-%02d %02d:%02d:%05.2f',i1,clock))
% end
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   %parTest = fminsearch(@(I) err4FlamingRays(I,v_p,I0b,stns,{bgMask,bgMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),parTest);
%   parTest = fminsearchbnd(@(I) err4FlamingRays(I,v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,1,110,errOps),It2(i1,:),parMin,parMax,fmsOPS);
%   It3(i1,:) = parTest;
%   disp(sprintf('%d %02d-%02d-%02d %02d:%02d:%05.2f',i1,clock))
% end
% 
% 
% for i1 = 12,%:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   res = err4FlamingRays(It2(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110);
%   IeRay(i1,:) = res.IeOutput{1};
% end
% 
% subplot(3,1,1)
% pcolor([1:20]*1/32,E*1e3,log10(IeRay')),shading flat,caxis([-5 0]+max(caxis))
% set(gca,'yscale','log')
% hold on
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   res = err4FlamingRays(It2(i1,:),v_p,I0b,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A1Z,A2Z},E,2,110);
%   subplot(3,1,1)
%   %semilogy(E,res.IeOutput{1})
%   ph = plot((i1+0.5)/32*[1 1],E([1,end])*1e3,'k');
%   subplot(3,2,3)
%   imagesc(res.currImg{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256]) 
%   subplot(3,2,4)
%   imagesc(res.currImg{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256]) 
%   subplot(3,2,5)
%   imagesc(res.currProj{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256])
%   subplot(3,2,6)
%   imagesc(res.currProj{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256])
%   mRay(i1) = getframe(gcf);
%   delete(ph)
% end
% 
% 
% 
% %% Strictly cylindrical...
% 
% 
% ItC = It(:,[1,2,4,3,6:end])/2 + It(:,[1,2,4,5,6:end])/2;
% %            I0     x0        y0      dS         g_x     E0      dE      g_E     g_E2     I1      E0    dE         g_E     g_E2                  
% parIC = [ 4.7336,   -6.0518, -12.553, 0.0021721, 2.2325, 3.2487, 2.9215, 2.9828, 0.47734, 0.927, 16.56,  0.044845, 1.8183, 1];
% pICMin = [  eps(1),-12.0518, -18.553, ds*1/3,    0.6325, 0.3248, 0.9215, 0.5828, 0.25,   eps(1),  0.56,  0.044845, 0.5183, 0.25];
% pICMax = [473.36,   -0.0518,  -6.553, 2.1721,    4.2325,32.487, 29.215,  4.9828, 2.47734,21.927, 16.56, 12.044845, 3.8183, 3.7833];
% vpC =    [  1          2       3          4      5       6       7       8       9       10      15     16         17      18];
% 
% fmsOPS.Display = 'final';
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   parTest = fminsearchbnd(@(I) err4FlamingRaysC(I,vpC,I0C,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),ItC(i1,:),pICMin,pICMax,fmsOPS);
%   ItC(i1,:) = parTest;
% end
% 
% fmsOPS.Display = 'final';
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   pICMin(2:3) = ItC0(i1,2:3)-0.5;
%   pICMax(2:3) = ItC0(i1,2:3)+0.5;
%   parTest = fminsearchbnd(@(I) err4FlamingRaysC(I,vpC,I0C,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),ItC0(i1,:),pICMin,pICMax,fmsOPS);
%   ItC(i1,:) = parTest;
% end
% 
% 
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   %parTest = fminsearch(@(I) err4FlamingRays(I,v_p,I0b,stns,{bgMask,bgMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),parTest);
%   parTest = fminsearchbnd(@(I) err4FlamingRays(I,vpC,I0C,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),ItC(i1,:),pICMin,pICMax,fmsOPS);
%   It2(i1,:) = parTest;
% end
% 
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   res = err4FlamingRaysC(ItC(i1,:),vpC,I0C,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110);
%   IeRay(i1,:) = res.IeOutput{1};
% end
% 
% subplot(3,1,1)
% pcolor([1:20]*1/32,E*1e3,log10(IeRay')),shading flat,caxis([-5 0]+max(caxis))
% set(gca,'yscale','log')
% hold on
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   res = err4FlamingRaysC(ItC(i1,:),vpC,I0C,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110);
%   subplot(3,1,1)
%   %semilogy(E,res.IeOutput{1})
%   ph = plot((i1+0.5)/32*[1 1],E([1,end])*1e3,'k');
%   subplot(3,2,3)
%   imagesc(res.currImg{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256]) 
%   subplot(3,2,4)
%   imagesc(res.currImg{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256]) 
%   subplot(3,2,5)
%   imagesc(res.currProj{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256])
%   subplot(3,2,6)
%   imagesc(res.currProj{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256])
%   mRay(i1) = getframe(gcf);
%   delete(ph)
% end
% 
% ItC2 = ItC;
% ItC2(:,2:3) = ItC2(:,2:3)*1.05;
% ItC2(:,6) = ItC2(:,6)/1.05;
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   res = err4FlamingRaysC(ItC2(i1,:),vpC,I0C,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110);
%   IeRay(i1,:) = res.IeOutput{1};
% end
% hold off
% subplot(3,1,1)
% pcolor([1:20]*1/32,E*1e3,log10(IeRay')),shading flat,caxis([-5 0]+max(caxis))
% set(gca,'yscale','log')
% hold on
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   res = err4FlamingRaysC(ItC2(i1,:),vpC,I0C,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,2,110);
%   subplot(3,1,1)
%   %semilogy(E,res.IeOutput{1})
%   ph = plot((i1+0.5)/32*[1 1],E([1,end])*1e3,'k');
%   subplot(3,2,3)
%   imagesc(res.currImg{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256]) 
%   subplot(3,2,4)
%   imagesc(res.currImg{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256]) 
%   subplot(3,2,5)
%   imagesc(res.currProj{1}),imgs_smart_caxis(0.0003,res.currImg{1}),axis([150 256 150 256])
%   subplot(3,2,6)
%   imagesc(res.currProj{2}),imgs_smart_caxis(0.0003,res.currImg{2}),axis([150 256 150 256])
%   mRay(i1) = getframe(gcf);
%   delete(ph)
% end
% 
% 
% for i1 = 1:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   pICMin(2:3) = ItC2(i1,2:3)-0.5;
%   pICMax(2:3) = ItC2(i1,2:3)+0.5;
%   parTest = fminsearchbnd(@(I) err4FlamingRaysC(I,vpC,I0C,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),ItC2(i1,:),pICMin,pICMax,fmsOPS);
%   ItC2(i1,:) = parTest;
% end
% 
% pT = [  4.804
%       -6.0539
%     0.0020815
%        -13.27
%       0.39244
%        2.6325
%        3.3457
%        2.8948
%         2.581
%       0.44457
%        16.479
%        16.755
%      0.050126
%         2.333
%        1.6808];
%       
% pT2 = [ 4.804
%       -6.0539
%     0.0020815
%        -13.27
%       0.39244
%        2.6325
%        3.3457
%        2.8948
%         2.581
%       0.44457
%        16.479
%        1.5893
%        16.752
%      0.050126
%         2.333
%       -1.6808];
% 
% disp('Starts with the Fit-n-Run!')
% fmsOPS = optimset('fminsearch');
% fmsOPS.Display = 'iter';
% 
% for iT = indices2run,
%   %errOps.saveruns = sprintf('errlog%s-%02d.dat',dOPS.saveFileBaseName,iT);
%   
%   [I0v,I0,v_p,bias_val,bias_Amp,Iupper,Ilower] = arc_split_reordernmerge_I0vpNbias(Ibestest{iT},IstartGuesses{iT},1);
%   %whos I0v I0 v_p bias_val bias_Amp Iupper Ilower
%   CurrCuts = {4*Keos{1}(:,iT),Keos{3}(:,iT)};
%   %testE0 = errDeParallax2DiffuseS(I0v,v_p,I0,1e-12*trmtr2Dto1D,{4*A1Z,A2Z},E,CurrCuts,Y,Z,[],[],2);
%   if dOPS.Plot4ShowInRun
%     testRes = errDeParallax2DiffuseS(I0v,v_p,I0,1e-12*trmtr2Dto1D,{4*A1Z,A2Z},E,CurrCuts,Y,Z,[],[],2,z_max);
%     arc_split_plotTestRes1(testRes,iT,1,[],[],[])
%   end
%   %keyboard
%   disp(sprintf('%d %02d-%02d-%02d %02d:%02d:%05.2f',iT,clock))
%   [Ip1F{iT},fv1(iT),exitflag,output] = fminsearchbnd(@(I) errDeParallax2DiffuseS(I,v_p,I0,1e-12*trmtr2Dto1D,{4*A1Z,A2Z},E,CurrCuts,Y,Z,bias_Amp',bias_val',1,z_max),I0v,Ilower,Iupper,fmsOPS);
%   fmsOPS.Display = 'notify';
%   if dOPS.forReals
%     I0c = I0;
%     I0c(v_p) = Ip1F{iT};
%     I0c = I0c(v_p);
%     I0c = Ip1F{iT}; % Has to be identical to the above!
%     [Ip1{iT},fv2(iT),exitflag,output] = fminsearchbnd(@(I) errDeParallax2DiffuseS(I,v_p,I0,1e-12*trmtr2Dto1D,{4*A1Z,A2Z},E,CurrCuts,Y,Z,bias_Amp',bias_val',1,z_max),I0c,Ilower,Iupper,fmsOPS);
%     I0c = I0;
%     I0c(v_p) = Ip1{iT};
%     I0c = I0c(v_p);
%     I0c = Ip1{iT}; % Has to be identical to the above!
%     [Ip1{iT},fv2(iT),exitflag,output] = fminsearchbnd(@(I) errDeParallax2DiffuseS(I,v_p,I0,1e-12*trmtr2Dto1D,{4*A1Z,A2Z},E,CurrCuts,Y,Z,bias_Amp',bias_val',1,z_max),I0c,Ilower,Iupper,fmsOPS);
%     I0c = I0;
%     I0c(v_p) = Ip1{iT};
%     I0c = I0c(v_p);
%     I0c = Ip1{iT}; % Has to be identical to the above!
%     [Ip1{iT},fv2(iT),exitflag,output] = fminsearchbnd(@(I) errDeParallax2DiffuseS(I,v_p,I0,1e-12*trmtr2Dto1D,{4*A1Z,A2Z},E,CurrCuts,Y,Z,bias_Amp',bias_val',1,z_max),I0c,Ilower,Iupper,fmsOPS);
%   end
%   Ibest{iT} = Ip1{iT};
%   testRes = errDeParallax2DiffuseS(Ip1{iT},v_p,I0,1e-12*trmtr2Dto1D,{4*A1Z,A2Z},E,CurrCuts,Y,Z,[],[],2,z_max);
%   
%   if dOPS.Plot4ShowInRun
%     arc_split_plotTestRes1(testRes,iT,2,[],[],[])
%     print('-depsc2','-painters',sprintf([dOPS.saveFileBaseName,'-%d-%03d'],dOPS.verNR,iT))
%   end
%   disp(sprintf('%d %02d-%02d-%02d %02d:%02d:%05.2f',iT,clock))
%   testresfile = sprintf('%s-%02d-%02d.mat',dOPS.saveFileBaseName,dOPS.verNR,iT);
%   save(testresfile,'testRes','Ibest')
%   
% end
% ItC = It(:,[1,2,4,3,6:end])/2 + It(:,[1,2,4,5,6:end])/2
% 
% ItC(20,:) = ItC(4,:);
% parTest = I0C(vpC)
% for i1 = 9:size(ImStack{1},3),
%   Iq = ( wiener2(ImStack{1}(:,:,i1),[3,3]) - wiener2(imbg{1}(:,:,i1),[3,3]) ) * 1/C_filter6370;
%   stns(1).img = Iq;
%   Iq = ( wiener2(ImStack{3}(:,:,i1),[3,3]) - wiener2(imbg{3}(:,:,i1),[3,3]) ) * 1/C_filter7774;
%   stns(2).img = Iq;
%   parTest = fminsearchbnd(@(I) err4FlamingRaysC(I,vpC,I0C,stns,{errMask,errMask},ZfI,XfI(:,:,115),YfI(:,:,115),{A2Z,A1Z},E,1,110),parTest,pICMin,pICMax,fmsOPS);
%   ItC(i1,:) = parTest;
%   disp(sprintf('Now after itteration %d ',i1))
%   save ItC20121128_C.mat ItC
% end
