% stdposCORE_200506 - ALIS fields-of-view for position: CORE

stnNR = [7,  3,  4,  5, 10, 11];
AZstn = [0,249,346,130,180,183];
ZEstn = [0, 28, 20, 24, 10, 12];
ALTstn = 100*ones(size(stnNR));
FOVstn = [60,60,60,60,90,1];

hndl = ALISstdpos_visvol(stnNR,AZstn,ZEstn,ALTstn,FOVstn);
