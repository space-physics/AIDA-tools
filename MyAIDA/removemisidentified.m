function SkMp=removemisidentified(SkMp,pixellimit)
%%Removes misidentified stars from SkMp
%%CFE 20080329

%%How much deviation (pixels) to accept?
if nargin<2
  pixellimit=0.6;
end

%From starerrorplot.m by BG
%Calculate errors

u = SkMp.identstars(:,3);
v = SkMp.identstars(:,4);

[ua,va] = project_directions(SkMp.identstars(:,1)', ...
			     SkMp.identstars(:,2)', ...
			     SkMp.optpar,SkMp.optmod,size(SkMp.img));
ua = ua';
va = va';
du=abs(u-ua);
dv=abs(v-va);

%Find stars outside the limit
%wrong=(du>pixellimit | dv>pixellimit);
wrong=((du.^2+dv.^2)>pixellimit^2);

SkMp.identstars(wrong,:)=[];
%%%%%


