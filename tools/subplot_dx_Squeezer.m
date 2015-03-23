function ph = subplot_dx_Squeezer(sph,spp_org)
% SUBPLOT_DX_SQUEEZER - Squeeze out space between subplot-axes
%   

squeeze_fraction = 0.99;
% spp_org = [2,1,1;4,5,11;4,5,12;4,5,13;4,5,14;4,5,15;5,1,4;5,1,5];
if nargin == 1
  for i1 = (length(sph)):-1:1,
    axes(sph(i1))
    axP{i1} = get(sph(i1),'position');
  end
else
  for i1 = 1:(size(spp_org,1)),
    sph(i1) = subplot(spp_org(i1,1),spp_org(i1,2),spp_org(i1,3));
    axP{i1} = get(sph(i1),'position');
  end
end
dx = axP{i1}(1) - (axP{i1-1}(1)+axP{i1-1}(3));
dx = dx*squeeze_fraction;
for i1 = 1:length(sph),
  %get(sph(i1),'position')
  %disp([axP{i1}+[-(i1-1)/length(sph)*dx,axP{1}(2),(length(sph)-1)/length(sph)*dx,0]])
  set(sph(i1),'position',axP{i1}+[-(i1-1)/length(sph)*dx,-dx/2,(length(sph)-1)/length(sph)*dx,dx])
  axP{i1} = get(sph(i1),'position');
end

if nargout
  ph = sph;
end
