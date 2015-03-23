function SkMp = remove_misidentified(SkMp,pixellimit)
%REMOVE_MISIDENTIFIED - Removes misidentified stars from SkMp
%
% SkMp: position calibration structure from starcal.m
% pixellimit: accepted radius of deviation (in pixel units)
%
% Calling:
%  SkMp = remove_misidentified(SkMp,pixellimit)
%

% Copyright Carl-Fredrik Enell 20080329, 2010024
%

%%How much deviation (pixels) to accept?
if nargin<2
  pixellimit=3.0;
end

%Calculate errors in pixel coordinates
%From starerrorplot.m
u = SkMp.identstars(:,3);
v = SkMp.identstars(:,4);

[ua,va] = project_directions(SkMp.identstars(:,1)', ...
                             SkMp.identstars(:,2)', ...
                             SkMp.optpar,SkMp.optmod,size(SkMp.img));
ua = ua';
va = va';
du = abs(u-ua);
dv = abs(v-va);

%Find stars outside the limit
wrong=((du.^2+dv.^2)>pixellimit^2);

%Remove the deviating stars
SkMp.identstars(wrong,:)=[];
%%%%%