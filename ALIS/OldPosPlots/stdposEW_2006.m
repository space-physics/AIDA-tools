% stdposEW_2006 - ALIS fields-of-view for position: EW

% $$$ OPS = alis_visiblevol;
% $$$ OPS.LL = 1;
% $$$ OPS.linewidth = 2;
% $$$ OP = OPS;
% $$$ OP = rmfield(OP,'clrs');
% $$$ PH = nscand_map('l');
% $$$ hold on
% $$$ OPS.clrs = [0 0 0];
% $$$ h3 = alis_visiblevol(3,0, 32,110,60,0,OP);
% $$$ h4 = alis_visiblevol(4,0, 42,110,60,0,OP);
% $$$ h5 = alis_visiblevol(5,0, 35,110,60,0,OP);
% $$$ OPS.clrs = [.9 .6 0];
% $$$ h11 = alis_visiblevol(11,180,12,1,110,0,OPS);
% $$$ OPS.clrs = [.6 0 1];
% $$$ h10 = alis_visiblevol(10,180,30,110,90,0,OPS);
% $$$ axis([15 26 67 71])
% $$$ OPS.clrs = [0 0 0];
% $$$ h1 = alis_visiblevol(1,0, 39,110,60,0,OPS);
% $$$ axis([15 26 66.75 70.75])
% $$$ set(gca,'fontsize',14)
% $$$ set(gca,'fontsize',15)
% $$$ xlabel('Longitude')
% $$$ ylabel('Latitude')


OPS = aida_visiblevol;
OPS.LL = 1;

stnNR = [7,   3,  4,  5, 10, 11];
AZstn = [0,   0,  0,  0,180,183];
ZEstn = [39, 32, 42, 35, 30, 12];
ALTstn = 100*ones(size(stnNR));
FOVstn = [60,60,60,60,90,1];

hndl = ALISstdpos_visvol(stnNR,AZstn,ZEstn,ALTstn,FOVstn);
