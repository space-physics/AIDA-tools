function [out_i,out_j,out_I] = find_the_stars(img_in)
% FIND_THE_STARS - finds stars in images. 
% OUT_I, OUT_J, are the horizontal and vertical image coordinates
% of the stars; OUT_I is the star intensity. IMG_IN is the image.
% 
% Calling:
% [out_i,out_j,out_I] = find_the_stars(img_in)
% 

%   Copyright ©  1998-2010 by Bjorn Gustavsson <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global s_prefs
[lmaxi,lmaxj,lmaxI] = find_loc_max_2d(img_in);

[sI,indx] = sort_bckgr(lmaxi,lmaxj,lmaxI,img_in);
si = lmaxi(indx);
sj = lmaxj(indx);

sI = fliplr(sI);
si = fliplr(si);
sj = fliplr(sj);

max_n = min(max(size(sI)),s_prefs.mx_nr_st);
[starpars] = sort_out(si(1:max_n),sj(1:max_n),sI(1:max_n),img_in);

[out_I,indx] = sort(starpars(:,6));
out_i = starpars(indx,3);
out_j = starpars(indx,4);

out_I = flipud(out_I);
out_i = flipud(out_i);
out_j = flipud(out_j);
