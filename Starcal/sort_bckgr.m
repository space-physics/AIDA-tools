function [sI,indx] = sort_bckgr(i,j,I,bild)
% SORT_BCKGR - sorts the local image maxima in I(i,j)
% according to how much they are above the local average
% intensity. 
%
% Calling:
% [sI,indx] = sort_bckgr(i,j,I,bild)

%   Copyright � 1998 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


b = size(bild);
bx = b(2);
by = b(1);
tbild = bild-min(min(bild));

%for k = 1:max(size(I)),
for k = max(size(I)):-1:1,
  
  x0 = i(k);
  y0 = j(k);
  if ( ( 5 < x0 && x0 < bx-5 ) && ( 5 < y0 && y0 < by-5 ) )
    
    % Determine the part of the image confining the star.
    xmin = floor(min(max(x0-5,1),bx-10));
    xmax = floor(max(min(x0+5,bx),11));
    ymin = floor(min(max(y0-5,1),by-10));
    ymax = floor(max(min(y0+5,by),11));
    
    starmat = tbild(ymin:ymax,xmin:xmax);
    
    bakgr2 = median( [starmat(1,:) starmat(11,:)  starmat(:,11)' starmat(:,1)' ]);
    
    startvec(k) = tbild(y0,x0)-bakgr2;
    
  end

end
[sI,indx] = sort(startvec);
