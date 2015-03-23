% stdposEISCAT_comparison - Compare ALIS-positions EISCAT and EISCAT2

h_plot = 100*ones(7,1);
OPS = aida_visiblevol;
OPS.linewidth = 2;
hold on


obs = struct('station',1);
obs(2).station = 3;
obs(3).station = 4;
obs(4).station = 5;
obs(5).station = 11;
obs(6).station = 10;
for i1 = 1:length(obs),
  Obs(i1) = AIDAstationize(obs(i1),1);
  stn_xyz(i1,:) = Obs.xyz;
end
idx_stn = [ 1,   3,  4,  5,  11,  10];
azims   = [ 0, 340,  0, 20, 180, 180];
zenits  = [39,  37, 42, 35,  12,  10];
cam_fov = [60,  60, 60, 60,   3,  90];

OPS.clrs = {'r','g','c','m',[0.2, 0.7, 0.99],'y'};

% In cartesian coordinates...
h3 = aida_visiblevol(stn_xyz,azims, zenits,h_plot,cam_fov,0,OPS);
PH = nscand_map;


figure

OPS.LL = 1;            % <- building up to lat-long!
PH = nscand_map('l');
hold on

for i1 = 1:length(obs),
  stn_pos(i1,:) = Obs(i1).longlat;
end
h3 = aida_visiblevol(fliplr(stn_pos),azims, zenits,h_plot,cam_fov,0,OPS);


axis([17 25 67 71])

set(gca,'fontsize',14) 
set(gca,'fontsize',15)
xlabel('Longitude')
ylabel('Latitude') 
