function [lmaxi,lmaxj,lmaxI] = find_loc_max_2d(in_matrix)
% FIND_LOC_MAX_2D find a set of local maximas i a matrix
%  
% Calling:
%  [x_out,y_out,sl_min] = find_loc_max_2d(in_matrix)


%   Copyright  ©  1997 by Bjorn Gustavsson <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Reduce noice
bx = size(in_matrix,2);
by = size(in_matrix,1);

fi = fftshift(fft2(in_matrix));
blx = blackman(bx);
bly = blackman(by);

bl2d = blx*bly';
fi = fi.*bl2d'.^2;
s_matr = real(ifft2(fftshift(fi)));
%lmaxindx = 1;

for ii = 2:by-1,
  
  slice = s_matr(ii,:);
  x = 1:max(size(slice));
  ix = x;
  lsl = slice;
  
  dsl = diff(lsl);
  d2sl = diff(dsl);
  d2sl = [d2sl 1];
  
  dsl01 = [dsl dsl(max(size(dsl)))];
  dsl10 = [dsl(1) dsl];
  
  [qw,idsz] = find( ( dsl01>0&dsl10<0 ) | ( dsl01<0&dsl10>0 ));

  lx_lextr = ix(idsz);
  sl_lextr = lsl(idsz);
  d2sl_lextr = d2sl(idsz);
  
  minind = find(d2sl_lextr<0);
  
  if ( ~exist('sl_minx','var') )
    
    sl_minx = sl_lextr(minind);
    x_outx = lx_lextr(minind);
    y_outx = ii*ones(size(lx_lextr(minind)));
    
  else
    
    sl_minx = [sl_minx sl_lextr(minind)];
    x_outx = [x_outx lx_lextr(minind)];
    y_outx = [y_outx ii*ones(size(lx_lextr(minind)))];
    
  end
  
end

lii = 1;
for i = 1:max(size(sl_minx)),
  
  if ( sl_minx(i) > s_matr(y_outx(i)-1,x_outx(i)-1) ) 
    
    if ( sl_minx(i) > s_matr(y_outx(i)-1,x_outx(i)) )
      
      if ( sl_minx(i) > s_matr(y_outx(i)-1,x_outx(i)+1) )
	
	if ( sl_minx(i) > s_matr(y_outx(i)+1,x_outx(i)-1) )
	  
	  if ( sl_minx(i) > s_matr(y_outx(i)+1,x_outx(i) ) )
	    
	    if ( sl_minx(i) > s_matr(y_outx(i)+1,x_outx(i)+1) )
	      
	      lmaxI(lii) = sl_minx(i);
	      lmaxi(lii) = x_outx(i);
	      lmaxj(lii) = y_outx(i);
	      lii = lii+1;
	      
	    end
	    
	  end
	  
	end
	
      end
      
    end
    
  end
  
end
