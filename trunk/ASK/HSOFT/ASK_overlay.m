function rgb = ASK_overlay(D1,D2,D3,R1,R2,R3)
% ASK_OVERLAY - short procedure to overlay three images 
%   into a true color image. Due to matlabs restrictions for
%   displaying RGB images the intensities of the input images is
%   cropped to the intensity range [R1(1) R1(2)] (cycl.) and scaled
%   to [0-1]
%   
% Calling:
%   rgb = ASK_overlay(D1,D2,D3,R1,R2,R3)
% Input:
%   D1 - image to be put into the R-plane of RGB image [ny x nx]
%   D2 - image to be put into the G-plane of RGB image [ny x nx]
%   D3 - image to be put into the B-plane of RGB image [ny x nx]
%   R1 - range to crop-n-scale D1 into [0-1]
%   R2 - range to crop-n-scale D2 into [0-1]
%   R3 - range to crop-n-scale D3 into [0-1]

% Modified from overlay.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies


sz1 = size(D1);
sz2 = size(D2);
sz3 = size(D3);

if ~all(sz1==sz2) |  ~all(sz1==sz3)
  error(sprintf('All sizes of D1, D2 and D3 must be equal, are now: [%d, %d], [%d, %d], [%d, %d],',sz1,sz2,sz3))
end

rgb(:,:,3) = min(1,max(0,(D3-R3(1))/(R3(2)-R3(1))));
rgb(:,:,2) = min(1,max(0,(D2-R2(1))/(R2(2)-R2(1))));
rgb(:,:,1) = min(1,max(0,(D1-R1(1))/(R1(2)-R1(1))));
