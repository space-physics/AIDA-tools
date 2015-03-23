function ok = three_d_save(Vem,fname)
% three_d_save - save 3-D arrays as ascii file
%
% Calling:
% ok = three_d_save(Vem,fname)


%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


ok = 0;
fp = fopen(fname,'w');

if fp == -1
  
  error(['could not open file: ',fname,' for writing, sorry...'])

end

for jj = 1:size(Vem,2),
  
  for ii = 1:size(Vem,1),
    
    for kk = 1:size(Vem,3),
      
      fprintf(fp,'%6.2g ',Vem(ii,jj,kk));
      
    end
    fprintf(fp,'\n');
    
  end
  
end
fclose(fp);
ok = 1;
