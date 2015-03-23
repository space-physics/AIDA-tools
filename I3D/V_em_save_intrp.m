function ok = V_em_save_intrp(I0_R0_DR,X,Y,Z,tau3D,T)
% V_em_save_intrp - save volume distribution emission and
% excitation rates (in default files named ['heat',sprintf('%02d',i1),'.dat']
% and ['excit',sprintf('%02d',i),'.dat'].
% 
% Calling:
%  ok = V_em_save_intrp(I0_R0_DR,X,Y,Z,tau3D,T)



%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

V_em = zeros(size(X));

for i1 = 2:length(I0_R0_DR),
  
  if ( ~isnan(I0_R0_DR(i1,1) ) )
    
    Iintrp = I0_R0_DR(i1,:)*.25+I0_R0_DR(i1-1,:)*.75;
    dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
    V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1) T(i1)+2.5], ...
                      T(1:i1),tau3D,V_em,dI3d);
    Iintrp = I0_R0_DR(i1,:)*.5+I0_R0_DR(i1-1,:)*.5;
    dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
    V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+2.5 T(i1)+5], ...
                      T(1:i1),tau3D,V_em,dI3d);
    
    Iintrp = I0_R0_DR(i1,:)*.75+I0_R0_DR(i1-1,:)*.25;
    dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
    V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+5 T(i1)+7.5], ...
                      T(1:i1),tau3D,V_em,dI3d);
    U = I0_R0_DR(i1,7);
    V = I0_R0_DR(i1,8);
    W = I0_R0_DR(i1,9);
    
    savestr = ['U',num2str(i1),'.dat'];
    fp = fopen(savestr,'w');
    fprintf(fp,'%6.2g\n',U);
    fclose(fp);
    savestr = ['V',num2str(i1),'.dat'];
    fp = fopen(savestr,'w');
    fprintf(fp,'%6.2g\n',V);
    fclose(fp);
    savestr = ['W',num2str(i1),'.dat'];
    fp = fopen(savestr,'w');
    fprintf(fp,'%6.2g\n',W);
    fclose(fp);
    %nani = find(isnan(V_em(:)));
    %V_em(nani) = 0;
    V_em(isnan(V_em(:))) = 0;
    filename = ['heat',sprintf('%02d',i1),'.dat'];
    disp(filename)
    fp = fopen(filename,'w');
    for ii = 1:32,
      for jj = 1:32,
	for kk = 1:32,
	  fprintf(fp,'%6.2g ',V_em(ii,jj,kk));
	end
	fprintf(fp,'\n');
      end
    end
    fclose(fp);
    filename = ['excit',sprintf('%02d',i1),'.dat'];
    fp = fopen(filename,'w');
    for ii = 1:32,
      for jj = 1:32,
	for kk = 1:32,
	  fprintf(fp,'%6.2g ',dI3d(ii,jj,kk));
	end
	fprintf(fp,'\n');
      end
    end
    fclose(fp);
    
    Iintrp = I0_R0_DR(i1,:);
    dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
    V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+7.5 T(i1+1)], ...
                      T(1:i1),tau3D,V_em,dI3d);
    
  end
  
end
ok = 1;
