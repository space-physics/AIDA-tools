
h_plot = 95*ones(7,1);
OPS = aida_visiblevol;
OPS.linewidth = 2;
hold on

load stationpos.inm
stn_pos = stationpos;
idx_stn = [ 1,    3,  4,  5,  7   10];
azims   = [ 20,   0, 10, 60, 20, 180];
zenits  = [ 41,  35, 45, 40, 41,   5];
cam_fov = [ 60,  60, 60, 60, 60,  60];

OPS.clrs = {'r','g','c','m',[0.2, 0.7, 0.99],'y'};

% In cartesian coordinates...
h3 = aida_visiblevol(stn_pos(idx_stn,:),azims, zenits,h_plot,cam_fov,0,OPS);
PH = nscand_map;


figure

OPS.LL = 1;            % <- building up to lat-long!
PH = nscand_map('l');
hold on

load stationpos.dat
stn_pos = [stationpos(1:20,1)+stationpos(1:20,2)/60+stationpos(1:20,3)/3600,stationpos(1:20,5)+stationpos(1:20,6)/60+stationpos(1:20,7)/3600];

h3 = aida_visiblevol(stn_pos(idx_stn,:),azims, zenits,h_plot,cam_fov,0,OPS);


axis([17 25 67 71])

set(gca,'fontsize',14) 
set(gca,'fontsize',15)
xlabel('Longitude')
ylabel('Latitude') 
