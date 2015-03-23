function [identstars] = sort_out(in_i,in_j,in_I,bild)
% SORT_OUT - finds the possible stars among the local maxima. 
% The function takes the image coordinates and intensity of the
% local maximas as well as the image as input.
%
% Calling:
% [identstars] = sort_out(in_i,in_j,in_I,bild)

%   Copyright � 1998 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global s_prefs
warning off

star_lims = s_prefs.sz_rg_st.^-2;

b = size(bild);
bx = b(2);
by = b(1);
tbild = bild-min(min(bild));

imax = max(size(in_I));
idnr = 1;

%opt = [0,5e-2,0,0,0,0,0,0,0,0,0,0,0,2000];
for i = 1:imax,
  
  clear sortids1 order x1 indx1
  
  x0 = in_i(i);
  y0 = in_j(i);
  if ( ( 5 < x0 && x0 < bx-5 ) && ( 5 < y0 && y0 < by-5 ) )
    
    % Determine the part of the image confining the star.
    xmin = floor(min(max(x0-5,1),bx-10));
    xmax = floor(max(min(x0+5,bx),11));
    ymin = floor(min(max(y0-5,1),by-10));
    ymax = floor(max(min(y0+5,by),11));
    
    % Find the star in the region of interest.
    starmat = tbild(ymin:ymax,xmin:xmax);
    
    bakgr2 = median( [starmat(1,:) starmat(11,:)  starmat(:,11)' starmat(:,1)' ]);
    
    startvec = [x0,y0,tbild(y0,x0)-bakgr2,1,.01,1];
    if ( startvec(3) > 1.1*(max([starmat(1,:) starmat(11,:)  starmat(:,11)' starmat(:,1)' ])-bakgr2) )
      
      if ( exist('fminunc','file') == 2 )
	starpar = fminunc('stardiff2',startvec,[0,5e-2,0,0,0,0,0,0,0,0,0,0,0,2000],[],xmin,xmax,ymin,ymax,starmat,x0,y0);
      else
        try 
          starpar = fminsearch('stardiff2',startvec,[0,5e-2,0,0,0,0,0,0,0,0,0,0,0,2000],[],xmin,xmax,ymin,ymax,starmat,x0,y0);
        catch
          starpar = fminsearch(@(startvec) stardiff2(startvec,xmin,xmax,ymin,ymax,starmat,x0,y0),startvec);
        end
      end
      fynd = starint(starpar,xmin,xmax,ymin,ymax);
      star_intm = (starmat-bakgr2).*(fynd>.07*(max(max(fynd))));
      star_intt = sum(sum(star_intm));
      star_max = max(max(star_intm));
      
      if ( ( xmin<starpar(1) && starpar(1) < xmax && ymin < starpar(2) && starpar(2) < ymax )...
	    && ( starpar(3) > 1.2*(max([starmat(1,:) starmat(11,:)  starmat(:,11)' starmat(:,1)' ])-bakgr2) )...
	    && ( starpar(4)*starpar(6)-starpar(5)^2 > 0 )...
	    && ( max(starpar(4),starpar(6))<star_lims(1) && min(starpar(4),starpar(6))>star_lims(2) ) )
	
	%out_i(idnr) = x0;
	%out_j(idnr) = y0;
	%out_I(idnr) = starpar(3);
	
	identstars(idnr,3) = x0; 	%starpos in image(x)
	identstars(idnr,4) = y0; 	%starpos in image(y)
	identstars(idnr,5) = star_max; 	%max count from star
	identstars(idnr,6) = star_intt; %total counts from star
	identstars(idnr,7) = 1; 	%good gaussian fit
	identstars(idnr,8) = 0; 	%wide circular gausian
	idnr = idnr + 1;
	
      end
      
    end
    
  end
  if rem(i,20)==0
    disp(['number of star-like maximas found in image: ',num2str(idnr),' out of ',num2str(i),' possible'])
  end
end % for i = 1:imax,
