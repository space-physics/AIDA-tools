%% Use of the routine vol3d to plot ALIS formatted outputs in 3D
% Stand-alone script, using the functions vol3d.m and vold3dtool.m
%
% The *.mat file used in input has the structure from the tomography-like ALIS script:
%     save(['tomo-',sprintf('%03d',i_T(i2)),'_new_MART_xyz.mat'],'Vem','zalis','XfI','YfI','ZfI');
%
% C. Simon Wedlund et al. (2011)

%% Loading ALIS mat file
load('tomo-003_new_MART_xyz.mat');

%% Definition of the indices of the boundary
ix(1) = 20; %30
ix(2) = 70; %50

iy(1) = 30; %50
iy(2) = 80; %80

iz(1) = 15;
iz(2) = 50;

%% Selecting only the relevant VEM coordinates
Vem_orig=Vem(iy(1):iy(2),ix(1):ix(2),iz(1):iz(2));
%Vem_interp3=interp3(Vem(iy(1):iy(2),ix(1):ix(2),iz(1):iz(2)),2); % Interpolation

close; 

%% Draw in 3D the VEM from ALIS
fig1 = figure;
h2 = vol3d('cdata',Vem_orig,'texture','3D');
% Orientation of the 3D volume
view(3); 
daspect([1 1 .4]); 
% Transparency to be set up by user
alphamap('rampdown');alphamap(1. .* alphamap); 
cbar = colorbar; 
grid on;

% Set up the axes
h2.ydata=[XfI(iy(1),ix(1),1) XfI(iy(2),ix(2),1)];
h2.xdata=[YfI(iy(1),ix(1),1) YfI(iy(2),ix(2),1)];
h2.zdata=[zalis(iz(1)) zalis(iz(2))];

% Refresh twice to redraw the volume
vol3d(h2);vol3d(h2);

xlabel('S-N of Kiruna (km)');
ylabel('E-W of Kiruna (km)');
zlabel('Altitude (km)');

ylabel(cbar,'Volume Emission Rate (cm^{-3} s^{-1})');
zoom(0.65);

% Repositioning and size of figure
scnsize=get(0,'ScreenSize');
position = get(fig1,'Position');
outerpos = get(fig1,'OuterPosition');
borders = outerpos - position;
        
edge = -borders(1)/2;
pos1 = [edge, scnsize(4)*(1./4), scnsize(3)/2 - edge, scnsize(4)/1.5];
set(fig1,'Position',pos1);
