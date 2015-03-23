function ok = treDsave(V,filename)
% TREDSAVE - function to save 3D matlab arrays in ascii files.
%   
% Calling:
%  ok = treDsave(V,filename)


%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

fp = fopen(filename,'w');
for jj = 1:size(V,2),
  
  for ii = 1:size(V,1),
    
    for kk = 1:size(V,3),
      
      fprintf(fp,'%6.2g ',V(ii,jj,kk));
      
    end
    
    fprintf(fp,'\n');
    
  end
  
end
fclose(fp);
