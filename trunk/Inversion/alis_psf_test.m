% Script file used to calculate 4 2D-to-1D projection matrices
% Used for calculating tomographic point spread functions for my
% thesis/ B Gustavsson


%   Copyright © 2000 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

sx = 2;
sy = 64;
sz = 64;
dr1 = [10 0 0];
dr2 = [0 2 0];
dr3 = [0 0 2];

optpar1 = [1.02 -1.021 -0.02 0.01 0.01 .001 -.001 .345 3 0];
optpar2 = [1.02 -1.021 -0.02 -20.01 0.01 .001 -.001 .345 3 0];
optpar3 = [1.02 -1.021  0.02 20.01 0.01 .001 -.001 .345 3 0];
optpar4 = [1.02 -1.021  0.02 30.01 0.01 .001 -.001 .345 3 0];
rllc = [-5 -64 90];
[pm1,X1,Y1,Z1] = ALIS_make_projmatr(dr1,dr2,dr3,sx,sy,sz,optpar1,rllc);
save pm1b.mat pm1 X1 Y1 Z1
rllc = [-5 -64 90]+[0 -50 0];
[pm2,X2,Y2,Z2] = ALIS_make_projmatr(dr1,dr2,dr3,sx,sy,sz,optpar2,rllc);
save pm2b.mat pm2 X2 Y2 Z2
rllc = [-5 -64 90]+[0 50 0];
[pm3,X3,Y3,Z3] = ALIS_make_projmatr(dr1,dr2,dr3,sx,sy,sz,optpar3,rllc);
save pm3b.mat pm3 X3 Y3 Z3
rllc = [-5 -64 90]+[0 100 0];
[pm4,X4,Y4,Z4] = ALIS_make_projmatr(dr1,dr2,dr3,sx,sy,sz,optpar4,rllc);
save pm4b.mat pm4 X4 Y4 Z4

[fi1,taeta1] = alisbestaemfitaeta(64,1:128,optpar1,3);
[fi2,taeta2] = alisbestaemfitaeta(64,1:128,optpar2,3);
[fi3,taeta3] = alisbestaemfitaeta(64,1:128,optpar3,3);
[fi4,taeta4] = alisbestaemfitaeta(64,1:128,optpar4,3);
