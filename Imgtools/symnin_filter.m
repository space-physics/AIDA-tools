function img_out = symnin_filter(img_in,n,OPS)
% SYMNIN_FILTER - symmetric nearest intensity neighbour filter
% is a filter that compares each pixel to its neighbors in an
% N-by-N region. The neighbors are inspected in symmetric 
% pairs around the center, i.e. N S, W E, NW SE, and NE SW. Select
% half the number of pixels in a square window by selecting one
% pixel nearest in gray value to the center pixel from each unique
% pair of pixels. From all unique pairs in the N-by-N window
% centered at the pixel(x,y) in the image,
% take I(x+i,y+j),if |I(x+i,y+j) - I(x,y)| < |I(x-i,y-j) - I(x,y)|
% take I(x-i,y-j),if |I(x+i,y+j) - I(x,y)| > |I(x-i,y-j) - I(x,y)|
% otherwise, take I(x-j,y+j) and I(x-i,y-j).
% Then calculate the mean (or median) of the selected pixel
% intensities. This filter has a characteristic between a 2-D
% median filter and a 2-D linear filter
%
% Calling:
%   img_out = symnin_filter(img_in,n,OPS)
% Input:
%   img_in - input image, [Ny x Nx] (double)
%   n      - size of negihbourhood region (odd integer)
%   OPS    - options struct with fields ".type" |{'mean'}|'median'|
%            for selecting between calculating the mean or median
%            of the nearest (intensity-wise) neighbours;
%            and ".include_centre" | { 1 } | 0 | for choosing to
%            include the central pixel at [x,y] in the averaging
%            When SYMNIN_FILTER is called with no input arguments
%            the default option is returned.
% The border-regions is treated as if the image intensities
% extrapolates with the border pixel intensities.
%
% See also: WIENER2, MEDFILT2, FILTER2, SYMNIN_FILTER


%   Copyright � 20100104 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% The default options structure
dOPS.type = 'mean';
dOPS.include_center = 1;

if nargin == 0
  % If there is no input arguments, return the default
  % option-struct
  img_out = dOPS;
  return
elseif nargin > 2
  % if there is more than 2 input arguments then "over-cat" the
  % user-supplied options struct.
  dOPS = catstruct(dOPS,OPS);
end
% Ensure that "n" produces an ODD-sized region.
N = ceil((n-1)/2);

class0 = class(img_in);
img_in = double(img_in);

% Make a padded version of the input image - to make it easier to
% index over a region centered at any pixel in the original image.
img_internal = img_in([ones(1,N) 1:end size(img_in,1)*ones(1,N)],...
                      [ones(1,N) 1:end size(img_in,2)*ones(1,N)]);


% Indicies to half the region pixels
[I1,J2] = meshgrid(-N:N,1:N);
i1 = 1:N;
j2 = 0*i1;
I1 = [i1';I1(:)];
J2 = [j2';J2(:)];


% Image size:
sz = size(img_in);
if strcmp(dOPS.type,'mean')
  % Central image
  img_out = dOPS.include_center*img_in;
  
else
  % If we want the median we calculate the nearest-intensities
  % for all neighbour pairs first, then we calculate their median.
  img_out = zeros([size(img_in),1+length(I1)]);
  img_out(:,:,1) = img_in;
  dimg_out = zeros(size(img_in));  
end
for i1 = 1:length(I1)
  if i1 == 0 && j2 == 0
    % Do nothing! Central pixel already taken care of
  else
    % if dOPS.display
    %   iP(i1,:) = [N+I1(i1),N+J2(i1)]-(1);
    %   iM(i1,:) = [N-I1(i1),N-J2(i1)]-(1);
    %   [pI,pJ] = meshgrid(N+I1(i1)+[1:sz(1)],N+J2(i1)+[1:sz(2)]);
    %   [mI,mJ] = meshgrid(N-I1(i1)+[1:sz(1)],N-J2(i1)+[1:sz(2)]);
    %   plot(pJ(1,1),pI(1,1),'b.')
    %   hold on
    %   plot(mJ(1,1),mI(1,1),'ro'),axis([0 n+1 0 n+1]),grid on,pause
    % end
    % Take the symmetric pixel pair
    img_internalp = img_internal(N+I1(i1)+[1:sz(1)],N+J2(i1)+[1:sz(2)]);
    img_internalm = img_internal(N-I1(i1)+[1:sz(1)],N-J2(i1)+[1:sz(2)]);
    % Calculate the absolute intensity differences
    ap = abs(img_in - img_internalp);
    am = abs(img_in - img_internalm);
    % If we take the mean it is just to add all the nearest
    % intensities and divide the total intensity at the end
    if strcmp(dOPS.type,'mean')
      % take the pixel with the nearest intensity
      img_out(am<ap) = img_out(am<ap) + img_internalm(am<ap);
      img_out(am>ap) = img_out(am>ap) + img_internalp(am>ap);
      % unless both pixels are at the same intensity difference,
      % then take their average
      img_out(am==ap) = img_out(am==ap) + ( img_internalm(am==ap)/2 + ...
                                            img_internalp(am==ap)/2 );
    else
      % If we want the median, then we save all the shifted
      % nearest-intensity-neighbour images, and then take the
      % median at the end.
      dimg_out = 0*dimg_out;
      dimg_out(am<ap) = img_internalm(am<ap);
      dimg_out(am>ap) = dimg_out(am>ap) + img_internalp(am>ap);
      dimg_out(am==ap) = dimg_out(am==ap) + ( img_internalm(am==ap)/2 + ...
                                              img_internalp(am==ap)/2 );
      img_out(:,:,i1+1) = dimg_out;
    end
  end
end

if strcmp(dOPS.type,'mean')
  % (i1+dOPS.include_center) is the number of pixel pairs plus the
  % central pixel, that is the number we should divide with.
  img_out = img_out / (i1+dOPS.include_center);
else
  % If we want the median, make it so.
  img_out = median(img_out(:,:,(dOPS.include_center+1):end),3);
end

img_out = cast(img_out,class0);
