function [CalFactors,stns,calimgs] = tomo_cal0(stns,XfI,YfI,ZfI,OPS)
% tomo_cal - estimate calibration factor for fastprojection of 3D b-o-b
% 
% Calling:
%   [CalFactors,stns] = tomo_cal(stns,XfI,YfI,ZfI)
%
% See also TOMO_INP_CAMERA, CAMERA_SET_UP_SC, MAKE_TOMO_OPS
%

%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

dOPS.disp3D = 0;
if nargin > 4
  dOPS = merge_structs(dOPS,OPS);
end
  
i1 = 0;

% Determine the size of the 3-D block-of-blobbs:
threeDdims = size(XfI);
% Prepare to put the spherical bright thing in the centre:
iCenter = round(threeDdims)/2;

% Determine the closest difference to the 3-D B-o-B edges from the centre:
lX = abs(diff(squeeze(XfI(iCenter(1),   [1 end],iCenter(3)))));
lY = abs(diff(squeeze(YfI(   [1 end],iCenter(2),iCenter(3)))));
lZ = abs(diff(squeeze(ZfI(iCenter(1),iCenter(2),   [1 end]))));
% and make the shortest
rMax = min([lX,lY,lZ])/2;
% the radius of the spherical BoB * 0.8:
r1 = rMax*0.8;
% and the centre point:
rCenter = [XfI(iCenter(1),iCenter(2),iCenter(3)),...
           YfI(iCenter(1),iCenter(2),iCenter(3)),...
           ZfI(iCenter(1),iCenter(2),iCenter(3))];
% and determine the point of the image mid-point at the same altitude:
[xx,yy,zz] = inv_project_points(round(size(stns(1).img,2)/2),...
                                round(size(stns(1).img,1)/2),...
                                stns(1).img,...
                                stns(1).r,...
                                stns(1).optpar(9),stns(1).optpar,...
                                [0 0 1],rCenter(3),stns(1).obs.trmtr);
rImgCenter = [xx,yy,zz];
% Make for a line between those 2 points.
dL = linspace(-1,1,23);
dL = linspace(0,1,15);
% $$$ r2 = rMax*0.6

fig4imgs = gcf;
if dOPS.disp3D
  fig3d = figure;
end
% Set up a suitable subplot panel distribution for that number (23)
% of images:
figure(fig4imgs)
SP = fix_subplots_tomo(length(dL));

for i1 = 1:length(dL),
  % Set the centre of the sphere
  rC = rCenter + dL(i1)*(rImgCenter-rCenter);
  % Make the sphere volume emission rate 1e13/2/r photon/km^3/s
  % But that is not at all what this does! This should be the
  % volume emission rate that makes the intensity integrated
  % through the centre exactly one Rayleigh
  Vem = 1e10/2/r1*double( (XfI-rC(1)).^2 + (YfI-rC(2)).^2 + (ZfI-rC(3)).^2 <= r1.^2 );
  % determine the image point of the sphere centre point:
  [u(i1),v(i1)] = project_point(stns(1).r,...
                                stns(1).optpar,...
                                rC',...
                                stns(1).obs.trmtr,...
                                size(stns(1).img));
  if dOPS.disp3D
    figure(fig3d)
    [ixBest,ixBest] = min((XfI(1,:,1)-rC(1)).^2);
    [izBest,izBest] = min((ZfI(1,ixBest,:)-rC(3)).^2);
    [iyBest,iyBest] = min((YfI(:,ixBest,izBest)-rC(2)).^2);
    tomo_slice_i(XfI,YfI,ZfI,Vem,ixBest,iyBest,izBest)
    hold on
    [xP,yP,zP] = inv_project_points(u(i1),v(i1),...
                                    stns(1).img,...
                                    stns(1).r,...
                                    stns(1).optpar(9),stns(1).optpar,...
                                    [0 0 1],[0:25:300],stns(1).obs.trmtr);
    
    plot3(stns(1).obs.xyz(1),stns(1).obs.xyz(2),stns(1).obs.xyz(3),'r.')
    plot3(xP,yP,zP,'g')
    keyboard
    figure(fig4imgs)
  end
  % Calculate the image of the sphere:
  stns(1).proj = fastprojection(Vem, ...
                                 stns(1).uv, ...
                                 stns(1).d, ...
                                 stns(1).l_cl, ...
                                 stns(1).bfk, ...
                                 size(stns(1).img));
  % Save away that image
  calimgs{i1} = stns(1).proj;
  % and display it:
  subplot(SP(1),SP(2),i1)
  imagesc(stns(1).proj)
  hold on
  plot(u(i1),v(i1))
  % Save away the pixel coordinates for the central point, the
  % image intensity.
  [phi,theta] = camera_invmodel(u(i1),v(i1),stns(1).optpar,stns(1).optpar(9),size(stns(1).img));
  CalFactors(i1,1:3) = [u(i1),v(i1),mean(mean(stns(1).proj(round(v(i1))+[-1:1],round(u(i1))+[-1:1])))];
  CalFactors(i1,4:5) = [phi,theta];
  CalFactors(i1,7)   = 1e10/2/r1;
  % Should also calculate the 
  drawnow
  
end

CalFactors(:,6) = r1;
