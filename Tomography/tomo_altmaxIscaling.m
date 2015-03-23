function [Vem,stns] = tomo_altmaxIscaling(Vem,stns,tomo_ops,X3,Y3,Z3)
% TOMO_ALTMAXISCALING - tomographic itterative step(s).
% VEM is the current 3D distribution STNS are the struct that
% contain the images and camera set up. TOMO_OPS is the struct
% containing the options controling the processing of the
% itteration, NR_LAPS are the number of steps to itterate. 
% 
% Calling:
% [Vem,stns] = tomo_altmaxIscaling(Vem,stns,tomo_ops,X3,Y3,Z3)
%
% See also TOMO_INP_CAMERA, CAMERA_SET_UP_SC, MAKE_TOMO_OPS
%


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

%i = 0;

%art
for j1 = 1:3
  io = find( [tomo_ops(:).randorder] == j1);
  junk = rand([1 length(io)]);
  [junk,order] = sort(junk);
  for k = 1:length(order),
    stns(io(order(k))).proj = fastprojection(Vem, ...
                                             stns(io(order(k))).uv, ...
                                             stns(io(order(k))).d, ...
                                             stns(io(order(k))).l_cl, ...
                                             stns(io(order(k))).bfk, ...
                                             size(stns(io(order(k))).img));
    [imax3,imax3] = nanmax(Vem,[],3);
    X2 = imax3;
    Y2 = imax3;
    Z2 = imax3;
    
    for i1 = 1:size(imax3,1),
      for i2 = 1:size(imax3,2),
        X2(i1,i2) = squeeze(X3(i1,i2,imax3(i1,i2)));
        Y2(i1,i2) = squeeze(Y3(i1,i2,imax3(i1,i2)));
        Z2(i1,i2) = squeeze(Z3(i1,i2,imax3(i1,i2)));
      end
    end
    Im_proj = imax3;
    Im_proj(:) = inv_project_img_surf(stns(io(order(k))).img./stns(io(order(k))).proj,...
                                      stns(io(order(k))).obs.xyz,...
                                      stns(io(order(k))).optpar(9),...
                                      stns(io(order(k))).optpar,...
                                      X2(:),Y2(:),Z2(:));
    %sum(~isfinite(Im_proj(:)))
    Im_proj(1,:) = 1;
    Im_proj(:,1) = 1;
    Im_proj(end,:) = 1;
    Im_proj(:,end) = 1;
    Im_proj = inpaint_nans(Im_proj);
    Im_proj(~isfinite(Im_proj(:))) = 1;
    Im_proj(Im_proj(:)==0) = 1;
    Im_proj = medfilt2(Im_proj,[5 5]); 
    for i1 = 1:size(Im_proj,1),
      for i2 = 1:size(Im_proj,2),
        
        Vem(i1,i2,:) = Vem(i1,i2,:).*max(0,Im_proj(i1,i2)).^0.5;
        
      end
    end
    %Infindx = find(~isfinite(Vem(:)));
    %Vem(Infindx) = 0;
    Vem(~isfinite(Vem(:))) = 0;
  end
end

% Here, after the itteration, we do filtering to suppress noise
switch tomo_ops(1).filtertype
 case 1 % horizontal 2D averaging
  for k = size(Vem,3),
    Vem(:,:,k) = conv2(squeeze(Vem(:,:,k)),tomo_ops(1).filterkernel,'same');
  end
 case 2 % horizontal 2D median
  for k = size(Vem,3),
    Vem(:,:,k) = medfilt2(squeeze(Vem(:,:,k)),tomo_ops(1).filterkernel);
  end
 case 3 % proximity filtering
  fiel_align_int = sum(Vem,3);
  filt_f_a_i = conv2(fiel_align_int,tomo_ops(1).filterkernel,'same');
  for k = size(Vem,3),
    Vem(:,:,k) = conv2(squeeze(Vem(:,:,k)),tomo_ops(1).filterkernel,'same').*fiel_align_int./filt_f_a_i;
  end
  %Infindx = find(~isfinite(Vem(:)));
  %Vem(Infindx) = 0;
  Vem(~isfinite(Vem(:))) = 0;
 case 4 % proximity sharpening, Lucy-Richardson deconvolution-like
  fiel_align_int = sum(Vem,3);
  filt_f_a_i = conv2(fiel_align_int,tomo_ops(:).filterkernel,'same');
  for k = size(Vem,3),
    Vem(:,:,k) = squeeze(Vem(:,:,k)).*fiel_align_int./filt_f_a_i;
  end
  %Infindx = find(~isfinite(Vem(:)));
  Vem(~isfinite(Vem(:))) = 0;
 otherwise
  % no filtering
end % switch filtertype

for j1 = 1:length(stns),
  stns(j1).proj = fastprojection(Vem, ...
				stns(j1).uv, ...
				stns(j1).d, ...
				stns(j1).l_cl, ...
				stns(j1).bfk, ...
				size(stns(j1).img));
end
