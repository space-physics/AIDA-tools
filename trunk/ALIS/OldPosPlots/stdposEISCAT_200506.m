% stdposEISCAT_200506 - ALIS fields-of-view for position: EISCAT
OPS = aida_visiblevol;
OPS.LL = 1;
OPS = rmfield(OPS,'clrs');

stnNR = [7,   3,  4,  5, 10, 11];
AZstn = [0, 340,  0, 20,180,183];
ZEstn = [39, 37, 42, 35, 10, 12];
ALTstn = 100*ones(size(stnNR));
FOVstn = [60,60,60,60,90,1];

hndl = ALISstdpos_visvol(stnNR,AZstn,ZEstn,ALTstn,FOVstn);
