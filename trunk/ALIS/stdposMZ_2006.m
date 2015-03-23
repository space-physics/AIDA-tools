% stdposMZ_2006 - ALIS fields-of-view for position: MZ


OPS = aida_visiblevol;
OPS.LL = 1;
OPS = rmfield(OPS,'clrs');

stnNR = [7,     3,   4,   5, 10, 11];
AZstn = [180, 180, 180, 180,180,183];
ZEstn = 12*ones(size(stnNR));
ALTstn = 100*ones(size(stnNR));
FOVstn = [60,60,60,60,90,1];

hndl = ALISstdpos_visvol(stnNR,AZstn,ZEstn,ALTstn,FOVstn);
