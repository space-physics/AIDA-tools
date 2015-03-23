% £££ Obsolete, perhaps, untested for such a long time it is
% certainly outdated!

% Script that tests that camera_model and camera_invmodel are a 
% function/inverse pair.

global bxy bx by

clear md_uv
clear MdUV
MdUV(4) = 0;

for jj = 1:4,
  
  for ii = 1:200;
    
    optpar = (.5-rand([1 10])).*[1 1 30 30 30 .05 .05 .3 1 1];
    optpar(9) = jj;
    optpar(8) = .35;
    optpar(1:2) = .7*sign(optpar(1:2) );
    
    bxy = [512 512];
    bx = bxy(2);
    by = bxy(1);
    
    i = 1:bx;
    j = 1:by;
    
    rotmtr = camera_rot(optpar(3),optpar(4),optpar(5));
    [e1,e2,e3] = camera_base(optpar(3),optpar(4),optpar(5));
    
    [fi,taeta] = camera_invmodel(i(:)',j(:)',optpar,optpar(9),bxy);
    epix = [sin(taeta).*sin(fi); sin(taeta).*cos(fi); cos(taeta)];
    epix = rotmtr*epix;
    epix = epix';
    
    ze1 = acos(epix(:,3));
    
    az1 = atan2(epix(:,1),epix(:,2));
    
    [u,v] = camera_model(az1,ze1,e1,e2,e3,optpar,optpar(9),bxy);
    
    md_uv(ii,:) = [mean(abs(diff([u,i']'))) mean(abs(diff([v,j']')))];
    drawnow
    MdUV(optpar(9)) = MdUV(optpar(9)) + median(md_uv(:));
    
  end
  
end

for jj = 1:4,
  
  switch jj
   case 1
    fw = [.3 .5 .7 1];
    alfa = 0;
   case 2
    fw = [1 .8 .75 .5];
    alfa = .5;
   case 3
    fw = [.3 .5 .7 1];
    alfa = 0.35;
   case 4
    fw = [.35 .5 .7 1];
    alfa = 1;
   otherwise
  end

  for ii = 1:4;
    
    optpar = (.5-rand([1 10])).*[1 1 30 30 30 .05 .05 .3 1 1];
    optpar(9) = jj;%1+round(4*rand);
    optpar(8) = alfa;
    optpar(1:2) = fw(ii)*sign(optpar(1:2) );
    bxy = [512 512];
    bx = bxy(2);
    by = bxy(1);
    
    i = 1:8:bx;
    j = 1:8:by;
    [i,j] = meshgrid(i,j);
    
    rotmtr = camera_rot(optpar(3),optpar(4),optpar(5));
    [e1,e2,e3] = camera_base(optpar(3),optpar(4),optpar(5));
    
    [fi,taeta] = camera_invmodel(i(:)',j(:)',optpar,optpar(9),bxy);
    epix = [sin(taeta).*sin(fi); sin(taeta).*cos(fi); cos(taeta)];
    epix = rotmtr*epix;
    epix = epix';
    
    ze1 = acos(epix(:,3));
    
    az1 = atan2(epix(:,1),epix(:,2));
    u = i;
    v = j;
    [u(:),v(:)] = camera_model(az1,ze1,e1,e2,e3,optpar,optpar(9),bxy);
    
    subplot(2,1,1)
    plot(i,j,'g.')
    hold on
    plot(u,v,'r.')
    hold off
    subplot(2,1,2)
    plot(asinh(u(:)-i(:)),asinh(v(:)-j(:)),'.')
    pause
    
  end
  
end
