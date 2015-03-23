function C = tomo_rescaling(I_img,e_los,I3D,X,Y,Z,r0)
% TOMO_RESCALING - rescale volume emission rate to correct l-o-s intensity
%   
% Calling:
%  C = tomo_rescaling(I_img,I3D,X,Y,Z,r0,e_los)
% 
% Input:
%  I_img - image intensity in Rayleighs
%  I3D
% 

%   Copyright � 2008 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

l = 0:800;

r_los = points_on_line(r0,e_los',l);

% I_los = interp3(X,Y,Z,I3D,r_los(1,:),r_los(2,:),r_los(3,:));
% I_los = griddata3(X,Y,Z,I3D,r_los(1,:),r_los(2,:),r_los(3,:));
I_los = griddata(X,Y,Z,I3D,r_los(1,:),r_los(2,:),r_los(3,:));

I_los(~isfinite(I_los)) = 0;

I_col = sum(I_los.*gradient(l*1e3));

C = 1e10*I_img/I_col;
