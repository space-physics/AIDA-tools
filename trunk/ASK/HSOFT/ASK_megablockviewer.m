function ASK_megablockviewer(ASKaction)
% ASK_MEGABLOCKVIEWER - Utility callback function for zooming around
%    in a ASK keogram-overlayed. This function is used in the
%    callbacks for the ASK-menu items: zoom-in, zoom-out and
%    zoom-Out-all-the-way
% 
% Calling:
%   ASK_megablockviewer(ASKaction)
% Input:
%  ASKaction - [1 | 2 | 3], where 1 makes it zoom in to
%              ginput-selected time-interval, 2 makes it zoom back
%              out one step, and 3 makes it zoom out to the full
%              mega-block time-interval.

% Copyright B Gustavsson 20101119 <bjorn@irf.se>
% This is free software, licensed under GNU GPL version 2 or later


global vs
persistent indxStack

% Make good options for the overlayed-keogram:
ops4k = ASK_keogram_overlayed;
% Cascade filtering with Lee's sigma filter and 2-D median filter:
ops4k.filtertype = {'sigma'  'median'};
ops4k.filterArgs =  {{[3,3]}  {[3,3],'symmetric'}};
% Only display the RGB-composite image in the image row:
ops4k.oneImg = 4;
% Make it show 9 images in that row:
ops4k.subplot4imgs = [5 9 10];

qweT = ASK_MJS_TT(vs.vmjs(vs.vsel));
if ASKaction == 1 % Then zoom in
  [tG,yG,bG] = ginput(2);
  tZoom = [qweT(1:3),tG(1),0,0;qweT(1:3),tG(2),0,0];
  iZ = sort(ASK_time2indx(tZoom));
  
  if ~isempty(indxStack)
    indxStack(end+1,:) = iZ;
  else
    axT = axis;
    tZoom = [qweT(1:3),axT(1),0,0;qweT(1:3),axT(2),0,0];
    try
      i1 = ASK_time2indx(tZoom(1,:));
    catch
      i1 = 1;
    end
    try
      i2 = ASK_time2indx(tZoom(2,:));
    catch
      i2 = vs.vnl(vs.vsel);
    end
    indxStack(1,:) = sort([i1,i2]);
    indxStack(2,:) = iZ;
  end
elseif ASKaction == 3 & size(indxStack,1) > 1 % Zoom all the way
  % reset the zoom-stack (scrap all of it except the first item): 
  iZ = indxStack(1,:);
  indxStack = indxStack(1,:);
elseif size(indxStack,1) > 1
  % Zoom back out one step:
  iZ = indxStack(end-1,:);
  indxStack = indxStack(1:end-1,:);
end
% Make the keograms for the current time-frame:
%Was; [keo,imstack,timeV] = ASK_keogram_overlayed(iZ(1),iZ(2),max(round(diff(iZ)/500),1),[0,0,0],7,128,128,90,ops4k);
ASK_keogram_overlayed(iZ(1),iZ(2),max(round(diff(iZ)/500),1),[0,0,0],7,128,128,90,ops4k);


for i1 = 1:ops4k.subplot4imgs(2),
  sph(i1) = subplot(ops4k.subplot4imgs(1),...
                    ops4k.subplot4imgs(2),...
                    ops4k.subplot4imgs(3)-1+i1);
end
% And squeeze out the empty space between the images by making them
% bigger:
subplot_dx_Squeezer(sph)
