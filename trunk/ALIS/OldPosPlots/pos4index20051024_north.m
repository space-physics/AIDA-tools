% pos4index20051024_north - ALIS fields-of-view for position: INDEX-rocket

[stnXYZ,stnLongLat,trmtr] = AIDApositionize([1:11],1);

OPS = aida_visiblevol;
OPS.LL = 1;
OPS.linewidth = 2;
OP = OPS;
OP = rmfield(OP,'clrs');
PH = nscand_map('l');
hold on
OPS.clrs = {[0 0 0]};
h3 = aida_visiblevol(stnLongLat(3,[2,1]),311, 15,110,60,0,OP);
%h4 = aida_visiblevol(4,355, 33,110,60,0,OP);
h4 = aida_visiblevol(stnLongLat(4,[2,1]),5, 33,110,60,0,OP);
h5 = aida_visiblevol(stnLongLat(5,[2,1]),85,  30,110,60,0,OP);
OPS.clrs = {[.9 .6 0]};
h11 = aida_visiblevol(stnLongLat(11,[2,1]),0,0,0,90,0,OPS);
OPS.clrs = {[.6 0 1]};
h10 = aida_visiblevol(stnLongLat(10,[2,1]),180,10,110,90,0,OPS);
axis([15 26 67 71])
OPS.clrs = {[0 0 0]};
h1 = aida_visiblevol(stnLongLat(1,[2,1]),20,  20,110,60,0,OPS);

if exist('longIndx','var')
  plot3(longIndx,latIndx,hIndx,'w-','linewidth',2)
end
if exist('sat_pos','var')
  plot3(sat_pos(:,3),sat_pos(:,2),sat_pos(:,end),'k.--')
end
axis([15 26 67 71 -5 150e3])
set(gca,'fontsize',14)
set(gca,'fontsize',15)
xlabel('Longitude')
ylabel('Latitude')
