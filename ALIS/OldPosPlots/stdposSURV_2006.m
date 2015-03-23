% stdposSURV_2006 - ALIS fields-of-view for position: SURV

OPS = aida_visiblevol;
OPS.LL = 1;
OPS = rmfield(OPS,'clrs');

stnNR = [  7,  3,   4,  5, 10, 11];
AZstn = [225, 45, 115, 30,180,183];
ZEstn = [ 20, 12,  15, 14, 10, 12];
ALTstn = 100*ones(size(stnNR));
FOVstn = [60,60,60,60,90,1];

hndl = ALISstdpos_visvol(stnNR,AZstn,ZEstn,ALTstn,FOVstn);
