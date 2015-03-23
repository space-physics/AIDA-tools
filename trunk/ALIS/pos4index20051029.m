% pos4index20051029 - ALIS fields-of-view for position: INDEX-rocket
clf
OPS = alis_visiblevol;
%OPS.LL = 1;
OPS.linewidth = 2;
OP = OPS;
OP = rmfield(OP,'clrs');
PH = nscand_map;%('l');
hold on
OPS.clrs = [0 0 0];
h3 = alis_visiblevol(3,311, 15,110,60,0,OP);
%h4 = alis_visiblevol(4,355, 33,110,60,0,OP);
h4 = alis_visiblevol(4,5, 33,110,60,0,OP);
h5 = alis_visiblevol(5,85,  30,110,60,0,OP);
OPS.clrs = [.9 .6 0];
h11 = alis_visiblevol(11,0,0,0,90,0,OPS);
OPS.clrs = [.6 0 1];
h10 = alis_visiblevol(10,180,10,110,90,0,OPS);
%axis([15 26 67 71])
OPS.clrs = [0 0 0];
h1 = alis_visiblevol(1,20,  20,110,60,0,OPS);
plot3(longIndx,latIndx,hIndx,'w-','linewidth',2)
plot3(sat_pos(:,3),sat_pos(:,2),sat_pos(:,end),'k.--')
%axis([15 26 67 71])
set(gca,'fontsize',14)
set(gca,'fontsize',15)
xlabel('Longitude')
ylabel('Latitude')



s_p = [20051029  21 28 04  65.5    7.4   2245    343.8  -35.1
       20051029  23 05 55  88.7   25.2   1292     13    -35.4
       20051030   0 42 46 109.5   83.7    650     40.8  -31.3
       20051030   2 18 46 312.8    34    1056     65.9  -24.1];

plot3(sin(s_p(:,5)/180*pi).*cos(s_p(:,6)/180*pi).*s_p(:,7),...
      cos(s_p(:,5)/180*pi).*cos(s_p(:,6)/180*pi).*s_p(:,7),...
      sin(s_p(:,6)/180*pi).*s_p(:,7),...
      'h')
